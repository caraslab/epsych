function handles = cl_UpdateSoundLevelandFreq(handles)
%handles = cl_UpdateSoundLevelandFreq(handles)
%
%Custom function for Caras Lab
%
%This function updates sound level and frequency in the rpvds circuit.
%
%Input:
%   handles: GUI handles structure
%
%Written by ML Caras 7.28.2016
%Updated by ML Caras 10.19.2019

global AX RUNTIME


param_present = ~isempty(find(ismember(RUNTIME.TDT.devinfo(handles.dev).tags,'Freq'),1));
ampInd = find(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(handles.dev).tags,'_Amp')));
ampTag = ['.',RUNTIME.TDT.devinfo(handles.dev).tags{ampInd}]; %#ok<*FNDSB>


%If the user has GUI control over the sound frequency, set the frequency in
%the RPVds circuit to the desired value. Otherwise, simply read the
%frequency from the circuit directly.
switch get(handles.freq,'enable')
    case 'on'
        
        %Get sound frequency from GUI
        sound_freq = cl_GetValue(handles.freq);
        
        %Set the value in RPVds circuit
        v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.Freq'],sound_freq);
        
        %Set the menu dropdown color blue
        set(handles.freq,'ForegroundColor',[0 0 1]);
        
    otherwise
        
        %If Frequency is a parameter tag in the circuit, just get the freq
        if param_present
            sound_freq = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.Freq']);
        end
        
end


%Calculate the appropriate calibration adjustment
if param_present
    CalAmp = Calibrate(sound_freq,handles.C);
else
    CalAmp = handles.C.data(1,4);
end

%Send the calibration value to the RPVds circuit
v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,ampTag],CalAmp); %#ok<*NASGU>

%If the user has GUI control over the sound level, set the level in
%the RPVds circuit to the desired value. Otherwise, do nothing.
switch get(handles.level,'enable')
    case 'on'
       
        %Get sound level from GUI
        sound_level = cl_GetValue(handles.level);

        %Send the dBSPL value to the RPVds circuit
        if isfield(handles,'level2')
            v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.dBSPL1'],sound_level);
            
            sound_level2 = cl_GetValue(handles.level2);
            v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.dBSPL2'],sound_level2);
            %Set the dropdown menu color to blue
            set(handles.level2,'ForegroundColor',[0 0 1]);
        else
            v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,'.dBSPL'],sound_level);
            %Set the dropdown menu color to blue
            set(handles.level,'ForegroundColor',[0 0 1]);
        end
        
end
