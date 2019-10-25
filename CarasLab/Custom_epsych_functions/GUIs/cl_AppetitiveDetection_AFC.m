function varargout = cl_AppetitiveDetection_AFC(varargin)
% GUI for 1AFC or 2AFC
%   
%To do:
%Add trial order control (ascending, descending, shuffled)
%Add bandwidth cutoffs
%
%
%Written by ML Caras Jun 10, 2015
%Updated Apr 26, 2016


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_AppetitiveDetection_AFC_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_AppetitiveDetection_AFC_OutputFcn, ...
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
function cl_AppetitiveDetection_AFC_OpeningFcn(hObject, ~, handles, varargin)
global  GUI_HANDLES PERSIST AX 

%Start fresh
GUI_HANDLES = [];
PERSIST = 0;

%Choose default command line output for Appetitive_detection_GUI_v2
handles.output = hObject;

%Find the index of the RZ6 device (running behavior)
handles = findModuleIndex_SanesLab('RZ6', handles);

%Adjust pump and feeder dropdowns
handles = findRewardType_SanesLab(handles);

%Initialize physiology settings for 16 channel recording (if OpenEx)
[handles,AX] = initializePhysiology_SanesLab(handles,AX);

%Setup Response History Table and Trial History Table
handles = setupResponseandTrialHistory_SanesLab(handles);

%Setup Next Trial Table
handles = setupNextTrial_SanesLab(handles);

%Set up list of possible trial types (ignores reminder)
handles = populateLoadedTrials_SanesLab(handles);

%Setup X-axis options for I/O plot
handles = setupIOplot_SanesLab(handles);

%Collect GUI parameters for selecting next trial, and for pump settings
collectGUIHANDLES_SanesLab(handles);

%Disable frequency dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.freq,handles.dev,handles.module,'freq')
disabledropdown_SanesLab(handles.freq2,handles.dev,handles.module,'freq2')

%Disable FMRate dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
% disabledropdown_SanesLab(handles.FMRate,handles.dev,handles.module,'FMrate')

%Disable FMDepth dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
% disabledropdown_SanesLab(handles.FMDepth,handles.dev,handles.module,'FMdepth')

%Disable AMrate2 dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.AMrate1,handles.dev,handles.module,'AMrate1')
disabledropdown_SanesLab(handles.AMrate2,handles.dev,handles.module,'AMrate2')

%Disable AMDepth2 dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.AMDepth1,handles.dev,handles.module,'AMDepth1')
disabledropdown_SanesLab(handles.AMDepth2,handles.dev,handles.module,'AMDepth2')

%Disable expected probability dropdown if it's not a roved parameter 
%or if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.ExpectedProb,handles.dev,handles.module,'Expected')

%Disable level2 dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.level,handles.dev,handles.module,'dBSPL1')
disabledropdown_SanesLab(handles.level2,handles.dev,handles.module,'dBSPL2')

%Disable sound duration dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.Stim1_Dur,handles.dev,handles.module,'Stim1_Dur')
disabledropdown_SanesLab(handles.Stim2_Dur,handles.dev,handles.module,'Stim2_Dur')

%Disable silent delay dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.silent_delay,handles.dev,handles.module,'Silent_delay')

%Disable minimum poke duration dropdown if it's a roved parameter
%or if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.MinPokeDur,handles.dev,handles.module,'MinPokeDur')

%Disable response window delay if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.respwin_delay,handles.dev,handles.module,'RespWinDelay')

%Disable intertrial interval if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.ITI,handles.dev,handles.module,'ITI_dur')

%Disable pellet dropdown if it's a roved parameter or if it's not a
%parameter tag in the circuit
disabledropdown_SanesLab(handles.numPellets,handles.dev,handles.module,'num_pellets')

%Disable ISI if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.ISI,handles.dev,handles.module,'ISI')

%Disable LED_Delay if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.LED_Delay,handles.dev,handles.module,'LED_Delay')

%Disable ModDur if it's not a parameter tag in the circuit
disabledropdown_SanesLab(handles.ModDur,handles.dev,handles.module,'ModDur')

%Link axes
linkaxes([handles.trialAx,handles.spoutAx,handles.pokeAx,...
    handles.soundAx,handles.respWinAx,handles.waterAx],'x');

%Load in calibration file
handles = initializeCalibration_SanesLab(handles);

%Apply current settings
apply_Callback(handles.apply,[],handles)

%Update handles structure
guidata(hObject, handles);


%GUI OUTPUT FUNCTION AND INITIALIZING OF TIMER
function varargout = cl_AppetitiveDetection_AFC_OutputFcn(hObject, ~, handles) 

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
    
    %Capture sound level2 from microphone (but only if tags are in circuit)
    tags = RUNTIME.TDT.devinfo(h.dev).tags;
    if sum(~cellfun('isempty',strfind(tags,'bufferSize')))== 1
        h = capturesound_SanesLab(h);
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
    [HITind,MISSind,ABOind,HANGind,GOind,NOGOind,REMINDind,...
        reminders,variables,TrialTypeInd,TrialType,waterupdate,h,bits,...
        expectInd,YESind,NOind] = ...
        update_params_runtime_SanesLab_v2(waterupdate,ntrials,h,bits);
    
    %Update next trial table in gui
    h = updateNextTrial_SanesLab(h);
    
    %Update response history table
    h = updateResponseHistory_SanesLab_afc(h,HITind,MISSind,...
        ABOind,HANGind,GOind,NOGOind,variables,...
        ntrials,TrialTypeInd,TrialType,...
        REMINDind,expectInd,YESind,NOind);
    
% % %     %Update FA rate
% % %     h = updateFArate_SanesLab(h,variables,FAind,NOGOind,f);
    %Update Abort rate
    h = updateABORTrate_SanesLab(h,variables,ABOind,f);

    %Calculate hit rates and update plot
    h = updateIOPlot_SanesLab_afc(h,variables,HITind,GOind,REMINDind);
    
%     %Update trial history table
    h = updateTrialHistory_SanesLab_afc(h,variables,reminders,HITind,GOind,NOGOind);
    
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

handles = Apply_Callback_SanesLab(handles);

guidata(hObject,handles)

%REMIND BUTTON
function Remind_Callback(hObject, ~, handles)

handles = Remind_Callback_SanesLab(handles);

guidata(hObject,handles)

%REFERENCE PHYSIOLOGY BUTTON
function ReferencePhys_Callback(~, ~, handles)
global AX

AX = ReferencePhys_SanesLab(handles,AX);

%TRIAL FILTER SELECTION 
function TrialFilter_CellSelectionCallback(hObject, eventdata, handles)

[hObject,handles] = filterTrials_SanesLab(hObject, eventdata, handles);

guidata(hObject,handles)

function TrialFilter_CellEditCallback(~, ~, ~)

%DROPDOWN CHANGE SELECTION
function selection_change_callback(hObject, ~, handles)

[hObject,handles] = select_change_SanesLab(hObject,handles);

guidata(hObject,handles)

%REPEAT NOGO IF FA CHECKBOX 
function RepeatNOGO_Callback(hObject, ~, handles)
set(hObject,'ForegroundColor','r');
set(handles.apply,'enable','on');

guidata(hObject,handles);

%CLOSE GUI WINDOW 
function figure1_CloseRequestFcn(hObject, ~, ~)

closeGUI_SanesLab(hObject)

%LOAD GUI SETTINGS
function loadSettings_ClickedCallback(hObject, ~, handles)

handles = loadGUISettings_SanesLab(handles);
apply_Callback(handles.apply,[],handles)

guidata(hObject,handles);

%SAVE GUI SETTINGS
function saveSettings_ClickedCallback(hObject, ~, handles)
handles = saveGUISettings_SanesLab(handles);

guidata(hObject,handles);
%-----------------------------------------------------------



%-----------------------------------------------------------
%%%%%%%%%%%%%% PLOTTING FUNCTIONS %%%%%%%%%%%%%%%
%------------------------------------------------------------

%PLOT REALTIME HISTORY
function UpdateAxHistory(handles,starttime,event)

% %Update the TTL histories
% [handles,xmin,xmax,timestamps,trial_hist,spout_hist,~,poke_hist,...
%     sound_hist,water_hist,response_hist,~,led_hist] = ...
%     update_TTLhistory_SanesLab(handles,starttime,event);
%Update the TTL histories
[handles,xmin,xmax,timestamps,trial_hist,spout_hist,~,poke_hist,...
    sound_hist,water_hist,response_hist,~,led_hist] = ...
    update_TTLhistory_SanesLab(handles,starttime,event);
%Update realtime displays
str = get(handles.realtime_display,'String');
val = get(handles.realtime_display,'Value');

switch str{val}
    case {'Continuous'}
        
        %Plot the in trial realtime TTL
        plotContinuous_SanesLab(timestamps,trial_hist,handles.trialAx,[0.5 0.5 0.5],xmin,xmax);
        
        %Plot the poke realtime TTL
        plotContinuous_SanesLab(timestamps,poke_hist,handles.pokeAx,'g',xmin,xmax)
        
        %Plot the sound realtime TTL
        plotContinuous_SanesLab(timestamps,sound_hist,handles.soundAx,'r',xmin,xmax)
        
        %Plot the spout realtime TTL
        plotContinuous_SanesLab(timestamps,spout_hist,handles.spoutAx,'k',xmin,xmax)
        
        %Plot the response window realtime TTL
        plotContinuous_SanesLab(timestamps,response_hist,handles.respWinAx,[1 0.5 0],xmin,xmax);
        
        %Plot the water realtime TTL
        plotContinuous_SanesLab(timestamps,water_hist,handles.waterAx,'b',xmin,xmax,'Time (sec)')
        
        %Plot the LED realtime TTL
        plotContinuous_SanesLab(timestamps,led_hist,handles.ledAx,'b');
        
    case {'Triggered'}
        
        %Plot the in trial realtime TTL (all triggered off of poke onset)
        plotTriggered_SanesLab(timestamps,trial_hist,poke_hist,handles.trialAx,[0.5 0.5 0.5]);
        
        %Plot the poke realtime TTL
        plotTriggered_SanesLab(timestamps,poke_hist,poke_hist,handles.pokeAx,'g');
        
        %Plot the spout realtime TTL
        plotTriggered_SanesLab(timestamps,spout_hist,poke_hist,handles.spoutAx,'k');
        
        %Plot the response window realtime TTL
        plotTriggered_SanesLab(timestamps,response_hist,poke_hist,handles.respWinAx,[1 0.5 0]);
        
        %Plot the sound realtime TTL
        plotTriggered_SanesLab(timestamps,sound_hist,poke_hist,handles.soundAx,'r');
        
        %Plot the water realtime TTL
        plotTriggered_SanesLab(timestamps,water_hist,poke_hist,handles.waterAx,'b','Time (sec)');
        
        %Plot the LED realtime TTL
        plotTriggered_SanesLab(timestamps,led_hist,poke_hist,handles.ledAx,'b');
end
%-----------------------------------------------------------
