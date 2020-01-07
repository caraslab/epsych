function handles = cl_PopulateLoadedTrials(handles)
%handles = cl_PopulateLoadedTrials(handles)
%
%This function populates the trial filter table, and the reminder trial
%info table. It also gets and saves the java handle for the trial filter 
%table.
%
%Inputs:
%   handles: handles structure for GUI
%
%Outputs:
%   handles: handles structure for GUI
%
%Written by ML Caras 7.24.2016
%Updated by JDY & NP 10.9.2018
%Updated by ML Caras 10.19.2019
%Updated by ML Caras 1.07.2020 (Java compatability with 2018b)

global RUNTIME ROVED_PARAMS


%Pull trial list
trialList = RUNTIME.TRIALS.trials;
colnames = RUNTIME.TRIALS.writeparams;

%Find the index with the reminder info
remind_row = cl_FindReminderRow(colnames,trialList);
reminder_trial = trialList(remind_row,:);



%Set trial filter column names and find column with trial type
if RUNTIME.UseOpenEx
    strstart = length(handles.module)+2;
    rp =  cellfun(@(x) x(strstart:end), ROVED_PARAMS, 'UniformOutput',false);
    set(handles.ReminderParameters,'ColumnName',rp);
    set(handles.TrialFilter,'ColumnName',[rp,'Present']);
else
    set(handles.ReminderParameters,'ColumnName',ROVED_PARAMS);
    set(handles.TrialFilter,'ColumnName',[ROVED_PARAMS,'Present']);
end

colind =  cl_FindColumnIndex(ROVED_PARAMS,'TrialType',handles);

%Remove reminder trial from trial list
trialList(remind_row,:) = [];

%Set up two datatables
D_remind = cell(1,numel(ROVED_PARAMS));
D = cell(size(trialList,1),numel(ROVED_PARAMS)+1);

%For each roved parameter
for i = 1:numel(ROVED_PARAMS)
    
   %Find the appropriate index
   ind = find(strcmpi(ROVED_PARAMS(i),RUNTIME.TRIALS.writeparams));
 
   if isempty(ind)
       ind = find(strcmpi(['*', ROVED_PARAMS{i}],RUNTIME.TRIALS.writeparams));
   end
   
   %Add parameter each datatable
   D(:,i) = trialList(:,ind);
   D_remind(1,i) = reminder_trial(1,ind);
end

GOind = find([D{:,colind}] == 0);
NOGOind = find([D{:,colind}] == 1);
p   =   RUNTIME.TRIALS.writeparams;
sel =   strcmp(p,'AMrate1');
ssel    =   strcmp(p,'RZ6(1).AMrate1');
afcindx =   [sum(sel) sum(ssel)];
afcindx =   sum(afcindx);
if( afcindx == 1 )
    D(GOind,colind) = {'RIGHT'}; %#ok<*FNDSB>
    D(NOGOind,colind) = {'LEFT'};
    D_remind(1,colind) = {'REMIND'};
    D(:,end) = {'true'};
else
    D(GOind,colind) = {'GO'}; %#ok<*FNDSB>
    D(NOGOind,colind) = {'NOGO'};
    D_remind(1,colind) = {'REMIND'};
    D(:,end) = {'true'};
end

%Set formatting parameters
formats = cell(1,size(D,2));
formats(1,:) = {'numeric'};
formats(1,colind) = {'char'};
formats(1,end) = {'logical'};

editable = zeros(1,size(D,2));
editable(1,end) = 1;
editable = logical(editable);


%Special case: if "expected" is a parameter
if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(handles.dev).tags,'Expected')))
    expect_ind =  cl_FindColumnIndex(ROVED_PARAMS,'Expected',handles);
    YESind = find([D{:,expect_ind}] == 1); 
    NOind = find([D{:,expect_ind}] == 0); 
    D(YESind,expect_ind) = {'Yes'}; 
    D(NOind,expect_ind) = {'No'}; 
    formats(1,expect_ind) = {'char'}; 
end

%Populate roved trial list box
set(handles.TrialFilter,'Data',D)
set(handles.ReminderParameters,'Data',D_remind);
set(handles.TrialFilter,'ColumnFormat',formats);
set(handles.TrialFilter,'ColumnEditable',editable);






