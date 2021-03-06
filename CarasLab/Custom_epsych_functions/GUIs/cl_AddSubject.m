function varargout = cl_AddSubject(varargin)
%S = cl_AddSubject.m
%
%Custom function for adding a new subject for a Caras Lab experiment.
%
%Created by ML Caras Jun 9 2015
%
% Last Modified by GUIDE v2.5 24-Nov-2019 10:17:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cl_AddSubject_OpeningFcn, ...
                   'gui_OutputFcn',  @cl_AddSubject_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cl_AddSubject is made visible.
function cl_AddSubject_OpeningFcn(hObj, ~, h, varargin)
h.output = hObj;

%Set Box ID
set(h.box_id,'String',1:16,'Value',1);

%Set Condition
condition = getpref('cl_AddSubject','condition','< ADD CONDITION >');
condition = cellstr(condition);
condition = cellfun(@(a) (a(:)'),condition,'uniformoutput',false);
usercond = cellstr(getpref('cl_AddSubject','user_conditions',''));
sval = find(ismember(condition,usercond),1);
if isempty(sval), sval = 1; end
set(h.condition,'String',condition,'Value',sval);
condition_Callback(h.condition)



% handle inputs
S = varargin{1};
boxids = varargin{2};


if ~isempty(S) && isstruct(S)
    PopulateFields(S,h);
end

if isvector(boxids)
    set(h.box_id,'String',boxids,'Value',1)
end

guidata(hObj, h);
uiwait(h.cl_AddSubject);


% --- Outputs from this function are returned to the command line.
function varargout = cl_AddSubject_OutputFcn(hObj, ~, ~)
varargout{1} = [];
if ~ishandle(hObj), return; end
h = guidata(hObj);
if isfield(h,'S'), varargout{1} = h.S; end
close(h.cl_AddSubject);


function PopulateFields(S,h)
if isfield(S,'BoxID')
    n = str2num(get(h.box_id,'String')); %#ok<ST2NM>
    idx = find(S.BoxID == n,1);
    if ~isempty(idx)
        set(h.box_id,'Value',idx)
    end
end

if isfield(S,'Name')
    set(h.subject_name,'String',S.Name);
end

if isfield(S,'Sex')
    idx = find(ismember(get(h.sex,'String'),S.Sex),1);
    if ~isempty(idx)
        set(h.sex,'Value',idx)
    end
end

if isfield(S,'Condition')
    idx = find(ismember(get(h.condition,'String'),S.Condition),1);
    if ~isempty(idx)
        set(h.condition,'Value',idx)
    end
end


if isfield(S,'Age')
    idx = find(ismember(get(h.age,'String'),S.Age),1);
    if ~isempty(idx)
        set(h.age,'Value',idx)
    end
end

if isfield(S,'recdepth')
    set(h.recdepth,'String',S.RecordingDepth);
end

if isfield(S,'Notes')
    set(h.notes,'String',S.Notes);
end


function condition_Callback(hObj)
s = get_string(hObj);

if ~strcmp(s,'< ADD CONDITION >')
    setpref('cl_AddSubject','user_conditions',s);
    return
end

alls = get(hObj,'String');

news = inputdlg('Enter new condition:','Add Subject',1);
if isempty(char(news))
    set(hObj,'Value',1);
    return
end

news = strtrim(news);

if ismember(news,alls)
    msgbox('Condition Already Exists');
    return
end
alls = [news;alls(:)];
set(hObj,'String',alls,'Value',1);

news = char(news);

setpref('cl_AddSubject',{'condition','user_conditions'},{alls,news})

fprintf('A new condition was added to the list: %s\n',news)




function S = CollectSubjectInfo(h)
S.BoxID   = str2double(get_string(h.box_id));
S.Name    = strtrim(get(h.subject_name,'String'));
S.Sex     = strtrim(get_string(h.sex));
S.Condition = get_string(h.condition);
S.Age = strtrim(get_string(h.age));
S.RecordingDepth = strtrim(get(h.recdepth,'String'));
S.Notes   = get(h.notes,'String');





function Done(h) %#ok<DEFNU>
h.S = CollectSubjectInfo(h);

hObj = h.cl_AddSubject;

guidata(hObj,h);

if isequal(get(hObj, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(hObj);
else
    % The GUI is no longer waiting, just close it
    delete(hObj);
end



function recdepth_Callback(hObject, eventdata, handles)
% hObject    handle to recdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recdepth as text
%        str2double(get(hObject,'String')) returns contents of recdepth as a double


% --- Executes during object creation, after setting all properties.
function recdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
