function handles = cl_SaveGUISettings(handles)
%handles = cl_SaveGUISettings(handles)
%
%Custom function for Caras Lab
%
%This function saves GUI settings to a file (*.GUIset) 
%that can be re-loaded at a later date.
%
%Inputs: 
%   handles: GUI handles structure
%
%Written by ML Caras 8.3.2016. 
%Updated by ML Caras 10.19.2019



%Get the prefered directory
pn = getpref('PSYCH','ProtDir',cd);

%If the preferred directory doesn't exist, use the current directory
if ~ischar(pn)
    pn = cd;
end

%Prompt user to select file name and storage location
[fn,pn] = uiputfile({'*.GUIset','GUI Settings File File (*.GUIset)'}, ...
    'Save GUI Settings File',pn);

%If the user cancelled, abort the function
if ~fn
    return;
end

%Create the file name
fn = fullfile(pn,fn);

%Update the directory preferences
setpref('PSYCH','ProtDir',pn);




%Find the fieldnames for all dropdown menu options and checkboxes
flds = fieldnames(handles);

for i = 1:length(flds)
   
    if ~isstruct(handles.(flds{i}))
        
        if( strcmp(flds{i},'module') )  %%%Added this because of weird error - JDY 12/16/16%%%
            flds{i} = [];
        else
            try
            subflds = get(handles.(flds{i}));
            end
        end
        
        if ~isfield(subflds,'Style')|| any(strcmp(subflds.Style,{'pushbutton','text'}))
            flds{i} = [];
        end
    else
        flds{i} = [];
    end
    
end

flds = flds(~cellfun('isempty',flds));

%Now save some values
saveStructure.flds = flds;

for i = 1:length(flds)
    property(i).Value = get(handles.(flds{i}),'Value'); %#ok<*AGROW>
    property(i).String = get(handles.(flds{i}),'String');
end

saveStructure.property = property; %#ok<*STRNU>

save(fn,'saveStructure','-mat');

%Update the user
vprintf('Saved GUI settings\nFile Location: ''%s''\n',fn')
