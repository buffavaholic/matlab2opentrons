function varargout = OTgui(varargin)
% OTGUI MATLAB code for OTgui.fig
%      OTGUI, by itself, creates a new OTGUI or raises the existing
%      singleton*.
%
%      H = OTGUI returns the handle to a new OTGUI or the handle to
%      the existing singleton*.
%
%      OTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OTGUI.M with the given input arguments.
%
%      OTGUI('Property','Value',...) creates a new OTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OTgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OTgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OTgui

% Last Modified by GUIDE v2.5 15-Dec-2016 16:49:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OTgui_OpeningFcn, ...
                   'gui_OutputFcn',  @OTgui_OutputFcn, ...
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


% --- Executes just before OTgui is made visible.
function OTgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OTgui (see VARARGIN)

% Choose default command line output for OTgui
handles.output = hObject;

handles.robot = varargin{1};
handles.deckSlots = struct(handles.robot.deck.children_by_name);


pycomPorts = cell(handles.robot.get_serial_ports_list());
handles.InitComPorts = cellfun(@char,pycomPorts,'UniformOutput',0);

if handles.robot.is_connected()==1
   handles.is_connected = 1;
   handles.port = char(handles.robot.get_connected_port);
   tempCell = [{handles.port},handles.InitComPorts];
   handles.InitComPorts = tempCell;
   set(handles.comPortsList,'BackgroundColor','green');
   set(handles.connButton,'String','Disconnect');
else
    handles.is_connected = 0;
end

set(handles.comPortsList,'String',handles.InitComPorts);


handles.axisToggleGrp.SelectionChangedFcn = @(gr,ev) axisToggleGrp_onChange(gr,ev,handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes OTgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OTgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on change of selection in axisToggleGrp.
function axisToggleGrp_onChange(source,callbackdata,handles)
% hObject    handle to yNegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% fprintf('what')
pipetteAxis = get(handles.axisToggleGrp.SelectedObject,'String');
% maxVolume = num2str(handles.LH.Head.(pipetteAxis).maxVol);
% contents = cellstr(get(handles.volMenu,'String'));
% 
% findVol = strncmp(maxVolume,contents,length(maxVolume));
% if sum(findVol) == 1
%     set(handles.volMenu,'value',find(findVol))
% end

% --- Executes on button press in yNegButton.
function yNegButton_Callback(hObject, eventdata, handles)
% hObject    handle to yNegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('Y',-jogDist)
handles.robot.move_head(pyargs('y',-jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"Y":',num2str(-1*jogDist),'}}'])

% --- Executes on button press in yPosButton.
function yPosButton_Callback(hObject, eventdata, handles)
% hObject    handle to yPosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('Y',jogDist)
handles.robot.move_head(pyargs('y',jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"Y":',num2str(1*jogDist),'}}'])

% --- Executes on button press in xNegButton.
function xNegButton_Callback(hObject, eventdata, handles)
% hObject    handle to xNegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('X',-jogDist)
handles.robot.move_head(pyargs('x',-jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"X":',num2str(-1*jogDist),'}}'])

% --- Executes on button press in xPosButton.
function xPosButton_Callback(hObject, eventdata, handles)
% hObject    handle to xPosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('X',jogDist)
handles.robot.move_head(pyargs('x',jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"X":',num2str(1*jogDist),'}}'])

% --- Executes on button press in zNegButton.
function zNegButton_Callback(hObject, eventdata, handles)
% hObject    handle to zNegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('Z',-jogDist)
handles.robot.move_head(pyargs('z',jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"Z":',num2str(-1*jogDist),'}}'])

% --- Executes on button press in zPosButton.
function zPosButton_Callback(hObject, eventdata, handles)
% hObject    handle to zPosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.jogDistDropdown,'String'));
jogDist = str2num(contents{get(handles.jogDistDropdown,'Value')});

% handles.LH.Com.jogDir('Z',jogDist)
handles.robot.move_head(pyargs('z',-jogDist,'mode','relative'))
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move","param" : {"Z":',num2str(1*jogDist),'}}'])


% --- Executes on selection change in jogDistDropdown.
function jogDistDropdown_Callback(hObject, eventdata, handles)
% hObject    handle to jogDistDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns jogDistDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from jogDistDropdown


% --- Executes during object creation, after setting all properties.
function jogDistDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jogDistDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in homeAllButton.
function homeAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to homeAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.robot.home()
% handles.LH.Com.homeAxis('ZAB')
% handles.LH.Com.homeAxis('XY')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"":""}}'])

% --- Executes on button press in homeXbutton.
function homeXbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homeXbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.LH.Com.homeAxis('X')
handles.robot.home('x')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"X":""}}'])

% --- Executes on button press in homeYbutton.
function homeYbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homeYbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.LH.Com.homeAxis('Y')
handles.robot.home('y')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"Y":""}}'])

% --- Executes on button press in homeZbutton.
function homeZbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homeZbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.LH.Com.homeAxis('Z')
handles.robot.home('z')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"Z":""}}'])

% --- Executes on button press in homeAbutton.
function homeAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homeAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.LH.Com.homeAxis('A')
handles.robot.home('a')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"A":""}}'])

% --- Executes on button press in homeBbutton.
function homeBbutton_Callback(hObject, eventdata, handles)
% hObject    handle to homeBbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.LH.Com.homeAxis('B')
handles.robot.home('b')
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "home","param" : {"B":""}}'])

% --- Executes on button press in jumpA1Button.
function jumpA1Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpA1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [10, 397,121]

handles.robot.move_to(handles.deckSlots.A1);
% posIndex = handles.LH.Com.str2inds('A1');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[10,340,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":10,"Y":340,"Z":0}}'])

% --- Executes on button press in jumpA2Button.
function jumpA2Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpA2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [9, 262,121]

handles.robot.move_to(handles.deckSlots.A2);
% posIndex = handles.LH.Com.str2inds('A2');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[10,220,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":10,"Y":220,"Z":0}}'])

% --- Executes on button press in jumpA3Button.
function jumpA3Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpA3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [6, 126,121]
handles.robot.move_to(handles.deckSlots.A3);
% posIndex = handles.LH.Com.str2inds('A3');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[10,100,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":10,"Y":100,"Z":0}}'])

% --- Executes on button press in jumpB1Button.
function jumpB1Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpB1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [103.5, 397,121]
handles.robot.move_to(handles.deckSlots.B1);

% posIndex = handles.LH.Com.str2inds('B1');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[90,340,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":90,"Y":340,"Z":0}}'])

% --- Executes on button press in jumpB2Button.
function jumpB2Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpB2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [102, 263,120]

handles.robot.move_to(handles.deckSlots.B2);

% posIndex = handles.LH.Com.str2inds('B2');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[90,220,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":90,"Y":220,"Z":0}}'])

% --- Executes on button press in jumpB3Button.
function jumpB3Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpB3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [99, 126,121]

handles.robot.move_to(handles.deckSlots.B3);

% posIndex = handles.LH.Com.str2inds('B3');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[90,100,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":90,"Y":100,"Z":0}}'])

% --- Executes on button press in jumpC1Button.
function jumpC1Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpC1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [196, 397,120]

handles.robot.move_to(handles.deckSlots.C1);

% posIndex = handles.LH.Com.str2inds('C1');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[170,340,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":170,"Y":340,"Z":0}}'])

% --- Executes on button press in jumpC2Button.
function jumpC2Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpC2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [195, 263,120]

handles.robot.move_to(handles.deckSlots.C2);

% posIndex = handles.LH.Com.str2inds('C2');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[170,220,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":170,"Y":220,"Z":0}}'])

% --- Executes on button press in jumpC3Button.
function jumpC3Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpC3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [193, 128,121]

handles.robot.move_to(handles.deckSlots.C3);

% posIndex = handles.LH.Com.str2inds('C3');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[170,100,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":170,"Y":100,"Z":0}}'])

% --- Executes on button press in jumpD1Button.
function jumpD1Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpD1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [288, 398,118]

handles.robot.move_to(handles.deckSlots.D1);

% posIndex = handles.LH.Com.str2inds('D1');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[250,340,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":250,"Y":340,"Z":0}}'])

% --- Executes on button press in jumpD2Button.
function jumpD2Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpD2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [288, 263,120]

handles.robot.move_to(handles.deckSlots.D2);

% posIndex = handles.LH.Com.str2inds('D2');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[250,220,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":250,"Y":220,"Z":0}}'])

% --- Executes on button press in jumpD3Button.
function jumpD3Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpD3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [285, 128,121]

handles.robot.move_to(handles.deckSlots.D3);

% posIndex = handles.LH.Com.str2inds('D3');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[250,100,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":250,"Y":100,"Z":0}}'])

% --- Executes on button press in jumpE1Button.
function jumpE1Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpE1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [381, 399,117]

handles.robot.move_to(handles.deckSlots.E1);

% posIndex = handles.LH.Com.str2inds('E1');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)

% handles.LH.Com.moveToZzero('XYZ',[330,340,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":330,"Y":340,"Z":0}}'])

% --- Executes on button press in jumpE2Button.
function jumpE2Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpE2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [379, 264,119]

handles.robot.move_to(handles.deckSlots.E2);

% posIndex = handles.LH.Com.str2inds('E2');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[330,220,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":330,"Y":220,"Z":0}}'])

% --- Executes on button press in jumpE3Button.
function jumpE3Button_Callback(hObject, eventdata, handles)
% hObject    handle to jumpE3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Left pipette extreme [379, 128,120]

handles.robot.move_to(handles.deckSlots.E3);

% posIndex = handles.LH.Com.str2inds('E3');
% posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
% if get(handles.rightAxisToggleBtn,'Value')
%     posCoords = posCoords + handles.LH.Deck.centPipetteOffset;
%     if max(posCoords<=0) || max(posCoords>=400)
%         posCoords = handles.LH.Deck.cornerCoords{posIndex(1),posIndex(2)};
%     end
% end
% posCoords = posCoords + [0,0,-10]
% handles.LH.Com.moveToZzero('XYZ',posCoords)
% handles.LH.Com.moveToZzero('XYZ',[330,100,0])
% fprintf(handles.LHclient,['{"topic" :"driver" ,"type" :"command" ,"name" : "smoothie"',...
%     ',"message" : "move_to","param" : {"X":330,"Y":100,"Z":0}}'])


% --- Executes on button press in plungeUpBtn.
function plungeUpBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plungeUpBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


moveDist = -1*str2double(get(handles.plungeIncrGrp.SelectedObject,'String'));
if get(handles.rightAxisToggleBtn,'Value')
    handles.robot.move_plunger(pyargs('a',moveDist,'mode','relative'));
%     handles.LH.Com.jogDir('A',moveDist)
else
    handles.robot.move_plunger(pyargs('b',moveDist,'mode','relative'));
%     handles.LH.Com.jogDir('B',moveDist)
end


% --- Executes on button press in plungeDownBtn.
function plungeDownBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plungeDownBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveDist = str2double(get(handles.plungeIncrGrp.SelectedObject,'String'));
if get(handles.rightAxisToggleBtn,'Value')
    handles.robot.move_plunger(pyargs('a',moveDist,'mode','relative'));
%     handles.LH.Com.jogDir('A',moveDist)
else
    handles.robot.move_plunger(pyargs('b',moveDist,'mode','relative'));
%     handles.LH.Com.jogDir('B',moveDist)
end

% --- Executes on button press in plunge2mmBtn.
function plunge2mmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plunge2mmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plunge1mmBtn.
function plunge1mmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plunge1mmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plunge0_5mmBtn.
function plunge0_5mmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plunge0_5mmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plunge0_1mmBtn.
function plunge0_1mmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plunge0_1mmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pipetteDroptipSaveBtn.
function pipetteDroptipSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteDroptipSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Com.a;
    handles.LH.Head.calibrate('Right','droptip',pos)
else
    pos = handles.LH.Com.b;
    handles.LH.Head.calibrate('Left','droptip',pos)
end


% --- Executes on button press in pipetteDroptipGotoBtn.
function pipetteDroptipGotoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteDroptipGotoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Head.Right.droptip;
    handles.LH.Com.moveTo('A',pos)
else
    pos = handles.LH.Head.Left.droptip;
    handles.LH.Com.moveTo('B',pos)
end

% --- Executes on button press in pipetteFSsaveBtn.
function pipetteFSsaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteFSsaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Com.a;
    handles.LH.Head.calibrate('Right','firstStop',pos)
else
    pos = handles.LH.Com.b;
    handles.LH.Head.calibrate('Left','firstStop',pos)
end


% --- Executes on button press in pipetteFSgotoBtn.
function pipetteFSgotoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteFSgotoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Head.Right.firstStop;
    handles.LH.Com.moveTo('A',pos)
else
    pos = handles.LH.Head.Left.firstStop;
    handles.LH.Com.moveTo('B',pos)
end

% --- Executes on button press in pipetteTopSaveBtn.
function pipetteTopSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteTopSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Com.a;
    handles.LH.Head.calibrate('Right','top',pos)
else
    pos = handles.LH.Com.b;
    handles.LH.Head.calibrate('Left','top',pos)
end

% --- Executes on button press in pipetteTopGotoBtn.
function pipetteTopGotoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteTopGotoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rightAxisToggleBtn,'Value')
    pos = handles.LH.Head.Right.top;
    handles.LH.Com.moveTo('A',pos)
else
    pos = handles.LH.Head.Left.top;
    handles.LH.Com.moveTo('B',pos)
end


% --- Executes on button press in pickupTipBtn.
function pickupTipBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pickupTipBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pipetteAxis = get(handles.axisToggleGrp.SelectedObject,'String');
plungeDepth = handles.LH.Head.(pipetteAxis).tipPlunge;
if ~isnan(plungeDepth)
    handles.LH.Com.jogDir('Z',plungeDepth)
    handles.LH.Com.jogDir('Z',-plungeDepth)
    handles.LH.Com.jogDir('Z',plungeDepth)
    handles.LH.Com.jogDir('Z',-plungeDepth)
else
    fprintf('set pipette type to axis first')
    
end


% --- Executes on button press in testVolBtn.
function testVolBtn_Callback(hObject, eventdata, handles)
% hObject    handle to testVolBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pipetteAxis = get(handles.axisToggleGrp.SelectedObject,'String');
volCats = get(handles.volMenu,'String');
volSel = get(handles.volMenu,'Value');
testVol = str2double(volCats{volSel});

handles.LH.testPickupVol(pipetteAxis,testVol)


% --- Executes on selection change in volMenu.
function volMenu_Callback(hObject, eventdata, handles)
% hObject    handle to volMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns volMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volMenu




% --- Executes during object creation, after setting all properties.
function volMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comPortsList.
function comPortsList_Callback(hObject, eventdata, handles)
% hObject    handle to comPortsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comPortsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comPortsList


% --- Executes during object creation, after setting all properties.
function comPortsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comPortsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in connButton.
function connButton_Callback(hObject, eventdata, handles)
% hObject    handle to connButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 contents = cellstr(get(handles.comPortsList,'String'));

if handles.robot.is_connected()==1
   handles.is_connected = 1;
   handles.port = char(handles.robot.get_connected_port);
   handles.robot.disconnect();
   set(handles.comPortsList,'BackgroundColor','white');
   set(handles.connButton,'String','Connect');
   
else
    handles.is_connected = 0;
    comStr = contents{get(handles.comPortsList,'Value')};
    
    try
    connConf = handles.robot.connect(comStr);
    
        if connConf == 1
            set(handles.comPortsList,'BackgroundColor','green');
            set(handles.connButton,'String','Disconnect');
        end
    
    catch
        warning('Could not connect to that port');
        set(handles.comPortsList,'BackgroundColor','red');
        handles.robot.disconnect();
    end
        
    
end

% --- Executes on button press in scanPortsButton.
function scanPortsButton_Callback(hObject, eventdata, handles)
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
else
    handles.is_connected = 0;
end

set(handles.comPortsList,'String',handles.InitComPorts);


% --- Executes on button press in pipetteBlowSaveBtn.
function pipetteBlowSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteBlowSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pipetteBlowGotoBtn.
function pipetteBlowGotoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to pipetteBlowGotoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
