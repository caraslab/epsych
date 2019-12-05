function [RUNTIME,varargout]  = ReadSynapseTags(SYN,RUNTIME)
%[RUNTIME,varargout]  = ReadSynapseTags(SYN,RUNTIME)
%
%Custom function for Caras Lab.
%Reads parameter tags using Synapse API
%
%SYN is the handle to the Synapse API control
%
%Written by ML Caras Apr 7 2018
%Updated by ML Caras Oct 19 2019
%Updated by ML Caras Nov 24 2019

warning('off','MATLAB:strrep:InvalidInputType')

%Find out how many modules there are.
%Note: When run in Matlab 2019b, the command below gave an error 
%on the first time it was called. No idea why- adding
%a pause of a full second to let RUNTIME initialize didn't solve it.
%Therefore, we'll embed the command in a try/catch and while statement,
%so it ends up being called multiple times until it works. Most of the
%time, the second call is sufficient to run it, but ocassionally, again for
%unknown reasons, additional calls are needed.
trying = 1;
badcount = 0;

while trying == 1
    
    try
        nMods = numel(RUNTIME.TDT.name);
        trying = 0;
    catch
        
        %Sometimes, for no reason, matlab still can't execute the function.
        %In this case, let the error be thrown.
        badcount = badcount + 1;
        if badcount > 10
        error('MATLAB is having trouble connecting to TDT. This is a known bug that occurs sporadically. Restart MATLAB.')
        end
    end
    
end

for i = 1:nMods
    dinfo(i).tags = {[]};
    dinfo(i).datatypes = {[]};
end
    

%Get Gizmo Names
gizmo_names = SYN.getGizmoNames();

%For each gizmo..
for j = 1:numel(gizmo_names)
    gizmo = gizmo_names{j};
    
    %Find the parent module
    module = SYN.getGizmoParent(gizmo);
    
    %Find the appropriate index for the module
    if ~module
        for m = 1:nMods
            modInfo = SYN.getGizmoInfo(RUNTIME.TDT.name{m});
            if strcmp(modInfo.cat,'Legacy')
                ind = m;
                break
            end
        end
        
    else
        module = module(1:regexp(module,'\_')-1);
        ind = find(cell2mat(cellfun(@(x) ~isempty(x),strfind(RUNTIME.TDT.name,module),'UniformOutput',false)));
    end
    
    %Read the parameter tags
    params = SYN.getParameterNames(gizmo);
    
    %Abort if there are no tags
    if isempty(params)
        continue
    end
    
    kk = 0;
    
    %For each parameter
    for k = 1:numel(params)
        param = params{k};
        
        %Abort if the tag is an OpenEx proprietary tag
        if any(ismember(param,'/\|')) || ~isempty(strfind(param,'rPvDsHElpEr')) %#ok<*STREMP>
            continue
        end
        
        %Otherwise, get datatype for the parameter
        try
            info = SYN.getParameterInfo(gizmo,param);
            paramtype = info.Type;
        catch
            paramtype = 'Trig'; %probably a trigger embedded in an epsych macro
        end
        
        kk = kk+1;
        %Append to cell array
        dinfo(ind).tags{kk} = param; %#ok<*AGROW>
        dinfo(ind).datatypes{kk} = paramtype; 
    end

end

%Append to RUNTIME Structure
for i = 1:nMods
    RUNTIME.TDT.devinfo(i).tags = dinfo(i).tags;
    RUNTIME.TDT.devinfo(i).datatype = dinfo(i).datatypes;
    RUNTIME.TDT.tags{i} = dinfo(i).tags;
    RUNTIME.TDT.datatypes{i} = dinfo(i).datatypes;
end

if nargout > 1
    varargout{1} = dinfo;
end


warning('on','MATLAB:strrep:InvalidInputType')
