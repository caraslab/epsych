function handles = cl_InitializeCalibration(handles)
%handles = cl_InitializeCalibration(handles)
%
%Custom function for Caras Lab
%
%This function prompts user to select and load a calibration file, and sets
%the normalization value correctly in the RPVds circuit. If an incorrect
%calibration file is loaded (i.e. a noise calibration file was selected
%when we need a tone calibration file), the user is alerted and prompted to
%make a new selection.
%
%
%Written by ML Caras 8.10.2016. 
%Updated by ML Caras 4.11.2018
%Updated by ML Caras 10.19.2019
%Updated by ML Caras 12.17.2019

global CONFIG RUNTIME AX SYN_STATUS

calcheck = 0;
loadtype = 0;

%Define RZ6 Module
if isempty(handles.module) || isempty(SYN_STATUS)
    flds = fields(CONFIG.PROTOCOL.MODULES);
    mod = flds{1};
    
    %If we're not running synapse, you can update the handles for the
    %module. Otherwise, leave it as is.
    if ~isempty(SYN_STATUS)
        handles.module = mod;               %kp 2016-12
    end
    
    %Warning if we can't find the right module
    if numel(flds) ~= 1
        vprintf(0,'**WARNING: Problem identifying RZ6 module for calibration.**');
    end
    
else
 
    %If the module is already defined, and we're not running synapse, use
    %the predefined module
    mod = handles.module;
end


while calcheck == 0
    
    fidx = 0;
    
    %Define calibration file
    if isfield(CONFIG.PROTOCOL.MODULES.(mod),'calibrations')
        ind = find(~cellfun('isempty',CONFIG.PROTOCOL.MODULES.(mod).calibrations(:)));
        
        if numel(ind)>1
            ind = ind(1);
            vprintf(0,'**WARNING: Problem identifying calibration file.**');
        end
        
        calfile = CONFIG.PROTOCOL.MODULES.(mod).calibrations{ind}.filename;
        fidx = 1;
        loadtype = 1; %Prevents endless looping
        
    %If undefined
    else
        
        if fidx == 0
            %Get the path for calibration file storage (preferred or default)
            defaultpath = pwd;
            calpath = getpref('PSYCH','CalDir',defaultpath);
            
            %Prompt user to select file
           
            %Note: The line below avoids a bug first observed using MATLAB 
            %2019b on a 64 bit Windows Platform, where MATLAB will freeze
            %and become unresponsive if the user clicks outside the
            %dialogue box before selecting a calibration file. The more
            %common fix of adding a drawnow; pause(0.10); line after the
            %dialog box command did not fix it.
            com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1);
            
            [fn,pn,fidx] = uigetfile([calpath,'\*.cal'],'Select speaker calibration file');
            calfile = fullfile(pn,fn);
            
            %If they selected a file, reset the preferred path
            if ischar(pn)
                setpref('PSYCH','CalDir',pn)
            end
            
            %If they selected a file, display file name
            if ischar(fn)
                vprintf(0,['Calibration file is: ' fn])
            end
        end
        
    end
    
    
    %Determine if we are running a circuit with frequency as a parameter
    parametertype = any(ismember(RUNTIME.TDT.devinfo(handles.dev).tags,'Freq'));
    
    
    %If the calibration file is still undefined, set to default
    if fidx == 0
        
        if parametertype == 1 %tones
            fn = 'DefaultTone.cal';
            
        elseif parametertype == 0 %noise
            fn = 'DefaultNoise.cal';
            
        end
        
        calfile = fullfile(defaultpath,fn);
        
        %Alert user and log it
        beep
        vprintf(0,['Calibration file undefined. Set to ',fn])
        
    end
    
    %Load the file
    handles.C = load(calfile,'-mat');
    calfiletype = ~feval('isempty',strfind(func2str(handles.C.hdr.calfunc),'Tone'));
    
    
    %If we loaded in the wrong calibration file type
    if calfiletype ~= parametertype && loadtype == 0;
        
        %Prompt user to reload file.
        beep
        vprintf(0,'Wrong calibration file loaded. Reload file.')
  
    elseif calfiletype ~= parametertype && loadtype == 1;
        
        %Warn user that calibration file might not be correct in protocol
        beep
        vprintf(0,'Warning: calibration file might not be compatible with protocol.')
        
    %Otherwise, we're good to go!
    else
        
        %Update the sound level and frequency
        handles = cl_UpdateSoundLevelandFreq(handles);
        
        %Store the calibration file name
        RUNTIME.TRIALS.Subject.CalibrationFile = calfile;
        
        
        %Set normalization value for calibation in RPVds circuit
        normInd = find(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(handles.dev).tags,'_norm')));
        normTag = ['.',RUNTIME.TDT.devinfo(handles.dev).tags{normInd}]; %#ok<*FNDSB>
        v = TDTpartag(AX,RUNTIME.TRIALS,[handles.module,normTag],handles.C.hdr.cfg.ref.norm);
        
        %Break out of while loop
        calcheck = 1;
    end
    
    
    

    
end
