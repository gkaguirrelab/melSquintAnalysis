function bootstrapDistribution = bootstrapPercentPersistent_perSubject(subjectList, varargin)

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

p.parse(varargin{:});

%% Fit the TPUP model to the each subject within subjectList
% This will serve to give us a list of parameter values to draw from

if ~p.Results.loadFits
    subjectList = generateSubjectList;
    percentPersistentDistribution = [];
    for ii = 1:length(subjectList)
        [modeledResponses] = fitTPUP(subjectList{ii}, 'methodForDeterminingPersistentGammaTau', 213.888);
        percentPersistentDistribution = [percentPersistentDistribution, modeledResponses.Melanopsin.params.paramMainMatrix(7)/(modeledResponses.Melanopsin.params.paramMainMatrix(7) + modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6))];
    end
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'percentPersistentDistribution.mat'), 'percentPersistentDistribution');
else
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'percentPersistentDistribution.mat'));
end
%% Do the bootstrapping

rangeOfBootstrapSampleSizes = 20:40;
nBootstrapIterations = p.Results.nBootstrapIterations;

for bootstrapSampleSize = rangeOfBootstrapSampleSizes
    
    bootstrapDistribution{bootstrapSampleSize} = [];
    
    for ii = 1:nBootstrapIterations
        bootstrapSubjectIndices = datasample(1:length(percentPersistentDistribution), bootstrapSampleSize);
        
        meanPercentPersistent = mean(percentPersistentDistribution(bootstrapSubjectIndices));
        
        bootstrapDistribution{bootstrapSampleSize} = [bootstrapDistribution{bootstrapSampleSize}, meanPercentPersistent];
        
    end
end

%% Using this bootstrap distribution for a power calculation
% based on this website: https://www.stat.ubc.ca/~rollin/stats/ssize/n2.html

sampleSize = 20;
% For a given bootstrap sample size, fit it to a Gaussian
pd = fitdist(bootstrapDistribution{sampleSize}','Normal');
% obtain the SEM of the bootstrap distribution mean, which corresponds to the
% standard deviation of the bootstrap sample distribution
SEM = pd.std;
% convert SEM to standard deviation of the population
standardDeviation = (sampleSize)^(1/2) * SEM;
% the website says for a sample of 20 subjects, the minimum increase in
% percent persistent we'd likely be able to detect is 93%


sampleSize = 40;
% For a given bootstrap sample size, fit it to a Gaussian
pd = fitdist(bootstrapDistribution{sampleSize}','Normal');
% obtain the SEM of the bootstrap distribution mean, which corresponds to the
% standard deviation of the bootstrap sample distribution
SEM = pd.std;
% convert SEM to standard deviation of the population
standardDeviation = (sampleSize)^(1/2) * SEM;
% the website says for a sample of 20 subjects, the minimum increase in
% percent persistent we'd likely be able to detect is 87.7%

%% What these increases in percent persistent look like
% for 20 subjects
computeIncreasedPercentPersistentFromMean(0.93)

% for 40 subjects:
computeIncreasedPercentPersistentFromMean(0.877)