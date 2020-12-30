function TRIALS = cl_TrialFcn_FreqTuning(TRIALS)
%NextTrialID = cl_TrialFcn_FreqTuning(TRIALS)
%
%Custom function for Caras Lab epsych
%
%This function controls the Frequency Tuning program and GUI.
%
% Inputs: 
%   TRIALS: RUNTIME.TRIALS structure
%
% Outputs:
%   NextTrialID: Index of a row in TRIALS.trials. This row contains all
%       of the information for the next trial.
%
%Written by ML Caras Dec 30, 2020


global TONE_CAL G_DA SYN

%If the calibration directory preference already exists, use it, otherwise,
%use the present working directory as the default path
defaultpath = pwd;
caldir = getpref('PSYCH','CalDir',defaultpath);
   


%If it's the start
if TRIALS.tidx == 1
  
    %Load tone calibration file
    [fn,pn,fidx] = uigetfile([caldir,'\*.cal'],'Select tone calibration file'); %#ok<ASGLU>
    tone_calfile = fullfile(pn,fn);
    
    disp(['Tone calibration file is: ' tone_calfile])
    TONE_CAL = load(tone_calfile,'-mat');
    
    %Update the calibration directory preference
    setpref('PSYCH','CalDir',pn);
    
    %Initialize physiology and launch common average referencing
    [~,G_DA] = cl_InitializePhysiology([],G_DA);
    SYN = cl_ReferencePhysiology([],SYN);
    
end