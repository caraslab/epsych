function handles = cl_UpdateNextTrial(handles)
%handles = cl_UpdateNextTrial(handles)
%
%Custom function for Caras Lab
%
%This function updates the GUI Next Trial Table
%Input:
%   handles: GUI handles structure
%
%Written by ML Caras 7.27.2016
%Updated by ML Caras 10.19.2019


global USERDATA

%Create a cell array containing the information for the next trial
NextTrialData = struct2cell(USERDATA)';


%Update the table handle
set(handles.NextTrial,'Data',NextTrialData);