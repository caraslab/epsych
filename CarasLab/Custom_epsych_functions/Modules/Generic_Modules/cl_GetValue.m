function output = cl_GetValue(handle)
%output = cl_GetValue(handle)
%
%Custom function for Caras Lab
%
%This function retreives the user-selected value of a GUI handle
%
%Input:
%   handle: GUI handle
%
%
%Written by ML Caras 7.28.2016
%Updated by ML Caras 10.19.2019


str = get(handle,'String');
val = get(handle,'Value');

output = str2num(str{val}); %#ok<*ST2NM>