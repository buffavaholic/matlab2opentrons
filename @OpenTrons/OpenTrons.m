classdef OpenTrons < dynamicprops
    %OpenTrons MATLAB interface with the OpenTrons liquid handling robot. 
    %   Detailed explanation goes here
    
    properties
        %% Directory information
        % Library path
        libPath
        % Class file path
        classPath
        
        %% Robot class
        robot
        
        %% Python helper module
        helper
        
        %% Container Properties
        contHandles = {}; %List of handles of containers that have been added to the deck
        
        %% Pipettes Properties
        axisA; % Handle for the pipette on axis A
        axisB; % Handle for the pipette on axis B
        pipHandles = {'a',[];'b',[]}; %List of handles of the dynamic properties used for pipettes
        
        %% Local queues
        QueueList;
    end
    
    methods (Static = true)
        function inds = str2inds(posString)
            % must be of the format '[A-Z][1-1000]' with capital letter in
            % front, and integer following
            alph = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            inds(2) = strfind(alph,posString(1));
            inds(1) = str2num(posString(2:end));
        end
        
    end
    
    methods
        
        %% Constructor
        
        function OT = OpenTrons(startGUI)
            if nargin == 0
                startGUI = 1;
            end
            % save current directory to move back to later
            curDir = pwd;
            % Get the class path location
            getFileName = mfilename('fullpath');
            OT.classPath = fileparts(getFileName);
            
            cd(OT.classPath)
            cd ..
            % Save the main directory path. 
            OT.libPath = pwd;
            
            % Move into the OTfiles directory so that the calibration,
            % logs, etc are all saved in there for cleanliness
            cd([OT.libPath,'\Util\OTfiles'])
            
            % Initialize the python robot class
            OT.robot = genOT;
            
            % Reset robot
            OT.robot.reset();
            cd([OT.libPath,'\Util\pyScripts'])
            
            % Load the helper python file
            OT.helper = py.importlib.import_module('MAT2OT_helpers');
            py.importlib.reload(OT.helper);
            
            % Open up the OT GUI
            if startGUI == 1
                OTgui(OT);
            end
            % Finally, move back to the directory origionally started in
            cd(curDir);
        end
        
        %% Robot Methods
        
        function clearSetup(OT)
            % Clears the deck, instruments, and commands from the robot.
            
            % Reset the python robot
            OT.robot.reset();
            
            % Clear the dynamic properties of the containers that were set
            [handleRows,~] = size(OT.contHandles);
            for k = 1:handleRows
                propHandle = OT.contHandles{k,2};
                delete(propHandle);
            end            
            OT.contHandles = {};
            
        end
        
        
        
        %% Container Methods
        
        function contHandle = loadContainer(OT,contRef,contName,slot)
            % loads a container and adds it to the deck
            
            % Inputs: contName - *str* identifier of the container in the
            %                    OpenTrons Labware
            %         contRef  - *str* name to add the container as a
            %                    property of the OT class. Must conform to
            %                    MATLAB variable name rules.
            %         slot     - *str* Deck slot the container is being
            %                    added to, e.g. 'A1'.
            
            if ~isprop(OT,contRef) && isvarname(contRef)
                % Verify that the property is not already assigned and is a
                % valid MATLAB variable name. 
                
                try 
                    % Try loading container and assigning it to variable. 
                    propHandle = OT.addprop(contRef);
                    OT.(contRef) = py.opentrons.containers.load(contName,slot,contRef);
                    
                    contHandle = OT.(contRef);
                    [handleRows,~] = size(OT.contHandles);
                    OT.contHandles(handleRows+1,1:2)=[contRef,{propHandle}];
                catch ME
                    
                    error('Error loading container to deck, check container name and slot. Error details: \n %s',ME.message);
                    
                end
                
                
            else
                % Throw errors if the reference handle is not valid.
                if isprop(OT,contRef)
                    error('Container reference handle conflicts with properties already set. Please choose a different contRef name');
                end
                
                if ~isvarname(contRef)
                    error('Container reference handle does not conform to MATLAB variable name requirements. Please choose a different contRef name');
                end
                
            end
                
                
        end
        
        function rel_pos_vect = rel_pos(OT,cont,well,varargin)
            % Calculates the relative position within a well of a container
            
            % Parse optional variables
            arg.rel_x = 0; % (double between -1 and 1) Relative position of well x position 
            arg.rel_y = 0; % (double between -1 and 1) Relative position of well y position 
            arg.rel_z = -1; % (double between -1 and 1) Relative position of well z position (-1= bottom, 1=top of well)
            arg.rel_r = []; % (double between -1 and 1) Relative position of polar radius from well center
            arg.rel_theta = []; % (double) Relative position of polar angle from well center in radians
            arg.rel_h = []; % (double between -1 and 1) Relative position of polar height from well center
            arg.reference = cont; % (OT Container Class) position relative to what container
            
            arg = parseVarargin(varargin,arg);
            
            % Get well of container based on how 'well' is passed in
            if ischar(well)
                wellPointer = OT.helper.get_well(cont,well);
            elseif isnumeric(well)
                wellPointer = OT.helper.get_well(cont,int16(well));
            else
                error('Well must be specified as either a string or integer')
            end
            
            % if polar references are specified use the polar reference
            if (~isempty(arg.rel_r) && ~isempty(arg.rel_theta) && ~isempty(arg.rel_h))
                rel_pos_vect = wellPointer.from_center(pyargs('r',arg.rel_r,'theta',arg.rel_theta,'h',arg.rel_h,'reference',arg.reference));
            else
                rel_pos_vect = wellPointer.from_center(pyargs('x',arg.rel_x,'y',arg.rel_y,'z',arg.rel_z,'reference',arg.reference));
            end
        end
        
        %% Pipette Methods
        
        function pipetteHandle = loadPipette(OT,pipRef,axis,max_vol,varargin)
            % Adds a pipette to the OpenTrons robot using the Pipette class
            
            % Inputs: pipRef   - *str* name to add the pipette as a
            %                    property of the OT class. Must conform to
            %                    MATLAB variable name rules.
            %         axis     - *str* Axis of the pipette being added.
            %                    Must be 'a' or 'b'.
            %         max_vol  - *int* Maximum volume allowed on the
            %                    pipette being added.
            %         varargin - Optional input arguments in a string
            %                    identifier - value pairs.
            if checkRefName(OT,pipRef)
                if strcmpi(axis,'a')
                    propHandle = OT.addprop(pipRef);
                    OT.axisA = Pipettes(OT,pipRef,'a',max_vol,varargin{:}); % Initialize the pipette and save to axis specific handle
                    OT.(pipRef) = OT.axisA; % Point dynamic prop handle to the axis specific handle
                    OT.pipHandles(1,2) = {propHandle}; % Save dynamic prop handle
                    pipetteHandle = OT.(pipRef); % Pass out pointer to the pipette
                elseif strcmpi(axis,'b')
                    propHandle = OT.addprop(pipRef);
                    OT.axisB = Pipettes(OT,pipRef,'b',max_vol,varargin{:}); % Initialize the pipette and save to axis specific handle
                    OT.(pipRef) = OT.axisB; % Point dynamic prop handle to the axis specific handle
                    OT.pipHandles(2,2) = {propHandle}; % Save dynamic prop handle
                    pipetteHandle = OT.(pipRef); % Pass out pointer to the pipette
                else
                    error('Pipette axis must be specified as a string either ''a'' or ''b'' ');                    
                end            
            end
        end
        
        %% Queuing Methods
        
        function prepTransfer(OT,pipette,timePoint,timeType,timeOrder,queueType)
            
            % set default properties for things that arent added
            switch nargin
                case 3
                    timeType = 'absolute';
                    timeOrder = -1;
                    queueType = 'ExtQueue';
                case 4                    
                    
                case 5                    
                    
            end
            % Get the pipette reference name for inside OT
            pipName = pipette.name;
            
            
            
        end
        
        
        
        function sendToExtQueue(OT,extQueue,queueList)
            % Pass information to the external queue
            
            % number of different queue groups
            nQueues = length(queueList);
            
            for k = 1:nQueues
                qGroup = queueList(k);
                
                % Check that the queue is set
                if qGroup.checkLocQueue==1
                    extQueue.addToQueue(qGroup.Name,...
                        {qGroup.TimePoint,qGroup.TimeType},...
                        qGroup.TimeOrder,'OTcommand',...
                        {qGroup},'',OT,'runFromExtQueue',qGroup.MDdescr,0);
                else
                    error('one of the queues in the queue list is not properly set');
                end
            end
        end
        
        function runFromExtQueue(OT,queueCell)
            
            OT.robot.clear_commands();
            
            queue = queueCell{:};
            commandCell =queue.comd;
            
            for k=1:length(commandCell(:,1))
                runner = commandCell{k,1};
                vars = commandCell{k,3};
                
                runner.(commandCell{k,2})(vars{:});
            end
            
            OT.robot.run()
%             OT.runPar();
            
        end
        
        %% Internal Methods
        
        function is_a_GO = checkRefName(OT,refName)
            
            is_a_GO = 0;
            if ~isprop(OT,refName) && isvarname(refName)
                % Verify that the property is not already assigned and is a
                % valid MATLAB variable name. 
                
                is_a_GO = 1;
                
            else
                % Throw errors if the reference handle is not valid.
                if isprop(OT,refName)
                    error('Reference handle conflicts with properties already set. Please choose a different reference name');
                end
                
                if ~isvarname(refName)
                    error('Reference handle does not conform to MATLAB variable name requirements. Please choose a different reference name');
                end
                
            end
            
        end
    end
    
end

