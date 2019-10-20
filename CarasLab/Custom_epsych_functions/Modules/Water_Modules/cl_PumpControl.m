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


%Close and delete all open serial ports
out = instrfind('Status','open');
if ~isempty(out)
    fclose(out);
    delete(out);
end

%Create a serial connection to the pump
pump = serial('com1','BaudRate',19200,'DataBits',8,'StopBits',1,'TimerPeriod',0.1);
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

















