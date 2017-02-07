classdef Pipettes < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
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
            
            % Save required variables 
            Pip.axis = axis; % (str) Axis of the pipettes's actuator on the Opentrons robot('a' or 'b') 
            Pip.name = pipRef; % (str) Unique name for saving it's calibrations. 
            Pip.max_volume = max_vol; % (int) Largest volume in uL 
            
            % Parse optional variables
            arg.channels = Pip.channels; % (int) Number of pipette channels 
            arg.min_volume = Pip.min_volume; % (int) Smallest recommended volume in uL             
            arg.trash_container = []; % (Container) Sets the default location for 'drop_tip()' 
            arg.tip_racks = {}; % (cell array of Containers) A list of containers for this Pipette to track tips when calling 'pick_up_tip()'
            arg.aspirate_speed = Pip.aspirate_speed; % (int) The speed (in mm/minute) the plunger will move while aspirating
            arg.dispense_speed = Pip.dispense_speed; % (int) The speed (in mm/minute) the plunger will move while dispensing
            
            arg = parseVarargin(varargin,arg);
            
            % Save rest of Pipette properties after optional var have been
            % parsed
            Pip.channels = arg.channels; % (int) Number of pipette channels 
            Pip.min_volume = arg.min_volume; % (int) Smallest recommended volume in uL             
            Pip.trash_container = arg.trash_container; % (Container) Sets the default location for 'drop_tip()' 
            Pip.tip_racks = arg.tip_racks; % (cell array of Containers) A list of containers for this Pipette to track tips when calling 'pick_up_tip()'
            Pip.aspirate_speed = arg.aspirate_speed; % (int) The speed (in mm/minute) the plunger will move while aspirating
            Pip.dispense_speed = arg.dispense_speed; % (int) The speed (in mm/minute) the plunger will move while dispensing
            
            % Initalize the pipette in Python
            
            Pip.pypette = py.opentrons.instruments.Pipette(pyargs('axis',Pip.axis,...
                            'name',Pip.name,...
                            'channels',int16(Pip.channels),...
                            'min_volume',int16(Pip.min_volume),...
                            'max_volume',int16(Pip.max_volume),...
                            'trash_container',Pip.trash_container,...
                            'tip_racks',py.list(Pip.tip_racks),...
                            'aspirate_speed',int16(Pip.aspirate_speed),...
                            'dispense_speed',int16(Pip.dispense_speed)));
                        

            
        end
        
        %% Set pipette type to axis
        function setPipette(Head,Axis,name)
            
            paramRow = Head.pipetteParamTable.Type == name;
            
            if sum(paramRow)==0
                error('No container with that name\n Pipette names are: "p1000", "p200","p10","multichannel"\n')
            elseif sum(paramRow)==1
                propsRow = Head.pipetteParamTable(paramRow,:);
                Head.(Axis).Type = char(propsRow.Type);
                Head.(Axis).maxVol = propsRow.maxVol;
                Head.(Axis).minVol = propsRow.minVol;
                Head.(Axis).tipPlunge = propsRow.tipPlunge;
            else
                error('More than one pipette type with that name...somehow...')
            end
            
        end
        
        function calibrate(Head,Axis,stop,pos)
            Head.(Axis).(stop) = pos;
            Head.checkIfCalibrated(Axis)
%             switch Axis
%                 case 'Left'
%                     Head.Left.(stop) = pos;
%                 case 'Right'
%                     Head.Right.(stop) = pos;
%             end
        end
        
        function checkIfCalibrated(Head,Axis)
            if sum(isnan([Head.(Axis).top,Head.(Axis).firstStop,Head.(Axis).droptip]))==0
                Head.(Axis).isCalib = 1;
            end
        end
        
        function setTipCont(Head,Axis,contName)
            numCont = length(Head.(Axis).tipCont);
            if numCont==0
                Head.(Axis).tipCont = {contName};
            else
                Head.(Axis).tipCont(numCont+1) = {contName};
            end
        end
        
        function removeTipCont(Head,Axis,contName)
            
            % find the container to be removed
            contInd = find(strcmp(Head.(Axis).tipCont,contName));
            if ~isempty(contInd)
                Head.(Axis).tipCont(contInd) = [];
            else
                error(['container not set as a tip box for ',Axis])
            end
            
        end
    end
    
end

