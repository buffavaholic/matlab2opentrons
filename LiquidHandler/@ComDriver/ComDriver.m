classdef ComDriver < handle% < LiquidHandler.Driver
    % Version 0.1
    % Liquid Handler class to control the opentrons liquid handler
    % Created by Eric Greenwald - 05/09/16
    
    
    properties (Transient = true) % don't save to disk - ever...
        
        % Class file path
        classPath
        
        % Communication properties
        TCPobj
        connStat = false;
        clientID
        driverID
        
        % Message handling
        allMsg = cell(1,5);
        
        % Head position data
        x=NaN;
        y=NaN;
        z=NaN;
        a=NaN;
        b=NaN;
        
        % Deck properties
%         Deck 
        
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
        function Com = ComDriver
            % Get File Path
            getFileName = mfilename('fullpath');
            Com.classPath = fileparts(getFileName);
            
            % Initalize TCP connection
            Com.TCPobj=tcpip('10.10.1.2',7887,'NetworkRole','client','Terminator',{'LF/CR','LF/CR'});
            Com.TCPobj.OutputBufferSize = 400000;
            Com.TCPobj.InputBufferSize = 400000;
            Com.TCPobj.BytesAvailableFcn = @Com.msgInCallback;
            fopen(Com.TCPobj);
            
            
            
            % Wait until handshake complete
            while Com.connStat ~= 1
                fprintf('waiting to connect\n')
                
            end
            
            % Initalize Deck
%             Com.Deck = LiquidHandler.DeckClass(Com);
            
        end
        
        %% Deconstructor 
        function delete(Com)
            
            fclose(Com.TCPobj)
        end
        
        %% Send message 
        function sendMsg(Com,topic,to,type,name,message,param)
            if strcmp(to,'driver')
                to = Com.driverID;
                fprintf(Com.TCPobj,['{"topic":"',topic,'", "to":"',to,'","from":"',...
                Com.clientID,'","sessionID":"',Com.clientID,'","type":"',type,...
                '","data":{"name":"',name,'","message":{"',message,'":',param,'}}}']);
            end
%             fprintf(Com.TCPobj,['{"topic":"',topic,'", "to":"',to,'","from":"',...
%                 Com.clientID,'","sessionID":"',Com.clientID,'","type":"',type,...
%                 '","name":"',name,'","message":"',message,'","param":',param,'}']);
        end
        
        function recoverFromLock(Com)
            Com.sendMsg('driver','driver','command','smoothie','reset_from_halt','"true"')
            Com.homeAxis('XYZAB')
%             Com.sendMsg('driver','driver','command','smoothie','reset','"true"')
%             Com.sendMsg('driver','driver','command','smoothie','limit_switches','"true"')
%             Com.sendMsg('driver','driver','command','smoothie','unlock','"true"')
%             to = Com.driverID;
%                 fprintf(Com.TCPobj,['{"topic":"driver", "to":"',to,'","from":"',...
%                 Com.clientID,'","sessionID":"',Com.clientID,'","type":"command","data":{"name":"smoothie","message":"unlock"}}']);
        end
        
        function msgInCallback(Com,obj, event)

            callbackTime = datestr(datenum(event.Data.AbsTime));
            fprintf(['A ',event.Type,' event occurred for ',obj.Name, ' at ',callbackTime,'.\n']);
            
            data = fscanf(obj);
            dataCellStr = cellstr(data);
            fprintf('raw msg: %s \n',dataCellStr{1})
            Com.recordMSG(dataCellStr,callbackTime)
        end
        
        function recordMSG(Com, strIn,callbackTime)
            
            numEntries = length(Com.allMsg(:,1));
            if numEntries == 1 && isempty(Com.allMsg{1})
                numEntries = 0;
            end
            try                
                jsonData = loadjson(strIn{1});
                fromName = jsonData.from;
                toName = jsonData.to;
                typeName = jsonData.type;
                msgData = jsonData.data;
                Com.allMsg(numEntries+1,1:5) = {callbackTime,fromName,toName,typeName,msgData};
                if Com.connStat ~= 1 
                    if strcmp(typeName,'handshake')
                        if max(strcmp(msgData.message.result,{'success','already_connected'}))
                            Com.clientID = toName;
                            Com.driverID = fromName;
                            Com.connStat = 1;
                        else
                            Com.connStat = -1;
                        end
                        
                    end
                end
                
            catch
                Com.allMsg{numEntries+1,1} = callbackTime;
            end
        end
        
        
        
        function homeAxis(Com,axisStr)
            numAxis = length(axisStr);
            
            paramStr = '{';
            
            for k = 1:numAxis
                axisLabel = axisStr(k);
                switch axisLabel
                    case 'X'
                        Com.x = 0;
                    case 'Y'
                        Com.y = 0;
                    case 'Z'
                        Com.z = 0;
                    case 'A'
                        Com.a = 0;
                    case 'B'
                        Com.b = 0;
                end
                if k==numAxis
                    paramStr = [paramStr,'"',axisStr(k),'":"true"}'];
                else
                    paramStr = [paramStr,'"',axisStr(k),'":"true",'];
                end
            end
            
            Com.sendMsg('driver','driver','command','smoothie','home',paramStr)
        end
        
        function jogDir(Com,axisStr,dist)
            
            switch axisStr
                case 'X'
                    Com.x = Com.x + dist;
                case 'Y'
                    Com.y = Com.y + dist;
                case 'Z'
                    Com.z = Com.z + dist;
                case 'A'
                    Com.a = Com.a + dist;
                case 'B'
                    Com.b = Com.b + dist;
            end
            paramStr =  ['{"',axisStr,'":',num2str(dist),'}'];
            Com.sendMsg('driver','driver','command','smoothie','move',paramStr)
        end
        
        %% move in all directions given simultaneously
        function moveTo(Com,axisStr,pos)
            if max(isnan(pos))~=0
                error('Trying to send NaN coordinates...do not do')
            else
            numAxis = length(axisStr);
            if numAxis>1
                paramStr = '{';
                for k = 1:numAxis
                    axisLabel = axisStr(k);
                    switch axisLabel
                        case 'X'
                            Com.x = pos(k);
                        case 'Y'
                            Com.y = pos(k);
                        case 'Z'
                            Com.z = pos(k);
                        case 'A'
                            Com.a = pos(k);
                        case 'B'
                            Com.b = pos(k);
                    end
                    if k==numAxis
                        paramStr = [paramStr,'"',axisStr(k),'":',num2str(pos(k)),'}'];
                    else
                        paramStr = [paramStr,'"',axisStr(k),'":',num2str(pos(k)),','];
                    end
                end
            else
                axisLabel = axisStr;
                    switch axisLabel
                        case 'X'
                            Com.x = pos;
                        case 'Y'
                            Com.y = pos;
                        case 'Z'
                            Com.z = pos;
                        case 'A'
                            Com.a = pos;
                        case 'B'
                            Com.b = pos;
                    end
                paramStr =  ['{"',axisStr,'":',num2str(pos),'}'];
            end
            
            Com.sendMsg('driver','driver','command','smoothie','move_to',paramStr)
            end
        end
        
        %% move while going all the way to zero on Z first
        function moveToZzero(Com,axisStr,pos)
            numAxis = length(axisStr);
            currX = Com.x;
            currY = Com.y;
            currZ = Com.z;
            if isempty(strfind(axisStr,'X'))
                newX = currX;
            end
            if isempty(strfind(axisStr,'Y'))
                newY = currY;
            end
            if isempty(strfind(axisStr,'Z'))
                newZ = currZ;
            end
            %             if numAxis>1
            Com.moveTo('Z',0)
%             pause(2)
            paramStr = '{';
            for k = 1:numAxis
                axisLabel = axisStr(k);
                switch axisLabel
                    case 'X'
                        newX = pos(k);
                        skipMove = 0;
                    case 'Y'
                        newY = pos(k);
                        skipMove = 0;
                    case 'Z'
                        newZ = pos(k);
                        skipMove = 1;
%                     case 'A'
%                         Com.a = pos(k);
%                     case 'B'
%                         Com.b = pos(k);
                end
                if skipMove ~=1
                if k==1%numAxis
                    paramStr = [paramStr,'"',axisStr(k),'":',num2str(pos(k))];
                else
                    paramStr = [paramStr,', "',axisStr(k),'":',num2str(pos(k)),','];
                end
                end
            end
            paramStr = [paramStr,'}'];
            
            Com.moveTo('XY',[newX,newY])
%             pause(2)
            
            Com.moveTo('Z',newZ)
%             pause(2)
%             else
%                 paramStr =  ['{"',axisStr,'":',num2str(pos),'}'];
%             end
            
%             Com.sendMsg('driver','driver','command','smoothie','move_to',paramStr)
        end
        
        function moveToZheight(Com,axisStr,pos,height)
            numAxis = length(axisStr);
            currX = Com.x;
            currY = Com.y;
            currZ = Com.z;
            if isempty(strfind(axisStr,'X'))
                newX = currX;
            end
            if isempty(strfind(axisStr,'Y'))
                newY = currY;
            end
            if isempty(strfind(axisStr,'Z'))
                newZ = currZ;
            end
            %             if numAxis>1
            Com.moveTo('Z',height)
%             pause(2)
            paramStr = '{';
            for k = 1:numAxis
                axisLabel = axisStr(k);
                switch axisLabel
                    case 'X'
                        newX = pos(k);
                        skipMove = 0;
                    case 'Y'
                        newY = pos(k);
                        skipMove = 0;
                    case 'Z'
                        newZ = pos(k);
                        skipMove = 1;
%                     case 'A'
%                         Com.a = pos(k);
%                     case 'B'
%                         Com.b = pos(k);
                end
                if skipMove ~=1
                if k==1%numAxis
                    paramStr = [paramStr,'"',axisStr(k),'":',num2str(pos(k))];
                else
                    paramStr = [paramStr,', "',axisStr(k),'":',num2str(pos(k)),','];
                end
                end
            end
            paramStr = [paramStr,'}'];
            
            Com.moveTo('XY',[newX,newY])
%             pause(2)
            
            Com.moveTo('Z',newZ)
%             pause(2)
%             else
%                 paramStr =  ['{"',axisStr,'":',num2str(pos),'}'];
%             end
            
%             Com.sendMsg('driver','driver','command','smoothie','move_to',paramStr)
        end
        
        
    end
        
    
end
    
    
    
