subjectStruct = getDeuteranopeSubjectStruct;

%% Summarize pupillometry
fitType = 'initial';
saveNameSuffix = '_postSpotCheck';

for experiment = 2:2
    experimentName = ['experiment_', num2str(experiment)];
    subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = 2:5
        
        makeSubjectAverageResponses(subjectIDs{ss}, 'experimentName', experimentName, 'stimuli', {'Melanopsin', 'LightFlux', 'LS'}, 'contrasts', contrasts, 'Protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes','blinkBufferFrames', [3 6], 'saveNameSuffix', saveNameSuffix, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectIDs{ss}))
        
    end
end
    
    