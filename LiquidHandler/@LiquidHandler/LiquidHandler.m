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
    
    methods
        
        %% Constructor
        function LH = LiquidHandler(SavedConfig)
            % Get File Path
            getFileName = mfilename('fullpath');
            LH.classPath = fileparts(getFileName);
            % Initalize Connection
            LH.Com = ComDriver;
            
            switch nargin
                case 0
                    % setting up config from raw
                    % Initalize Pipettes
                    LH.Head = Pipettes;
                    
                    % Initalize Deck
                    LH.Deck = DeckClass;
                case 1
                    % setting up from previous calibration
                    % Get Pipette Properties
                    LH.Head = SavedConfig.Head;
                    
                    % Get Deck Properties
                    LH.Deck = SavedConfig.Deck;
            end
            
        end
        
        %% Deconstructor 
        function delete(LH)
            
            delete(LH.Com)
        end
        
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
        
%         function connect(LH)
%             LH.Com = ComDriver;
%         end
    end
    
end

