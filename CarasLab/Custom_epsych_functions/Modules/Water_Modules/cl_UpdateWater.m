function output = cl_UpdateWater(varargin)
%output = cl_UpdateWater(varargin)
%
% Custom function for Caras Lab
%
%This function queries the pump to obtain the delivered water volume, and 
%updates the GUI text, if appropriate
%
%Inputs:
%   varargin{1}: GUI handles structure
%
%
%Written by ML Caras 7.25.2016
%Updated by ML Caras 10.19.2019

global PUMPHANDLE

%Wait for pump to finish water delivery
pause(0.06)
    
%Flush the pump's input buffer
flushinput(PUMPHANDLE);

%Query the total dispensed volume
fprintf(PUMPHANDLE,'DIS');
[V,count] = fscanf(PUMPHANDLE,'%s',10); %#ok<*ASGLU> %very very slow

%Pull out the digits and display in GUI
ind = regexp(V,'\.');

%Return volume as string embedded in handles structure (online runtime, 
%or as a double (for final saving).
if nargin == 1
    handles = varargin{1};
    V = V(ind-1:min(ind+3,length(V))); %kp 2017-10 fixed error when V only returns with 2 decimal places
    set(handles.watervol,'String',V);
    output = handles;
else
    output = str2num((V(ind-1:ind+3))); %#ok<*ST2NM>
end