function handles = cl_Callback_Airpuff(handles)
%handles = cl_Callback_Airpuff(handles)
%
%Custom function for Caras Lab
%
%This function triggers the airpuff when the Air Puff button is pressed
%Input:
%   handles: GUI handles structure
%
%Written by ML Caras May 1 2018
%Updated by ML Caras Oct 17, 2019


global AX RUNTIME

module = handles.module;
dev = handles.dev;
paramtag = 'AirPuff';

%Abort if airpuff parameter tag is not in the RPVds circuit
if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(dev).tags,paramtag)))== 0
    return
end

%Use Active X controls to trigger the airpuff
v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],1);

%Use Active X controls to reset trigger
v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],0);

end

