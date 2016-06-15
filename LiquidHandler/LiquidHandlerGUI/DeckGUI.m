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

% Last Modified by GUIDE v2.5 15-Jun-2016 11:54:31

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

handles.LH = varargin{1};
contNames = handles.LH.Deck.getContainerList();
handles.contNames = contNames;
buttonToSlot = {'buttonA1','A1';
    'buttonA2','A2';
    'buttonA3','A3';
    'buttonB1','B1';
    'buttonB2','B2';
    'buttonB3','B3';
    'buttonC1','C1';
    'buttonC2','C2';
    'buttonC3','C3';
    'buttonD1','D1';
    'buttonD2','D2';
    'buttonD3','D3';
    'buttonE1','E1';
    'buttonE2','E2';
    'buttonE3','E3';
    'buttonCustom','Cusom'};
nSlots = length(buttonToSlot(:,1));
buttonToSlot = table(buttonToSlot(:,1),buttonToSlot(:,2),...
    cell(nSlots,1),cell(nSlots,1),...
    'VariableNames',{'Tag', 'Slot','Name','Type'});
buttonToSlot.Tag= categorical(buttonToSlot.Tag);
buttonToSlot.Slot= categorical(buttonToSlot.Slot);
handles.buttonToSlot = buttonToSlot;

handles.nonCalibSlotColor = [1 0.6 0.6];
handles.calibSlotColor  = [0.6 1 0.6];
currContainers = handles.LH.Deck.contNames;
for k = 1:length(currContainers)
    
    slotInd = find(handles.LH.Deck.(currContainers{k}).slot==buttonToSlot.Slot);
    handles.buttonToSlot.Name(slotInd) = currContainers(k);
    contType = char(handles.LH.Deck.(currContainers{k}).props.contName);
    handles.buttonToSlot.Type(slotInd) = {contType};
    slotHandle = buttonToSlot.Tag(slotInd);
    handles.(char(slotHandle)).String = [char(handles.buttonToSlot.Slot(slotInd)),': ',currContainers{k}];
    if handles.LH.Deck.(currContainers{k}).isCalibLeft == 1 || handles.LH.Deck.(currContainers{k}).isCalibRight ==1
        handles.(char(slotHandle)).BackgroundColor = handles.calibSlotColor;
    else
        handles.(char(slotHandle)).BackgroundColor = handles.nonCalibSlotColor;
    end
    
end

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

function slotDisplayFields(handles,slot)
% update the display fields (calibration, name, type, etc.)

contName = handles.buttonToSlot.Name(handles.buttonToSlot.Slot == slot);
if ~isempty(contName{1})
    contName = char(contName);
    handles.contNameText.String = contName;
    contType = char(handles.LH.Deck.(contName).props.contName);
    handles.contTypeText.String = contType;
    % Set text values of the current calibration positions
    calibLeft = handles.LH.Deck.(contName).calibLeft;
    handles.xCalibTextLeft.String = num2str(calibLeft(1));
    handles.yCalibTextLeft.String = num2str(calibLeft(2));
    handles.zCalibTextLeft.String = num2str(calibLeft(3));
    calibRight = handles.LH.Deck.(contName).calibRight;
    handles.xCalibTextRight.String = num2str(calibRight(1));
    handles.yCalibTextRight.String = num2str(calibRight(2));
    handles.zCalibTextRight.String = num2str(calibRight(3));
    
    % get container family
    contFam = handles.LH.Deck.(contName).props.type;
    
    % if container is tiprack activate fields to assign pipette axis
    if contFam == 'tiprack'
        % activate checkboxes to assign tipboxes to pipette axis
        handles.leftTipBoxCheck.Visible = 'On';
        handles.rightTipBoxCheck.Visible = 'On';
        
        handles.rightTipBoxCheck.Value = 0;
        handles.leftTipBoxCheck.Value = 0;
        % check if assigned to an axis
        assgAxis = handles.LH.Deck.(contName).tipAxis;
        
        % check assigned axis accordingly
        if strcmp(assgAxis,'Right')
            handles.rightTipBoxCheck.Value = 1;
        elseif strcmp(assgAxis,'Left')
            handles.leftTipBoxCheck.Value = 1;
        end
    else
        handles.leftTipBoxCheck.Visible = 'Off';
        handles.rightTipBoxCheck.Visible = 'Off';
    end
    
else
    handles.contNameText.String ='';
    handles.contTypeText.String ='';
    handles.xCalibTextLeft.String = '';
    handles.yCalibTextLeft.String ='';
    handles.zCalibTextLeft.String = '';
    handles.xCalibTextRight.String = '';
    handles.yCalibTextRight.String = '';
    handles.zCalibTextRight.String ='';
    
    handles.leftTipBoxCheck.Visible = 'Off';
        handles.rightTipBoxCheck.Visible = 'Off';
end



% answer = inputdlg(prompt);
% LH.Deck.addContainer('mp1','B2','microplate_96_deep_well');

% --- Executes on button press in buttonA1.
function buttonA1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonA1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'A1')
% --- Executes on button press in buttonA2.
function buttonA2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonA2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'A2')

% --- Executes on button press in buttonA3.
function buttonA3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonA3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'A3')

% --- Executes on button press in buttonB1.
function buttonB1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonB1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'B1')

% --- Executes on button press in buttonB2.
function buttonB2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonB2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'B2')

% --- Executes on button press in buttonB3.
function buttonB3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonB3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'B3')

% --- Executes on button press in buttonC1.
function buttonC1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonC1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'C1')

% --- Executes on button press in buttonC2.
function buttonC2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonC2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'C2')

% --- Executes on button press in buttonC3.
function buttonC3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonC3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'C3')

% --- Executes on button press in buttonD2.
function buttonD2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonD2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'D2')

% --- Executes on button press in buttonD1.
function buttonD1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonD1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'D1')

% --- Executes on button press in buttonD3.
function buttonD3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonD3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'D3')

% --- Executes on button press in buttonE1.
function buttonE1_Callback(hObject, eventdata, handles)
% hObject    handle to buttonE1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'E1')

% --- Executes on button press in buttonE2.
function buttonE2_Callback(hObject, eventdata, handles)
% hObject    handle to buttonE2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'E2')

% --- Executes on button press in buttonE3.
function buttonE3_Callback(hObject, eventdata, handles)
% hObject    handle to buttonE3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'E3')

% --- Executes on button press in buttonCustom.
function buttonCustom_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCustom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slotDisplayFields(handles,'Custom')

% --- Executes on button press in addToSlotButton.
function addToSlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to addToSlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addToSlotButton

[Selection,ok] = listdlg('PromptString','Select a container:',...
    'SelectionMode','single',...
    'ListString',handles.contNames);

if ok ==1
    answer = inputdlg('Enter MATLAB valid container name:');
    
    if ~isempty(answer)
        selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
        selSlotTag = selSlotHandle.Tag;
        slotStr = handles.buttonToSlot.Slot(handles.buttonToSlot.Tag == selSlotTag);
        if length(slotStr)==1
            handles.LH.Deck.addContainer(answer{1},char(slotStr),handles.contNames{Selection});
            set(selSlotHandle,'String',[char(slotStr),': ',answer{1}])
            set(selSlotHandle,'BackgroundColor',handles.nonCalibSlotColor)
            
            % Add name to slot table
            handles.buttonToSlot.Name(handles.buttonToSlot.Slot == slotStr) = answer(1);
        else
            return
        end
        
    else
        return
        
    end
    
else
    return
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in contList.
function contList_Callback(hObject, eventdata, handles)
% hObject    handle to contList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns contList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contList


% --- Executes during object creation, after setting all properties.
function contList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearSlotButton.
function clearSlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearSlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
    selSlotTag = selSlotHandle.Tag;
    slotStr = char(handles.buttonToSlot.Slot(handles.buttonToSlot.Tag == selSlotTag));
    contStr = char(handles.buttonToSlot.Name(handles.buttonToSlot.Tag == selSlotTag));
    
    handles.LH.Deck.removeContainer(contStr)
    
    set(selSlotHandle,'String',[slotStr,' Slot'])
    set(selSlotHandle,'BackgroundColor',[.94 .94 .94])
    


% --- Executes on button press in saveCalibButton.
function saveCalibButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveCalibButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get slot container
selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
selSlotTag = selSlotHandle.Tag;
slotStr = char(handles.buttonToSlot.Slot(handles.buttonToSlot.Tag == selSlotTag));
contCell = handles.buttonToSlot.Name(handles.buttonToSlot.Tag == selSlotTag);
if isempty(contCell{1})
    errordlg(['No container defined for slot ',slotStr])
end
contStr = contCell{1};

% Get Pipette Axis
if handles.rightAxisButton.Value ==1
    axis = 'Right';
else
    axis = 'Left';
end

% Get Head Position
comH = handles.LH.Com;
pos = [comH.x, comH.y, comH.z];

% Calibrate container based on that position
handles.LH.Deck.(contStr).calibrate(pos,axis)



% --- Executes on button press in moveToButton.
function moveToButton_Callback(hObject, eventdata, handles)
% hObject    handle to moveToButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get slot container
selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
selSlotTag = selSlotHandle.Tag;
slotStr = char(handles.buttonToSlot.Slot(handles.buttonToSlot.Tag == selSlotTag));
contCell = handles.buttonToSlot.Name(handles.buttonToSlot.Tag == selSlotTag);
if isempty(contCell{1})
    errordlg(['No container defined for slot ',slotStr])
end
contStr = contCell{1};

% Get Pipette Axis
if handles.rightAxisButton.Value ==1
    axis = 'Right';
else
    axis = 'Left';
end

% Get Calibration position for that container and axis
pos = handles.LH.Deck.(contStr).get_rel_child_coord('A1',axis);

if sum(isnan(pos))==0
    % Valid positions for calibration
    
    % Move to that position
    handles.LH.Com.moveToZzero('XYZ',pos)
    
else
    % NaN in position string
    errordlg(['Container not correctly calibrated for ',axis,' axis!'])
end


% --- Executes on button press in leftTipBoxCheck.
function leftTipBoxCheck_Callback(hObject, eventdata, handles)
% hObject    handle to leftTipBoxCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of leftTipBoxCheck

% Get value of checkbox
newVal = get(hObject,'Value');

% Get container name
selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
selSlotTag = selSlotHandle.Tag;
contCell = handles.buttonToSlot.Name(handles.buttonToSlot.Tag == selSlotTag);
contStr = contCell{1};

if newVal == 1
    % assign tip box to left axis
    handles.LH.setTipContainer('Left',contStr)
else
    % remove container as tip box for right axis
    handles.LH.Head.removeTipCont('Left',contStr)    
    handles.LH.Deck.(contStr).tipAxis = '';
end

% --- Executes on button press in rightTipBoxCheck.
function rightTipBoxCheck_Callback(hObject, eventdata, handles)
% hObject    handle to rightTipBoxCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rightTipBoxCheck

% Get value of checkbox
newVal = get(hObject,'Value');

% Get container name
selSlotHandle = get(handles.slotBtnGroup,'SelectedObject');
selSlotTag = selSlotHandle.Tag;
contCell = handles.buttonToSlot.Name(handles.buttonToSlot.Tag == selSlotTag);
contStr = contCell{1};

if newVal == 1
    % assign tip box to right axis
    handles.LH.setTipContainer('Right',contStr)
else
    % remove container as tip box for right axis
    handles.LH.Head.removeTipCont('Right',contStr)
    handles.LH.Deck.(contStr).tipAxis = '';
end
