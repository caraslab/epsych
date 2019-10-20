function handles = cl_FindRewardType(handles)
%handles = cl_FindRewardType(handles)
%
%Custom function for Caras Lab
%
%This function sets GUI parameters based on the reward type.
%
%Inputs:
%   handles: GUI handles   
%
%
%Written by ML Caras 4.5.2017
%Updated by ML Caras 10.19.2019


global REWARDTYPE


switch REWARDTYPE
    
    case 'water'
        
        set(handles.PelletCount,'ForeGroundColor',[0.5 0.5 0.5]);
        set(handles.PelletCountPanel,'ForeGroundColor',[0.5 0.5 0.5]);
        set(handles.numPellets,'enable','off');
        
        
    case 'food'
        
        set(handles.watervol,'ForeGroundColor',[0.5 0.5 0.5]);
        set(handles.watervolpanel,'ForeGroundColor',[0.5 0.5 0.5]);
        set(handles.reward_vol,'enable','off');
        set(handles.Pumprate,'enable','off');
        set(handles.waterAx,'visible','off');
end
