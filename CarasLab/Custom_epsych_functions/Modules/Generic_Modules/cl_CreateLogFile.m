function cl_CreateLogFile
%cl_CreateLogFile
%
%Custom function for Caras Lab
%
%This function creates an log file for documenting errors and other
%important information.
%
%Written by ML Caras 7.28.2016
%Updated by ML Caras 10.17.2019


global GLogFID GVerbosity CONFIG

GVerbosity = 2; %see vprintf.m for more info

%Close any existing log files
if ~isempty(GLogFID) && GLogFID >2
    fclose(GLogFID);
end

%Find local LogFiles directory
w = what('LogFiles');
defaultpath = w.path;
logpath = getpref('PSYCH','logfiledir',defaultpath);
   

%Set the path for log file storage
subject = CONFIG.SUBJECT.Name;

GLogFID = fopen(sprintf([logpath,'\',subject,'_%s.log'],datestr(now,'ddmmmyyyy')),'at');
