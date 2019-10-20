function cl_UpdateSoundDur(handles)
%cl_UpdateSoundDur(handles)
%
%Custom function for Caras Lab
%
%This function updates the sound duration in the RPVds circuit
%
%Inputs:
%   handles: GUI handles structure
%
%
%Written by ML Caras 7.25.2016
%Updated by ML Caras 10.19.2019


global AX %RUNTIME

switch get(handles.sound_dur,'enable')
    
    case 'on'
        %Get sound duration from GUI
        soundstr = get(handles.sound_dur,'String');
        soundval = get(handles.sound_dur,'Value');
        sound_dur = str2num(soundstr{soundval})*1000; %#ok<*ST2NM> %in msec
        
        %Use Active X controls to set duration directly in RPVds circuit
        v = TDTpartag(AX,[handles.module,'.Stim_Duration'],sound_dur);

        
        set(handles.sound_dur,'ForegroundColor',[0 0 1]);
        
end