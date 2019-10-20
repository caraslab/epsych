function varargout = cl_AppetitiveTrainingMenu(varargin)
% varargout = cl_AppetitiveTrainingMenu(varargin)
% 
% This GUI lanuches a menu that allows a user to select a
% appetitive training paradigm. Paradigms are as follows:
%
% Pure Tone Training Stage 1: 
%   A pure tone is generated by default.  Water is available at the spout
%   as long as the pure tone is on.  The user can use a manual override
%   control to momentarily pause water availability and pure tone
%   presentation.  The frequency and dB SPL level of the tone can be
%   edited by the user during the session.  This paradigm is appropriate
%   for animals in the very early stages of appetitive training.
%
% Pure Tone Training Stage 2:
%   The default condition is silence. A pure tone is generated and water
%   becomes available when the user contacts the manual override control.
%   The frequency and dB SPL level of the tone can be edited by the user
%   during the session. This paradigm is appropriate for animals in the
%   later stages of appetitive training (i.e. they've already learned to
%   quickly leave the spout once the sound stops).
%
% Noise Training Stage 1:
%   Identical to Pure Tone Training Stage 1, except a broadband gaussian
%   noise is used for training, instead of a pure tone. Only the dBSPL of
%   the noise is available for editing.
%
% Noise Training Stage 2:
%   Identical to Pure Tone Training Stage 2, except a broadband gaussian
%   noise is used for training, instead of a pure tone. Only the dBSPL of
%   the noise is available for editing.
%
% AM Noise Training Stage 1:
%   Identical to Noise Training Stage 1, except an AM noise is used. The AM
%   rate and depth and the dB SPL are available for editing.
%
% AM Noise Training Stage 2:
%   Identical to Noise Training Stage 2, except an AM noise is used. The AM
%   rate and depth and the dB SPL are available for editing.
%
% Written by ML Caras Jun 18 2015
% Updated by ML Caras Oct 19, 2019

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_AppetitiveTrainingMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_AppetitiveTrainingMenu_OutputFcn, ...
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


% --- Executes just before cl_AppetitiveTrainingMenu is made visible.
function cl_AppetitiveTrainingMenu_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for cl_AppetitiveTrainingMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = cl_AppetitiveTrainingMenu_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


 
%Appetitive Training Callback
 function Training_Callback(hObject, ~, handles)

% Creates new timer for RPvds control of experiment
T = timerfind;
if ~isempty(T)
    stop(T);
    delete(T);
end
     

%Set reward type global variable based on toggle button
setRewardType(handles)

%What type of training?
ttype = get(hObject,'String');

%Get the RPVdsEx circuit
switch ttype
    
    %STAGE 1 CIRCUITS
    case 'Pure Tone Stage 1'
        rpfile = 'Appetitive_pure_tone_training_stage1.rcx';
        
    case 'Noise Stage 1'
        rpfile = 'Appetitive_noise_training_stage1.rcx';
        
    case 'AM Noise Stage 1'
        rpfile = 'Appetitive_AMnoise_training_stage1.rcx';
        
    case 'Same-Diff Stage 1'
        rpfile = 'Appetitive_SameDifferent_training_stage1.rcx';
        
        
    %STAGE 2 CIRCUITS    
    case 'Pure Tone Stage 2'
        rpfile = 'Appetitive_pure_tone_training_stage2.rcx';
        
    case 'Noise Stage 2'
        rpfile = 'Appetitive_noise_training_stage2.rcx';
        
    case 'AM Noise Stage 2'
        rpfile = 'Appetitive_AMnoise_training_stage2.rcx';

    case 'Same-Diff Stage 2'
        rpfile = 'Appetitive_SameDifferent_training_stage2.rcx';
end

%Get the full path of the circuit file
rpfile = which(rpfile);

if isempty(rpfile)
    error('The RPvds file: ''%s'' was not found along the Matlab path',rpfile);
else
    cl_AppetitiveTraining({rpfile},{ttype});
end






%Set Reward Type Function
function setRewardType(handles)
         
         %Set reward type global variable based on toggle button
         global REWARDTYPE
         
         selection = get(handles.reward_panel,'selectedobject');
         
         switch get(selection,'tag')
             case 'water'
                 REWARDTYPE = 'water';
             case 'food'
                 REWARDTYPE = 'food';
         end
