classdef Container < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Class file path
        classPath
        
        contParamTable;% = readtable('contParam.csv');
%         contParamTable.contName = categorical(contParamTable.contName);
%         contParamTable.type = categorical(contParamTable.type);

        % properties of chosen container
        props
%         name
%         type
%         nRows
%         nCols
%         a1_x
%         a1_y
%         spacing
%         diameter
%         zHeight
%         well_depth
%         volume
%         min_vol
%         max_vol
%         custom

        calibLeft = [NaN,NaN,NaN];
        calibRight = [NaN,NaN,NaN];
        
        isCalibLeft = 0;
        isCalibRight =0;
        
        % Keep track of tips if tiprack
        tipInd = NaN;
        tipLoc
        tipAxis = '';
        
        % deck slot
        slot
        
        % record name used in deck to refer to this container
        refName
        
        
        
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
        function Cont = Container(nameIn,slot,refName,newVarArray)
            
            % Get File Path
            getFileName = mfilename('fullpath');
            Cont.classPath = fileparts(getFileName);
            
            Cont.contParamTable = readtable([Cont.classPath,'\contParam.csv']);
            Cont.contParamTable.contName = categorical(Cont.contParamTable.contName);
            Cont.contParamTable.type = categorical(Cont.contParamTable.type);
            
            paramRow = Cont.contParamTable.contName == nameIn;
            if sum(paramRow)==0
                fprintf('No container with that name... adding new container')
                Cont.addContType(newVarArray)
                Cont.props = table2struct(Cont.contParamTable(end,:));
            elseif sum(paramRow)==1
                Cont.props = table2struct(Cont.contParamTable(paramRow,:));
            else
                error('More than one container with that name...somehow...')
            end
            
            if strcmp(char(Cont.props.type),'tiprack')
                Cont.tipInd = 1;
                Cont.setTipLoc(Cont.tipInd);
            end
            
            Cont.slot = slot;
            Cont.refName = refName;
            
            
            
            
        end
        
        % tool to generate string of position
        function str = inds2str(Cont,ind)
            alph = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            if strcmp(Cont.tipAxis,'Right')
                rowNum = num2str(floor((ind-0.5)/Cont.props.nCols)+1,'%u');
                colInd = mod(ind,Cont.props.nCols);
                if colInd == 0
                    colInd = Cont.props.nCols;
                end
                str = [alph(colInd),rowNum];
            elseif strcmp(Cont.tipAxis,'Left')
                rowNum = num2str(floor((ind-.5)/Cont.props.nCols)+1,'%u');
                colInd = Cont.props.nCols-mod(ind,Cont.props.nCols)+1;
                if colInd == Cont.props.nCols+1
                    colInd = 1;
                end
                str = [alph(colInd),rowNum];
            else
                str='';
            end
        end
        
        function addContType(Cont,varArray)
            
            % Template cell Array
%             varArray = {'contName'  ,   ;
%                         'type'      ,   ;
%                         'nRows'     ,   ;
%                         'nCols'     ,   ;
%                         'a1_x'      ,   ;
%                         'a1_y'      ,   ;
%                         'spacing'   ,   ;
%                         'diameter'  ,   ;
%                         'height'    ,   ;
%                         'well_depth',   ;
%                         'volume'    ,   ;
%                         'min_vol'   ,   ;
%                         'max_vol'   ,   ;
%                         'custom'    ,  '{none}'  };
            % must have all variables, and if no custom just add '{none}'
            
             newRow = cell2table(varArray(:,2)','VariableNames',varArray(:,1)');
             
             if ismember(newRow.contName,Cont.contParamTable.contName)
                fprintf('Container name already exists: choose another name \n')
             else
                 Cont.contParamTable = [Cont.contParamTable;newRow];
                 writetable(Cont.contParamTable,[Cont.classPath,'\contParam.csv'])
             end
        end
        
        %% Define Calibration
        % these coordinates are now relative to robot home
        
        function calibrate(Cont,pos,pipette)
            if strcmp(pipette,'Left')
                Cont.calibLeft = pos; 
                Cont.isCalibLeft=1;
            elseif strcmp(pipette,'Right')
                Cont.calibRight = pos; 
                Cont.isCalibRight=1;
            end
        end
        
        function coord = get_rel_child_coord(Cont,wellStr,pipette)
            wellInd = Cont.str2inds(wellStr);%[y dir, x dir]
            xWellInd = wellInd(2);
            yWellInd = wellInd(1);
            if yWellInd>Cont.props.nRows || xWellInd>Cont.props.nCols
                fprintf('No well at that position for this plate! \n')
                coord = [NaN,NaN,NaN];
            else
                switch pipette
                    case 'Left'
                        isCalib = Cont.isCalibLeft;
                        calib = Cont.calibLeft;
                    case 'Right'
                        isCalib = Cont.isCalibRight;
                        calib = Cont.calibRight;
                end
                if isCalib
                    coord = calib;
                    if ~isstruct(Cont.props.custom)
                        % standard spaced container
                    coord(1) = coord(1) + (xWellInd-1)*Cont.props.spacing; %x direction is also positive relative to the head
                    coord(2) = coord(2) - (yWellInd-1)*Cont.props.spacing;
                    else
                        % custom defined well coordinates
                        try
                            xWellLoc = Cont.props.custom.(wellStr).x;
                            yWellLoc = Cont.props.custom.(wellStr).y;
                            coord(1) = coord(1) + xWellLoc; %x direction is also positive relative to the head
                            coord(2) = coord(2) - yWellLoc;
                        catch
                            error('Custom well not defined correctly')
                        end
                        
                            
                            
                        
                    end
                else
                    fprintf('Container has not been calibrated! \n')
                    coord = [NaN,NaN,NaN];
                end
            end
            
            
        end
        
        % set tip well
        function setTipLoc(Cont,tipInd)
           Cont.tipInd = tipInd;
           Cont.tipLoc = Cont.inds2str(tipInd);
        end
        
        function useTip(Cont)
            if ~isnan(Cont.tipInd)
               Cont.tipInd = Cont.tipInd+1;
               Cont.tipLoc = Cont.inds2str(Cont.tipInd);
            else
                error('Not a tip type')
            end
        end
    end
    
end

