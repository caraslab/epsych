function varargout = cl_AppetitiveDetection(varargin)
% GUI for appetitive GO/NOGO detection task
%
%
%Written by ML Caras Jun 10, 2015
%Updated Oct 17, 2019.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_AppetitiveDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_AppetitiveDetection_OutputFcn, ...
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
function cl_AppetitiveDetection_OpeningFcn(hObject, ~, handles, varargin)
global  GUI_HANDLES PERSIST AX SYN SYN_STATUS

%Start fresh
GUI_HANDLES = [];
PERSIST = 0;

%Choose default command line output for cl_AppetitiveDetection
handles.output = hObject;

%Find the index of the RZ6 device (running behavior)
handles = cl_FindModuleIndex('RZ6', handles);

%Adjust pump and feeder dropdowns
handles = cl_FindRewardType(handles);

%Initialize physiology settings for multi channel recording (if OpenEx)
[handles,AX] = cl_InitializePhysiology(handles,AX);

if strcmp(get(handles.ReferencePhys,'enable'),'on') 
    
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

%Disable expected probability dropdown if it's not a roved parameter 
%or if it's not a parameter tag in the circuit
cl_DisableDropDown(handles.ExpectedProb,handles.dev,handles.module,'Expected')

%Disable level dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.level,handles.dev,handles.module,'dBSPL')

%Disable sound duration dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.sound_dur,handles.dev,handles.module,'Stim_Duration')

%Disable silent delay dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.silent_delay,handles.dev,handles.module,'Silent_delay')

%Disable minimum poke duration dropdown if it's a roved parameter
%or if it's not a parameter tag in the circuit
cl_DisableDropDown(handles.MinPokeDur,handles.dev,handles.module,'MinPokeDur')

%Disable response window delay if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.respwin_delay,handles.dev,handles.module,'RespWinDelay')

%Disable intertrial interval if it's not a parameter tag in the circuit
cl_DisableDropDown(handles.ITI,handles.dev,handles.module,'ITI_dur')

%Disable pellet dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
cl_DisableDropDown(handles.numPellets,handles.dev,handles.module,'num_pellets')

%Link axes
linkaxes([handles.trialAx,handles.spoutAx,handles.pokeAx,...
    handles.soundAx,handles.respWinAx,handles.waterAx],'x');

%Load in calibration file
handles = cl_InitializeCalibration(handles);

%Apply current settings
apply_Callback(handles.apply,[],handles)

%Update handles structure
guidata(hObject, handles);


%GUI OUTPUT FUNCTION AND INITIALIZING OF TIMER
function varargout = cl_AppetitiveDetection_OutputFcn(hObject, ~, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



% Create new timer for RPvds control of experiment
T = CreateTimer(hObject);

%Start timer
start(T);



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
    'Period',0.05, ...
    'StartFcn',{@BoxTimerSetup,f}, ...
    'TimerFcn',{@BoxTimerRunTime,f}, ...
    'ErrorFcn',{@BoxTimerError}, ...
    'StopFcn', {@BoxTimerStop}, ...
    'TasksToExecute',inf, ...
    'StartDelay',2); 

%TIMER RUNTIME FUNCTION
function BoxTimerRunTime(~,event,f)
global RUNTIME PERSIST AX REWARDTYPE
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
    
    %Capture sound level from microphone (but only if tags are in circuit)
    tags = RUNTIME.TDT.devinfo(h.dev).tags;
    if sum(~cellfun('isempty',strfind(tags,'bufferSize')))== 1
        h = cl_CaptureSound(h);
    end
    
    %Which trial are we on?
    ntrials = length(RUNTIME.TRIALS.DATA);
    
    %Update the number of pellets delivered in realtime
    switch REWARDTYPE
        case 'food'
            pelletcount = TDTpartag(AX,RUNTIME.TRIALS,[h.module,'.','PelletCount']);
            set(h.PelletCount,'String',num2str(pelletcount));
    end
    
    
    %--------------------------------------------------------
    %Only continue updates if a new trial has been completed
    %--------------------------------------------------------
    %--------------------------------------------------------
    if (isempty(RUNTIME.TRIALS.DATA(1).TrialType))| ntrials == lastupdate %#ok<OR2>
        return
    end
    
    %Update runtime parameters
    [HITind,MISSind,CRind,FAind,GOind,NOGOind,REMINDind,...
        reminders,variables,TrialTypeInd,TrialType,waterupdate,h,bits,...
        expectInd,YESind,NOind] = ...
        cl_UpdateParamsRuntime(waterupdate,ntrials,h,bits);
    
    %Update next trial table in gui
    h = cl_UpdateNextTrial(h);
    
    %Update response history table
    h = cl_UpdateResponseHistory(h,HITind,MISSind,...
        FAind,CRind,GOind,NOGOind,variables,...
        ntrials,TrialTypeInd,TrialType,...
        REMINDind,expectInd,YESind,NOind);
    
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
%----------------------------------------------------------------------


%----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%   BUTTON AND SELECTION FUNCTIONS   %%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------

%APPLY CHANGES BUTTON
function apply_Callback(hObject,~,handles)

handles = cl_Callback_Apply(handles);

guidata(hObject,handles)

%REMIND BUTTON
function Remind_Callback(hObject, ~, handles)

handles = cl_Callback_Remind(handles);

guidata(hObject,handles)

%AIR PUFF BUTTON
function airpuff_Callback(hObject, ~, handles)

handles = cl_Callback_Airpuff(handles);

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

%REPEAT NOGO IF FA CHECKBOX 
function RepeatNOGO_Callback(hObject, ~, handles)
set(hObject,'ForegroundColor','r');
set(handles.apply,'enable','on');

guidata(hObject,handles);

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
%-----------------------------------------------------------



%-----------------------------------------------------------
%%%%%%%%%%%%%% PLOTTING FUNCTIONS %%%%%%%%%%%%%%%
%------------------------------------------------------------

%PLOT REALTIME HISTORY
function UpdateAxHistory(handles,starttime,event)

%Update the TTL histories
[handles,xmin,xmax,timestamps,trial_hist,spout_hist,~,poke_hist,...
    sound_hist,water_hist,response_hist] = ...
    cl_UpdateTTLHistory(handles,starttime,event);

%Update realtime displays
str = get(handles.realtime_display,'String');
val = get(handles.realtime_display,'Value');

switch str{val}
    case {'Continuous'}
        
        %Plot the in trial realtime TTL
        cl_PlotContinuous(timestamps,trial_hist,handles.trialAx,[0.5 0.5 0.5],xmin,xmax);
        
        %Plot the poke realtime TTL
        cl_PlotContinuous(timestamps,poke_hist,handles.pokeAx,'g',xmin,xmax)
        
        %Plot the sound realtime TTL
        cl_PlotContinuous(timestamps,sound_hist,handles.soundAx,'r',xmin,xmax)
        
        %Plot the spout realtime TTL
        cl_PlotContinuous(timestamps,spout_hist,handles.spoutAx,'k',xmin,xmax)
        
        %Plot the response window realtime TTL
        cl_PlotContinuous(timestamps,response_hist,handles.respWinAx,[1 0.5 0],xmin,xmax);
        
        %Plot the water realtime TTL
        cl_PlotContinuous(timestamps,water_hist,handles.waterAx,'b',xmin,xmax,'Time (sec)')
        
        
        
    case {'Triggered'}
        
        %Plot the in trial realtime TTL (all triggered off of poke onset)
        cl_PlotTriggered(timestamps,trial_hist,poke_hist,handles.trialAx,[0.5 0.5 0.5]);
        
        %Plot the poke realtime TTL
        cl_PlotTriggered(timestamps,poke_hist,poke_hist,handles.pokeAx,'g');
        
        %Plot the sound realtime TTL
        cl_PlotTriggered(timestamps,sound_hist,poke_hist,handles.soundAx,'r');
        
        %Plot the spout realtime TTL
        cl_PlotTriggered(timestamps,spout_hist,poke_hist,handles.spoutAx,'k');
        
        %Plot the response window realtime TTL
        cl_PlotTriggered(timestamps,response_hist,poke_hist,handles.respWinAx,[1 0.5 0]);
        
        %Plot the water realtime TTL
        cl_PlotTriggered(timestamps,water_hist,poke_hist,handles.waterAx,'b','Time (sec)');
        
end
%-----------------------------------------------------------
