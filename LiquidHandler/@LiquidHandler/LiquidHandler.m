classdef LiquidHandler < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Class file path
        classPath
        % Sub classes to populate
        Com
        Head
        Deck
        
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
        function LH = LiquidHandler(SavedConfigHead,SavedConfigDeck)
            % Get File Path
            getFileName = mfilename('fullpath');
            LH.classPath = fileparts(getFileName);
            % Initalize Connection
%             LH.Com = ComDriver;
            

            switch nargin
                case 0
%                     % setting up config from raw
%                     % Initalize Pipettes
%                     LH.Head = Pipettes;
%                     
%                     % Initalize Deck
%                     LH.Deck = DeckClass;
%                 case 1
%                     % setting up from previous calibration
%                     % Get Pipette Properties
%                     LH.Head = Pipettes(SavedConfigHead);
%                     
%                     % Get Deck Properties
%                     LH.Deck = DeckClass ;
%                  case 2
%                     % setting up from previous calibration
%                     % Get Pipette Properties
%                     LH.Head = Pipettes(SavedConfigHead,SavedConfigDeck);
%                     
%                     % Get Deck Properties
%                     LH.Deck = SavedConfigDeck;
            end
            
        end
        
        %% Deconstructor 
        function delete(LH)
            
            delete(LH.Com)
        end
        
        function saveConfig(LH)
            oldHead = LH.Head;
            oldDeck = LH.Deck;
            save([LH.classPath,'\savedConfig.mat'],'oldHead','oldDeck')
        end
%         function connect(LH)
%             LH.Com = ComDriver;
%         end
        
        function ejectLiq(LH,Axis,rpt)
            if nargin<3
                rpt = 1;
            end
            fs = LH.Head.(Axis).firstStop;
            dt = LH.Head.(Axis).droptip;
            top = LH.Head.(Axis).top;
            blowoutPos = fs+.33*(dt-fs);
            
            for k = 1:rpt
                LH.Com.moveTo(LH.Head.(Axis).axis,blowoutPos)
                LH.Com.moveTo(LH.Head.(Axis).axis,fs-.25*(fs-top))
            end
            
            LH.Com.moveTo(LH.Head.(Axis).axis,blowoutPos)
            
        end
        
        %% function used to test volume calibration
        function testPickupVol(LH,Axis,vol)
            maxVol = LH.Head.(Axis).maxVol;
            minVol = LH.Head.(Axis).minVol;
            if vol>maxVol || vol <minVol
                error('volume out of pipette range')
            else
                baseZ = LH.Com.z;
                newZ = baseZ -20;
                if newZ<0
                    newZ = 0;
                end
                
                % leave liquid and clear out anything in it
                LH.Com.moveTo('Z',newZ)
                LH.ejectLiq(Axis)
                
                % calculate piston height for volume
                
                top = LH.Head.(Axis).top;
                fs = LH.Head.(Axis).firstStop;
                volPos = fs - (vol/maxVol)*(fs-top);
                LH.Com.moveTo(LH.Head.(Axis).axis,fs)
                pause(2)
                
                % move back down into liquid
                LH.Com.moveTo('Z',baseZ)
                pause(2)
                
                %pick up liquid
                LH.Com.moveTo(LH.Head.(Axis).axis,volPos)
            end
            
        end
        
        function setTipContainer(LH,Axis,contName)
            LH.Head.setTipCont(Axis,contName)
            LH.Deck.(contName).tipAxis = Axis;
            LH.Deck.(contName).setTipLoc(1)
        end
        
        function pickUpTip(LH,Axis)
            plungeDepth = LH.Head.(Axis).tipPlunge;
            if ~isnan(plungeDepth)
                LH.Com.jogDir('Z',plungeDepth)
                LH.Com.jogDir('Z',-plungeDepth)
                LH.Com.jogDir('Z',plungeDepth)
                LH.Com.jogDir('Z',-plungeDepth)
            else
                fprintf('set pipette type to axis first')                
            end
        end
        
        function getNextTip(LH,Axis)
            tipCont = LH.Head.(Axis).tipCont{1};
            if ~strcmp(tipCont,'')
                availTipLoc = LH.Deck.(tipCont).tipLoc;
                tipPos = LH.Deck.(tipCont).get_rel_child_coord(availTipLoc,Axis);
                if max(isnan(tipPos))==0
                    LH.Com.moveToZzero('XYZ',tipPos);
                    LH.pickUpTip(Axis)
                    LH.Deck.(tipCont).useTip;
                end
            end
            
        end
        
        function moveToCalib(LH,Axis,cont)
            % get deck slot
            contSlot = LH.Deck.(cont).slot;
            slotInds = LH.str2inds(contSlot);
            cornerCoord = LH.Deck.cornerCoords{slotInds(1),slotInds(2)};
            if strcmp(Axis,'Right')
                cornerCoord = cornerCoord+LH.Deck.centPipetteOffset;
            end
            % if a1 offset is defined, move to that location instead of
            % deck junction
            a1_x = LH.Deck.(cont).props.a1_x;
            a1_y = LH.Deck.(cont).props.a1_y;
            cornerCoord(1) = cornerCoord(1)+ a1_x;
            cornerCoord(2) = cornerCoord(2)- a1_y;
            cornerCoord(3) = 0;
            LH.Com.moveToZzero('XYZ',cornerCoord);
            
            
        end
        
        function trashTip(LH,Axis)
            
            % Move to trash location
            trashName = LH.Deck.trashCont;
            if isprop(LH.Deck,trashName)
                trashCoord =LH.Deck.(trashName).get_rel_child_coord('A1',Axis);
                LH.Com.moveToZzero('XYZ',trashCoord);
                
                % check if pipette is calibrated
                LH.Head.checkIfCalibrated(Axis)
                if LH.Head.(Axis).isCalib
                    pipetteAxis = LH.Head.(Axis).axis;
                    dropTipPos = LH.Head.(Axis).droptip;
                    fsPos = LH.Head.(Axis).firstStop;
                    topPos = LH.Head.(Axis).top;
                
%                 if ~isnan(dropTipPos) && ~isnan(fsPos)&& ~isnan(topPos)
                    LH.Com.moveTo(pipetteAxis,dropTipPos);
                    LH.Com.moveTo(pipetteAxis,fsPos);
                    LH.Com.moveTo(pipetteAxis,dropTipPos);
                    LH.Com.moveTo(pipetteAxis,topPos);
                else
                    error('Calibrate pipette positions first')
                end
               
                
            else
                error('Trash container not defined')
            end
            
            
            
        end
        
        function transfer(LH,Axis,vol,fromCont,fromWell,toCont,toWell)
            % Pick up a tip
            LH.getNextTip(Axis)
            
            % move to "from" container
            fromWellCoord = LH.Deck.(fromCont).get_rel_child_coord(fromWell,Axis);
            LH.Com.moveToZzero('XYZ',fromWellCoord);
            
            % pick up liquid
            LH.testPickupVol(Axis,vol)
            
            % move to "to" container
            toWellCoord = LH.Deck.(toCont).get_rel_child_coord(toWell,Axis);
            LH.Com.moveToZzero('XYZ',toWellCoord);
            
            % Eject liquid
            LH.ejectLiq(Axis,1)
            
            % Dump the tip
            LH.trashTip(Axis)
            
        end
        

    end
    
end

