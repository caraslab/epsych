function [handles,AX] = cl_InitializePhysiology(handles,AX)
%[handles,AX] = cl_InitializePhysiology(handles,AX)
%
%Custom function for Caras Lab
%
%This function creates an initial weight matrix for common average
%referencing of multi-channel recordings. This initial matrix is unweighted
%(i.e. no common averaging is applied). The matrix is sent directly 
%to the RPVds circuit. This function also enables or disables the reference
%physiology button in the GUI, as appropriate. The number of recording
%channels is identified via a parameter tag ('nChannels') in the RZ5 
%circuit. If no tag exists, the number of channels defaults to 16.
%
%Inputs:
%   handles: GUI handles structure
%   AX: handle to Active X controls
%
%Written by ML Caras 7.24.2016. 
%Updated 8.25.2016. 
%Updated 2.20.2018. (RZ2 compatibility)
%Updated 4.12.2018. (Synapse compatibility)
%Updated 10.19.2019

global RUNTIME SYN_STATUS SYN

%If we're running synapse
if isempty(SYN_STATUS)
    
    %Look through each gizmo
    gizmos = SYN.getGizmoNames();
    
    %Find the gizmo with the WeightMatrix parameter tag
    for i = 1:numel(gizmos)
        gizmo = gizmos{i};
        params = SYN.getParameterNames(gizmo);
        
        if ~iscell(params)
            continue
        end
        
        if any(~cellfun('isempty',strfind(params,'WeightMatrix'))); %#ok<*STRCL1>
            chk = 1;
            break;
        end
        
    end
    
    %If we found the gizmo, continue. Otherwise, return to invoking
    %function, and warn user
    if ~chk
        warning('WARNING: Unable to find common average referencing gizmo. Check Synapse processing tree.')
        return
    end
    
    %Find the number of channels in the circuit 
    n = SYN.getParameterValue(gizmo,'nChannels');
    
    
    %Create initial, non-biased weights
    v = ones(1,n);
    WeightMatrix = diag(v);
    
    %Reshape matrix into single row for RPVds compatibility
    WeightMatrix =  reshape(WeightMatrix',[],1);
    WeightMatrix = WeightMatrix';
    
    %Send value to Synapse Gizmo
    %Note: For sending arrays to Synapse, must use the plural version of 
    %the command: setParameterValues (not SetParameterValue)
    SYN.setParameterValues(gizmo,'WeightMatrix',WeightMatrix);
    
    %Enable reference physiology button in gui
    set(handles.ReferencePhys,'enable','on')
    

%If we're not running synapse    
else
    
    %If we're using OpenEx,
    if RUNTIME.UseOpenEx
        
        %Find the index of the physiology device
        h = cl_FindModuleIndex('Phys', handles);
        
        %Find the number of channels in the circuit via a parameter tag
        n = AX.GetTargetVal([h.module,'.nChannels']);
        
        if n == 0
            n = 16; %Default to 16 channel recording if no param tag, and
            vprintf(0,'Number of recording channels is not defined in RPVds circuit. \nSet to default (16).')
        end
        
        %Create initial, non-biased weights
        v = ones(1,n);
        WeightMatrix = diag(v);
        
        %Reshape matrix into single row for RPVds compatibility
        WeightMatrix =  reshape(WeightMatrix',[],1);
        WeightMatrix = WeightMatrix';
        
        AX.WriteTargetVEX([h.module,'.WeightMatrix'],0,'F32',WeightMatrix);
        
        %Enable reference physiology button in gui
        set(handles.ReferencePhys,'enable','on')
        
    else
        %Disable reference physiology button in gui
        set(handles.ReferencePhys,'enable','off')
        set(handles.ReferencePhys,'BackgroundColor',[0.9 0.9 0.9])
    end
end