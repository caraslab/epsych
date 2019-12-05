function TRIALS = cl_TrialFcn_BasicCharacterization(TRIALS)
%NextTrialID = cl_TrialFcn_BasicCharacterization(TRIALS)
%
%Custom function for Caras Lab epsych
%
%This function controls the Basic Characterization program and GUI.
%
% Inputs: 
%   TRIALS: RUNTIME.TRIALS structure
%
% Outputs:
%   NextTrialID: Index of a row in TRIALS.trials. This row contains all
%       of the information for the next trial.
%
%Written by ML Caras
%Updated by ML Caras Oct 17, 2019

global TONE_CAL NOISE_CAL

%If the calibration directory preference already exists, use it, otherwise,
%use the present working directory as the default path
defaultpath = pwd;
caldir = getpref('PSYCH','CalDir',defaultpath);
   


%If it's the start
if TRIALS.tidx == 1
  
    %Load tone calibration file
    [fn,pn,fidx] = uigetfile([caldir,'\*.cal'],'Select tone calibration file');
    tone_calfile = fullfile(pn,fn);
    
    disp(['Tone calibration file is: ' tone_calfile])
    TONE_CAL = load(tone_calfile,'-mat');
    
    %Load noise calibration file
    [fn,pn,fidx] = uigetfile([caldir,'\*.cal'],'Select noise calibration file');
    noise_calfile = fullfile(pn,fn);
    
    disp(['Noise calibration file is: ' noise_calfile])
    NOISE_CAL = load(noise_calfile,'-mat');
    
    %Update the calibration directory preference
    setpref('PSYCH','CalDir',pn);
    
    %Launch basic characterization gui
    cl_basic_characterization
    
end