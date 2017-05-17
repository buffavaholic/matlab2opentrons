function varargout = DeckGUI(varargin)
% DECKGUI MATLAB code for DeckGUI.fig
%      DECKGUI, by itself, creates a new DECKGUI or raises the existing
%      singleton*.
%
%      H = DECKGUI returns the handle to a new DECKGUI or the handle to
%      the existing singleton*.
%
%      DECKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DECKGUI.M with the given input arguments.
%
%      DECKGUI('Property','Value',...) creates a new DECKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DeckGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DeckGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DeckGUI

% Last Modified by GUIDE v2.5 12-May-2017 16:11:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DeckGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DeckGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DeckGUI is made visible.
function DeckGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DeckGUI (see VARARGIN)

% Choose default command line output for DeckGUI
handles.output = hObject;

% Get opentrons pointers

handles.OT = varargin{1};
handles.robot = handles.OT.robot;
handles.deck = handles.robot.deck;

% Pre-allocate pipette axis struct fields for dynamic reference
handles.A.name = 'A';
handles.B.name = 'B';

% get the deck slots
handles.deckSlots = struct(handles.robot.deck.children_by_name);

% get field names 
handles.deckSlotNames = fieldnames(handles.deckSlots);

% plot handles table var names
handles.tableVarNames = {'name','type','selfPointer','parName','parType','parPointer','originCoord','poly','plotH'};


% Extract slot sizes
slotProp = struct(handles.deckSlots.A1.properties);
slWidth = double(slotProp.width);
slLength = double(slotProp.length);
handles.slWidth = slWidth;
handles.slLength = slLength;
% Get Slot coordinates
minX = 10^8;
maxX = 0;
minY = 10^8;
maxY = 0;
for k = 1:length(handles.deckSlotNames)
    slotVectPos = handles.deckSlots.(handles.deckSlotNames{k}).coordinates(handles.deck);
    slotTuplePos = slotVectPos.to_tuple;
    slotPos = [double(slotTuplePos.x), double(slotTuplePos.y), double(slotTuplePos.z)];
    handles.deckSlotCoord.(handles.deckSlotNames{k}) = slotPos;
    
    slotEdge = [slotPos(1)+slWidth,slotPos(2)+slLength];
    rectVerts = [slotPos(1),slotPos(2);...
                slotEdge(1),slotPos(2);...
                slotEdge(1),slotEdge(2);...
                slotPos(1),slotEdge(2);...
                slotPos(1),slotPos(2)];
    handles.plotPolys.(handles.deckSlotNames{k}) = rectVerts;
    
    hold on;
    slH = plot(handles.deckAxis,rectVerts(:,1),rectVerts(:,2),'b');
    
    % save plot handles
    plotCell = {handles.deckSlotNames{k},'slot',{handles.deckSlots.(handles.deckSlotNames{k})},'deck','deck',{handles.deck},slotPos,rectVerts,slH};
    tableRow = cell2table(plotCell,'VariableNames',handles.tableVarNames);
    if k == 1        
        handles.deckTable = tableRow;
        handles.deckTable.type = categorical(handles.deckTable.type);
        handles.deckTable.parType = categorical(handles.deckTable.parType);
    else
        handles.deckTable = [handles.deckTable;tableRow];
    end
    
    halfXall(k) = slotPos(1)+slWidth/2;
    halfYall(k) = slotPos(2)+slLength/2;
    
    if slotPos(1)<minX
        minX = slotPos(1);
    end
    if slotPos(2)<minY
        minY = slotPos(2);
    end
    if slotEdge(1)>maxX
        maxX = slotEdge(1);
    end
    if slotEdge(2)>maxY
        maxY = slotEdge(2);
    end
    
    
end

% Get axes ticks
[uniqueX,uniqueXi,~] = unique(halfXall);
[uniqueY,uniqueYi,~] = unique(halfYall);

for m = 1:length(uniqueXi)
    slotStr = handles.deckSlotNames{uniqueXi(m)};    
    xStr{m} = slotStr(1);
end
for m = 1:length(uniqueYi)
    slotStr = handles.deckSlotNames{uniqueYi(m)};    
    yStr{m} = slotStr(2);
end

% Change axes ticks and labels
handles.deckAxis.XTick = uniqueX;
handles.deckAxis.XTickLabel = xStr;
handles.deckAxis.YTick = uniqueY;
handles.deckAxis.YTickLabel = yStr;
handles.deckAxis.TickDir = 'out';

% Adjust axis size
[minX,maxX]
[minY,maxY]
handles.deckAxis.XLim = [minX,maxX];
handles.deckAxis.YLim = [minY,maxY];
axis(handles.deckAxis,'equal');
axis(handles.deckAxis,'tight');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DeckGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DeckGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selPosButton.
function selPosButton_Callback(hObject, eventdata, handles)
% hObject    handle to selPosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.posSelText.String = {'Click well  or ';'slot to select'};

if isfield(handles,'selInd')
    handles.selInd = [];
end
    
[deckX,deckY]=ginput(1);

% nonSlots = find(handles.deckTable.type ~= 'slot');

tablePolys = handles.deckTable.poly;

nRows = height(handles.deckTable);

matchCounter = 0;

for k = 1:nRows
    polyIn = tablePolys{k};
    if inpolygon(deckX,deckY,polyIn(:,1),polyIn(:,2))
        matchCounter = matchCounter + 1;
        
        matchInds(matchCounter) = k;
    end
end

if matchCounter == 1 
    if handles.deckTable.type(matchInds(1))=='slot'
%         fprintf('Clicked on slot %s\n',handles.deckTable.name{matchInds(1)});
        handles = highlightPoly(handles,'slot',handles.deckTable.poly{matchInds(1)});
        handles.posSelText.String = ['Slot ',handles.deckTable.name{matchInds(1)}];
        handles.selInd = matchInds(1);
    else
        error('Matched some polygon but not inside of a slot, try again.');
    end
elseif matchCounter == 2
    nonSlot = find(handles.deckTable.type(matchInds)~='slot');
    
    if length(nonSlot) == 1
%         fprintf('Clicked on well %s in container %s\n', ...
%             handles.deckTable.name{matchInds(nonSlot)},...
%             handles.deckTable.parName{matchInds(nonSlot)})
        handles = highlightPoly(handles,'well',handles.deckTable.poly{matchInds(nonSlot)});
        handles.posSelText.String = {['Well - ',handles.deckTable.name{matchInds(nonSlot)}];['Container - ',handles.deckTable.parName{matchInds(nonSlot)}]};
        handles.selInd = matchInds(nonSlot);
    elseif length(nonSlot) == 2
        error('Only matched 2 wells and no slot, try again.')
    else
        error('Only matched 2 slots and no wells, try again.')
    end
elseif matchCounter == 0 || matchCounter >2
    error('Either matched no polygons or matched more than one well and one slot')    
end

% Update handles structure
guidata(hObject, handles);
    
function handlesOut = highlightPoly(guiHandles,type,poly)
    % Highlight the selected polygon
    
    % clear previous patch
    if isfield(guiHandles,'hlPatch')
        delete(guiHandles.hlPatch);
        guiHandles.hlPatch = [];
    end
    
    switch type
        case 'slot'
            patchH = patch(poly(:,1),poly(:,2),'b','Parent',guiHandles.deckAxis,'FaceAlpha',0.8);
        case 'well'
            patchH = patch(poly(:,1),poly(:,2),'r','Parent',guiHandles.deckAxis,'FaceAlpha',0.8);
    end
    
    uistack(patchH,'bottom');
    guiHandles.hlPatch = patchH;
    
    handlesOut = guiHandles;
        
    

% Update filled deck slots
function handlesOut = updateDeckContainers(handles)

% Clear all the current plots off the deck
nonSlotRows = find(handles.deckTable.type ~= 'slot');
for j = 1:length(nonSlotRows)
    
    % delete previous well plots
    delete(handles.deckTable.plotH(nonSlotRows(j)))
end
if ~isempty(nonSlotRows)
    handles.deckTable(nonSlotRows,:) = [];
end

if isfield(handles,'hlPatch')
    delete(handles.hlPatch);
    handles.hlPatch = [];
end

% Get the containers on the deck
allCont = struct(handles.deck.containers);

contNames = fieldnames(allCont);
tableCell = {};
tableCellCounter = 0;

if ~isempty(handles.OT.axisA)
    NextTipWellA = handles.OT.axisA.pypette.get_next_tip;
    if ~isempty(NextTipWellA)
        handles.OT.axisA.pypette.start_at_tip(NextTipWellA);
    end
else
    NextTipWellA = [];
end

if ~isempty(handles.OT.axisB)
    NextTipWellB = handles.OT.axisB.pypette.get_next_tip;
    if ~isempty(NextTipWellB)
        handles.OT.axisB.pypette.start_at_tip(NextTipWellB);
    end
else
    NextTipWellB = [];
end

for k = 1:length(contNames)
%     tic
    cont = allCont.(contNames{k});
    
    contChil = struct(cont.children_by_name);
    contChilNames = fieldnames(contChil);
    
    contSubProp.name = {};
    contSubProp.x = [];
    contSubProp.y = [];
    contSubProp.r = [];
%     toc
%     tic
    for m = 1:length(contChilNames)
        well = contChil.(contChilNames{m});
        
%         coords = well.coordinates(handles.deck).to_tuple;
% %         props = struct(well.properties);
%         
%         x = double(coords.x);
%         y = double(coords.y);
        r = double(well.properties{'diameter'})/2;
        
        if r == 0 
            r = handles.slWidth/4;
        end
        
%         relCoords = well.coordinates(cont).to_tuple;
        relCoords = well.from_center(pyargs('x',0,'y',0,'z',-1,'reference',cont)).to_tuple;
        contSubProp.name{m} = contChilNames{m};
        contSubProp.x(m) = double(relCoords.x);
        contSubProp.y(m) = double(relCoords.y);
        contSubProp.z(m) = double(relCoords.z);
        contSubProp.r(m) = r;
        
        
            
%         % Plot the well
%         hold on
%         th = 0:pi/50:2*pi;
%         xunit = r * cos(th) + x;
%         yunit = r * sin(th) + y;
%         h = plot(handles.deckAxis,xunit, yunit,'g');
%         hold off
        
        
    end
%     toc
%     tic
    % Get container center
    
    contMinX = min(contSubProp.x);
    contMaxX = max(contSubProp.x);
    contMinY = min(contSubProp.y);
    contMaxY = max(contSubProp.y);
    
    contCenter = [(contMinX +contMaxX)/2,(contMinY +contMaxY)/2];
    
    contSubProp.rel_x = contSubProp.x - contCenter(1);
    contSubProp.rel_y = contSubProp.y - contCenter(2);
    % Get parent slot location
    parSlot = cont.get_parent;
    
    parCoord = parSlot.coordinates(handles.deck).to_tuple;
    
    parCenter = [double(parCoord.x)+handles.slWidth/2, double(parCoord.y)+handles.slLength/2];
    
    % get shifted coordinates relative to slot center
    
    contSubProp.centered_x = contSubProp.rel_x + parCenter(1);
    contSubProp.centered_y = contSubProp.rel_y + parCenter(2);
    
%     toc
    tic
    for m = 1:length(contChilNames)
%         tic
        hold on
        th = 0:pi/50:2*pi;
        well_r = contSubProp.r(m);
        xunit = well_r * cos(th) + contSubProp.centered_x(m);
        yunit = well_r * sin(th) + contSubProp.centered_y(m);
        h = plot(handles.deckAxis,xunit, yunit,'Color',[0 .75 0],'LineWidth',1.5);
%         hold off
%         toc
%         tic
        plotCell = {contChilNames{m},'well',{contChil.(contChilNames{m})},contNames{k},'container',{cont},[contSubProp.x(m),contSubProp.y(m),contSubProp.z(m)],[xunit',yunit'],h};
        tableCellCounter = tableCellCounter +1;
        tableCell(tableCellCounter,:) = plotCell;
        
        if ~isempty(NextTipWellA)
            if NextTipWellA == contChil.(contChilNames{m})
                hpt = plot(handles.deckAxis,contSubProp.centered_x(m), contSubProp.centered_y(m),'*r');
                plotCell = {'startTipA','tip',{},contChilNames{m},'well',{contChil.(contChilNames{m})},[contSubProp.centered_x(m),contSubProp.centered_y(m),0],[contSubProp.centered_x(m),contSubProp.centered_y(m)],hpt};
                tableCellCounter = tableCellCounter +1;
                tableCell(tableCellCounter,:) = plotCell;
            end
        end
        
        if ~isempty(NextTipWellB)
            if NextTipWellB == contChil.(contChilNames{m})
                hpt = plot(handles.deckAxis,contSubProp.centered_x(m), contSubProp.centered_y(m),'*b');
                plotCell = {'startTipB','tip',{},contChilNames{m},'well',{contChil.(contChilNames{m})},[contSubProp.centered_x(m),contSubProp.centered_y(m),0],[contSubProp.centered_x(m),contSubProp.centered_y(m)],hpt};
                tableCellCounter = tableCellCounter +1;
                tableCell(tableCellCounter,:) = plotCell;
            end
        end
%         tableRow = cell2table(plotCell,'VariableNames',handles.tableVarNames);
%         handles.deckTable = [handles.deckTable;tableRow];
%         toc
    end
    toc
    
end
if ~isempty(tableCell)
    tableRow = cell2table(tableCell,'VariableNames',handles.tableVarNames);
    handles.deckTable = [handles.deckTable;tableRow];
end

handlesOut = handles;


% --- Executes on button press in updateDeckButton.
function updateDeckButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateDeckButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = updateDeckContainers(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in calibratePosButton.
function calibratePosButton_Callback(hObject, eventdata, handles)
% hObject    handle to calibratePosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'selInd')
    errordlg('You must select a valid position first using the ''Select Position'' button first');
else
    if isempty(handles.selInd)
        errordlg('You must select a valid position first using the ''Select Position'' button first');
    else
        ind = handles.selInd;
        % Get what type was selected from the deckTable
        selType = handles.deckTable.type(ind);
        
        if selType == 'well'
            % Get the container pointer;
            contPointer = handles.deckTable.parPointer{ind};
            % Get the well name
            wellName = handles.deckTable.name{ind};
            
            % Get which pipette is selected
            handles = updatePipetteList(handles);

            if get(handles.rightPipButton,'Value')
                axisID = 'axisA';
%                 robotAxis = 'a';
            else
                axisID = 'axisB';
                robotAxis = 'b';
            end
            
%             plunger position string (for easier replication)
%             plungerPosStr = 'bottom';

            % Check if pipette is set
%             if isfield(handles.(axisID),'pointer')
            if ~isempty(handles.OT.(axisID))
                
                % Calibrate position using current position
                handles.OT.(axisID).calibrate_position(contPointer,wellName);
%                 % Check if the calibrated position is numeric 
%                 if isnumeric(handles.(axisID).pos.(plungerPosStr))
%                     % Passed checks move plunger position
%                     posLoc = handles.(axisID).pos.(plungerPosStr);
%                     handles.OT.move_plunger(pyargs(robotAxis,posLoc));    
%                 else
%                     errordlg('Plunger position for this location and pipette need to be calibrated first.');
%                 end
            else
                % if a pipette isnt set then cant move it.
                errordlg('Cannot move position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
            end

        else
            errordlg('Cannot calibrate deck slot, please select well')
        end
        
    end
    
end

% p200.calibrate_position(tubeRack,'A1')

% --- Executes on selection change in zPosList.
function zPosList_Callback(hObject, eventdata, handles)
% hObject    handle to zPosList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns zPosList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from zPosList


% --- Executes during object creation, after setting all properties.
function zPosList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zPosList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in move2selButton.
function move2selButton_Callback(hObject, eventdata, handles)
% hObject    handle to move2selButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'selInd')
    errordlg('You must select a valid position first using the ''Select Position'' button first');
else
    if isempty(handles.selInd)
        errordlg('You must select a valid position first using the ''Select Position'' button first');
    else
        ind = handles.selInd;
        % Get what type was selected from the deckTable
        selType = handles.deckTable.type(ind);
        
        if selType == 'well'
            % Get the container pointer;
            contPointer = handles.deckTable.parPointer{ind};
            % Get the well name
            wellName = handles.deckTable.name{ind};
            wellPointer = handles.deckTable.selfPointer{ind};
            wellPointer = wellPointer{:};
            % Get which pipette is selected
            handles = updatePipetteList(handles);

            if get(handles.rightPipButton,'Value')
                axisID = 'axisA';
%                 robotAxis = 'a';
            else
                axisID = 'axisB';
                robotAxis = 'b';
            end
            
%             plunger position string (for easier replication)
%             plungerPosStr = 'bottom';
            
            contents = cellstr(get(handles.zPosList,'String')) ;
            strLoc = contents{get(handles.zPosList,'Value')} ;
            % Check if pipette is set
%             if isfield(handles.(axisID),'pointer')
            if ~isempty(handles.OT.(axisID))
                
                switch strLoc
                    case 'Bottom'
                        % move to bottom of selected well
                        handles.OT.(axisID).move_to(wellPointer.bottom,'queuing','Now');
                    case 'Top'
                        handles.OT.(axisID).move_to(py.tuple({wellPointer,wellPointer.from_center(pyargs('x',0,'y',0,'z',1))}),'queuing','Now');
                    case 'Center'
                        handles.OT.(axisID).move_to(py.tuple({wellPointer,wellPointer.from_center(pyargs('x',0,'y',0,'z',0))}),'queuing','Now');
                end
%                 % Check if the calibrated position is numeric 
%                 if isnumeric(handles.(axisID).pos.(plungerPosStr))
%                     % Passed checks move plunger position
%                     posLoc = handles.(axisID).pos.(plungerPosStr);
%                     handles.OT.move_plunger(pyargs(robotAxis,posLoc));    
%                 else
%                     errordlg('Plunger position for this location and pipette need to be calibrated first.');
%                 end
            else
                % if a pipette isnt set then cant move it.
                errordlg('Cannot move position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
            end

        else
            errordlg('Cannot calibrate deck slot, please select well')
        end
        
    end
    
end


% Check for and update pointers to connected pipettes
function handles = updatePipetteList(handles)

instruments = handles.robot.get_instruments();
setAflag = 0;
setBflag = 0;
for k = 1:length(instruments)
    axisID = char(instruments{k}{1});
    pipettePointer = instruments{k}{2};
    try
        handles.(axisID).pointer = pipettePointer;
        handles.(axisID).pos = struct(handles.(axisID).pointer.positions);
        if axisID == 'A'
            %         handles.PipetteA = pipettePointer;
            setAflag = 1;
        elseif axisID == 'B'
            %         handles.PipetteB = pipettePointer;
            setBflag = 1;
        end
    catch
        error('parsing instruments issue')
    end
    
end

if setAflag == 0;
    if isfield(handles.A,'pointer')
        handles.A = rmfield(handles.A,'pointer');
    end
    if isfield(handles.A,'pos')
        handles.A = rmfield(handles.A,'pos');
    end
end
if setBflag == 0;
    if isfield(handles.B,'pointer')
        handles.B = rmfield(handles.B,'pointer');
    end
    if isfield(handles.B,'pos')
        handles.B = rmfield(handles.B,'pos');
    end
end