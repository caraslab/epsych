function cl_CloseGUI(hObject)
%cl_CloseGUI(hObject)
%
%Custom function for Caras Lab
%
%This function closes the COM port to the pump,cleans up global and 
%persistent variables, closes log files, and closes the GUI window.
%
%Input:
%   hObject: handle to GUI figure
%
%Written by ML Caras 7.28.2016. 
%Updated by ML Caras 4.21.2017.
%Updated by ML Caras 10.19.2019.
%
%To do: Update deletion of persistent variables in trial function. 
%       Stop hardcoding function names.


global RUNTIME PUMPHANDLE GLogFID

%Check to see if user has already pressed the master stop button
if ~isempty(RUNTIME)
    
    if RUNTIME.UseOpenEx
        h = findobj('Type','figure','-and','Name','ODevFig');
    else
        h = findobj('Type','figure','-and','Name','RPfig');
    end
    
    %If not, prompt user to press STOP
    if ~isempty(h)
        beep
        warnstring = 'You must press STOP before closing this window';
        warnhandle = warndlg(warnstring,'Close warning'); %#ok<*NASGU>
    else
        if ~isempty(PUMPHANDLE)
            %Close COM port to PUMP
            fclose(PUMPHANDLE);
            delete(PUMPHANDLE);
        end
        
        %Clean up global variables
        clearvars -global PUMPHANDLE CONSEC_NOGOS SHOCK_ON AUTOSHOCK
        clearvars -global GUI_HANDLES ROVED_PARAMS USERDATA
        
        
        %Clean up persistent variables in trial function
        clear cl_TrialFcn
        
        %Delete figure
        delete(hObject)
        
    end
    
else
    
    if ~isempty(PUMPHANDLE)
        %Close COM port to PUMP
        fclose(PUMPHANDLE);
        delete(PUMPHANDLE);
    end
    
    %Close log files
    if ~isempty(GLogFID) && GLogFID >2
        fclose(GLogFID);
    end
    
    
    %Clean up global variables
    clearvars -global PUMPHANDLE CONSEC_NOGOS GLogFID GVerbosity
    clearvars -global GUI_HANDLES ROVED_PARAMS USERDATA
    
    %Clean up persistent variables in trial function
    clear cl_TrialFcn
    
    %Delete figure
    delete(hObject)
    
end