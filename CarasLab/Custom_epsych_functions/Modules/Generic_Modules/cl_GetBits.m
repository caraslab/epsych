function bits = cl_GetBits
%bits = cl_GetBits
%
%Custom function for Caras Lab
%
%This function retreives the bit information for hits, misses, correct
%rejects, and false alarms for each paradigm.
%
%
%Written by ML Caras 7.25.2016
%Updated by ML Caras 10.19.2019

global FUNCS

%Find the name of the GUI box figure
boxfig = FUNCS.BoxFig;

switch lower(boxfig)
    case {'cl_aversivedetection','cl_appetitivedetection'}
        bits.hit = 1;
        bits.miss = 2;
        bits.cr = 3;
        bits.fa = 4;
        
    case {'cl_appetitivedetection_afc'}
        bits.hit = 1;
        bits.miss = 2;
        bits.abo = 3;
        bits.hang = 4;
        
    %Default
    otherwise
        warning('Box Figure not defined in cl_GetBits.m. Response code bits set to default.');
        bits.hit = 1;
        bits.miss = 2;
        bits.cr = 3;
        bits.fa = 4;
end
