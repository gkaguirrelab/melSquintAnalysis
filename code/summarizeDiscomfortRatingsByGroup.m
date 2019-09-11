%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% Pool results
controlDiscomfort = [];
mwaDiscomfort = [];
mwoaDiscomfort = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};



for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(analysisBasePath, fileName));
                controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            elseif strcmp(group, 'mwa')
                load(fullfile(analysisBasePath, fileName));
                mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                
            elseif strcmp(group, 'mwoa')
                load(fullfile(analysisBasePath, fileName));
                mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end


%% Display results
% First by individual migraine group
discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage.pdf'))

% Next by combine migraineurs
discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage_combinedMigraineurs.pdf'))









