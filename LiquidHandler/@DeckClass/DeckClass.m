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
%         A1;A2;A3;B1;B2;B3;C1;C2;C3;D1;D2;D3;E1;E2;E3;CustSlot;
        
%         posMap = {'A1',B1;;;C1;C2;C3;D1;D2;D3;E1;E2;E3;CustSlot;
%                   'A2',B2;
%                   'A3',B3
%         LHouter
    end
    
    methods
        
        %% Constructor
        function DK = DeckClass%(LH)
            % Get File Path
            getFileName = mfilename('fullpath');
            DK.classPath = fileparts(getFileName);
            
%             if nargin == 1
%                 DK.LHouter = LH;
%             end
                
            
        end
        
        function addContainer(DK,contName,slotStr,contType)
            if ~isprop(DK,contName)
                DK.addprop(contName);
            end
            DK.(contName) = Container(contType,slotStr,contName);
%             eval(['DK.',slotStr,' = Container(''',contName,''');'])
            
        end
        
    end
    
end

