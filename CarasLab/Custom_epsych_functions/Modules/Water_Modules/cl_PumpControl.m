function varargout = cl_PumpControl
% varargout = cl_PumpControl
%
% Custom function for Caras Lab
% 
% This function sets and controls a New Era-1000 Syringe Pump.
%
% Outputs:
%   varargout{1}: serial port object associated with pump
%
%
% Written by DJ Stolzberg 2014
% Updated by ML Caras 2017
%Updated by ML Caras Dec 2019


%Close and delete all open serial ports
out = instrfind('Status','open');
if ~isempty(out)
    fclose(out);
    delete(out);
end

%Create a serial connection to the pump. Each rig uses a different COM
%port.Note that the COM port can change depending on which USB port the 
%pump is plugged into. If moving or re-assembling the rig for any reason, 
%beware!

username=getenv('USERNAME');

switch username
    case 'Rig 1'
        %Rig 1 uses COM6
        pump = serial('com6','BaudRate',19200,'DataBits',8,'StopBits',1,'TimerPeriod',0.1);
    case 'Rig 2'
        %Rig 2 uses COM3
        pump = serial('com3','BaudRate',19200,'DataBits',8,'StopBits',1,'TimerPeriod',0.1);  
    case 'Caras Lab' %Rig 3 in 4275
       pump = serial('com4','BaudRate',19200,'DataBits',8,'StopBits',1,'TimerPeriod',0.1);
end

fopen(pump);

warning('off','MATLAB:serial:fscanf:unsuccessfulRead')
set(pump,'Terminator','CR','Parity','none','FlowControl','none','timeout',0.1);


%Set up pump parameters. Obtain diameter, min and max rates from the last
%page of the NE-1000 Syringe Pump User Manual. Current values are for a 30
%ml B-D syringe.
fprintf(pump,'DIA%0.1f\n',21.5); % set inner diameter of syringe (mm)
fprintf(pump,'RAT%s\n','MM');    % set rate units to mL/min
fprintf(pump,'RAT%0.1f\n',18);   % set rate
fprintf(pump,'INF\n');           % set to infuse
fprintf(pump,'VOL%0.2f\n',0);    % set unlimited volume to infuse (==0)
fprintf(pump,'TRGLE\n');         % set trigger type

%Send out variable arguments, if appropriate
if nargout == 1 
    varargout{1} = pump;
else
    fclose(pump); delete(pump)
end

vprintf(0,'Connected to pump.')

















