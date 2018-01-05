% Test fancy gui
function fig = OTcontrol(OT)
% function testFancyGUI()

handles.OT = OT;
pycomPorts = cell(handles.OT.robot.get_serial_ports_list());
handles.InitComPorts = cellfun(@char,pycomPorts,'UniformOutput',0);
% unifiy font sizes
bigFont = 12;
normFont = 10;
% Create the window and main layout
fig = figure( 'Name', 'OpenTrons Control GUI', ...'
    'NumberTitle', 'off', ...
    'Toolbar', 'none', ...
    'MenuBar', 'none', ...
    'CloseRequestFcn', @nCloseAll );



fig.Units = 'normalized';
fig.Position = [0.1 0.05 .8 .9];
box = uix.HBox( 'Parent', fig );

% Add three panels to the box
panel{1} = uix.BoxPanel( 'Title', 'Deck', 'Parent', box ,'FontSize',bigFont);
% panel{2} = uix.BoxPanel( 'Title', 'Pipette', 'Parent', box ,'FontSize',bigFont);
subVbox = uix.VBox( 'Parent', box );
panel{2} = uix.BoxPanel( 'Title', 'Connect', 'Parent', subVbox ,'FontSize',bigFont);
panel{3} = uix.BoxPanel( 'Title', 'Movement', 'Parent', subVbox ,'FontSize',bigFont);
panel{4} = uix.BoxPanel( 'Title', 'Selected Pipette', 'Parent', subVbox ,'FontSize',bigFont);
panel{5} = uix.BoxPanel( 'Title', 'Pipette calibration', 'Parent', subVbox ,'FontSize',bigFont);
panel{6} = uix.BoxPanel( 'Title', 'Deck Calibration and Movement', 'Parent', subVbox ,'FontSize',bigFont);

set( panel{1}, 'DockFcn', {@nDock, 1} );
set( panel{2}, 'DockFcn', {@nDock, 2} );
set( panel{3}, 'DockFcn', {@nDock, 3} );
set( panel{4}, 'DockFcn', {@nDock, 4} );
set( panel{5}, 'DockFcn', {@nDock, 5} );
set( panel{6}, 'DockFcn', {@nDock, 6} );


% Hook up the minimize callback.
% set( panel{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( panel{2}, 'MinimizeFcn', {@nMinimize, 2} );
set( panel{3}, 'MinimizeFcn', {@nMinimize, 3} );
set( panel{4}, 'MinimizeFcn', {@nMinimize, 4} );
set( panel{5}, 'MinimizeFcn', {@nMinimize, 5} );
set( panel{6}, 'MinimizeFcn', {@nMinimize, 6} );

p2height = 75;
p3height = 350;
p4height = 75;
p5height = -1;
p6height = 200;
panelTableVarNames = {'ind','parent','subGroup','subInd','origHeight','minHeight','currHeight'};
panelTableCell = {1,box,1,1,-1,40,-1;...
                  2,subVbox,2,1,p2height,40,p2height;...
                  3,subVbox,2,2,p3height,40,p3height;...
                  4,subVbox,2,3,p4height,40,p4height;...
                  5,subVbox,2,4,p5height,40,p5height;...
                  6,subVbox,2,5,p6height,40,p6height};
panelTable = cell2table(panelTableCell,'VariableNames' ,panelTableVarNames);

set(box,'MinimumWidths',[400 300],'Widths',[-1 300]);

deckAxesBox = uix.HBox('Parent',panel{1},'Padding',40);
handles.deckAxis = axes('Parent',deckAxesBox,'Unit','normalized','Position',[0 0 1 1]);

% handles.deckAxis = axes('Parent',panel{1},'Unit','normalized','Position',[0 0 .5 .5]);

% Initialize the deck plot
initDeckPlot();


% set(deckAxesBox,'Widths',[-1 100]);

%% Connection pannel
connBox = uix.HBox('Parent',panel{2},'Spacing', 3,'Padding',10);
handles.scanPortsButton = uicontrol( 'Parent',connBox, ...
    'String', 'Scan Ports','Callback',@scanPortsButton_Callback,'fontsize',normFont);
handles.comPortsList = uicontrol( 'Parent', connBox,'style','popupmenu','String',handles.InitComPorts,'fontsize',normFont);
handles.connButton = uicontrol( 'Parent',connBox, ...
    'String', 'Connect','Callback',@connButton_Callback,'fontsize',normFont);

% uicontrol( 'Parent',panel{3}, ...
%     'String', 'Button 4' );



%% Movment panel
moveGroup = uix.VBox( 'Parent', panel{3});
% Homing buttons
homePanel = uix.Panel('Parent',moveGroup,'Title','Home Axes','Padding',2,'fontsize',normFont);
homeGroup = uix.HBox('Parent',homePanel, 'Spacing', 5,'Padding',10);
handles.homeAllButton =uicontrol( 'Parent', homeGroup, 'String', 'All', 'Callback', @homeAllButton_Callback,'fontsize',normFont);
handles.homeXbutton =uicontrol( 'Parent', homeGroup, 'String', 'X', 'Callback', @homeXbutton_Callback,'fontsize',normFont);
handles.homeYbutton =uicontrol( 'Parent', homeGroup, 'String', 'Y', 'Callback', @homeYbutton_Callback,'fontsize',normFont);
handles.homeZbutton =uicontrol( 'Parent', homeGroup, 'String', 'Z', 'Callback', @homeZbutton_Callback,'fontsize',normFont);
handles.homeAbutton =uicontrol( 'Parent', homeGroup, 'String', 'A', 'Callback', @homeAbutton_Callback,'fontsize',normFont);
handles.homeBbutton =uicontrol( 'Parent', homeGroup, 'String', 'B', 'Callback', @homeBbutton_Callback,'fontsize',normFont);


% Jogging buttons

jogGroupPannel = uix.Panel('Parent',moveGroup,'Title','Jog Head','Padding',2,'fontsize',normFont);
jogGroupComb = uix.VBox( 'Parent', jogGroupPannel);
jogGroup = uix.HBox( 'Parent', jogGroupComb);
jogGrid = uix.Grid( 'Parent', jogGroup, 'Spacing', 5,'Padding',10 );
uix.Empty( 'Parent', jogGrid );
handles.xNegButton =uicontrol( 'Parent', jogGrid, 'String', 'X -', 'Callback', @xNegButton_Callback,'fontsize',normFont );
uix.Empty( 'Parent', jogGrid );
handles.yPosButton =uicontrol( 'Parent', jogGrid, 'String', 'Y +', 'Callback', @yPosButton_Callback,'fontsize',normFont);
uix.Empty( 'Parent', jogGrid );
handles.yNegButton = uicontrol( 'Parent', jogGrid, 'String', 'Y -', 'Callback', @yNegButton_Callback,'fontsize',normFont );
uix.Empty( 'Parent', jogGrid );
handles.xPosButton =uicontrol( 'Parent', jogGrid, 'String', 'X +', 'Callback', @xPosButton_Callback ,'fontsize',normFont);
uix.Empty( 'Parent', jogGrid );
set( jogGrid, 'Widths', [-1 -1 -1], 'Heights', [-1 -1 -1] );

zJogBox = uix.VBox('Parent',jogGroup,'Spacing', 5,'Padding',10);
uix.Empty( 'Parent', zJogBox);
handles.zNegButton =uicontrol( 'Parent', zJogBox, 'String', 'Up', 'Callback', @zNegButton_Callback,'fontsize',normFont );
handles.zPosButton =uicontrol( 'Parent', zJogBox, 'String', 'Down', 'Callback', @zPosButton_Callback,'fontsize',normFont);
uix.Empty( 'Parent', zJogBox);
set( zJogBox, 'Heights', [-1 -3 -3 -1] );
set(jogGroup, 'Widths', [-3 -1]);

jogDistBox = uix.HBox('Parent',jogGroupComb,'Spacing', 5,'Padding',10);
uicontrol('Parent',jogDistBox,'style','text','string','Jog Distance','fontsize',normFont);
handles.jogDistDropdown = uicontrol( 'Parent', jogDistBox,'style','popupmenu','String',{'100';'50';'20';'10';'5';'2';'1';'0.5'},'fontsize',normFont);
set(jogGroupComb,'Heights',[175 -1]);

set(moveGroup,'Heights',[75 -1]);

%% Pipette Panel

pipAxGroup = uix.VBox( 'Parent', panel{4});
% axisBoxPanel = uix.Panel('Parent',pipGroup,'Title','Selected Pipette','Padding',2,'fontsize',normFont);
axisBox = uix.HBox( 'Parent', pipAxGroup);
% handles.axisToggleGrp = uibuttongroup('Visible','on',...
%                   'Parent',axisBox,...
%                   'SelectionChangedFcn',@axisToggleGrp_onChange);
              
% Create three radio buttons in the button group.
handles.leftAxisToggleBtn = uicontrol('Parent',axisBox,'Style','togglebutton',...
                  'String','Left (B)', 'Callback', @leftAxisToggleBtn_Callback,'fontsize',normFont);
              
handles.rightAxisToggleBtn = uicontrol('Parent',axisBox,'Style','togglebutton',...
                  'String','Right (A)', 'Callback', @rightAxisToggleBtn_Callback,'fontsize',normFont);

handles.rightAxisToggleBtn.Value = 1;  

pipGroup = uix.VBox( 'Parent', panel{5});
movePlungerPanel = uix.Panel('Parent',pipGroup,'Title','Increment Plunger Pos.','Padding',2,'fontsize',normFont);
movePlungerBox = uix.HBox( 'Parent', movePlungerPanel);
plungeUDmoveGroup = uix.VBox( 'Parent', movePlungerBox, 'Spacing', 10,'Padding',5 );
handles.plungeUpBtn =uicontrol( 'Parent', plungeUDmoveGroup, 'String', 'Up', 'Callback', @plungeUpBtn_Callback,'fontsize',normFont);
handles.plungeDownBtn =uicontrol( 'Parent', plungeUDmoveGroup, 'String', 'Down', 'Callback', @plungeDownBtn_Callback,'fontsize',normFont );

plungeIncrGrid = uix.HBox( 'Parent', movePlungerBox, 'Spacing', 5,'Padding',5 );

handles.plungeIncrGrp = uibuttongroup('Parent',plungeIncrGrid, 'Units', 'normalized', 'Position', [0 0 1 1]); 
spaceGap = 0.05;
normSize = (1-spaceGap*3)/2;
secondStart = 2*spaceGap+normSize;
uicontrol( 'Parent', handles.plungeIncrGrp, 'Style', 'togglebutton', 'String', '2', ... 
    'Units', 'normalized', 'Position', [spaceGap secondStart normSize normSize] );
uicontrol( 'Parent', handles.plungeIncrGrp, 'Style', 'togglebutton', 'String', '1', ... 
    'Units', 'normalized', 'Position', [secondStart secondStart normSize normSize] );
uicontrol( 'Parent', handles.plungeIncrGrp, 'Style', 'togglebutton', 'String', '0.5', ... 
    'Units', 'normalized', 'Position', [spaceGap spaceGap normSize normSize] ); 
uicontrol( 'Parent', handles.plungeIncrGrp, 'Style', 'togglebutton', 'String', '0.1', ... 
    'Units', 'normalized', 'Position', [secondStart spaceGap normSize normSize] ); 

plungerPosPanel = uix.Panel('Parent',pipGroup,'Title','Calibrate Plunger Pos.','Padding',2,'fontsize',normFont);
plungerPosGroup = uix.Grid( 'Parent',plungerPosPanel,'Spacing', 5,'Padding',5);
uicontrol( 'Parent', plungerPosGroup, ...
    'style','text','String', 'Top:','fontsize',normFont,'HorizontalAlignment','right');
uicontrol( 'Parent', plungerPosGroup, ...
    'style','text','String', 'Bottom:','fontsize',normFont,'HorizontalAlignment','right');
uicontrol( 'Parent', plungerPosGroup, ...
    'style','text','String', 'Blowout:','fontsize',normFont,'HorizontalAlignment','right');
uicontrol( 'Parent', plungerPosGroup, ...
    'style','text','String', 'Drop Tip:','fontsize',normFont,'HorizontalAlignment','right');

handles.pipetteTopSaveBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Save', 'Callback', @pipetteTopSaveBtn_Callback,'fontsize',normFont );
handles.pipetteFSsaveBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Save', 'Callback', @pipetteFSsaveBtn_Callback,'fontsize',normFont );
handles.pipetteBlowSaveBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Save', 'Callback', @pipetteBlowSaveBtn_Callback,'fontsize',normFont );
handles.pipetteDroptipSaveBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Save', 'Callback', @pipetteDroptipSaveBtn_Callback,'fontsize',normFont );

handles.pipetteTopGotoBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Go To', 'Callback', @pipetteTopGotoBtn_Callback,'fontsize',normFont );
handles.pipetteFSgotoBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Go To', 'Callback', @pipetteFSgotoBtn_Callback,'fontsize',normFont );
handles.pipetteBlowGotoBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Go To', 'Callback', @pipetteBlowGotoBtn_Callback,'fontsize',normFont );
handles.pipetteDroptipGotoBtn =uicontrol( 'Parent', plungerPosGroup, 'String', 'Go To', 'Callback', @pipetteDroptipGotoBtn_Callback,'fontsize',normFont );

set(plungerPosGroup, 'Widths', [-0.5 -1 -1], 'Heights', [-1 -1 -1 -1] );
set(pipGroup,'Heights',[110,-1])

%% Deck calibration panel

deckCtrlBox = uix.VBox('Parent', panel{6},'Spacing', 5,'Padding',10);
selPosGrid = uix.Grid('Parent',deckCtrlBox);
uicontrol( 'Parent', selPosGrid, ...
    'style','text','String', 'Selected Pos:','fontsize',normFont,'HorizontalAlignment','right');
handles.updateDeckButton =uicontrol( 'Parent', selPosGrid, ...
    'String', 'Update Deck', 'Callback', @updateDeckButton_Callback,'fontsize',normFont);
handles.posSelText =uicontrol( 'Parent', selPosGrid, ...
    'style','text','String', '','fontsize',normFont);
handles.selPosButton =uicontrol( 'Parent', selPosGrid, ...
    'String', 'Select Position','Callback',@selPosButton_Callback,'fontsize',normFont);

set(selPosGrid, 'Widths', [-1 -1], 'Heights', [-1 -1] );
handles.zPosList = uicontrol( 'Parent', deckCtrlBox,'style','popupmenu','String',{'Bottom';'Top';'Center'},'fontsize',normFont);

deckCalibBox = uix.HBox('Parent', deckCtrlBox,'Spacing', 5);
handles.calibratePosButton =uicontrol( 'Parent',deckCalibBox, 'String', 'Calibrate Sel.', 'Callback', @calibratePosButton_Callback,'fontsize',normFont );
handles.move2selButton =uicontrol( 'Parent',deckCalibBox, 'String', 'Move to Sel.', 'Callback', @move2selButton_Callback,'fontsize',normFont );

set(deckCtrlBox,'Heights',[75,30,40])
%% Set right pannel heights
set(subVbox,'Heights',[p2height p3height p4height p5height p6height]);
% set(moveGroup,'MinimumHeights',[150 300 50 50],'Heights',[150 -1 -1 -3]);
%-------------------------------------------------------------------------%
    function nDock( eventSource, eventData, whichpanel ) %#ok<INUSL>
        parentFigPos = getpixelposition(fig);
        % Set the flag
        panel{whichpanel}.Docked = ~panel{whichpanel}.Docked;
        panelRow = find(panelTable.ind == whichpanel);
        subGrRows = find(panelTable.subGroup ==panelTable.subGroup(panelRow));
        grSubinds = panelTable.subInd(subGrRows);
        maxOfSubgroup = max(grSubinds);
        if panel{whichpanel}.Docked
            % Put it back into the layout
            newfig = get( panel{whichpanel}, 'Parent' );
            set( panel{whichpanel}, 'Parent', panelTable.parent(panelRow) );
            delete( newfig );
            if maxOfSubgroup >0
                panelTable.subInd(panelRow) = maxOfSubgroup + 1;
            else
                panelTable.subInd(panelRow) = 1;
            end
        else
            % Take it out of the layout
            pos = getpixelposition( panel{whichpanel} );
            newfig = figure( ...
                'Name', get( panel{whichpanel}, 'Title' ), ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'CloseRequestFcn', {@nDock, whichpanel} );
            figpos = get( newfig, 'Position' );
            set( newfig, 'Position', [parentFigPos(1,1:2), pos(1,3:4)]);
            set( panel{whichpanel}, 'Parent', newfig, ...
                'Units', 'Normalized', ...
                'Position', [0 0 1 1] );
            
            greaterSubInds = find(grSubinds>panelTable.subInd(panelRow));
            if ~isempty(greaterSubInds)
                for k = 1:length(greaterSubInds)
                    panelTable.subInd(subGrRows(greaterSubInds(k))) = panelTable.subInd(subGrRows(greaterSubInds(k)))-1;
                end
            end
            panelTable.subInd(panelRow) = 0;
        end
    end % nDock

%-------------------------------------------------------------------------%

    function nMinimize( eventSource, eventData, whichpanel )
        % A panel has been maximized/minimized
        panelRow = find(panelTable.ind == whichpanel);
        subInd = panelTable.subInd(panelRow);
        if subInd > 0
        subGr = find(panelTable.subGroup ==panelTable.subGroup(panelRow));
        % Assemble heights
        subSubInd = 0;
        for k = 1:length(subGr)
            if panelTable.subInd(subGr(k))>0
                s(panelTable.subInd(subGr(k))) = panelTable.currHeight(subGr(k));
                if panelTable.subInd(subGr(k)) == subInd
                    subSubInd = k;
                end
            end
        end
%         s = get( panelTable.parent(panelRow), 'Heights' );
%         pos = get( fig, 'Position' );
        panel{whichpanel}.Minimized = ~panel{whichpanel}.Minimized;
        
        
        if panel{whichpanel}.Minimized
            s(panelTable.subInd(subGr(subSubInd))) = panelTable.minHeight(panelRow);
            panelTable.currHeight(subGr(subSubInd)) = panelTable.minHeight(panelRow);
        else
            s(panelTable.subInd(subGr(subSubInd))) = panelTable.origHeight(panelRow);
            panelTable.currHeight(subGr(subSubInd)) = panelTable.origHeight(panelRow);
        end
        set( panelTable.parent(panelRow), 'Heights', s );
        end
        % Resize the figure, keeping the top stationary
%         delta_height = pos(1,4) - sum( box.Heights );
%         set( fig, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % Minimize
%-------------------------------------------------------------------------%
    function nCloseAll( ~, ~ )
        % User wished to close the application, so we need to tidy up
        
        % Delete all windows, including undocked ones. We can do this by
        % getting the window for each panel in turn and deleting it.
        for ii=1:numel( panel )
            if isvalid( panel{ii} ) && ~strcmpi( panel{ii}.BeingDeleted, 'on' )
                figh = ancestor( panel{ii}, 'figure' );
                delete( figh );
            end
        end
        
    end % nCloseAll

%% button call backs

%% Connection Buttons

% --- Executes on button press in connButton.
function connButton_Callback(hObject, eventdata)
% hObject    handle to connButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 contents = cellstr(get(handles.comPortsList,'String'));
numTriesToConnect = 10;
if handles.robot.is_connected()==1
   handles.is_connected = 1;
   handles.port = char(handles.robot.get_connected_port);
   handles.robot.disconnect();
   set(handles.comPortsList,'BackgroundColor','white');
   set(handles.connButton,'String','Connect');
   
else
    handles.is_connected = 0;
    comStr = contents{get(handles.comPortsList,'Value')};
    comNum = get(handles.comPortsList,'Value');
    try
        connConf = handles.robot.connect(comStr);
        for k = 1:numTriesToConnect
            if OT.robot.is_connected == 1
                set(handles.comPortsList,'BackgroundColor','green');
                set(handles.connButton,'String','Disconnect');
                break
            else
                pause(2)
            end
        end
        
        if OT.robot.is_connected == 0
            warning('Did not connect after 20 seconds')
        end
    
    catch
        warning('Could not connect to that port');
        set(handles.comPortsList,'BackgroundColor','red');
        handles.robot.disconnect();
    end
        
    
end
end

% --- Executes on button press in scanPortsButton.
function scanPortsButton_Callback(hObject, eventdata)
% hObject    handle to scanPortsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pycomPorts = cell(handles.robot.get_serial_ports_list());
handles.InitComPorts = cellfun(@char,pycomPorts,'UniformOutput',0);

if handles.robot.is_connected()==1
   handles.is_connected = 1;
   handles.port = char(handles.robot.get_connected_port);
   tempCell = [{handles.port},handles.InitComPorts];
   handles.InitComPorts = tempCell;
   set(handles.comPortsList,'BackgroundColor','green');
   set(handles.connButton,'String','Disconnect');
   set(handles.comPortsList,'Value',1);
else
    handles.is_connected = 0;
end

set(handles.comPortsList,'String',handles.InitComPorts);
end

%% Jogging Buttons
% --- Executes on button press in yNegButton.
    function yNegButton_Callback(hObject, eventdata)
        % hObject    handle to yNegButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        % handles.LH.Com.jogDir('Y',-jogDist)
        handles.OT.move_head(pyargs('y',-jogDist,'mode','relative'))
        % handles.robot.move_head(pyargs('y',-jogDist,'mode','relative'))
        
    end
% --- Executes on button press in yPosButton.
    function yPosButton_Callback(hObject, eventdata)
        % hObject    handle to yPosButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        % handles.LH.Com.jogDir('Y',jogDist)
        handles.OT.move_head(pyargs('y',jogDist,'mode','relative'))
        % handles.robot.move_head(pyargs('y',jogDist,'mode','relative'))
        
    end

% --- Executes on button press in xNegButton.
    function xNegButton_Callback(hObject, eventdata)
        % hObject    handle to xNegButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        % handles.LH.Com.jogDir('X',-jogDist)
        handles.OT.move_head(pyargs('x',-jogDist,'mode','relative'))
        % handles.robot.move_head(pyargs('x',-jogDist,'mode','relative'))
    end

% --- Executes on button press in xPosButton.
    function xPosButton_Callback(hObject, eventdata)
        % hObject    handle to xPosButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        % handles.LH.Com.jogDir('X',jogDist)
        handles.OT.move_head(pyargs('x',jogDist,'mode','relative'))
        % handles.robot.move_head(pyargs('x',jogDist,'mode','relative'))
    end

% --- Executes on button press in zNegButton.
    function zNegButton_Callback(hObject, eventdata)
        % hObject    handle to zNegButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        handles.OT.move_head(pyargs('z',jogDist,'mode','relative'));
        
    end

% --- Executes on button press in zPosButton.
    function zPosButton_Callback(hObject, eventdata)
        % hObject    handle to zPosButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        contents = cellstr(get(handles.jogDistDropdown,'String'));
        jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});
        
        handles.OT.move_head(pyargs('z',-jogDist,'mode','relative'));
    end

%% Homing Buttons
% --- Executes on button press in homeAllButton.
    function homeAllButton_Callback(hObject, eventdata)
        % hObject    handle to homeAllButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home();
    end

% --- Executes on button press in homeXbutton.
    function homeXbutton_Callback(hObject, eventdata)
        % hObject    handle to homeXbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home('x');
    end

% --- Executes on button press in homeYbutton.
    function homeYbutton_Callback(hObject, eventdata)
        % hObject    handle to homeYbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home('y');
    end

% --- Executes on button press in homeZbutton.
    function homeZbutton_Callback(hObject, eventdata)
        % hObject    handle to homeZbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home('z');
    end

% --- Executes on button press in homeAbutton.
    function homeAbutton_Callback(hObject, eventdata)
        % hObject    handle to homeAbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home('a');
    end

% --- Executes on button press in homeBbutton.
    function homeBbutton_Callback(hObject, eventdata)
        % hObject    handle to homeBbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles.OT.home('b');
    end

%% Pipette Buttons
    % --- Executes on button press in leftAxisToggleBtn
    function leftAxisToggleBtn_Callback(hObject, eventdata)
        
        hObject.Value = 1;
        handles.rightAxisToggleBtn.Value = 0;
        
    end

    % --- Executes on button press in rightAxisToggleBtn.
    function rightAxisToggleBtn_Callback(hObject, eventdata)
        
        hObject.Value = 1;
        handles.leftAxisToggleBtn.Value = 0;
    end

    % --- Executes on button press in plungeUpBtn.
    function plungeUpBtn_Callback(hObject, eventdata)
    % hObject    handle to plungeUpBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)


    moveDist = -1*str2double(get(handles.plungeIncrGrp.SelectedObject,'String'));
    if get(handles.rightAxisToggleBtn,'Value')
        handles.OT.move_plunger(pyargs('a',moveDist,'mode','relative'));
    %     handles.LH.Com.jogDir('A',moveDist)
    else
        handles.OT.move_plunger(pyargs('b',moveDist,'mode','relative'));
    %     handles.LH.Com.jogDir('B',moveDist)
    end
    end


    % --- Executes on button press in plungeDownBtn.
    function plungeDownBtn_Callback(hObject, eventdata)
    % hObject    handle to plungeDownBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    moveDist = str2double(get(handles.plungeIncrGrp.SelectedObject,'String'));
    if get(handles.rightAxisToggleBtn,'Value')
        handles.OT.move_plunger(pyargs('a',moveDist,'mode','relative'));
    %     handles.LH.Com.jogDir('A',moveDist)
    else
        handles.OT.move_plunger(pyargs('b',moveDist,'mode','relative'));
    %     handles.LH.Com.jogDir('B',moveDist)
    end
    end

% --- Executes on button press in pipetteFSsaveBtn.
    function pipetteFSsaveBtn_Callback(hObject, eventdata)
        % hObject    handle to pipetteFSsaveBtn (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        updatePipetteList();
        
        if get(handles.rightAxisToggleBtn,'Value')
            axisID = 'A';
        else
            axisID = 'B';
        end
        
        % Calibrate axis bottom position (if pipette is set)
        if isfield(handles.(axisID),'pointer')
            instr = handles.(axisID).pointer;
            instr.calibrate('bottom');
            % update positions
            handles.(axisID).pos = struct(instr.positions);
        else
            % if a pipette isnt set then cant calibrate it.
            error('Cannot calibrate plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot');
        end
    end


% --- Executes on button press in pipetteFSgotoBtn.
    function pipetteFSgotoBtn_Callback(hObject, eventdata)
        % hObject    handle to pipetteFSgotoBtn (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        updatePipetteList();
        
        if get(handles.rightAxisToggleBtn,'Value')
            axisID = 'A';
            robotAxis = 'a';
        else
            axisID = 'B';
            robotAxis = 'b';
        end
        
        % plunger position string (for easier replication)
        plungerPosStr = 'bottom';
        
        % Check if pipette is set
        if isfield(handles.(axisID),'pointer')
            % Check if the calibrated position is numeric
            if isnumeric(handles.(axisID).pos.(plungerPosStr))
                % Passed checks move plunger position
                posLoc = handles.(axisID).pos.(plungerPosStr);
                handles.OT.move_plunger(pyargs(robotAxis,posLoc));
            else
                error('Plunger position for this location and pipette need to be calibrated first.');
            end
        else
            % if a pipette isnt set then cant move it.
            error('Cannot move plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
        end
    end

% --- Executes on button press in pipetteTopSaveBtn.
    function pipetteTopSaveBtn_Callback(hObject, eventdata)
        % hObject    handle to pipetteTopSaveBtn (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        updatePipetteList();
        
        if get(handles.rightAxisToggleBtn,'Value')
            axisID = 'A';
        else
            axisID = 'B';
        end
        
        % Calibrate axis top position (if pipette is set)
        if isfield(handles.(axisID),'pointer')
            instr = handles.(axisID).pointer;
            instr.calibrate('top');
            % update positions
            handles.(axisID).pos = struct(instr.positions);
        else
            % if a pipette isnt set then cant calibrate it.
            error('Cannot calibrate plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot');
        end
    end

% --- Executes on button press in pipetteTopGotoBtn.
    function pipetteTopGotoBtn_Callback(hObject, eventdata)
        % hObject    handle to pipetteTopGotoBtn (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        
        updatePipetteList();
        
        if get(handles.rightAxisToggleBtn,'Value')
            axisID = 'A';
            robotAxis = 'a';
        else
            axisID = 'B';
            robotAxis = 'b';
        end
        
        % plunger position string (for easier replication)
        plungerPosStr = 'top';
        
        % Check if pipette is set
        if isfield(handles.(axisID),'pointer')
            % Check if the calibrated position is numeric
            if isnumeric(handles.(axisID).pos.(plungerPosStr))
                % Passed checks move plunger position
                posLoc = handles.(axisID).pos.(plungerPosStr);
                handles.OT.move_plunger(pyargs(robotAxis,posLoc));
            else
                error('Plunger position for this location and pipette need to be calibrated first.');
            end
        else
            % if a pipette isnt set then cant move it.
            error('Cannot move plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
        end
        
    end

    % --- Executes on button press in pipetteBlowSaveBtn.
    function pipetteBlowSaveBtn_Callback(hObject, eventdata)
    % hObject    handle to pipetteBlowSaveBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    updatePipetteList();

    if get(handles.rightAxisToggleBtn,'Value')
        axisID = 'A';
    else
        axisID = 'B';
    end

    % Calibrate axis blow_out position (if pipette is set)
    if isfield(handles.(axisID),'pointer')
        instr = handles.(axisID).pointer;
        instr.calibrate('blow_out');
        % update positions
        handles.(axisID).pos = struct(instr.positions);
    else
        % if a pipette isnt set then cant calibrate it.
        error('Cannot calibrate plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot');
    end
    end

    % --- Executes on button press in pipetteBlowGotoBtn.
    function pipetteBlowGotoBtn_Callback(hObject, eventdata)
    % hObject    handle to pipetteBlowGotoBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    updatePipetteList();

    if get(handles.rightAxisToggleBtn,'Value')
        axisID = 'A';
        robotAxis = 'a';
    else
        axisID = 'B';
        robotAxis = 'b';
    end

    % plunger position string (for easier replication)
    plungerPosStr = 'blow_out';

    % Check if pipette is set
    if isfield(handles.(axisID),'pointer')    
        % Check if the calibrated position is numeric 
        if isnumeric(handles.(axisID).pos.(plungerPosStr))
            % Passed checks move plunger position
            posLoc = handles.(axisID).pos.(plungerPosStr);
            handles.OT.move_plunger(pyargs(robotAxis,posLoc));    
        else
            error('Plunger position for this location and pipette need to be calibrated first.');
        end
    else
        % if a pipette isnt set then cant move it.
        error('Cannot move plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
    end
    end

% --- Executes on button press in pipetteDroptipSaveBtn.
function pipetteDroptipSaveBtn_Callback(hObject, eventdata)
% hObject    handle to pipetteDroptipSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updatePipetteList();

if get(handles.rightAxisToggleBtn,'Value')
    axisID = 'A';
else
    axisID = 'B';
end

% Calibrate axis drop_tip position (if pipette is set)
if isfield(handles.(axisID),'pointer')
    instr = handles.(axisID).pointer;
    instr.calibrate('drop_tip');
    % update positions
    handles.(axisID).pos = struct(instr.positions);
else
    % if a pipette isnt set then cant calibrate it.
    error('Cannot calibrate plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot');
end
end

% --- Executes on button press in pipetteDroptipGotoBtn.
function pipetteDroptipGotoBtn_Callback(hObject, eventdata)
% hObject    handle to pipetteDroptipGotoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updatePipetteList();

if get(handles.rightAxisToggleBtn,'Value')
    axisID = 'A';
    robotAxis = 'a';
else
    axisID = 'B';
    robotAxis = 'b';
end

% plunger position string (for easier replication)
plungerPosStr = 'drop_tip';

% Check if pipette is set
if isfield(handles.(axisID),'pointer')    
    % Check if the calibrated position is numeric 
    if isnumeric(handles.(axisID).pos.(plungerPosStr))
        % Passed checks move plunger position
        posLoc = handles.(axisID).pos.(plungerPosStr);
        handles.OT.move_plunger(pyargs(robotAxis,posLoc));    
    else
        error('Plunger position for this location and pipette need to be calibrated first.');
    end
else
    % if a pipette isnt set then cant move it.
    error('Cannot move plunger position for selected axis as a pipette has not been added to that position. Either select correct axis or add pipette to slot and then calibrate');
end
end

% Check for and update pointers to connected pipettes
function updatePipetteList()

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
end

%% Deck Buttons

% --- Executes on button press in selPosButton.
    function selPosButton_Callback(hObject, eventdata)
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
        
    end

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
    end


% Update filled deck slots
    function handlesOut = updateDeckContainers()
        
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
    end

% --- Executes on button press in updateDeckButton.
    function updateDeckButton_Callback(hObject, eventdata)
        % hObject    handle to updateDeckButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        handles = updateDeckContainers();
        
        %         % Update handles structure
        %         guidata(hObject, handles);
    end

    function initDeckPlot()
        
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
%         [minX,maxX]
%         [minY,maxY]
        handles.deckAxis.XLim = [minX,maxX];
        handles.deckAxis.YLim = [minY,maxY];
        axis(handles.deckAxis,'equal');
        axis(handles.deckAxis,'tight');
        
    end

    % --- Executes on button press in calibratePosButton.
    function calibratePosButton_Callback(hObject, eventdata)
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
                updatePipetteList();

                if get(handles.rightAxisToggleBtn,'Value')
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
    end

    % --- Executes on button press in move2selButton.
    function move2selButton_Callback(hObject, eventdata)
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
                if iscell(wellPointer)
                    wellPointer = wellPointer{:};
                end
                % Get which pipette is selected
                updatePipetteList();

                if get(handles.rightAxisToggleBtn,'Value')
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
                            handles.OT.(axisID).move_to(wellPointer.bottom(),'queuing','Now');
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
    end

end

