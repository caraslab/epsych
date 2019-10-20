function handles = cl_SetupNextTrial(handles)
%handles = cl_SetupNextTrial(handles)
%
%Custom function for Caras Lab
%
%This function sets up the GUI next trial table 
%
%Inputs:
%   handles: handles structure for GUI
%
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019

global RUNTIME ROVED_PARAMS


empty_cell = cell(1,numel(ROVED_PARAMS));



if RUNTIME.UseOpenEx
    strstart = length(handles.module)+2;
    rp =  cellfun(@(x) x(strstart:end), ROVED_PARAMS, 'UniformOutput',false);
    set(handles.NextTrial,'Data',empty_cell,'ColumnName',rp);
else
    set(handles.NextTrial,'Data',empty_cell,'ColumnName',ROVED_PARAMS);
end
