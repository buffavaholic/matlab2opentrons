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
        
        %% Pipette action methods
        
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
             
        %% Tip Methods
        
        function pick_up_tip(Pip,Loc,queuing)
            % Pick up a new tip
            
            % Allow less than all inputs
            if nargin == 2
                queuing = 'OTqueue';
            elseif nargin == 1
                queuing = 'OTqueue';
                Loc = [];
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % Run the pick up tip now
                    Pip.pypette.pick_up_tip(Loc,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.pick_up_tip(Loc);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function drop_tip(Pip,Loc,queuing)
            % Drop current tip in trash or if undefined the current
            % location
            
            % Allow less than all inputs
            if nargin == 2
                queuing = 'OTqueue';
            elseif nargin == 1
                queuing = 'OTqueue';
                Loc = [];
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % Run the drop tip now
                    Pip.pypette.drop_tip(Loc,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.drop_tip(Loc);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function return_tip(Pip,queuing)
            % Return current tip to it's previous tiprack location
            
            % Allow less than all inputs
            if nargin == 1
                queuing = 'OTqueue';
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % Run the drop tip now
                    Pip.pypette.return_tip(false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.drop_tip();
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        %% General movement methods
        
        function home(Pip,queuing)
            % Home this pipette's axis either right now or during a
            % protocol
            
            % Allow the default be to add to queue
            if nargin == 1
                queuing = 'OTqueue';
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % Home now
                    Pip.pypette.home(false);                    
                case 'OTqueue'
                    % Add home to the OT queue
                    Pip.pypette.home();
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
        end
        
        function move_to(Pip,loc,strategy,queuing)
            % Move robot to given location based on this pipettes
            % calibration
            %     No checking that loc is of the right format because it
            %     can be several different types.
            
            % Assign default variables if not passed in
            if nargin==3
                queuing = 'OTqueue';
            elseif nargin == 2
                queuing = 'OTqueue';
                strategy = 'arc';
            end
            
            if isempty(strategy)
                strategy = 'arc';
            end
            
            % Confirm strategy is in the correct format
            assert(strcmp(strategy,'arc') || strcmp(strategy,'direct'),...
                'move_to strategy must be either ''arc'' or ''direct'' ');
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % move to location now
                    Pip.pypette.move_to(loc,strategy,false);                    
                case 'OTqueue'
                    % Add move to location to the OT queue
                    Pip.pypette.move_to(loc,strategy,1);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function delay(Pip,time,queuing)
            % Pause movement either during queued run or right now
            
            % Assign default queue variable if not passed in
            if nargin == 2
                queuing = 'OTqueue';
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            switch queuing
                case 'Now'
                    % pause now
                    Pip.pypette.delay(time,false);                    
                case 'OTqueue'
                    % Add pause to the OT queue
                    Pip.pypette.delay(time,true);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
        end
        
        %% Moving liquid methods
        
        function aspirate(Pip,vol,loc,rate,queuing)
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
            
            % Assign default variables if not passed in            
            switch nargin
                case 1
                    vol = py.None;
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';
                case 2
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';                    
                case 3
                    rate = 1;
                    queuing = 'OTqueue';
                case 4
                    queuing = 'OTqueue';                    
            end
            
            % If an empty place holder is passed in for vol set to
            % max_volume            
            if isempty(vol)
                vol = py.None;
            end
            
            % If an empty place holder is passed in for rate set to 1
            if isempty(rate)
                rate = 1;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            % Execute python method 'aspirate' based on queue option
            switch queuing
                case 'Now'
                    % Execute now
                    Pip.pypette.aspirate(vol,loc,rate,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.aspirate(vol,loc,rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function dispense(Pip,vol,loc,rate,queuing)
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
            
            
            % Assign default variables if not passed in            
            switch nargin
                case 1
                    vol = py.None;
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';
                case 2
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';                    
                case 3
                    rate = 1;
                    queuing = 'OTqueue';
                case 4
                    queuing = 'OTqueue';                    
            end
            
            % If an empty place holder is passed in for vol set to
            % max_volume            
            if isempty(vol)
                vol = py.None;
            end
            
            % If an empty place holder is passed in for rate set to 1
            if isempty(rate)
                rate = 1;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            % Execute python method 'dispense' based on queue option
            switch queuing
                case 'Now'
                    % Execute now
                    Pip.pypette.dispense(vol,loc,rate,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.dispense(vol,loc,rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function mix(Pip,reps, vol,loc,rate,queuing)
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
            
           
            % Assign default variables if not passed in            
            switch nargin
                case 1
                    reps = 1;
                    vol = py.None;
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';
                case 2
                    vol = py.None;
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';
                case 3
                    loc = [];
                    rate = 1;
                    queuing = 'OTqueue';                    
                case 4
                    rate = 1;
                    queuing = 'OTqueue';
                case 5
                    queuing = 'OTqueue';                    
            end
            
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
            
            % If an empty place holder is passed in for rate set to 1
            if isempty(rate)
                rate = 1;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
            
            % Execute python method 'mix' based on queue option
            switch queuing
                case 'Now'
                    % Execute now
                    Pip.pypette.mix(reps,vol,loc,rate,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.mix(reps,vol,loc,rate,true);
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function blow_out(Pip,loc,queuing)
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
            
            % Assign default variables if not passed in            
            switch nargin
                case 1
                    loc = py.None;
                    queuing = 'OTqueue';
                case 2
                    queuing = 'OTqueue'; 
            end
            
            % Pass None to python if empty
            if isempty(loc)
                loc = py.None;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
                       
            % Execute python method 'blow_out' based on queue option
            switch queuing
                case 'Now'
                    % Execute now
                    Pip.pypette.blow_out(loc,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.blow_out(loc,true); 
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
        function touch_tip(Pip,loc,queuing)
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
            
            % Assign default variables if not passed in            
            switch nargin
                case 1
                    loc = py.None;
                    queuing = 'OTqueue';
                case 2
                    queuing = 'OTqueue'; 
            end
            
            % Pass None to python if empty
            if isempty(loc)
                loc = py.None;
            end
            
            % Confirm queuing is in the correct format
            Pip.checkQueuingInput(queuing);
                       
            % Execute python method 'touch_tip' based on queue option
            switch queuing
                case 'Now'
                    % Execute now
                    Pip.pypette.touch_tip(loc,false);                    
                case 'OTqueue'
                    % Add to the OT queue
                    Pip.pypette.touch_tip(loc,true); 
                case 'ExtQueue'
                    % Send to external queue
                    % Need to do
            end
            
        end
        
    end
    
end

