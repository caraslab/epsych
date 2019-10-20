function cl_DisableDropDown(h,dev,module,param)
%cl_DisableDropDown(h,dev,module,param)
%
%Custom function for Caras Lab.
%
%This function disables the dropdown button if the parameter is roved, or
%if the parameter tag does not exist in the circuit.
%
%Inputs:
%   h: handles of dropdown menu
%   dev: index of RZ6 TDT module
%   module: name of RZ6 TDT module
%   param: parameter tag string
%
%Example usage: cl_DisableDropdown(handles.freq,handles.dev,handles.module,'Freq')
%
%Written by ML Caras 7.24.2016
%Updated by ML Caras 10.19.2019


global RUNTIME 

%Tag name in RPVds
tag = param;

%Rename parameter for OpenEx Compatibility
if RUNTIME.UseOpenEx
    param = [module,'.',param];
end

%Disable dropdown if it's not a parameter tag in the circuit,
%or if it is set in the protocol (it's a writeparam)
circuit_tags = RUNTIME.TDT.devinfo(dev).tags;
write_params = RUNTIME.TRIALS.writeparams;


if isempty(find(ismember(circuit_tags,tag),1)) ||...
        ~isempty(find(ismember(write_params,param),1))
    set(h,'enable','off');
end
