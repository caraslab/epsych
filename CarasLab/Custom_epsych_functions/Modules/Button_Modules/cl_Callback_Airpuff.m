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


global AX RUNTIME G_DA

module = handles.module;
dev = handles.dev;
paramtag = 'AirPuff';


if (isa(AX,'COM.RPco_x')||isa(AX,'COM.TDevAcc_X'))
    
    %Abort if airpuff parameter tag is not in the RPVds circuit
    if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(dev).tags,paramtag)))== 0
        return
    end
    
    %Use Active X controls to trigger the airpuff
    v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],1);
    
    %Use Active X controls to reset trigger
    v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],0);
    
    
elseif isa(G_DA,'COM.TDevAcc_X')
    
    %Use open developer controls to trigger the airpuff
    v = G_DA.SetTargetVal([module,'.',paramtag],1);
    
    %Use open developer controls to reset the trigger
    v = G_DA.SetTargetVal([module,'.',paramtag],0);
    
else

    return
    
end

