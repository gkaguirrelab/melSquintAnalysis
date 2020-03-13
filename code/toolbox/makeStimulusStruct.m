function stimulusStruct = makeStimulusStruct

waveformParams = OLWaveformParamsFromName('MaxContrastPulse'); % get generic pulse parameters
waveformParams.stimulusDuration = 4; % 4 second pulses
[Pulse400Waveform, pulseTimestep] = OLWaveformFromParams(waveformParams);

stimulusStruct.timebase = 0:pulseTimestep*1000:18.5*1000;
stimulusStruct.values = zeros(1,length(stimulusStruct.timebase));
stimulusStruct.values(find(stimulusStruct.timebase == 1.5*1000):find(stimulusStruct.timebase == 5.5*1000) - 1) = Pulse400Waveform;
end