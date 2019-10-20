function [HITind,MISSind,CRind,FAind,GOind,NOGOind,REMINDind,reminders,...
    variables,TrialTypeInd,TrialType,waterupdate,handles,bits,varargout] = ...
    cl_UpdateParamsRuntime(waterupdate,ntrials,handles,bits)
%[HITind,MISSind,CRind,FAind,GOind,NOGOind,REMINDind,reminders,...
%    variables,TrialTypeInd,TrialType,waterupdate,handles,bits,varargout] = ...
%    cl_UpdateParamsRuntime(waterupdate,ntrials,handles,bits)
%
%Custom function for Caras Lab

%This function updates parameters during GUI runtime
%
%Inputs:
%   waterupdate: scalar value to track whether GUI text displaying
%                water volume has been updated 
%                (if updated, is identical to ntrials)
%
%   ntrials:     scalar value indicating the number of trials completed
%
%   handles:     GUI handles structure
%
%   bits:        structure returned by cl_GetBits.m containing bit
%                information for response codes (i.e. the hit bit, fa bit, etc). Can
%                also pass an empty matrix, and it will be updated by
%                cl_GetBits.m.
%
%Outputs:
%   HITind:     logical index pointing to all the previous HIT responses
%
%   MISSind:    logical index pointing to all the previous MISS responses
%
%   CRind:      logical index pointing to all the previous CORRECT REJECT responses
%
%   FAind:      logical index pointing to all the previous FALSE ALARM responses
%
%   GOind:      numerical (non-logical) index pointing to all the GO trial rows
%               in the variables matrix (see below)
%
%   NOGOind:    numerical (non-logical) index pointing to all the NOGO trial rows
%               in the variables matrix 
%
%   REMINDind:  numerical (non-logical) index pointing to all the REMINDER trial rows
%               in the variables matrix 
%
%   reminders:  vector indicating reminder status (0= no, 1 = yes) for all
%               previous trials
%
%   varaibles:  matrix created from RUNTIME.DATA structure containing trial
%               information for each roved paramater
%
%   TrialTypeInd: index of the TrialType Column in the ROVED_PARAMS array
%
%   TrialType:    the TrialType column in the variables matrix
%
%   waterupdate:  scalar value to track whether GUI text displaying
%                 water volume has been updated (see above)
%
%   handles:      GUI handles structure
%
%   bits:         structure returned by cl_GetBits.m containing bit
%                 information for response codes
%
%
%Written by ML Caras 7.25.2016
%Updated by KP 11.05.2016 (param WAV/MAT compatibility)
%Updated by ML Caras 10.19.2019


global RUNTIME ROVED_PARAMS REWARDTYPE


%DATA structure
DATA = RUNTIME.TRIALS.DATA;

%Retreive response code bits
if isempty(bits)
    bits = cl_GetBits;
end

bitmask = [DATA.ResponseCode]';
HITind  = logical(bitget(bitmask,bits.hit));
MISSind = logical(bitget(bitmask,bits.miss));
CRind   = logical(bitget(bitmask,bits.cr));
FAind   = logical(bitget(bitmask,bits.fa));

switch REWARDTYPE
    case 'water'
        %If the water volume text is not up to date...
        if waterupdate < ntrials
            
            %Update the water text
            handles = cl_UpdateWater(handles);
            waterupdate = ntrials;
            
        end 
end

%Update roved parameter variables
h = cl_FindModuleIndex('RZ6',[]);
strstart = length(h.module)+2;

for i = 1:numel(ROVED_PARAMS)
    
    if RUNTIME.UseOpenEx
        if regexp(ROVED_PARAMS{i},'~.+_ID')            %kp
            vstr = ROVED_PARAMS{i}(strstart+1:end);    %kp
        else
            vstr = ROVED_PARAMS{i}(strstart:end);
        end
        eval(['variables(:,i) = [DATA.' vstr ']'';'])
    else
        if regexp(ROVED_PARAMS{i},'~.+_ID')            %kp
            vstr = ROVED_PARAMS{i}(2:end);             %kp
        else
            vstr = ROVED_PARAMS{i};
        end
        eval(['variables(:,i) = [DATA.' vstr ']'';'])
    end
    
end


%Update reminder status
reminders = [DATA.Reminder]';


%Find indices for different trial types
%TrialTypeInd =  cl_FindTrialTypeColumn(ROVED_PARAMS);
TrialTypeInd =  cl_FindColumnIndex(ROVED_PARAMS,'TrialType',handles);

TrialType = variables(:,TrialTypeInd);

GOind = find(TrialType == 0);
NOGOind = find(TrialType == 1);
REMINDind = find(reminders == 1);



%Special case: if 'Expected' is a parameter tag in the circuit
if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(handles.dev).tags,'Expected')))
    
    if RUNTIME.UseOpenEx
        expectInd = find(strcmpi([handles.module,'.Expected'],ROVED_PARAMS));
    else
        expectInd = find(strcmpi('Expected',ROVED_PARAMS));
    end
    
    expected = variables(:,expectInd);
    
    varargout{1} = expectInd;
    varargout{2} = find(expected == 1); %YESind
    varargout{3} = find(expected == 0); %NOind
    
else
    varargout{1} = [];
    varargout{2} =[]; 
    varargout{3} = []; 
    
end


end