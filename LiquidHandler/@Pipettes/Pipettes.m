classdef Pipettes < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Class file path
        classPath
        
        % table of possible pipette types
        pipetteParamTable %= table({'p1000';'p200';'p10';'multichannel'},...
%                                     [1000;200;10;300],[100;20;1;50],...
%                                     'VariableNames',{'Type','maxVol','minVol'})
                                
        % Left and Right pipette properties (structs)
        Left = struct('Type','','axis','B','isCalib',0,'top',NaN,...
                    'firstStop',NaN,'droptip',NaN,'tipPlunge',NaN,...
                    'maxVol',NaN,'minVol',NaN,'tipCont',{''})
        Right = struct('Type','','axis','A','isCalib',0,'top',NaN,...
                    'firstStop',NaN,'droptip',NaN,'tipPlunge',NaN,...
                    'maxVol',NaN,'minVol',NaN,'tipCont',{''})
        AxesLabel = {'Left','Right'};
    end
    
    methods
        
        %% Constructor
        function Head = Pipettes(headConfigImport,deckConfigImport)
            % Get File Path
            getFileName = mfilename('fullpath');
            Head.classPath = fileparts(getFileName); 
            
            % configure param table
            Head.pipetteParamTable = table({'p1000';'p200';'p10';'multichannel'},...
                                    [1000;200;10;300],[100;20;1;50],[6;6;6;6],...
                                    'VariableNames',{'Type','maxVol','minVol','tipPlunge'});
            Head.pipetteParamTable.Type = categorical(Head.pipetteParamTable.Type);
            
            if nargin>=1
                for k = 1:2
                    Axis = Head.AxesLabel{k};
                    Head.(Axis) = headConfigImport.(Axis);                    
                    if nargin == 2
                        tipContNames = headConfigImport.(Axis).tipCont;
                        validCounter = 0;
                        if ~iscell(tipContNames)
                            tipContNames = {tipContNames};
                        end
                        for m = 1:length(tipContNames)
                            if isprop(deckConfigImport,tipContNames{m})
                                validCounter = validCounter +1;
                            end
                        end
                        if validCounter ~= m
                            Head.(Axis).tipCont = {};
                        end
                    else
                        Head.(Axis).tipCont = {};
                    end
                end
                
            end
            
           
            
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

