function handles = cl_Callback_Remind(handles)
%handles = cl_Callback_Remind(handles)
%
%Custom function for Caras Lab
%
%This function forces a reminder trial when the REMIND button is pressed
%Input:
%   handles: GUI handles structure
%
%Written by ML Caras 7.27.2016


global GUI_HANDLES AX FUNCS RUNTIME

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


%If we're not in the middle of a trial, or we're in the middle of a safe
%trial
if trial_TTL == 0 || trial_type == 1
    
    %Force a reminder for the next trial
    GUI_HANDLES.remind = 1;
    
    %Update RUNTIME structure and parameters for next trial delivery
    cl_UpdateRuntime
    
    %Update Next trial information in gui
    handles = cl_UpdateNextTrial(handles);
end

