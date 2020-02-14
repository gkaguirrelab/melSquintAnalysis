subjectStruct = getDeuteranopeSubjectStruct;
stimuli = {'LightFlux', 'Melanopsin',  'LS'};

%% Summarize pupillometry
fitType = 'initial';
saveNameSuffix = '_postSpotCheck';

for experiment = 1:2
    experimentName = ['experiment_', num2str(experiment)];
    subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = 1:5
        
        makeSubjectAverageResponses(subjectIDs{ss}, 'experimentName', experimentName, 'stimuli', stimuli, 'contrasts', contrasts, 'Protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes','blinkBufferFrames', [3 6], 'saveNameSuffix', saveNameSuffix, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectIDs{ss}))
        
    end
end

%% Summarize discomfort ratings

fileName = 'audioTrialStruct_final.mat';
discomfort = [];

% pre-allocate results variable
for experiment = 1:2
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
    end
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            discomfort.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
        
    end
end

% pool results
for experiment = 1:2
    experimentName = ['experiment_', num2str(experiment)];
    subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = 1:5
        analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles/', subjectIDs{ss}, ['experiment_', num2str(experiment)]);
        load(fullfile(analysisBasePath, fileName));
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                discomfort.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            end
        end
        
    end
end

% plot results
for experiment = 1:2
    discomfortRating.Controls = discomfort.(['experiment', num2str(experiment)]);
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'deuteranopes');
    plotSpreadResults(discomfortRating, 'stimuli', stimuli, 'contrasts', contrasts, 'saveName', fullfile(savePath, ['groupSummary_experiment', num2str(experiment), '.pdf']))
    
    
end

