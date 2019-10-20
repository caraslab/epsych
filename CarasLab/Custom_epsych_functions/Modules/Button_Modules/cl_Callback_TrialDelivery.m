function handles = cl_Callback_TrialDelivery(handles,status)
%handles = cl_Callback_TrialDelivery(handles,status)
%
%Custom function for Caras Lab
%
%This function turns trial delivery on or off when the DELIVER TRIALS or 
%PAUSE TRIALS button is pressed, respectively.
%
%Input:
%   handles: GUI handles structure
%   status: string input ('on' or 'off') that toggles trial delivery  
%
%Updated by ML Caras 8.17.2016
%Updated Oct 17,2019

global AX RUNTIME

%Determine if we're currently in the middle of a trial
trial_TTL = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.~InTrial_TTL']);

%Determine if we're in a safe trial
trial_type = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.TrialType']);


%If we're not in the middle of a trial, or we're in the middle of a safe
%trial
if trial_TTL == 0 || trial_type == 1
    
    
    switch lower(status)
        case 'on'
            %Start Trial Delivery
            v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.~TrialDelivery'],1);
            
            %Enable pause trials button
            set(handles.PauseTrials,'enable','on');
            
            %Disable deliver trials button
            set(handles.DeliverTrials,'enable','off');
       
        case 'off'
            %Pause Trial Delivery
            v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.~TrialDelivery'],0);
            
            %Disable pause trials button
            set(handles.PauseTrials,'enable','off');
            
            %Enable deliver trials button
            set(handles.DeliverTrials,'enable','on');
            
    end
    
end
