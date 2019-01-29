% divide audio into each trial
nTrials = 36;
for tt = 1:nTrials
    firstTrialIndex = ((tt - 1) * length(audioRec.data)/nTrials) + 1;
    secondTrialIndex = ((tt) * length(audioRec.data)/nTrials) + 1;
    trialAudio = audioRec.data(firstTrialIndex:secondTrialIndex);
    [ firstTimePoint, secondTimePoint ] = grabRelevantAudioIndices(trialAudio, audioRec.Fs);
    
    % index that starts the numerical rating
    firstIndex = firstTimePoint*audioRec.Fs;
    
    % index that ends the numerical rating
    secondIndex = secondTimePoint*audioRec.Fs;
    
    sound(trialAudio(firstIndex:secondIndex), audioRec.Fs);
end