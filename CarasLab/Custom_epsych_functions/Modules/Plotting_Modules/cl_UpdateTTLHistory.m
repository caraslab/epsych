function [handles,xmin,xmax,varargout] = cl_UpdateTTLHistory(handles,starttime,event)
%[handles,xmin,xmax,varargout] = cl_UpdateTTLHistory(handles,starttime,event)
%
%Custom function for Caras Lab
%
%This function updates the TTL history for plotting purposes
%
%Inputs: 
%   handles: GUI handles structure
%   starttime: experiment start time
%   event: event time
%
%Outputs:
%   handles: GUI handles structure
%   xmin: x axis minimum value
%   xmax: x axis maximum value
%
%   varargout{1} = [1xN] vector of timestamps
%   varargout{2} = [1xN] vector of the InTrial TTL value (0 or 1)
%   varargout{3} = [1xN] vector of the spout TTL value (0 or 1)
%   varargout{4} = [1xN] vector of the TrialType value (0 or 1)
%   varargout{5} = [1xN] vector of the Poke TTL value (0 or 1)
%   varargout{6} = [1xN] vector of the Pump TTL value (0 or 1)
%   varargout{7} = [1xN] vector of the Sound TTL value (0 or 1)
%   varargout{8} = [1xN] vector of the response window TTL value (0 or 1)
%   varargout{9} = [1xN] vector of the TimeOut Light TTL value (0 or 1)
%   varargout{10} = [1xN] vector of the LED TTL value (0 or 1)
%
%
%Example usage: [timestamps,trial_hist,spout_hist] = cl_UpdateTTLHistory(handles,starttime,event)
%
%Written by ML Caras 7.25.2016
%Updated by ML Caras 10.19.2019

global PERSIST
persistent timestamps trial_hist spout_hist type_hist poke_hist sound_hist water_hist response_hist light_hist led_hist

%If this is a fresh run, clear persistent variables 
if PERSIST == 1
    timestamps = [];
    trial_hist = [];
    spout_hist = [];
    type_hist = [];
    poke_hist = [];
    sound_hist = [];
    water_hist = [];
    response_hist = [];
    light_hist = [];
    led_hist = [];
    
    PERSIST = 2;
end


%Determine current time
currenttime = etime(event.Data.time,starttime);

%Update timetamp
timestamps = [timestamps;currenttime];

%Update Poke History
poke_hist = cl_UpdateHist('~Poke_TTL',poke_hist,handles);

%Update Spout History
spout_hist = cl_UpdateHist('~Spout_TTL',spout_hist,handles);

%Update Sound History
sound_hist = cl_UpdateHist('~Sound_TTL',sound_hist,handles);

%Update Water History
water_hist = cl_UpdateHist('~Water_TTL',water_hist,handles);

%Update Response History
response_hist = cl_UpdateHist('~RespWin_TTL',response_hist,handles);

%Update trial TTL history
trial_hist = cl_UpdateHist('~InTrial_TTL',trial_hist,handles);

%Update trial type history
type_hist = cl_UpdateHist('~TrialType',type_hist,handles);

%Update room light history
light_hist = cl_UpdateHist('~Light_TTL',light_hist,handles);

%Update room light history
led_hist = cl_UpdateHist('~LED_TTL',led_hist,handles);

%Limit matrix size
xmin = timestamps(end)- 10;
xmax = timestamps(end)+ 10;
ind = find(timestamps > xmin+1 & timestamps < xmax-1);


timestamps = timestamps(ind);

if ~isempty(trial_hist)
    trial_hist = trial_hist(ind);
end

if ~isempty(spout_hist)
    spout_hist = spout_hist(ind);
end

if ~isempty(type_hist)
    type_hist = type_hist(ind);
end

if ~isempty(poke_hist)
    poke_hist = poke_hist(ind);
end

if ~isempty(water_hist)
    water_hist = water_hist(ind);
end

if ~isempty(sound_hist)
    sound_hist = sound_hist(ind);
end

if ~isempty(response_hist)
    response_hist = response_hist(ind);
end

if ~isempty(light_hist)
    light_hist = light_hist(ind);
end

if ~isempty(led_hist)
    led_hist = led_hist(ind);
end

%Pass to output variables
varargout{1} = timestamps;
varargout{2} = trial_hist;
varargout{3} = spout_hist;
varargout{4} = type_hist;
varargout{5} = poke_hist;
varargout{6} = sound_hist;
varargout{7} = water_hist;
varargout{8} = response_hist;
varargout{9} = light_hist;
varargout{10} = led_hist;



