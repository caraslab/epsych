function T = cl_CreateTimer(hO,fs)
%T = cl_CreateTimer(hO,fs)
%
%Custom function for Caras Lab
%
%This function creates a new timer for RPVds control of experiment
%
%Inputs: 
%   f: GUI Output function hObject
%   fs: period of timer (seconds)
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019

%Stop and close existing timers
T = timerfind('Name','BoxTimer');
if ~isempty(T)
    stop(T);
    delete(T);
end

%All values in seconds
T = timer('BusyMode','drop', ...
    'ExecutionMode','fixedSpacing', ...
    'Name','BoxTimer', ...
    'Period',fs, ...
    'StartFcn',{@BoxTimerSetup_CarasLab,hO}, ...
    'TimerFcn',{@BoxTimerRunTime_CarasLab,hO}, ...
    'ErrorFcn',{@BoxTimerError_CarasLab}, ...
    'StopFcn', {@BoxTimerStop_CarasLab}, ...
    'TasksToExecute',inf, ...
    'StartDelay',2); 







