classdef OTexQueue < handle
    
    
    
    properties
        Name
        TimePoint
        TimeType ='absolute';
        TimeOrder = -1;
        QueueIndex;
        
        comd = {}; % Commands Cell list   
        
        MDdescr = '';
        
        waitToCont = 1;
        
        numTipsPickedUp = [0,0];
    end
    
    methods
        
        function exQ = OTexQueue
            
        end
        
        function queueMeth(exQ,source,meth,methInputs,methMD,varargin)
            % Sends a method to the OTexQueue 
            
            % Inputs: source   - *Pipettes or Opentrons class* The class
            %                    that the command originated from and must 
            %                    run out of.
            %         meth     - *str* name of the method to be run
            %         methInputs - *Cell array* Array of inputs for the
            %                    method to be run.
            %         methMD   - *str* Human readable string of what that
            %                    method is doing for recording in the
            %                    external method.
            %         varargin - Optional input arguments in a string
            %                    identifier - value pairs.
            
            % Parse optional variables
            arg.localpos = -1; % Where to add this into the comd list
            
            arg = parseVarargin(varargin,arg);
            
            % Check if source has parent then it is a pipette
            if isprop(source,'parent')
                % This is a pipette then
                
                % OT handle
                OTpointer = source.parent;
                % reference name for pipette in OT
                pipName = source.name;
                % check if pick_up_tip or return_tip is the method
                changeTipNum = 0;
                if strcmp(meth,'pick_up_tip')==1
                    changeTipNum = 1;
                elseif strcmp(meth,'return_tip')==1
                    changeTipNum = -1;
                end
                
                if changeTipNum ~= 0
                    % Pipette axis
                    pipAxis = source.axis;
                    
                    if strcmp(pipAxis,'a')==1
                        exQ.numTipsPickedUp(1) = exQ.numTipsPickedUp(1) + changeTipNum;
                    elseif strcmp(pipAxis,'b')==1
                        exQ.numTipsPickedUp(2) = exQ.numTipsPickedUp(2) + changeTipNum;
                    else
                        error('Pipette axis does not make sense')
                    end
                end
                
                
                mainSource = OTpointer.(pipName);
            else
                mainSource = source;
            end
            
            % Current number of commands in list
            [nComd,~ ]  = size(exQ.comd);
            if arg.localpos == -1 || arg.localpos == nComd +1
                
                exQ.comd(nComd+1,1:4) = {mainSource,meth,methInputs,methMD};
            elseif arg.localpos <= nComd && arg.localpos > 0
                
                % Grab the commands to be shifted down
                tempCommands = exQ.comd(arg.localpos:end,1:4);
                
                % Put the new command in
                exQ.comd(arg.localpos,1:4) = {mainSource,meth,methInputs,methMD};
                
                % add the old commands back in
                exQ.comd(arg.localpos+1:nComd+1,1:4) = tempCommands;
                
            else
                error('Position within the local queue supplied is greater than the number of commands currently in the local queue');
            end
            
        end
        
        function isGood = checkLocQueue(exQ)
            % Check that the properties are set
            
            % initalize as good
            isGood = 1;
            
            % If either the name or TimePoint are empty return 0
            if isempty(exQ.Name) || isempty(exQ.TimePoint) 
                isGood = 0;
            end
            
            
        end
        
    end
    
    
end