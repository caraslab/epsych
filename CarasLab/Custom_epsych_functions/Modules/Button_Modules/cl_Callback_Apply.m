function handles = cl_Callback_Apply(handles)
%handles = cl_Callback_Apply(handles)
%
%Custom function for Caras Lab
%
%This function applies changes made by the user.
%Input:
%   handles: GUI handles structure
%
%Updated by ML Caras 8.17.2016
%Written by ML Caras 10.17.2019


global  AX FUNCS TRIAL_STATUS RUNTIME AUTOSHOCK

%Determine if we're currently in the middle of a trial
trial_TTL = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.InTrial_TTL']);

%In the aversive paradigm, the user is allowed to apply changes during safe
%trials because trials are completed so quickly. In the appetitive
%paradigm, the user can only apply changes if we're not in the middle of a
%trial.
switch lower(FUNCS.BoxFig)
    
    case 'cl_aversivedetection'
        %Determine if we're in a safe trial
        trial_type = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.TrialType']);
        
    otherwise
        trial_type = 0;
        
end

%If we're not in the middle of a trial, or we're in the middle of a NOGO
%trial
if trial_TTL == 0 || trial_type == 1
    
    %Collect GUI parameters for selecting next trial
    cl_CollectGUIHandles(handles);
    
    %Update RUNTIME structure and parameters for next trial delivery
    cl_UpdateRuntime
    
    %Update Next trial information in gui
    handles = cl_UpdateNextTrial(handles);
    
    
    %-----------------------------------------------------
    %%%%  UPDATE REWARD PARAMETERS %%%%
    %-----------------------------------------------------
    
    %Update pump control
    cl_UpdatePump(handles);
    
    %Update numPellets
    if isfield(handles,'numPellets')
        cl_Updatetag(handles.numPellets,handles.module,handles.dev,'num_pellets');
    end
    
    %-----------------------------------------------------
    %%%%  UPDATE TRIAL HARDWARE AND TIMING PARAMETERS %%%%
    %-----------------------------------------------------
    
    %Update Minimum Poke Duration
    if isfield(handles,'MinPokeDur')
        cl_Updatetag(handles.MinPokeDur,handles.module,handles.dev,'MinPokeDur')
    end
    
    %Update Silent Delay Period
    if isfield(handles,'silent_delay')
        cl_Updatetag(handles.silent_delay,handles.module,handles.dev,'Silent_delay')
    end
    
    %Update Response Window Delay
    if isfield(handles,'respwin_delay')
        cl_Updatetag(handles.respwin_delay,handles.module,handles.dev,'RespWinDelay')
    end
    
    %Update Response Window Duration
    if isfield(handles,'respwin_dur')
        cl_Updatetag(handles.respwin_dur,handles.module,handles.dev,'RespWinDur')
    end
        
    %Update intertrial interval
    if isfield(handles,'ITI')
        cl_Updatetag(handles.ITI,handles.module,handles.dev,'ITI_dur')
    end
    
    %Update ISI
    if isfield(handles,'ISI')
        cl_Updatetag(handles.ISI,handles.module,handles.dev,'ISI')
    end

    %Update LED Delay
    if isfield(handles,'LED_Delay')
        cl_Updatetag(handles.LED_Delay,handles.module,handles.dev,'LED_Delay')
    end
    
    %Update Optogenetic Trigger
    if isfield(handles,'optotrigger')
        cl_Updatetag(handles.optotrigger,handles.module,handles.dev,'Optostim')
    end
    
    %Update Shocker Status
    if isfield(handles,'ShockStatus')
        cl_Updatetag(handles.ShockStatus,handles.module,handles.dev,'ShockFlag')
    end
    
    if isfield(handles,'Shock_dur')
        cl_Updatetag(handles.Shock_dur,handles.module,handles.dev,'ShockDur')
    end
    
    %Update Time Out Duration
    if isfield(handles,'TOduration')
        cl_Updatetag(handles.TOduration,handles.module,handles.dev,'to_duration')
    end
    
    
    
    %-------------------------------------
    %%%%  UPDATE SOUND PARAMETERS %%%%
    %-------------------------------------
    
    %Update sound frequency and level
    if isfield(handles,'AMrate1')
        handles = cl_UpdateSoundLevelandFreq_AFC(handles);
    else
        handles = cl_UpdateSoundLevelandFreq(handles);
    end
    %Update sound duration
    if isfield(handles,'sound_dur')
        cl_Updatetag(handles.sound_dur,handles.module,handles.dev,'Stim_Duration')
    end
     %Update Modulation duration
    if isfield(handles,'ModDur')
        cl_Updatetag(handles.ModDur,handles.module,handles.dev,'ModDur')
    end   
    %Update sound duration
    if isfield(handles,'Stim1_Dur')
        cl_Updatetag(handles.Stim1_Dur,handles.module,handles.dev,'Stim1_Dur')
    end
    %Update sound duration
    if isfield(handles,'Stim2_Dur')
        cl_Updatetag(handles.Stim2_Dur,handles.module,handles.dev,'Stim2_Dur')
    end
    
    %Update FM rate
    if isfield(handles,'FMRate')
        cl_Updatetag(handles.FMRate,handles.module,handles.dev,'FMrate')
    end
    
    %Update FM depth
    if isfield(handles,'FMDepth')
        cl_Updatetag(handles.FMDepth,handles.module,handles.dev,'FMdepth')
    end
    
    %Update AM rate: Important must be called BEFORE update AM depth
    if isfield(handles,'AMRate')
        cl_Updatetag(handles.AMRate,handles.module,handles.dev,'AMrate')
        cl_Updatetag(handles.AMRate,handles.module,handles.dev,'AMrateGO')
    end
    
    %Update AM Nogo rate: Important must be called BEFORE update AM Nogo depth
    if isfield(handles,'NogoAMRate')
        cl_Updatetag(handles.NogoAMRate,handles.module,handles.dev,'AMrateNOGO')
    end
    
    %Update AM depth
    if isfield(handles,'AMDepth')
        cl_Updatetag(handles.AMDepth,handles.module,handles.dev,'AMdepth')
        cl_Updatetag(handles.AMDepth,handles.module,handles.dev,'AMdepthGO')
    end
    
    %Update AM Nogo depth
    if isfield(handles,'NogoAMDepth')
        cl_Updatetag(handles.NogoAMDepth,handles.module,handles.dev,'AMdepthNOGO')
    end
    
    %Update Highpass cutoff
    if isfield(handles,'Highpass')
        cl_Updatetag(handles.Highpass,handles.module,handles.dev,'Highpass')
    end
    
    %Update Lowpass cutoff
    if isfield(handles,'Lowpass')
        cl_Updatetag(handles.Lowpass,handles.module,handles.dev,'Lowpass')
    end
    
    
    
    %-------------------------------------
    %%%%  UPDATE SHOCK PARAMETERS %%%%
    %-------------------------------------
    %If autoshock checkbox exists
    if isfield(handles,'AutoShock') 
        
        switch get(handles.AutoShock,'enable')
            
            %And if it's enabled...
            case 'on'
                
                %Get the current value
                val = get(handles.AutoShock,'Value');
                
                %If checked
                if val == 1
                    AUTOSHOCK = 1;
                    set(handles.ShockStatus,'enable','off')
                    
                %If unchecked    
                elseif val == 0
                    AUTOSHOCK = 0;
                    set(handles.ShockStatus,'enable','on')
                end
            %If it's disabled...    
            case 'off'
                AUTOSHOCK = 0;
        end
        
        %Reset color to black
        set(handles.AutoShock,'ForegroundColor',[0 0 0]);
    end
    
    
    %Reset foreground colors of remaining drop down menus to blue
    if isfield(handles,'nogo_max')
        set(handles.nogo_max,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'nogo_min')
        set(handles.nogo_min,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'NOGOlimit')
        set(handles.NOGOlimit,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'RepeatNOGO')
        set(handles.RepeatNOGO,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'TrialFilter')
        set(handles.TrialFilter,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'num_reminds')
        set(handles.num_reminds,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'GoProb')
        set(handles.GoProb,'ForegroundColor',[0 0 1]);
    end
    
    if isfield(handles,'ExpectedProb')
        set(handles.ExpectedProb,'ForegroundColor',[0 0 1]);
    end
    
    %Update trial status
    if TRIAL_STATUS == 1 %Indicates user edited trial filter
        TRIAL_STATUS = 2; %Indicates user has applied these changes
    end

    %Disable apply button
    set(handles.apply,'enable','off')
    
end
