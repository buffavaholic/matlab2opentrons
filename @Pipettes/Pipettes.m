classdef Pipettes < handle
    %PIPETTES MATLAB class to convert to OT Python pipette class 
    %   The PIPETTES class handles the MATLAB facing interactions with the
    %   OpenTrons pipette objects so the MATLAB user can use MATLAB
    %   notation to operate the Python object easier. 
    
    properties
        %% OT information
        
        parent; % (OpenTrons Class) Link to the calling OpenTrons class
        classPath; % (dir) file locaiton of the Pipettes class
        libPath; % (dir) file directory of the MAT2OT library
        
        %% OT Python Pipette parameters
        
        axis; % (str) Axis of the pipettes's actuator on the Opentrons robot('a' or 'b') 
        name; % (str) Unique name for saving it's calibrations. 
        channels = 1; % (int) Number of pipette channels 
        min_volume = 0; % (int) Smallest recommended volume in uL 
        max_volume; % (int) Largest volume in uL 
        trash_container ; % (Container) Sets the default location for 'drop_tip()' 
        tip_racks; % (cell array of Containers) A list of containers for this Pipette to track tips when calling 'pick_up_tip()'
        aspirate_speed = 300; % (int) The speed (in mm/minute) the plunger will move while aspirating
        dispense_speed = 500; % (int) The speed (in mm/minute) the plunger will move while dispensing
        
        %% Python Pipette pointer
        
        pypette; % Pointer to the python pipette object. 

    end
    
    %% Helper functions
    % methods to perform basic actions used in several methods
    
    methods (Static)
        
        function checkQueuingInput(queuing)
            % Check that the queuing input string is of the correct format
            assert(strcmp(queuing,'OTqueue') || strcmp(queuing,'Now') || strcmp(queuing,'ExtQueue'),...
                'queuing must be either ''Now'', ''OTqueue'' or ''ExtQueue'' ');
        end
    end
   
    methods
        
        %% Constructor
        function Pip = Pipettes(OT,pipRef,axis,max_vol,varargin)
            % Constructor of the Pipette class
            
            % Inputs: OT       - *OpenTrons Class* Pointer to the calling
            %                    OpenTrons class.
            %         pipRef   - *str* name to add the pipette as a
            %                    property of the OT class. Must conform to
            %                    MATLAB variable name rules.
            %         axis     - *str* Axis of the pipette being added.
            %                    Must be 'a' or 'b'.
            %         max_vol  - *int* Maximum volume allowed on the
            %                    pipette being added.
            %         varargin - Optional input arguments in a string
            %                    identifier - value pairs.
            
            
            % Link to OT class caller
            Pip.parent = OT;
            
            % Get File Path
            getFileName = mfilename('fullpath');
            Pip.classPath = fileparts(getFileName);
            Pip.libPath = OT.libPath; 
            
                      
            % Parse optional variables
            arg.channels = Pip.channels; % (int) Number of pipette channels 
            arg.min_volume = Pip.min_volume; % (int) Smallest recommended volume in uL             
            arg.trash_container = []; % (Container) Sets the default location for 'drop_tip()' 
            arg.tip_racks = {}; % (cell array of Containers) A list of containers for this Pipette to track tips when calling 'pick_up_tip()'
            arg.aspirate_speed = Pip.aspirate_speed; % (int) The speed (in mm/minute) the plunger will move while aspirating
            arg.dispense_speed = Pip.dispense_speed; % (int) The speed (in mm/minute) the plunger will move while dispensing
            
            arg = parseVarargin(varargin,arg);
            
            
            % Initalize the pipette in Python
            
            Pip.pypette = py.opentrons.instruments.Pipette(pyargs('axis',axis,...
                            'name',pipRef,...
                            'channels',int16(arg.channels),...
                            'min_volume',int16(arg.min_volume),...
                            'max_volume',int16(max_vol),...
                            'trash_container',arg.trash_container,...
                            'tip_racks',py.list(arg.tip_racks),...
                            'aspirate_speed',int16(arg.aspirate_speed),...
                            'dispense_speed',int16(arg.dispense_speed)));
            
            % Save required variables 
            Pip.axis = axis; % (str) Axis of the pipettes's actuator on the Opentrons robot('a' or 'b') 
            Pip.name = pipRef; % (str) Unique name for saving it's calibrations. 
            Pip.max_volume = max_vol; % (int) Largest volume in uL
            
            % Save rest of Pipette properties after optional var have been
            % parsed
            Pip.channels = arg.channels; % (int) Number of pipette channels 
            Pip.min_volume = arg.min_volume; % (int) Smallest recommended volume in uL             
            Pip.trash_container = arg.trash_container; % (Container) Sets the default location for 'drop_tip()' 
            Pip.tip_racks = arg.tip_racks; % (cell array of Containers) A list of containers for this Pipette to track tips when calling 'pick_up_tip()'
            Pip.aspirate_speed = arg.aspirate_speed; % (int) The speed (in mm/minute) the plunger will move while aspirating
            Pip.dispense_speed = arg.dispense_speed; % (int) The speed (in mm/minute) the plunger will move while dispensing
            

            
        end
        
        %% Set pipette properties after initalization
        
        function set.trash_container(Pip,trashCont)
            % Set the trash_container property for both the MATLAB Pipettes
            % class and the Python object.
            
            % Do nothing if empty
            if ~isempty(trashCont)
                % Confirm the trash container is a container.
                assert(isa(trashCont,'py.opentrons.containers.placeable.Container'),...
                    'Supplied trash container not a OpenTrons Container (wrong type)');

                try
                    % Add to python object
                    Pip.pypette.trash_container = trashCont;

                    % Add to MATLAB object
                    Pip.trash_container = trashCont;
                catch ME
                    % Throw Error
                    error('Error adding trash container to pipette. Error details: \n %s',ME.message);
                end
            else
                Pip.trash_container = trashCont;
            end
            
        end
        
        function set.tip_racks(Pip,tipRacks)
            % Set the tip_racks property for both the MATLAB Pipettes
            % class and the Python object.
            
            % Confirm the tipRacks is a cell array
            isCell = isa(tipRacks,'cell');
            % Check if singleton container and if items in cell are
            % containers
            if isCell == 0
                % If not a cell, check that it is at least a OT Container
                assert(isa(tipRacks,'py.opentrons.containers.placeable.Container'),...
                'Supplied tip rack not a OpenTrons Container (wrong type)');
                tipRacks = {tipRacks};
            else 
                % Check the contents of the cell array
                for k = 1:length(tipRacks)
                    assert(isa(tipRacks{k},'py.opentrons.containers.placeable.Container'),...
                        'One of the items in the tip_racks supplied is not a OpenTrons Container (wrong type)');
                end                
            end
           
           
            try
                % Add to python object
                Pip.pypette.tip_racks = py.list(tipRacks);

                % Add to MATLAB object
                Pip.tip_racks = tipRacks;
            catch ME
                % Throw Error
                error('Error adding tip_racks to pipette. Error details: \n %s',ME.message);
            end            
            
        end
        
        function add_tip_rack(Pip,tipRack,pos)
            % Add a single tip rack container to the list of tip_racks
            
            % Inputs: tipRack  - *OpenTrons Container Class* Single
            %                    tip-rack container to add to list.
            %         pos      - *int* (optional)Position in the tip_racks
            %                    list to add the tipRack to. Default: end

            % current number of tip racks
            nTR = length(Pip.tip_racks);
            % if pos is not supplied add to end of list.
            if nargin < 3
                pos = nTR+1;
            end
            
            % Confirm the tipRack is a container
            assert(isa(tipRack,'py.opentrons.containers.placeable.Container'),...
                'Supplied tip rack not a OpenTrons Container (wrong type)');
            
            %initalize tipList with current tips
            tipList = Pip.tip_racks;
            if pos == nTR+1;
                tipList{pos} = tipRack;
            else
                tipList = {tipList{1:(pos-1)},tipRack,tipList{pos:end}};
            end
            
            % Update new tip racks list
            Pip.tip_racks = tipList;           
        end
        
        function set.channels(Pip,numChannels)
            % Update the pipette number of channels
            
            try
                % Add to python object
                Pip.pypette.channels = int16(numChannels);

                % Add to MATLAB object
                Pip.channels = int16(numChannels);
            catch ME
                % Throw Error
                error('Error updating pipette channels. Error details: \n %s',ME.message);
            end       
        end
        
        function set.min_volume(Pip,minVol)
            % Update the pipette number of channels
            
            try
                % Add to python object
                Pip.pypette.min_volume = int16(minVol);

                % Add to MATLAB object
                Pip.min_volume = int16(minVol);
            catch ME
                % Throw Error
                error('Error updating pipette minimum volume. Error details: \n %s',ME.message);
            end       
        end
        
        function set.max_volume(Pip,maxVol)
            % Update the pipette number of channels
            
            try
                % Add to python object
                Pip.pypette.max_volume = int16(maxVol);

                % Add to MATLAB object
                Pip.max_volume = int16(maxVol);
            catch ME
                % Throw Error
                error('Error updating pipette maximum volume. Error details: \n %s',ME.message);
            end       
        end
        
        function set.aspirate_speed(Pip,aspSpeed)
            % Update the pipette number of channels
            
            try
                % Add to python object
                Pip.set_speed('aspirate',aspSpeed);

                % Add to MATLAB object
                Pip.aspirate_speed = aspSpeed;
            catch ME
                % Throw Error
                error('Error updating pipette aspiration speed. Error details: \n %s',ME.message);
            end       
        end
        
        function set.dispense_speed(Pip,dispSpeed)
            % Update the pipette number of channels
            
            try
                % Add to python object
                Pip.set_speed('dispense',dispSpeed);

                % Add to MATLAB object
                Pip.dispense_speed = dispSpeed;
            catch ME
                % Throw Error
                error('Error updating pipette dispensing speed. Error details: \n %s',ME.message);
            end       
        end
        
        function set_speed(Pip,speedType,speedRate)
            % Update the aspirate or dispense speed of the pipette
            
            if strcmpi(speedType,'aspirate')
                Pip.pypette.set_speed(pyargs('aspirate',speedRate));
            elseif strcmpi(speedType,'dispense')
                Pip.pypette.set_speed(pyargs('dispense',speedRate));
            else
                error('Speed type must be either ''aspirate'' or ''dispense'' ');
            end
            
        end
        
        %% Pipette Calibration methods
        
        function calibrate(Pip,stopSite)
            % Calibrate the plunger positions of the pipette
            
            % Inputs: stopSite - *str* plunger position to be calibrated
            %                    based on current robot position. Must be
            %                    either 'top', 'bottom', 'blow_out' or
            %                    'drop_tip'. (case sensitive)
            % Note: OpenTrons API must be connected to a robot.
            
            try
                % Submit 'calibrate' python method
                Pip.pypette.calibrate(stopSite);
            catch ME
                 error(['Error calibrating pipette plunger position.',...
                        'Input must be a string of either ''top'', ''bottom'',',...
                        ' ''blow_out'' or ''drop_tip'' (case sensitive).',...
                        ' Error details: \n %s'],ME.message);
            end
        end
        
        function calibrate_position(Pip,cont,well,varargin)
            % Calibrate the position of a container for this given pipette
            
            % Parse optional variables
            %   rel_pos variables
            arg.rel_x = 0; % (double between -1 and 1) Relative position of well x position 
            arg.rel_y = 0; % (double between -1 and 1) Relative position of well y position 
            arg.rel_z = -1; % (double between -1 and 1) Relative position of well z position (-1= bottom, 1=top of well)
            arg.rel_r = []; % (double between -1 and 1) Relative position of polar radius from well center
            arg.rel_theta = []; % (double) Relative position of polar angle from well center in radians
            arg.rel_h = []; % (double between -1 and 1) Relative position of polar height from well center
            arg.reference = cont; % (OT Container Class) position relative to what container
            
            % calibration variables
            arg.specified_pos = py.tuple({}); % (Python tuple) Calibration coordinates in py.tuple form. If not supplied use the pipette location.
            
            % Flag for updating a Dynamic Container only due to stage
            % movement (i.e. not from the pipette position)
            arg.update_dyn_stage = 0;
            
            arg = parseVarargin(varargin,arg);
            
            % Get relative position vector
            if (~isempty(arg.rel_r) && ~isempty(arg.rel_theta) && ~isempty(arg.rel_h))
                % if polar references are specified use the polar reference
                rel_pos_vect = Pip.parent.rel_pos(cont,well,'rel_r',arg.rel_r,'rel_theta',arg.rel_theta,'rel_h',arg.rel_h,'reference',arg.reference);
            else
                % Otherwise use cartesian.
                rel_pos_vect = Pip.parent.rel_pos(cont,well,'rel_x',arg.rel_x,'rel_y',arg.rel_y,'rel_z',arg.rel_z,'reference',arg.reference);
            end
            
            % Generate reference tuple
            refCoord = py.tuple({cont,rel_pos_vect});
            
            % Check If Dynamic Container
            if cont == Pip.parent.DynCont.pointer
                arg.specified_pos = Pip.updateDynContCalib(cont,well);
                if arg.update_dyn_stage == 0
                    % Use pipette position to calibrate
                    arg.specified_pos = py.tuple({});
                end
            end
      
            % Calibrate container position using the OpenTrons python meth.
            % If specified_pos is not supplied then calibrate based on
            % pipette location
            if isempty(cell(arg.specified_pos))
                % Calibrate using pipette location
                Pip.pypette.calibrate_position(refCoord);
            else 
                % Calibrate using specified coordinates
                Pip.pypette.calibrate_position(refCoord,arg.specified_pos);
            end 
        end
        
        function specified_pos = updateDynContCalib(Pip,cont,well)
            % 
            
            % Set a placeholder for specified_pos
            specified_pos = py.tuple({});
            
            % Get stage properties
            stage = Pip.parent.DynCont.stage;
            stage_units = Pip.parent.DynCont.stage_units;
            stage_dir = Pip.parent.DynCont.stage_dir;
            stage_axisOrder = Pip.parent.DynCont.stage_axisOrder;
            % Get current stage Position
            newXY = stage.XY;
            
            % Calculate change and set new reference for given axis
            switch Pip.axis
                case 'a'
                    oldXY = Pip.parent.DynCont.aCalibXY;
                    Pip.parent.DynCont.aCalibXY = newXY;
                    if isempty(oldXY)
                        return
                    end
                    delta = newXY - oldXY;
                case 'b'
                    oldXY = Pip.parent.DynCont.bCalibXY;
                    Pip.parent.DynCont.bCalibXY = newXY;
                    if isempty(oldXY)
                        return
                    end
                    delta = newXY - oldXY;
            end
            
            % convert units to mm
            switch stage_units
                case 'micrometer'
                    delta = delta/1000;
                case 'millimeter'
                    delta = delta/1;
            end
            % set direction and axis
            delX = stage_dir(1)*delta(stage_axisOrder(1));
            delY = stage_dir(2)*delta(stage_axisOrder(2));
            % get current calib position
            currCalib = Pip.pypette.calibrator.convert(cont,Pip.parent.rel_pos(cont,well));
            currCalibVV = currCalib.to_tuple;
            
            % return specified position cell array
            specified_pos = {currCalibVV.x+delX,currCalibVV.y+delY,currCalibVV.z};
        end
        
       
        %% Tip Methods
        
        function pick_up_tip(Pip,varargin)
            % Pick up a new tip
            
            % Parse optional variables
            arg.loc = py.None;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);            
             
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % Run the pick up tip now
%                     Pip.pypette.pick_up_tip(arg.loc,false);
                    % Run as daemon
                    Pip.parent.runMethDaemon(1,Pip.pypette,'pick_up_tip',arg.loc,false);
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.pick_up_tip(arg.loc);
                case 'ExtQueue'
                    % Send to external queue
                    
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'pick_up_tip',{'loc',arg.loc,'queuing','OTqueue'},'Pick up tip at??','localpos',arg.localpos);
                        
                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function drop_tip(Pip,varargin)
            % Drop current tip in trash or if undefined the current
            % location
            
            % Parse optional variables
            arg.loc = py.None;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
         
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % Run the drop tip now
%                     Pip.pypette.drop_tip(arg.loc,false);
                    % Run as daemon
                    Pip.parent.runMethDaemon(1,Pip.pypette,'drop_tip',arg.loc,false);
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.drop_tip(arg.loc);
                case 'ExtQueue'
                    % Send to external queue
                    
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'drop_tip',{'loc',arg.loc,'queuing','OTqueue'},'drop tip at??','localpos',arg.localpos);
                        
                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function return_tip(Pip,varargin)
            % Return current tip to it's previous tiprack location
            
            % Parse optional variables
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % Run the drop tip now
%                     Pip.pypette.return_tip(false);
                    % Run as daemon
                    Pip.parent.runMethDaemon(1,Pip.pypette,'return_tip',false);
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.return_tip();
                case 'ExtQueue'
                    % Send to external queue
                     if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'return_tip',{'queuing','OTqueue'},'return tip to ??','localpos',arg.localpos);
                        
                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        %% General movement methods
        
        function boolOut = check_conn(Pip)
            % Check that the robot is connected to the software
            
            boolOut = Pip.parent.check_conn();
        end
            
        
        function home(Pip,varargin)
            % Home this pipette's axis either right now or during a
            % protocol
            
            % Parse optional variables
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % Home now
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'home',false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add home to the OT queue
                    Pip.pypette.home();
                case 'ExtQueue'
                    % Send to external queue
                    
                     if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'home',{'queuing','OTqueue'},'home axis ??','localpos',arg.localpos);
                        
                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
        end
        
        function move_to(Pip,loc, varargin)
            % Move robot to given location based on this pipettes
            % calibration
            %     No checking that loc is of the right format because it
            %     can be several different types.
            
            % Parse optional variables
            arg.strategy = 'arc';
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            if isempty(loc)
                loc = py.None;
            end
            
            if isempty(arg.strategy)
                arg.strategy = 'arc';
            end
            
            % Confirm strategy is in the correct format
            assert(strcmp(arg.strategy,'arc') || strcmp(arg.strategy,'direct'),...
                'move_to strategy must be either ''arc'' or ''direct'' ');
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % move to location now
%                     Pip.pypette.move_to(loc,arg.strategy,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'move_to',loc,arg.strategy,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add move to location to the OT queue
                    Pip.pypette.move_to(loc,arg.strategy,1);
                case 'ExtQueue'
                    % Send to external queue
                     if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'move_to',{loc,'strategy',arg.strategy,'queuing','OTqueue'},'move to ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function delay(Pip,time,varargin)
            % Pause movement either during queued run or right now
            
            % Parse optional variables 
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            switch arg.queuing
                case 'Now'
                    % pause now
%                     Pip.pypette.delay(time,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'delay',time,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add pause to the OT queue
                    Pip.pypette.delay(time,true);
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'delay',{time,'queuing','OTqueue'},'delay ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
        end
        
        %% Moving liquid methods
        
        function aspirate(Pip,vol,loc,varargin)
            % Aspirate a volume of liquid (in uL) using this pipette
            
            % Inputs: vol      - *int or double* Number of microliters to
            %                    aspirate. If no volume is passed in the
            %                    max_volume of the pipette will be used.
            %         loc      - *Placable or tuple* The location to
            %                    aspirate from. If none is passed in the
            %                    volume will be aspirated from the current
            %                    location.
            %         rate     - *double* fraction of the aspirate_speed to
            %                    use when aspirating liquid. i.e. speed =
            %                    rate*aspirate_speed. Default: 1.
            %         queuing  - *str* Specifier if this command should be
            %                    run now, 'Now', added to the OT queue,
            %                    'OTqueue', or added to an external queue,
            %                    'ExtQueue'. Default: 'OTqueue'.
            
            
            % Parse optional variables 
            arg.rate = 1;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
                        
            % If an empty place holder is passed in for vol set to
            % max_volume            
            if isempty(vol)
                vol = py.None;
            end
                       
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            % Execute python method 'aspirate' based on queue option
            switch arg.queuing
                case 'Now'
                    % Execute now
%                     Pip.pypette.aspirate(vol,loc,arg.rate,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'aspirate',vol,loc,arg.rate,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.aspirate(vol,loc,arg.rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'aspirate',{vol,loc,'rate',arg.rate,'queuing','OTqueue'},'aspirate ?? from ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function dispense(Pip,vol,loc,varargin)
            % Dispense a volume of liquid (in uL) using this pipette
            
            % Inputs: vol      - *int or double* Number of microliters to
            %                    dispense. If no volume is passed in the
            %                    current_volume of the pipette will be used.
            %         loc      - *Placable or tuple* The location to
            %                    aspirate from. If none is passed in the
            %                    volume will be dispensed from the current
            %                    location.
            %         rate     - *double* fraction of the dispense_speed to
            %                    use when dispensing liquid. i.e. speed =
            %                    rate*dispense_speed. Default: 1.
            %         queuing  - *str* Specifier if this command should be
            %                    run now, 'Now', added to the OT queue,
            %                    'OTqueue', or added to an external queue,
            %                    'ExtQueue'. Default: 'OTqueue'.
            
             % Parse optional variables 
            arg.rate = 1;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            % If an empty place holder is passed in for vol set to
            % max_volume            
            if isempty(vol)
                vol = py.None;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            % Execute python method 'dispense' based on queue option
            switch arg.queuing
                case 'Now'
                    % Execute now
%                     Pip.pypette.dispense(vol,loc,arg.rate,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'dispense',vol,loc,arg.rate,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.dispense(vol,loc,arg.rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'dispense',{vol,loc,'rate',arg.rate,'queuing','OTqueue'},'dispense ?? to ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function mix(Pip,reps,vol,varargin)
            % Mix a volume of liquid (in uL) using this pipette
            
            % Inputs: reps     - *int* Number of times the pipette should
            %                    mix up and down. Default: 1
            %         vol      - *int or double* Number of microliters to
            %                    dispense. If no volume is passed in the
            %                    max_volume of the pipette will be used.
            %         loc      - *Placable or tuple* The location to
            %                    aspirate from. If none is passed in the
            %                    volume will be dispensed from the current
            %                    location.
            %         rate     - *double* fraction of the dispense_speed to
            %                    use when dispensing liquid. i.e. speed =
            %                    rate*dispense_speed. Default: 1.
            %         queuing  - *str* Specifier if this command should be
            %                    run now, 'Now', added to the OT queue,
            %                    'OTqueue', or added to an external queue,
            %                    'ExtQueue'. Default: 'OTqueue'.
            
            % Parse optional variables
            arg.loc = py.None;
            arg.rate = 1;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
    
            % If an empty place holder is passed in for reps set to 1
            if isempty(reps)
                reps = 1;
            end
            
            % Check if reps needs to be converted to integer
            if isnumeric(reps)
                if ~isinteger(reps)
                    if mod(reps,1) == 0
                        % reps passed in is an integer value but just
                        % passed in as a double. So convert it
                        reps = int16(reps);
                    else
                        % fractional number passed in. Warn then truncate
                        warning('Reps passed in was fractional when integer',...
                                ' is required. The number will be rounded ',...
                                ' to the nearest integer');
                        reps = int16(reps);
                    end
                        
                end
            else
                error('reps must be a number')
            end
            
            % If an empty place holder is passed in for vol set to
            % max_volume            
            if isempty(vol)
                vol = py.None;
            end
                       
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
            
            % Execute python method 'mix' based on queue option
            switch arg.queuing
                case 'Now'
                    % Execute now
%                     Pip.pypette.mix(reps,vol,arg.loc,arg.rate,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'mix',reps,vol,arg.loc,arg.rate,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.mix(reps,vol,arg.loc,arg.rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'mix',{reps,vol,'loc',arg.loc,'rate',arg.rate,'queuing','OTqueue'},'mix ?? uL in ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function blow_out(Pip,varargin)
            % Force any remaining liquid to dispense, by moving this 
            % pipette’s plunger to the calibrated 'blow_out' position.
            
            % Inputs: loc      - *Placable or tuple* The location to
            %                    blow out from. If none is passed in the
            %                    blow out will be occur at the current
            %                    location.
            %         queuing  - *str* Specifier if this command should be
            %                    run now, 'Now', added to the OT queue,
            %                    'OTqueue', or added to an external queue,
            %                    'ExtQueue'. Default: 'OTqueue'.
            
            % Parse optional variables
            arg.loc = py.None;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);

            % Pass None to python if empty
            if isempty(arg.loc)
                arg.loc = py.None;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
                       
            % Execute python method 'blow_out' based on queue option
            switch arg.queuing
                case 'Now'
                    % Execute now
%                     Pip.pypette.blow_out(arg.loc,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'blow_out',arg.loc,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.blow_out(arg.loc,true); 
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'blow_out',{'loc',arg.loc,'queuing','OTqueue'},'blowout at ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
        function touch_tip(Pip,varargin)
            % Touch the pipette tip to the side of the well, with the
            % intent of removing left-over droplets.
            
            % Inputs: loc      - *Placable or tuple* The location of well
            %                    to touch the tip on. If none is passed in
            %                    the pipette will touch_tip at the most
            %                    recent associated placable.
            %         queuing  - *str* Specifier if this command should be
            %                    run now, 'Now', added to the OT queue,
            %                    'OTqueue', or added to an external queue,
            %                    'ExtQueue'. Default: 'OTqueue'.
            
            % Parse optional variables 
            arg.loc = py.None;
            arg.queuing = 'OTqueue';
            arg.locqueue = OTexQueue;
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            % Assign default variables if not passed in 
            
            % Pass None to python if empty
            if isempty(arg.loc)
                arg.loc = py.None;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(arg.queuing);
                       
            % Execute python method 'touch_tip' based on queue option
            switch arg.queuing
                case 'Now'
                    % Execute now
%                     Pip.pypette.touch_tip(arg.loc,false);
                    % Run as daemon
                    if Pip.check_conn==1
                        Pip.parent.runMethDaemon(1,Pip.pypette,'touch_tip',arg.loc,false);
                    else
                        warningdlg('Robot not connected, connect to robot first');
                    end
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.touch_tip(arg.loc,true); 
                case 'ExtQueue'
                    % Send to external queue
                    if arg.locqueue.checkLocQueue
                        % Appropriate parameters are set so send to queue
                        arg.locqueue.queueMeth(Pip,'touch_tip',{'loc',arg.loc,'queuing','OTqueue'},'touch tip at ??','localpos',arg.localpos);

                    else
                        % Queue is either not defined or parameters not set
                        error('Local queue not initalized properly or supplied')
                    end
            end
            
        end
        
    end
    
end

