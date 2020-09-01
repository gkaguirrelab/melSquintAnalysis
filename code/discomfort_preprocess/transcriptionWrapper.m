function transcriptionWrapper(subjectID, experimentNumber)

if experimentNumber == 1
    contrasts = {100, 200, 400};
    experimentName = 'experiment_1';
elseif experimentNumber == 2
    contrasts = {400, 800, 1200};
    experimentName = 'experiment_2';
end

stimuli = {'LightFlux', 'Melanopsin', 'LS'};

    transcribeAudioResponses(subjectID, 'experimentNumber', experimentName, 'stimuli', stimuli, 'contrasts', contrasts', 'Protocol', 'Deuteranopes');


end