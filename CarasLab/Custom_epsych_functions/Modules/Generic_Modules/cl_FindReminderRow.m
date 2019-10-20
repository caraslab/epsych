function [remind_row,varargout] = cl_FindReminderRow(colnames,trials)
%[remind_row,varargout] = cl_FindReminderRow(colnames,trials)
%
%Custom function for Caras Lab
%
%This function finds the row and column index for the reminder trial
%
%Inputs:
%   colnames: cellstring array of column names
%   trials: cell array of trial parameters 
%
%Written by ML Caras 7.22.2016
%Updated by ML Caras 4.6.2018
%Updated by ML Caras 10.19.2019

 
%Find the column that specifies whether a trial (row) is a reminder trials
rc = cellfun(@(x) strfind(x,'Reminder'), colnames, 'UniformOutput', false);
remind_col = find(cell2mat(cellfun(@(x) ~isempty(x), rc, 'UniformOutput', false)));


if isempty(remind_col)
    warning('Warning: No reminder trial specified in protocol.')
end

%Find the trial (row) that is a reminder trial
remind_row = find([trials{:,remind_col}] == 1);



%If asked for, also return the column
if nargout>1
    varargout{1} = remind_col;
end


end
