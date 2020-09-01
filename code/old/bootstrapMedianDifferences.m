function bootstrapPPDistribution = bootstrapMedianDifferences(subjectList, varargin)

%{
Example:
subjectList = generateSubjectList;
pathToAverageResponseMatrix = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat');
saveName = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/bootstrap');

for ii = 20:40
    [ percentPersistentDistribution ] = bootstrapPercentPersistent(subjectList, 'nSubjectsInBootstrapSample', ii, 'saveName', saveName, 'pathToAverageResponseMatrix', pathToAverageResponseMatrix, 'makePlots', true);
    close all
end

plotFig = figure;
SEMBySampleSize = [];
for ii = 20:40
    load(fullfile('/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/', ['bootstrap_N', num2str(ii), '.mat']));
    SEMBySampleSize(end+1) = std(percentPersistentDistribution);
    clear percentPersistentDistribution
end
plot(20:40, SEMBySampleSize, 'o');
xlabel('Number of Subjects')
ylabel('Standard Error')


%}

p = inputParser; p.KeepUnmatched = true;
p.addParameter('loadFits',true,@islogical);
p.addParameter('nBootstrapIterations', 10000, @isnumeric);
p.addParameter('methodToIncreasePercentPersistent', 'sameAUC', @ischar);
p.addParameter('statistic', 'percentPersistent', @ischar);


p.parse(varargin{:});

%% Fit the TPUP model to the each subject within subjectList
% This will serve to give us a list of parameter values to draw from

if ~p.Results.loadFits
    subjectList = generateSubjectList;
    percentPersistentDistribution = [];
    amplitudeDistribution = [];
    for ii = 1:length(subjectList)
        [modeledResponses] = fitTPUP(subjectList{ii}, 'methodForDeterminingPersistentGammaTau', 213.888);
        percentPersistentDistribution = [percentPersistentDistribution, modeledResponses.Melanopsin.params.paramMainMatrix(7)/(modeledResponses.Melanopsin.params.paramMainMatrix(7) + modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6))];
        amplitudeDistribution = [amplitudeDistribution, (modeledResponses.Melanopsin.params.paramMainMatrix(7) + modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6))];
    end
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'percentPersistentDistribution.mat'), 'percentPersistentDistribution');
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'amplitudeDistribution.mat'), 'amplitudeDistribution');

else
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'percentPersistentDistribution.mat'));
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'amplitudeDistribution.mat'));

end
%% Do the bootstrapping

rangeOfBootstrapSampleSizes = 20:40;
nBootstrapIterations = p.Results.nBootstrapIterations;

if strcmp(p.Results.statistic, 'percentPersistent')
    statisticAcrossSubjects = percentPersistentDistribution;
elseif strcmp(p.Results.statistic, 'amplitude')
    statisticAcrossSubjects = amplitudeDistribution;
end

dValueCounter = 1;
for bootstrapSampleSize = rangeOfBootstrapSampleSizes
    
    bootstrapDistribution{bootstrapSampleSize} = [];
    
    
    for ii = 1:nBootstrapIterations
        groupOneIndices = datasample(1:length(percentPersistentDistribution), bootstrapSampleSize);
        groupTwoIndices = datasample(1:length(percentPersistentDistribution), bootstrapSampleSize);
        
        groupOneMedian = median(statisticAcrossSubjects(groupOneIndices));
        groupTwoMedian = median(statisticAcrossSubjects(groupTwoIndices));

        medianDifference = groupOneMedian - groupTwoMedian;

        bootstrapDistribution{bootstrapSampleSize} = [bootstrapDistribution{bootstrapSampleSize}, medianDifference];
    end
    dValue(dValueCounter) = prctile(bootstrapDistribution{bootstrapSampleSize}, 95);
    dValueCounter = dValueCounter + 1;
end

%% Show what detectable changes to this percent persistent would look like
% For 20 subjects
computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution)+0.5*dValue(find(rangeOfBootstrapSampleSizes == 20)), 'whichMeanResponse','fromParametesAcrossSubjects', 'centralTendencyForParams', 'median') 
title('20 Subjects, Same AUC')

% For 40 subjects
computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution)+0.5*dValue(find(rangeOfBootstrapSampleSizes == 40)), 'whichMeanResponse','fromParametesAcrossSubjects', 'centralTendencyForParams', 'median') 
title('40 Subjects, Same AUC')

computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution)+0.5*dValue(find(rangeOfBootstrapSampleSizes == 20)), 'whichMeanResponse','fromParametesAcrossSubjects', 'centralTendencyForParams', 'median', 'methodToIncreasePercentPersistent', 'increasePersistentComponentOnly') 
title('20 Subjects, Increased Persistent Component Only')

% For 40 subjects
computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution)+0.5*dValue(find(rangeOfBootstrapSampleSizes == 40)), 'whichMeanResponse','fromParametesAcrossSubjects', 'centralTendencyForParams', 'median', 'methodToIncreasePercentPersistent', 'increasePersistentComponentOnly') 
title('40 Subjects, Increased Persistent Component Only')

end

