function varargout = cl_freq_tuning(varargin)
% CL_FREQ_TUNING MATLAB code for cl_freq_tuning.fig
%      CL_FREQ_TUNING, by itself, creates a new CL_FREQ_TUNING or raises the existing
%      singleton*.
%
%      H = CL_FREQ_TUNING returns the handle to a new CL_FREQ_TUNING or the handle to
%      the existing singleton*.
%
%      CL_FREQ_TUNING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CL_FREQ_TUNING.M with the given input arguments.
%
%      CL_FREQ_TUNING('Property','Value',...) creates a new CL_FREQ_TUNING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cl_freq_tuning_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cl_freq_tuning_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cl_freq_tuning

% Last Modified by GUIDE v2.5 30-Dec-2020 12:39:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_freq_tuning_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_freq_tuning_OutputFcn, ...
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


% --- Executes just before cl_freq_tuning is made visible.
function cl_freq_tuning_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cl_freq_tuning (see VARARGIN)

% Choose default command line output for cl_freq_tuning
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cl_freq_tuning wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cl_freq_tuning_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in start_trials.
function start_trials_Callback(hObject, ~, handles)

handles = cl_Callback_TrialDelivery(handles,'on');

guidata(hObject,handles)


%PAUSE TRIALS BUTTON
function pause_trials_Callback(hObject, ~, handles)

handles = cl_Callback_TrialDelivery(handles,'off');

guidata(hObject,handles)
