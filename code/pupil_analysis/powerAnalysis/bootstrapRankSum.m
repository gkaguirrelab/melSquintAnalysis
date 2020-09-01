% routine for power analysis that was part of pre-registration

sampleSize = 20;
alpha = 0.05;
statistic = 'exponentialTau';

if strcmp(statistic, 'percentPersistent')
    %effectSizeScalarRange = 1.01:0.01:1.5;
    effectSizeScalarRange = 0:0.001:0.25;
    %effectSizeScalarRange = 0.07:0.001:0.075;
end

if strcmp(statistic, 'exponentialTau')
    effectSizeScalarRange = 0:0.1:10;
end
nBootstrapIterations = 1000;
%hypothesisTest = 't-test';
%hypothesisTest = 'rankSum';
hypothesisTest = 'labelPermutation';

powerDistribution = [];
for effectSizeScalar = effectSizeScalarRange
    probabilityDistribution = [];
    
    for ii = 1:nBootstrapIterations
        
        bootstrapIndicesControls = datasample(1:length(percentPersistentDistribution), sampleSize);
        bootstrapIndicesPatients = datasample(1:length(percentPersistentDistribution), sampleSize);
        
        if strcmp(statistic, 'percentPersistent')
            statisticControls = percentPersistentDistribution(bootstrapIndicesControls)-effectSizeScalar/2;
            statisticPatients = percentPersistentDistribution(bootstrapIndicesPatients)+effectSizeScalar/2;
            
            % enforce max percentPersistent of 100%
            statisticPatients(statisticPatients>1) = 1;
            statisticControls(statisticControls<0) = 0;
        end
        
        if strcmp(statistic, 'exponentialTau')
            statisticControls = exponentialTauDistribution(bootstrapIndicesControls) - effectSizeScalar/2;
            statisticPatients = exponentialTauDistribution(bootstrapIndicesPatients) + effectSizeScalar/2;
            
            % enforce our modeling bounds
            statisticPatients(statisticPatients>20) = 20;
            statisticControls(statisticControls<1) = 1;
        end
        


        if strcmp(hypothesisTest, 'rankSum')
            probability = ranksum(statisticControls, statisticPatients, 'tail', 'left');
        elseif strcmp(hypothesisTest, 't-test')
            [~, probability] = ttest2(statisticControls, statisticPatients, 'tail', 'left');
        elseif strcmp(hypothesisTest, 'labelPermutation')
            [probability] = evaluateSignificanceOfMedianDifference(statisticPatients, statisticControls);
        end

        probabilityDistribution = [probabilityDistribution, probability];
    end
    falseNegativeRate = (sum(probabilityDistribution > alpha)/nBootstrapIterations);
    power = 1 - falseNegativeRate;
    powerDistribution = [powerDistribution, power];
end

figure;
plot(effectSizeScalarRange, powerDistribution)
title(['N = ', num2str(sampleSize), ', ', hypothesisTest]);
ylabel('Power')
xlabel('Effect Size (Patients = Controls + Effect Size)')
hold on;
line([0 0.25], [0.8, 0.8], 'Color', 'r', 'LineStyle', '-')

indicesInWhichPowerSurpassesThreshold = find(powerDistribution>0.8);
minimumDetectableEffectSize = (effectSizeScalarRange(indicesInWhichPowerSurpassesThreshold(1)) + effectSizeScalarRange(indicesInWhichPowerSurpassesThreshold(1)-1))/2;
minimumDetectableEffectSize
