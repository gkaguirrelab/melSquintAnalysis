function analyzeDroppedFrames(varargin)

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('resume',false,@islogical);

% Parse and check the parameters
p.parse(varargin{:});


%% Get subject list
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

pooledTotalDroppedFrames.Controls = [];
pooledDroppedFramesDuringPulse.Controls = [];
pooledDroppedFramesOutsidePulse.Controls = [];
pooledNumberGoodTrials.Controls = [];
pooledProportionGoodTrials.Controls = [];

pooledTotalDroppedFrames.CombinedMigraineurs = [];
pooledDroppedFramesDuringPulse.CombinedMigraineurs = [];
pooledDroppedFramesOutsidePulse.CombinedMigraineurs = [];
pooledNumberGoodTrials.CombinedMigraineurs = [];
pooledProportionGoodTrials.CombinedMigraineurs = [];

stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
contrasts = {100, 200, 400};

% determine indices corresponding to when the pulse occurs
timebase = 0:1/60:18.5;
[~, pulseOnsetIndex] =  min(abs(1.5-timebase));
[~, pulseOffsetIndex] =  min(abs(5.5-timebase));

for ss = 1:length(subjectIDs)
    
    numberGoodTrials = 0;
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
    load(fullfile(resultsDir, [subjectIDs{ss}, '_trialStruct_radiusSmoothed.mat']));
    
    % determine number of included trials
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            numberGoodTrialsInThisStimulusCondition = size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
            
            numberGoodTrials = numberGoodTrials + numberGoodTrialsInThisStimulusCondition;
            
        end
    end
    
    % determine proportion of included trials
    nSessions = length(subjectListStruct.(subjectIDs{ss}));
    nTrialsPerSession = 54;
    proportionGoodTrials = numberGoodTrials/(nSessions * nTrialsPerSession);
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    % determine the number of dropped frames
    proportionDroppedFramesPerTrial = [];
    proportionDroppedFramesPerTrialDuringPulse = [];
    proportionDroppedFramesPerTrialOutsidePulse = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            for tt = 1:size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1)
                proportionDroppedFramesPerTrial(end+1) = sum(isnan(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,:)))/length(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,:));
                proportionDroppedFramesPerTrialDuringPulse(end+1) = sum(isnan(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,pulseOnsetIndex:pulseOffsetIndex)))/length(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,pulseOnsetIndex:pulseOffsetIndex));
                proportionDroppedFramesPerTrialOutsidePulse(end+1) = sum(isnan(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,[1:pulseOnsetIndex, pulseOffsetIndex:end])))/length(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,[1:pulseOnsetIndex, pulseOffsetIndex:end]));
                
            end
        end
    end
    
    
    
    % stash these results
    if strcmp(group, 'mwa') || strcmp(group, 'mwoa')
        pooledNumberGoodTrials.CombinedMigraineurs(end+1) = numberGoodTrials;
        pooledProportionGoodTrials.CombinedMigraineurs(end+1) = proportionGoodTrials;
        
        pooledTotalDroppedFrames.CombinedMigraineurs(end+1) = nanmean(proportionDroppedFramesPerTrial);
        pooledDroppedFramesDuringPulse.CombinedMigraineurs(end+1) = nanmean(proportionDroppedFramesPerTrialDuringPulse);
        pooledDroppedFramesOutsidePulse.CombinedMigraineurs(end+1) = nanmean(proportionDroppedFramesPerTrialOutsidePulse);
        
    elseif strcmp(group, 'c')
        
        pooledNumberGoodTrials.Controls(end+1) = numberGoodTrials;
        pooledProportionGoodTrials.Controls(end+1) = proportionGoodTrials;
        
        pooledTotalDroppedFrames.Controls(end+1) = nanmean(proportionDroppedFramesPerTrial);
        pooledDroppedFramesDuringPulse.Controls(end+1) = nanmean(proportionDroppedFramesPerTrialDuringPulse);
        pooledDroppedFramesOutsidePulse.Controls(end+1) = nanmean(proportionDroppedFramesPerTrialOutsidePulse);
    end
    
    
end

%% Summarize analyses
fprintf('<strong>*** Result of good trial analyses ***</strong>\n')
fprintf('\tMedian number of good trials included across migraine patients: %.1f\n', median(pooledNumberGoodTrials.CombinedMigraineurs));
fprintf('\tMedian number of good trials included across controls: %.1f\n\n', median(pooledNumberGoodTrials.Controls));
fprintf('\tMedian proportion of trials included across migraine patients: %.3f\n', median(pooledProportionGoodTrials.CombinedMigraineurs));
fprintf('\tMedian proportion of trials included across controls: %.3f\n\n', median(pooledProportionGoodTrials.Controls));

plotFig = figure; hold on;
data = [[pooledNumberGoodTrials.Controls, nan(1,20)]; pooledNumberGoodTrials.CombinedMigraineurs; ];
categoryIdx = [zeros(1,40), ones(1,40)];
plotSpread(data', 'categoryIdx', categoryIdx, 'categoryColors', {'k', 'r'})
plot(1, median(pooledNumberGoodTrials.Controls), '*', 'MarkerSize', 14, 'Color', 'k');
plot(2, median(pooledNumberGoodTrials.CombinedMigraineurs), '*', 'MarkerSize', 14, 'Color', 'r');
xticklabels({'Controls', 'Migraineurs'})
ylabel('Number of Trials')
title('Total number of included trials')
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/supplementaryAnalyses', 'numberOfIncludedTrials.pdf'));

plotFig = figure; hold on;
data = [[pooledProportionGoodTrials.Controls, nan(1,20)]; pooledProportionGoodTrials.CombinedMigraineurs; ];
categoryIdx = [zeros(1,40), ones(1,40)];
plotSpread(data', 'categoryIdx', categoryIdx, 'categoryColors', {'k', 'r'})
plot(1, median(pooledProportionGoodTrials.Controls), '*', 'MarkerSize', 14, 'Color', 'k');
plot(2, median(pooledProportionGoodTrials.CombinedMigraineurs), '*', 'MarkerSize', 14, 'Color', 'r');
xticklabels({'Controls', 'Migraineurs'})
ylabel('Proportion of Trials Included')
title('Proportion of Trials Included')
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/supplementaryAnalyses', 'proportionOfTrialsIncluded.pdf'));





fprintf('<strong>*** Result of dropped frames analyses ***</strong>\n')
fprintf('\tMedian proportion of total dropped frames across migraine patients: %.3f\n', median(pooledTotalDroppedFrames.CombinedMigraineurs));
fprintf('\tMedian proportion of total dropped frames across controls: %.3f\n\n', median(pooledTotalDroppedFrames.Controls));
fprintf('\tMedian proportion of dropped frames during the pulse across migraine patients: %.3f\n', median(pooledDroppedFramesDuringPulse.CombinedMigraineurs));
fprintf('\tMedian proportion of dropped frames during the pulse across controls: %.3f\n\n', median(pooledDroppedFramesDuringPulse.Controls));

plotFig = figure; hold on;
data = [[pooledTotalDroppedFrames.Controls, nan(1,20)]; pooledTotalDroppedFrames.CombinedMigraineurs; ];
categoryIdx = [zeros(1,40), ones(1,40)];
plotSpread(data', 'categoryIdx', categoryIdx, 'categoryColors', {'k', 'r'})
plot(1, median(pooledTotalDroppedFrames.Controls), '*', 'MarkerSize', 14, 'Color', 'k');
plot(2, median(pooledTotalDroppedFrames.CombinedMigraineurs), '*', 'MarkerSize', 14, 'Color', 'r');
xticklabels({'Controls', 'Migraineurs'})
ylabel('Proportion of Frames Dropped')
title('Proportion of Total Frames Dropped')
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/supplementaryAnalyses', 'proportionOfTotalFramesDropped.pdf'));

plotFig = figure; hold on;
data = [[pooledDroppedFramesDuringPulse.Controls, nan(1,20)]; pooledDroppedFramesDuringPulse.CombinedMigraineurs; ];
categoryIdx = [zeros(1,40), ones(1,40)];
plotSpread(data', 'categoryIdx', categoryIdx, 'categoryColors', {'k', 'r'})
plot(1, median(pooledDroppedFramesDuringPulse.Controls), '*', 'MarkerSize', 14, 'Color', 'k');
plot(2, median(pooledDroppedFramesDuringPulse.CombinedMigraineurs), '*', 'MarkerSize', 14, 'Color', 'r');
xticklabels({'Controls', 'Migraineurs'})
ylabel('Proportion of Frames Dropped')
title('Proportion of Frames Dropped During Pulse')
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/supplementaryAnalyses', 'proportionOfFramesDroppedDuringPulse.pdf'));




end