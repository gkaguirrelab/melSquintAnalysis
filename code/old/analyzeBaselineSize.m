function analyseBaselineSize(varargin)

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('resume',false,@islogical);

% Parse and check the parameters
p.parse(varargin{:});


%% Get subject list
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% 
pooledSubjectsMeanBaselineRadius.Controls = [];
pooledSubjectsMeanBaselineRadius.CombinedMigraineurs = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

for ss = 1:length(subjectIDs)
    pooledWithinSubjectBaselineSizes = [];
    % load up subject
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/baselineSize', [subjectIDs{ss}, '_baselineSize.mat']));
    
    for stimulus = 1:length(stimuli)
       
        pooledWithinSubjectBaselineSizes = [pooledWithinSubjectBaselineSizes; acquisitionsByStimulus.(stimuli{stimulus})(:)];
        
    end
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    if strcmp(group, 'mwa') || strcmp(group, 'mwoa')
        pooledSubjectsMeanBaselineRadius.CombinedMigraineurs(end+1) = sqrt(nanmean(pooledWithinSubjectBaselineSizes)/pi);
        
    elseif strcmp(group, 'c')
        
        pooledSubjectsMeanBaselineRadius.Controls(end+1) = sqrt(nanmean(pooledWithinSubjectBaselineSizes)/pi);
    end
    
end

%% summarize findings

fprintf('<strong>*** Result of baseline pupil size analyses analyses ***</strong>\n')
fprintf('\tMedian baseline pupil size across migraine patients: %.3f mm\n', median(pooledSubjectsMeanBaselineRadius.CombinedMigraineurs));
fprintf('\tMedian baseline pupil size across controls: %.3f mm\n\n', median(pooledSubjectsMeanBaselineRadius.Controls));

plotFig = figure; hold on;
data = [[pooledSubjectsMeanBaselineRadius.Controls, nan(1,20)]; pooledSubjectsMeanBaselineRadius.CombinedMigraineurs; ];
categoryIdx = [zeros(1,40), ones(1,40)];
plotSpread(data', 'categoryIdx', categoryIdx, 'categoryColors', {'k', 'r'})
plot(1, median(pooledSubjectsMeanBaselineRadius.Controls), '*', 'MarkerSize', 14, 'Color', 'k');
plot(2, median(pooledSubjectsMeanBaselineRadius.CombinedMigraineurs), '*', 'MarkerSize', 14, 'Color', 'r');
xticklabels({'Controls', 'Migraineurs'})
ylabel('Baseline Pupil Size (mm)')
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/baselineSize', 'summaryByMigraineGroup.pdf'));




end