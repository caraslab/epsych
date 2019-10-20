function varargout = cl_BasicCharacterization(varargin)
% cl_BasicCharacterization.m
%
% Function to generate GUI for Basic Characterization
% Written by ML Caras. Updated Oct 17, 2019.
% Last Modified by GUIDE v2.5 17-Oct-2019 20:53:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_BasicCharacterization_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_BasicCharacterization_OutputFcn, ...
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


%OPENING FUNCTION
function cl_BasicCharacterization_OpeningFcn(hObject, ~, handles, varargin)
global G_DA G_COMPILED RUNTIME


handles.output = hObject;

%Store device info
RUNTIME.TDT = TDT_GetDeviceInfo(G_DA);
RUNTIME.UseOpenEx = 1;
handles = cl_FindModuleIndex('RZ6',handles);

%Initialize physiology
[handles,G_DA] = cl_InitializePhysiology(handles,G_DA);



%--------------------------------------------
%INITIALIZE GUI TEXT
%--------------------------------------------
%Initialize selected stim mode: Tone
set(handles.stim_button_panel,'selectedobject',handles.tone);
set(handles.Highpass_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.highpass_slider,'enable','off');
set(handles.highpass_text,'visible','off');
set(handles.Lowpass_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.lowpass_slider,'enable','off');
set(handles.lowpass_text,'visible','off');
set(handles.noise,'ForegroundColor','k')
set(handles.noise,'FontWeight','normal')
set(handles.tone,'ForegroundColor','r')
set(handles.tone,'FontWeight','bold')
G_DA.SetTargetVal([handles.module,'.selector'],0);

%Initialize selected modulation mode: No modulation
set(handles.mod_button_panel,'selectedobject',handles.no_modulation);
set(handles.AM_depth_slider,'enable','off');
set(handles.AM_rate_slider,'enable','off');
set(handles.AMdepth_text,'visible','off');
set(handles.AMrate_text,'visible','off');
set(handles.AM_panel,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.AM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.AM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.AMdepth_text,'visible','off');
set(handles.AMrate_text,'visible','off');
set(handles.FM_depth_slider,'enable','off');
set(handles.FM_rate_slider,'enable','off');
set(handles.FMdepth_text,'visible','off');
set(handles.FMrate_text,'visible','off');
set(handles.no_modulation,'ForegroundColor','r');
set(handles.no_modulation,'FontWeight','bold');
set(handles.AM_modulation,'ForegroundColor','k');
set(handles.AM_modulation,'FontWeight','normal');
set(handles.freq_modulation,'ForegroundColor','k');
set(handles.freq_modulation,'FontWeight','normal');

G_DA.SetTargetVal([handles.module,'.mod_depth'],0);
G_DA.SetTargetVal([handles.module,'.mod_rate'],0);
G_DA.SetTargetVal([handles.module,'.FMdepth'],0);
G_DA.SetTargetVal([handles.module,'.FMrate'],0);

%Initialize gui display: center frequency
center_freq = get(handles.center_freq_slider,'Value');
set(handles.center_freq,'String',[num2str(center_freq), ' (Hz)']);

%Initialize gui display: dB SPL
dBSPL = get(handles.dBSPL_slider,'Value');
set(handles.dBSPL_text,'String',[num2str(dBSPL), ' (dB SPL)']);

%Initialize calibrated sound level
update_sound_level(0,dBSPL,handles);

%Initialize gui display: Bandwidth
highpass = get(handles.highpass_slider,'Value');
set(handles.highpass_text,'String',[num2str(highpass) ' (Hz)']);
lowpass = get(handles.lowpass_slider,'Value');
set(handles.lowpass_text,'String',[num2str(lowpass) ' (Hz)']);

%Initialize gui display: Sound duration
duration = G_DA.GetTargetVal([handles.module,'.StimDur']);
set(handles.duration_slider,'Value',duration);
set(handles.duration_text,'String',[num2str(duration), ' (msec)']);

%Initialize gui display: Inter-stim interval
ISI = G_COMPILED.OPTIONS.ISI;
set(handles.ISI_slider,'Value',ISI);
set(handles.ISI_text,'String',[num2str(ISI), ' (msec)']);

%Initialize gui display: AM depth
AMdepth = get(handles.AM_depth_slider,'Value');
set(handles.AMdepth_text,'String',[num2str(AMdepth*100), ' %']);

%Initialize gui display: AM rate
AMrate = get(handles.AM_rate_slider,'Value');
set(handles.AMrate_text,'String',[num2str(AMrate), ' (Hz)']);

%Initialize gui display: FM depth
FMdepth = get(handles.FM_depth_slider,'Value');
set(handles.FMdepth_text,'String',[num2str(FMdepth), ' %']);

%Initialize gui display: FM rate
FMrate = get(handles.FM_rate_slider,'Value');
set(handles.FMrate_text,'String',[num2str(FMrate), ' (Hz)']);

%Initialize selected optotgenetic mode: off
set(handles.opto_button_panel,'selectedobject',handles.opto_off);
G_DA.SetTargetVal([handles.module,'.Optostim'],0);

%Initialize sound status mode: off
set(handles.soundstatus_panel,'selectedobject',handles.sound_off);
G_DA.SetTargetVal([handles.module,'.SoundStatus'],0);

%Update handles structure
guidata(hObject, handles);


function varargout = cl_BasicCharacterization_OutputFcn(~, ~, handles) 

varargout{1} = handles.output;





%---------------------------------------------------------------
%PHYSIOLOGY
%---------------------------------------------------------------
%REFERENCE PHYS
function ReferencePhys_Callback(~, ~, handles) %#ok<*DEFNU>

global G_DA SYN_STATUS SYN

if ~isempty(SYN_STATUS)
    G_DA = cl_ReferencePhysiology(handles,G_DA);
elseif isempty(SYN_STATUS)
    SYN = cl_ReferencePhysiology(handles,SYN);
end



%OPTOGENETIC TRIGGER
function opto_button_panel_SelectionChangeFcn(hObject, eventdata, handles)
global G_DA

switch get(eventdata.NewValue,'String')
    case 'On'
        %Turn on optogenetic trigger
        G_DA.SetTargetVal([handles.module,'.Optostim'],1);
        
    case 'Off'
        %Turn off optogenetic trigger
        G_DA.SetTargetVal([handles.module,'.Optostim'],0);
    
end
guidata(hObject,handles)

%RESET LFP AVERAGING
function ResetLFP_Callback(hObject, ~, handles)
global G_DA

h = cl_FindModuleIndex('RZ5', handles);

%Send trigger to reset averaging
G_DA.SetTargetVal([h.module,'.ResetAvg'],1);

ResetStatus = G_DA.GetTargetVal([h.module,'.ResetAvg']) %#ok<*NOPRT,*NASGU>

%Reset trigger to low
G_DA.SetTargetVal([h.module,'.ResetAvg'],0);

ResetStatus = G_DA.GetTargetVal([h.module,'.ResetAvg']) %#ok<*NOPRT,*NASGU>

guidata(hObject,handles)


%UPDATE NUMBER OF LFP AVERAGES
function nAvg_Callback(hObject, ~, handles)
global G_DA

h = cl_FindModuleIndex('RZ5', handles);

val = get(hObject,'Value');
str = get(hObject,'String');

nAvgs = str2num(str{val}); %#ok<ST2NM>

G_DA.SetTargetVal([h.module,'.nAvgs'],nAvgs);

NumAvgs = G_DA.GetTargetVal([h.module,'.nAvgs'])

guidata(hObject,handles);


%---------------------------------------------------------------
%SOUND CONTROLS
%---------------------------------------------------------------
%SOUND STATUS
function soundstatus_panel_SelectionChangeFcn(hObject, eventdata, handles)
global G_DA

switch get(eventdata.NewValue,'String')
    case 'On' 
        %Tell the RPVds circuit that we want the sound on
        G_DA.SetTargetVal([handles.module,'.SoundStatus'],1); 
        
    case 'Off'
        %Tell the RPVds circuit that we want the sound off
        G_DA.SetTargetVal([handles.module,'.SoundStatus'],0);
end
guidata(hObject,handles)

%STIMULUS MODE
function stim_button_panel_SelectionChangeFcn(hObject, eventdata, handles)
global G_DA

switch get(eventdata.NewValue,'String')
    case 'Tone'
        
        %Disable bandwidth option
        set(handles.highpass_slider,'enable','off');
        set(handles.highpass_text,'visible','off');
        set(handles.Highpass_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.lowpass_slider,'enable','off');
        set(handles.lowpass_text,'visible','off');
        set(handles.Lowpass_slider_text,'ForegroundColor',[0.5 0.5 0.5]);        
        
        %Enable FM option
        set(handles.freq_modulation,'enable','on');
        set(handles.freq_modulation,'ForegroundColor','k');
        
        %Highlight selected choice
        set(handles.noise,'ForegroundColor','k')
        set(handles.noise,'FontWeight','normal')
        set(handles.tone,'ForegroundColor','r')
        set(handles.tone,'FontWeight','bold')
        
        %Tell the RPVds circuit that we want a tone
        G_DA.SetTargetVal([handles.module,'.selector'],0);
        
    case 'Noise'
        %Turn off FM
        G_DA.SetTargetVal([handles.module,'.FMdepth'],0);
        G_DA.SetTargetVal([handles.module,'.FMrate'],0);
        
        %Enable bandwidth option
        set(handles.highpass_slider,'enable','on');
        set(handles.highpass_text,'visible','on');
        set(handles.Highpass_slider_text,'ForegroundColor','k');
        set(handles.lowpass_slider,'enable','on');
        set(handles.lowpass_text,'visible','on');
        set(handles.Lowpass_slider_text,'ForegroundColor','k');        
        
        %Disable Center Frequency (Hz)
%         set(handles.center_freq_slider,'enable','off')
        %If FM option was highlighted, defualt to no modulation
        switch get(handles.mod_button_panel,'selectedobject')
            case handles.freq_modulation
            set(handles.mod_button_panel,'selectedobject',handles.no_modulation);
        end
        
        %Disable FM option
        set(handles.freq_modulation,'enable','off');
        set(handles.freq_modulation,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.freq_modulation,'FontWeight','normal');
        set(handles.FM_depth_slider,'enable','off')
        set(handles.FM_rate_slider,'enable','off')
        set(handles.FMdepth_text,'visible','off')
        set(handles.FMrate_text,'visible','off')
        set(handles.FM_panel,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        
        %Highlight selected choice
        set(handles.noise,'ForegroundColor','r')
        set(handles.noise,'FontWeight','bold')
        set(handles.tone,'ForegroundColor','k')
        set(handles.tone,'FontWeight','normal')
        
        %Tell the RPVds circuit we want noise
        G_DA.SetTargetVal([handles.module,'.selector'],1);
        
        %Apply bandwidth filter
%         center_freq = G_DA.GetTargetVal([handles.module,'.center_freq']);
        HP = get(handles.highpass_slider,'Value');
        LP = get(handles.lowpass_slider,'Value');
        updatebandwidth(HP,LP,handles);
        
        
end
guidata(hObject,handles)

%MODULATION MODE
function mod_button_panel_SelectionChangeFcn(hObject, eventdata, handles)
global G_DA

switch get(eventdata.NewValue,'String')
    
    case 'No Modulation'
        set(handles.AM_depth_slider,'enable','off')
        set(handles.AM_rate_slider,'enable','off')
        set(handles.FM_depth_slider,'enable','off')
        set(handles.FM_rate_slider,'enable','off')
        
        set(handles.AMdepth_text,'visible','off')
        set(handles.AMrate_text,'visible','off')
        set(handles.FMdepth_text,'visible','off')
        set(handles.FMrate_text,'visible','off')
        
        set(handles.AM_panel,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.AM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.AM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);

        set(handles.FM_panel,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        
        set(handles.no_modulation,'ForegroundColor','r');
        set(handles.no_modulation,'FontWeight','bold');
        set(handles.AM_modulation,'ForegroundColor','k');
        set(handles.AM_modulation,'FontWeight','normal');
        set(handles.freq_modulation,'ForegroundColor','k');
        set(handles.freq_modulation,'FontWeight','normal');
        
        %Turn off AM
        G_DA.SetTargetVal([handles.module,'.mod_depth'],0);
        G_DA.SetTargetVal([handles.module,'.mod_rate'],0);
        
        %Turn off FM
        G_DA.SetTargetVal([handles.module,'.FMdepth'],0);
        G_DA.SetTargetVal([handles.module,'.FMrate'],0);
        
    case 'Amplitude Modulation'
        set(handles.AM_depth_slider,'enable','on')
        set(handles.AM_rate_slider,'enable','on')
        set(handles.FM_depth_slider,'enable','off')
        set(handles.FM_rate_slider,'enable','off')
        
        set(handles.AMdepth_text,'visible','on')
        set(handles.AMrate_text,'visible','on')
        set(handles.FMdepth_text,'visible','off')
        set(handles.FMrate_text,'visible','off')
        
        set(handles.AM_panel,'ForegroundColor','k');
        set(handles.AM_depth_slider_text,'ForegroundColor','k');
        set(handles.AM_rate_slider_text,'ForegroundColor','k');

        set(handles.FM_panel,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.FM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        
        set(handles.no_modulation,'ForegroundColor','k');
        set(handles.no_modulation,'FontWeight','normal');
        set(handles.AM_modulation,'ForegroundColor','r');
        set(handles.AM_modulation,'FontWeight','bold');
        set(handles.freq_modulation,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.freq_modulation,'FontWeight','normal');

        %Turn off FM
        G_DA.SetTargetVal([handles.module,'.FMdepth'],0);
        G_DA.SetTargetVal([handles.module,'.FMrate'],0);
        
        %Turn on AM
        AMdepth = get(handles.AM_depth_slider,'Value');
        G_DA.SetTargetVal([handles.module,'.mod_depth'],AMdepth);
        
        AMrate = get(handles.AM_rate_slider,'Value');
        G_DA.SetTargetVal([handles.module,'.mod_rate'],AMrate);
        
    case 'Frequency Modulation'
        set(handles.AM_depth_slider,'enable','off')
        set(handles.AM_rate_slider,'enable','off')
        set(handles.FM_depth_slider,'enable','on')
        set(handles.FM_rate_slider,'enable','on')
        
        set(handles.AMdepth_text,'visible','off')
        set(handles.AMrate_text,'visible','off')
        set(handles.FMdepth_text,'visible','on')
        set(handles.FMrate_text,'visible','on')
        
        set(handles.AM_panel,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.AM_depth_slider_text,'ForegroundColor',[0.5 0.5 0.5]);
        set(handles.AM_rate_slider_text,'ForegroundColor',[0.5 0.5 0.5]);

        set(handles.FM_panel,'ForegroundColor','k');
        set(handles.FM_depth_slider_text,'ForegroundColor','k');
        set(handles.FM_rate_slider_text,'ForegroundColor','k');
        
        set(handles.no_modulation,'ForegroundColor','k');
        set(handles.no_modulation,'FontWeight','normal');
        set(handles.AM_modulation,'ForegroundColor','k');
        set(handles.AM_modulation,'FontWeight','normal');
        set(handles.freq_modulation,'ForegroundColor','r');
        set(handles.freq_modulation,'FontWeight','bold');
        
        %Turn off AM
        G_DA.SetTargetVal([handles.module,'.mod_depth'],0);
        G_DA.SetTargetVal([handles.module,'.mod_rate'],0);
        
        %Turn on FM
        FMdepth = get(handles.FM_depth_slider,'Value');
        G_DA.SetTargetVal([handles.module,'.FMdepth'],FMdepth);
        
        FMrate = get(handles.FM_rate_slider,'Value');
        G_DA.SetTargetVal([handles.module,'.FMrate'],FMrate);
end

guidata(hObject,handles)

%CENTER FREQUENCY CALLBACK
function center_freq_slider_Callback(hObject, ~, handles)
global G_DA

%Update the gui
center_freq = get(hObject,'Value');
set(handles.center_freq,'String',[num2str(center_freq), ' (Hz)']);

%Update the frequency in the RPVds circuit
G_DA.SetTargetVal([handles.module,'.center_freq'],center_freq);


selector = G_DA.GetTargetVal([handles.module,'.selector']);


switch selector
    case 0 %tone
        
        %Because we've changed the center frequency, we also need to update the
        %sound calibration level
        dBSPL = G_DA.GetTargetVal([handles.module,'.dBSPL']);
        update_sound_level(selector,dBSPL,handles)
        
    case 1 %noise
        
        %Because we've changed the center frequency, we need to update the
        %bandwidth of the sound
        HP = get(handles.highpass_slider,'Value');
        LP = get(handles.lowpass_slider,'Value');
        updatebandwidth(HP,LP,handles);
end

guidata(hObject,handles);

%FREQUENCY BANDWIDTH CALLBACK
function highpass_slider_Callback(hObject, ~, handles)
global G_DA
%Update the gui
highpass = get(hObject,'Value');
set(handles.highpass_text,'String',[num2str(highpass) ' (Hz)']);

%Get center frequency of carrier
% center_freq = G_DA.GetTargetVal([handles.module,'.center_freq']);
% LP = G_DA.GetTargetVal([handles.module,'.lowpass_text']);
LP = get(handles.lowpass_slider,'Value');
%Calculate high pass and low pass frequencies for the desired bandwidth
updatebandwidth(highpass,LP,handles);

guidata(hObject,handles);

function lowpass_slider_Callback(hObject, ~, handles)
global G_DA
%Update the gui
lowpass = get(hObject,'Value');
set(handles.lowpass_text,'String',[num2str(lowpass) ' (Hz)']);

%Get center frequency of carrier
% center_freq = G_DA.GetTargetVal([handles.module,'.center_freq']);
% HP = G_DA.GetTargetVal([handles.module,'.highpass_text']);
HP = get(handles.highpass_slider,'Value');
%Calculate high pass and low pass frequencies for the desired bandwidth
updatebandwidth(HP,lowpass,handles);

guidata(hObject,handles);

%UPDATE BANDWIDTH
function updatebandwidth(hp,lp,handles)
global G_DA

% hp = center_freq - (bandwidth*center_freq/2);
% lp = center_freq + (bandwidth*center_freq/2);

%Avoid hp filter values that are too low (not sure why this is a problem,
%but if the value is too low, the filter component macro in the RPVds
%circuit stops working.)
if hp < 10
    hp = 10;
end

%Avoid lp filter values that are too high for the sampling rate of the
%device (nyquist)
if lp > 48000
    lp = 48000;
end

%Send the filter frequencies to the RPVds circuit
G_DA.SetTargetVal([handles.module,'.FiltHP'],hp);
G_DA.SetTargetVal([handles.module,'.FiltLP'],lp);

%AM DEPTH CALLBACK
function AM_depth_slider_Callback(hObject, ~, handles)
global G_DA

AMdepth = get(hObject,'Value');
set(handles.AMdepth_text,'String',[num2str(AMdepth*100), ' %']);

G_DA.SetTargetVal([handles.module,'.mod_depth'],AMdepth);

guidata(hObject,handles);

%AM RATE CALLBACK
function AM_rate_slider_Callback(hObject, ~, handles)
global G_DA

AMrate = get(hObject,'Value');
set(handles.AMrate_text,'String',[num2str(AMrate), ' (Hz)']);

G_DA.SetTargetVal([handles.module,'.mod_rate'],AMrate);

guidata(hObject,handles);

%FM DEPTH CALLBACK
function FM_depth_slider_Callback(hObject, ~, handles)
global G_DA

FMdepth = get(hObject,'Value');
set(handles.FMdepth_text,'String',[num2str(FMdepth), ' %']);

G_DA.SetTargetVal([handles.module,'.FMdepth'],FMdepth);

guidata(hObject,handles);

%FM RATE CALLBACK
function FM_rate_slider_Callback(hObject, ~, handles)
global G_DA

FMrate = get(hObject,'Value');
set(handles.FMrate_text,'String',[num2str(FMrate), ' (Hz)']);

G_DA.SetTargetVal([handles.module,'.FMrate'],FMrate);

guidata(hObject,handles);

%SOUND LEVEL CALLBACK
function dBSPL_slider_Callback(hObject, ~, handles)
global G_DA

%Update gui
dBSPL = get(hObject,'Value');
set(handles.dBSPL_text,'String',[num2str(dBSPL), ' (dBSPL)']);

%Determine which sound carrier is selected (tone or noise)
selector = G_DA.GetTargetVal([handles.module,'.selector']);

%Update the sound level
update_sound_level(selector,dBSPL,handles)
 
 
 
guidata(hObject,handles);

%UPDATE CALIBRATED SOUND LEVEL
function update_sound_level(selector,dBSPL,handles)
global G_DA TONE_CAL NOISE_CAL

switch selector
    case 0 %tone
        
        %Set the normalization value for calibration
        G_DA.SetTargetVal([handles.module,'.~center_freq_norm'],TONE_CAL.hdr.cfg.ref.norm);
        
        %Get the center frequency
        center_freq = G_DA.GetTargetVal([handles.module,'.center_freq']);
        
        %Calculate the voltage adjustment
        CalAmp = Calibrate(center_freq,TONE_CAL);
        
    case 1 %noise
        
        %Set the normalization value for calibration
        G_DA.SetTargetVal([handles.module,'.~center_freq_norm'],NOISE_CAL.hdr.cfg.ref.norm);
        
        %Calculate the voltage adjustment
        CalAmp = NOISE_CAL.data(1,4);
end

%Send the values to the RPvds circuit
G_DA.SetTargetVal([handles.module,'.~center_freq_Amp'],CalAmp);
G_DA.SetTargetVal([handles.module,'.dBSPL'],dBSPL);

%SOUND DURATION SLIDER
function duration_slider_Callback(hObject, ~, handles)
global G_DA

duration = get(hObject,'Value');
set(handles.duration_text,'String',[num2str(duration), ' (msec)']);

G_DA.SetTargetVal([handles.module,'.StimDur'],duration);

guidata(hObject,handles)

%ISI SLIDER
function ISI_slider_Callback(hObject, ~, handles)
global G_COMPILED

ISI = get(hObject,'Value');
set(handles.ISI_text,'String',[num2str(ISI), ' (msec)']);

G_COMPILED.OPTIONS.ISI = ISI;


guidata(hObject,handles);




%---------------------------------------------------------------
%FIGURE WINDOW CONTROLS
%---------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, ~, ~)

%Close the figure
delete(hObject);
