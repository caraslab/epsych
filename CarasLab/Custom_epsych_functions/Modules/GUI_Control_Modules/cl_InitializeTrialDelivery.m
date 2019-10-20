function handles = cl_InitializeTrialDelivery(handles)
%handles = cl_InitializeTrialDelivery(handles)
%
%Custom function for Caras Lab
%
%This function initializes the GUI with trial delivery paused, and the
%apply button disabled.
%
%Inputs:
%   handles: handles structure for GUI
%
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019

global AX RUNTIME


%Pause Trial Delivery
v = TDTpartag(AX, RUNTIME.TRIALS, [handles.module,'.~TrialDelivery'],0);

%Enable deliver trials button and disable pause trial button
set(handles.DeliverTrials,'enable','on');
set(handles.PauseTrials,'enable','off');

%Disable apply button
set(handles.apply,'enable','off');