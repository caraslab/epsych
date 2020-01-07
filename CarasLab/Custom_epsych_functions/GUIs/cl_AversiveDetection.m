function varargout = cl_AversiveDetection(varargin)
% GUI for aversive GO/NOGO detection task
%
% Written by ML Caras Apr 21, 2016.
% Updated Oct 17, 2019


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cl_AversiveDetection_OpeningFcn, ...
    'gui_OutputFcn',  @cl_AversiveDetection_OutputFcn, ...
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


%SET UP INITIAL GUI TEXT BEFORE GUI IS MADE VISIBLE
function cl_AversiveDetection_OpeningFcn(hObject, ~, handles, varargin)
global GUI_HANDLES PERSIST AX AUTOSHOCK SYN SYN_STATUS

%Start fresh
GUI_HANDLES = [];
PERSIST = 0;

%Choose default command line output for cl_AversiveDetection
handles.output = hObject;

%Find the index of the RZ6 device (running behavior)
handles = cl_FindModuleIndex('RZ6', handles);

%Initialize physiology settings for multi channel recording (if OpenEx)
[handles,AX] = cl_InitializePhysiology(handles,AX);
if strcmp(get(handles.ReferencePhys,'enable'),'on') %kp 11/2017
    
    %If we're not running synapse, update via open developer controls
    if ~isempty(SYN_STATUS)
        AX = cl_ReferencePhysiology(handles,AX);
        
    %If we're running Synapse, update via Synapse API    
    elseif isempty(SYN_STATUS)
        SYN = cl_ReferencePhysiology(handles,SYN);
    end
    
    
end

%Setup Response History Table and Trial History Table
handles = cl_SetupResponseandTrialHistory(handles);

%Setup Next Trial Table
handles = cl_SetupNextTrial(handles);

%Set up list of possible trial types (ignores reminder)
handles = cl_PopulateLoadedTrials(handles);

%Setup X-axis options for I/O plot
handles = cl_SetupIOPlot(handles);

%Collect GUI parameters for selecting next trial, and for pump settings
cl_CollectGUIHandles(handles);

%Start with paused trial delivery
handles = cl_InitializeTrialDelivery(handles);

%Make NoGo AM Rate Text visible if it's a parameter tag in the circuit
cl_MakeVisible(handles.NogoAMRateText,handles.dev,'AMrateNOGO')

%Make NoGo AM Depth Text visible if it's a parameter tag in the circuit
cl_MakeVisible(handles.NogoAMDepthText,handles.dev,'AMdepthNOGO')

%Make NoGo AM Rate dropdown visible if it's a parameter tag in the circuit
cl_MakeVisible(handles.NogoAMRate,handles.dev,'AMrateNOGO')

%Make NoGo AM Depth dropdown visible if it's a parameter tag in the circuit
cl_MakeVisible(handles.NogoAMDepth,handles.dev,'AMdepthNOGO')

%Disable frequency dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.freq,handles.dev,handles.module,'Freq')

%Disable FMRate dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.FMRate,handles.dev,handles.module,'FMrate')

%Disable FMDepth dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.FMDepth,handles.dev,handles.module,'FMdepth')

%Disable AMRate dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.AMRate,handles.dev,handles.module,'AMrate')

%Disable AMDepth dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.AMDepth,handles.dev,handles.module,'AMdepth')

%Also disable AMRate dropdown if AMrateGO is a roved parameter or if it's not a
%parameter tag in the circuit
vis = get(handles.NogoAMRate,'visible');
if strcmp(vis,'on')
    cl_DisableDropDown(handles.AMRate,handles.dev,handles.module,'AMrateGO')
    cl_DisableDropDown(handles.NogoAMRate,handles.dev,handles.module,'AMrateNOGO')
end

%Also disable AMDepth dropdown if AMdepthGO is a roved parameter or if it's not a
%parameter tag in the circuit
vis = get(handles.NogoAMDepth,'visible');
if strcmp(vis,'on')
    cl_DisableDropDown(handles.AMDepth,handles.dev,handles.module,'AMdepthGO')
    cl_DisableDropDown(handles.NogoAMDepth,handles.dev,handles.module,'AMdepthNOGO')
end

%Disable Highpass dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.Highpass,handles.dev,handles.module,'Highpass')

%Disable Lowpass dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.Lowpass,handles.dev,handles.module,'Lowpass')

%Disable level dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.level,handles.dev,handles.module,'dBSPL')

%Disable sound duration dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.sound_dur,handles.dev,handles.module,'Stim_Duration')

%Disable response window duration dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.respwin_dur,handles.dev,handles.module,'RespWinDur')

%Disable intertrial interval if it's not a parameter tag in the circuit
cl_DisableDropDown(handles.ITI,handles.dev,handles.module,'ITI_dur')

%Disable AutoShock checkbox if it's a roved parameter
cl_DisableDropDown(handles.AutoShock,handles.dev,handles.module,'ShockFlag')

%If AutoShock is enabled and selected, turn off ShockStatus dropdown, and reset SHOCK_ON
switch get(handles.AutoShock,'enable')
    
    case 'on' %enabled
        
        if get(handles.AutoShock,'Value') == 1 %selected
            set(handles.ShockStatus,'enable','off');
            AUTOSHOCK = 1;
        
        else %enabled but de-selected
            AUTOSHOCK = 0;
        end
        
    case 'off' %disabled
        AUTOSHOCK = 0;
end

%Disable shock status if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.ShockStatus,handles.dev,handles.module,'ShockFlag')


%Disable shock duration if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.Shock_dur,handles.dev,handles.module,'ShockDur')

%Disable optogtenetic trigger if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.optotrigger,handles.dev,handles.module,'Optostim')

%Link axes
linkaxes([handles.trialAx,handles.spoutAx],'x');

%Load in calibration file
handles = cl_InitializeCalibration(handles);

%Apply current settings
apply_Callback(handles.apply,[],handles)

%Update handles structure
guidata(hObject, handles);


%GUI OUTPUT FUNCTION AND INITIALIZING OF TIMER
function varargout = cl_AversiveDetection_OutputFcn(hObject, ~, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

%The trial table contains a checklist and scrollbar to allow users to
%select which trials they want to deliver. The scrollbar automatically
%jumps back to the top of the window after each check, which is annoying
%when making lots of selections. There is a java workaround, the first step
%of which is implemented below. Note that in the original version of this
%workaround, this first step was implemented before the GUI became visible. 
%This worked fine in MATLB 2012ab, 2014ab, 2016ab and 2019b. For some
%unknown reason, it would not work properly in 2018b-- the GUI had to be
%visible first before we could excute the following lines of code. If we
%could use 2019b without issue, this wouldn't matter. However, 2018b is
%full of bugs that make the program alarmingly slow, or even non-functional,
%when also recording physiology. 2018b is much more stable. 
%Therefore, we've moved this initial step here, after the GUI is visible,
%but before the timer has started.

%Get java handle to the uitable object and the scrollbar (for resetting
%later. We do this once, and only once, here because findjobj.m is very
%slow and calling it during runtime can produce a substantial lag.)
warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid') 
jTable = findjobj(handles.TrialFilter);
handles.jScrollPane = jTable.getComponent(0);
warning('on','MATLAB:hg:uicontrol:ParameterValuesMustBeValid') 

% Create new timer for RPvds control of experiment
T = CreateTimer(hObject);

%Start timer
start(T);

%Update handles structure
guidata(hObject, handles);


%----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%    TIMER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------
%CREATE TIMER
function T = CreateTimer(f)

% Creates new timer for RPvds control of experiment
T = timerfind('Name','BoxTimer');
if ~isempty(T)
    stop(T);
    delete(T);
end

%All values in seconds
T = timer('BusyMode','drop', ...
    'ExecutionMode','fixedSpacing', ...
    'Name','BoxTimer', ...
    'Period',0.025, ...
    'StartFcn',{@BoxTimerSetup,f}, ...
    'TimerFcn',{@BoxTimerRunTime,f}, ...
    'ErrorFcn',{@BoxTimerError}, ...
    'StopFcn', {@BoxTimerStop}, ...
    'TasksToExecute',inf, ...
    'StartDelay',2);

%TIMER RUNTIME FUNCTION
function BoxTimerRunTime(~,event,f)
global RUNTIME PERSIST AX

persistent lastupdate starttime waterupdate bits

%--------------------------------------------------------
%Abort if active X controls have been closed
%--------------------------------------------------------
%--------------------------------------------------------
if ~(isa(AX,'COM.RPco_x')||isa(AX,'COM.TDevAcc_X'))
    return
end

%Clear persistent variables if it's a fresh run
if PERSIST == 0
    lastupdate = [];
    starttime = clock;
    waterupdate = 0;
    bits = [];
    
    PERSIST = 1;
end

%Retrieve GUI handles structure
h = guidata(f);


try
    %Update Realtime Plot
    UpdateAxHistory(h,starttime,event)
    
    %Capture sound level from microphone
    h = cl_CaptureSound(h);
    
    %Which trial are we on?
    ntrials = length(RUNTIME.TRIALS.DATA);
    
    %--------------------------------------------------------
    %Only continue updates if a new trial has been completed
    %--------------------------------------------------------
    %--------------------------------------------------------
    if (isempty(RUNTIME.TRIALS.DATA(1).TrialType))| ntrials == lastupdate %#ok<OR2>
        return
    end
    
    %Update runtime parameters
    [HITind,MISSind,CRind,FAind,GOind,NOGOind,REMINDind,...
        reminders,variables,TrialTypeInd,TrialType,waterupdate,h,bits] = ...
        cl_UpdateParamsRuntime(waterupdate,ntrials,h,bits);

    %Update next trial table in gui
    h = cl_UpdateNextTrial(h);

    %Update response history table
    h = cl_UpdateResponseHistory(h,HITind,MISSind,...
        FAind,CRind,GOind,NOGOind,variables,...
        ntrials,TrialTypeInd,TrialType,...
        REMINDind);

    %Update FA rate
    h = cl_UpdateFARate(h,variables,FAind,NOGOind,f);

    %Calculate hit rates and update plot
    h = cl_UpdateIOPlot(h,variables,HITind,GOind,REMINDind);

    %Update trial history table
    h =  cl_UpdateTrialHistory(h,variables,reminders,HITind,FAind,GOind);

    lastupdate = ntrials;
    
catch me
    vprintf(0,me) %Log error
end



%TIMER ERROR FUNCTION
function BoxTimerError(~,~)



%TIMER STOP FUNCTION
function BoxTimerStop(~,~)

%TIMER START FUNCTION
function BoxTimerSetup(~,~,~)
%---------------------------------------------------------------------


%----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%   BUTTON AND SELECTION FUNCTIONS   %%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------

%APPLY CHANGES BUTTON
function apply_Callback(hObject,~,handles)

handles = cl_Callback_Apply(handles);

guidata(hObject,handles)

%REMIND BUTTON
function Remind_Callback(hObject, ~, handles) %#ok<*DEFNU>

handles = cl_Callback_Remind(handles);

guidata(hObject,handles)

%AIR PUFF BUTTON
function airpuff_Callback(hObject,~, handles)

handles = cl_Callback_Airpuff(handles);

guidata(hObject,handles)

%DELIVER TRIALS BUTTON
function DeliverTrials_Callback(hObject, ~, handles)

handles = cl_Callback_TrialDelivery(handles,'on');

guidata(hObject,handles)

%PAUSE TRIALS BUTTON
function PauseTrials_Callback(hObject, ~, handles)

handles = cl_Callback_TrialDelivery(handles,'off');

guidata(hObject,handles)

%REFERENCE PHYSIOLOGY BUTTON
function ReferencePhys_Callback(~, ~, handles)
global AX SYN_STATUS SYN

if ~isempty(SYN_STATUS)
    AX = cl_ReferencePhysiology(handles,AX);
elseif isempty(SYN_STATUS)
    SYN = cl_ReferencePhysiology(handles,SYN);
end

%TRIAL FILTER SELECTION
function TrialFilter_CellSelectionCallback(hObject, eventdata, handles)

[hObject,handles] = cl_FilterTrials(hObject, eventdata, handles);

guidata(hObject,handles)

function TrialFilter_CellEditCallback(~, ~, ~)

%DROPDOWN CHANGE SELECTION
function selection_change_callback(hObject, ~, handles)

[hObject,handles] = cl_Callback_SelectChange(hObject,handles);

guidata(hObject,handles)

%CLOSE GUI WINDOW
function figure1_CloseRequestFcn(hObject, ~, ~)

cl_CloseGUI(hObject)

%LOAD GUI SETTINGS
function loadSettings_ClickedCallback(hObject, ~, handles)

handles = cl_LoadGUISettings(handles);
apply_Callback(handles.apply,[],handles)

guidata(hObject,handles);

%SAVE GUI SETTINGS
function saveSettings_ClickedCallback(hObject, ~, handles)

handles = cl_SaveGUISettings(handles);

guidata(hObject,handles);
%---------------------------------------------------------------------


%-----------------------------------------------------------
%%%%%%%%%%%%%% PLOTTING FUNCTIONS %%%%%%%%%%%%%%%
%------------------------------------------------------------

%PLOT REALTIME HISTORY
function UpdateAxHistory(handles,starttime,event)

%Update the TTL histories
[handles,xmin,xmax,timestamps,trial_hist,spout_hist,type_hist] = ...
    cl_UpdateTTLHistory(handles,starttime,event);

%Update realtime displays
str = get(handles.realtime_display,'String');
val = get(handles.realtime_display,'Value');

switch str{val}
    
    case {'Continuous'}
        
        %Plot the InTrial realtime TTL
        cl_PlotContinuous(timestamps,trial_hist,handles.trialAx,...
            [0.5 0.5 0.5],xmin,xmax,'',type_hist);
        
        %Plot the Spout realtime TTL
        cl_PlotContinuous(timestamps,spout_hist,handles.spoutAx,...
            'k',xmin,xmax,'Time (s)')
    
        
    case {'Triggered'}
        
        %Plot the InTrial realtime TTL (triggered off of trial onset)
        cl_PlotTriggered(timestamps,trial_hist,trial_hist,...
            handles.trialAx,[0.5 0.5 0.5],'',type_hist);
       
        %Plot the Spout realtime TTL (triggered off of trial onset)
        cl_PlotTriggered(timestamps,spout_hist,trial_hist,...
            handles.spoutAx,'k','Time (s)');
end

%-----------------------------------------------------------
