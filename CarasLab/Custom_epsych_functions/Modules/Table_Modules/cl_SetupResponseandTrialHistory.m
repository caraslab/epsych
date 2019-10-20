function handles = cl_SetupResponseandTrialHistory(handles)
%handles = cl_SetupResponseandTrialHistory(handles)
%
%Custom function for Caras Lab
%
%This function sets up the GUI response and trial history tables
%
%Inputs:
%   handles: handles structure for GUI
%
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019


global RUNTIME ROVED_PARAMS

%%%
AFCindex    =   strcmp(ROVED_PARAMS,'AMrate1') | strcmp(ROVED_PARAMS,'AMrate2');
AFCflag     =   sum(AFCindex);
%%%

%Set up Response History table
cols = cell(1,numel(ROVED_PARAMS)+1);

if RUNTIME.UseOpenEx
    strstart = length(handles.module)+2;
    rp =  cellfun(@(x) x(strstart:end), ROVED_PARAMS, 'UniformOutput',false);
    cols(1:numel(ROVED_PARAMS)) = rp;
else
    cols(1:numel(ROVED_PARAMS)) = ROVED_PARAMS;
end

cols(end) = {'Response'};
datacell = cell(size(cols));
set(handles.DataTable,'Data',datacell,'RowName','0','ColumnName',cols);


%Set up Trial History Table
cols(end) = {'# Trials'};
cols(end+1) = {'Hit rate(%)'};
if( ~AFCflag )
    cols(end+1) = {'dprime'};
end
set(handles.TrialHistory,'Data',datacell,'ColumnName',cols);
