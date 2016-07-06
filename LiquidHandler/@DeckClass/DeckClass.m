classdef DeckClass < dynamicprops
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Class file path
        classPath
        
        % Coordinates of corners of grid dividers based on the left pipette
        % Position = {A1, B1 ...
        %             A2, B2 ...
        cornerCoords = {[ 10,397,121],[103,397,121],[196,397,120],[288,398,118],[379,398,117];
            [  9,262,121],[102,263,120],[195,263,120],[288,263,120],[379,264,119];
            [  6,126,121],[ 99,126,121],[193,128,121],[285,128,121],[379,128,120]};
        
        centPipetteOffset = [-57,1,1];
        
        % Deck Slot Positions
        slotList = {'A1';'A2';'A3';'B1';'B2';'B3';'C1';'C2';'C3';
                    'D1';'D2';'D3';'E1';'E2';'E3';'Custom'};
                
        % keep track of slot occupancy
        slotFilled
        
        % collect container names
        contNames
        
        % name of trash container
        trashCont
        
    end
    
    methods
        
        %% Constructor
        function DK = DeckClass%(LH)
            % Get File Path
            getFileName = mfilename('fullpath');
            DK.classPath = fileparts(getFileName);
            
            % Initialize slotFilled variable
            DK.slotFilled = table(DK.slotList,zeros(length(DK.slotList),1),...
                        'VariableNames',{'slot','filled'});
            DK.slotFilled.slot = categorical(DK.slotFilled.slot);
                       
        end
        
        function addContainer(DK,contName,slotStr,contType,newVarArray)
            % Check if slot is already filled
            if DK.slotFilled.filled(DK.slotFilled.slot == slotStr) == 1
                error('Deck slot already filled \n Try different slot or clear that slot (removeContainer)')
            end
            % Check that the container name is not already used
            if ~isprop(DK,contName)
                
                % Add container property to deck handle
                DK.addprop(contName);
                if nargin ==4
                    % Adding already defined container
                    DK.(contName)= Container(contType,slotStr,contName);
                elseif nargin ==5
                    % Adding a new container type
                    DK.(contName)= Container(newVarArray{1,2},slotStr,contName,newVarArray);
                end
                % update slotFilled to show that there is now a container
                % in that slot
                DK.slotFilled.filled(DK.slotFilled.slot == slotStr) = 1;
                
                % Add container name to list of containers
                DK.contNames{length(DK.contNames)+1} = contName;
                
                % If the container type is "trash" then set as the deck
                % trash can.
                contType = DK.(contName).props.type;                
                if contType == 'trash'
                    DK.trashCont = contName;
                end
            else
                error('Container name already used or same as other property: \n Try with a different name')
            end
            
            
        end
        
        function conts = getContainerList(DK)
            contLoc = which('Container.m');
            contPath = fileparts(contLoc);
            contParamTable = readtable([contPath,'\contParam.txt'],'Delimiter','|');
            conts = contParamTable.contName;
        end
        
        function removeContainer(DK,contName)
            %%% remove a container from the deck
            
            % Check if that container exists on the deck
            if isprop(DK,contName)
                % Get the container slot
                contSlot = DK.(contName).slot;
                % Set that slot to empty
                DK.slotFilled.filled(DK.slotFilled.slot == contSlot) = 0;
                
                % Find container name in container name list and remove
                contInd = find(strcmp(DK.contNames,contName));
                DK.contNames(contInd) = [];
                
                % Delete class dynamic property for that container
                contPropHandle = DK.findprop(contName);
                delete(contPropHandle)
                
            else
                error('No container with that name on Deck')
            end
        end
        
    end
    
end

