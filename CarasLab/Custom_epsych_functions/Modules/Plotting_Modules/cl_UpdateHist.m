function hist = cl_UpdateHist(TTLstr,hist,handles)
%hist = cl_UpdateHist(TTLstr,hist,handles)
%
%Custom function for Caras Lab
%
%This function updates the TTL history for plotting purposes
%
%Inputs: 
%   TTLstr: String identifying the TTL 
%   hist: vector containing TTL high/low history
%   handles: GUI handles structure
%
%Example usage: spout_hist = cl_UpdateHist('Spout_TTL',spout_hist,handles)
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019

global RUNTIME AX

goodstr = [];

%Is the tag in the circuit?
if ~isempty(cell2mat(strfind(RUNTIME.TDT.devinfo(handles.dev).tags,TTLstr)))
    
    goodstr = TTLstr;
    
%Backwards compatability: older circuits may lack the '~' for TTLs    
elseif strcmp(TTLstr(1),'~') && ~isempty(cell2mat(strfind(RUNTIME.TDT.devinfo(handles.dev).tags,TTLstr(2:end))))
    
    goodstr = TTLstr(2:end);
end


%Abort if tag is not in circuit
if isempty(goodstr)
    return
end


%Update the history
if RUNTIME.UseOpenEx
    goodstr = [handles.module,'.',goodstr];
    TTL = AX.GetTargetVal(goodstr);
else
    TTL = AX.GetTagVal(goodstr);
end

hist = [hist;TTL];