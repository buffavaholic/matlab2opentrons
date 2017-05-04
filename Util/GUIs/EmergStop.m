function varargout = EmergStop(varargin)
% EMERGSTOP MATLAB code for EmergStop.fig
%      EMERGSTOP, by itself, creates a new EMERGSTOP or raises the existing
%      singleton*.
%
%      H = EMERGSTOP returns the handle to a new EMERGSTOP or the handle to
%      the existing singleton*.
%
%      EMERGSTOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMERGSTOP.M with the given input arguments.
%
%      EMERGSTOP('Property','Value',...) creates a new EMERGSTOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EmergStop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EmergStop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EmergStop

% Last Modified by GUIDE v2.5 03-May-2017 15:59:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EmergStop_OpeningFcn, ...
                   'gui_OutputFcn',  @EmergStop_OutputFcn, ...
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


% --- Executes just before EmergStop is made visible.
function EmergStop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EmergStop (see VARARGIN)

% Choose default command line output for EmergStop
handles.output = hObject;

% Get OT handle from varargin
handles.OT = varargin{1};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EmergStop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EmergStop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.OT.helper.doHalt(handles.OT.robot);
