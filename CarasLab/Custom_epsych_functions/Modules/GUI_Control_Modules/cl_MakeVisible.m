function cl_MakeVisible(h,dev,param)
%cl_MakeVisible(h,dev,param)
%
%Custom function for Caras Lab
%
%This function makes certain GUI text and dropdown menus visible if the 
%correct parameter tags are available in the circuit.
%
%Inputs:
%   h: handles of dropdown menu or text
%   dev: index of RZ6 TDT module
%   param: parameter tag string
%
%
%Written by ML Caras 3.15.2018
%Updated by ML Caras 10.19.2019


global RUNTIME

%Tag name in RPVds
tag = param;

%Is the tag in the cicuit?
circuit_tags = RUNTIME.TDT.devinfo(dev).tags;

if ~isempty(find(ismember(circuit_tags,tag),1))
    set(h,'visible','on');
end