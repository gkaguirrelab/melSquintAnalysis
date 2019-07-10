%% Percent persistent
% what we learned from the power analysis: with an alpha of 0.05 and 80%
% statistical power, we can detect a effect size of 10% in percent
% persistent (i.e. 80% + 10% -> 90% percent persistent, not 80% * 1.10)

sampleSize = 20;
statistic = 'percentPersistent';
hypothesisTest = 'labelPermutation';
percentPersistentDetectableEffectSize = simulatePowerAnalysis(sampleSize, statistic, hypothesisTest);

% get response forms
[decreasedResponse_decreasedSustained] = computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution) - percentPersistentDetectableEffectSize/2, 'methodToIncreasePercentPersistent', 'sameAUCDecreaseSustained');
[increasedResponse_decreasedSustained] = computeIncreasedPercentPersistentFromMean(median(percentPersistentDistribution) + percentPersistentDetectableEffectSize/2, 'methodToIncreasePercentPersistent', 'sameAUCDecreaseSustained');

% scale increased percent persistent response to have the same minmum value
increasePP_decreasedSustained_matched = min(decreasedResponse_decreasedSustained.values)/min(increasedResponse_decreasedSustained.values)*increasedResponse_decreasedSustained.values;
plotFig = figure; hold on; 
% plot control reduced percent persistent
plot(decreasedResponse_decreasedSustained.timebase, decreasedResponse_decreasedSustained.values); 
% plot patient group increased (and scaled) percent persistent)
plot(decreasedResponse_decreasedSustained.timebase, increasePP_decreasedSustained_matched);
xlabel('Time (ms)');
ylabel('Pupil Area (% Change from Baseline)');
reducedLegendString = sprintf('Percent Persistent = %4.2f%%', 100*(median(percentPersistentDistribution) - percentPersistentDetectableEffectSize/2));
increasedLegendString = sprintf('Percent Persistent = %4.2f%%', 100*(median(percentPersistentDistribution) + percentPersistentDetectableEffectSize/2));
legend(reducedLegendString, increasedLegendString);
%% Exponential tau
% what we learned from power analysis: with an alpha of 0.05 and 80%
% statisical power, we can detect an effect size of 6.15 in our exponential
% tau parameter

sampleSize = 20;
statistic = 'exponentialTau';
hypothesisTest = 'labelPermutation';
exponentialTauDetectableEffectSize = simulatePowerAnalysis(sampleSize, statistic, hypothesisTest);

% compute reduced exponential tau response
reducedParams.paramMainMatrix(1) = -206.1377;
reducedParams.paramMainMatrix(2) = 500.4936;
reducedParams.paramMainMatrix(3) = 213.888;
reducedParams.paramMainMatrix(4) = 10.0222 - exponentialTauDetectableEffectSize/2;
reducedParams.paramMainMatrix(5) = -0.40153;
reducedParams.paramMainMatrix(6) = -0.15851;
reducedParams.paramMainMatrix(7) = -2.4391;

reducedParams.paramNameCell{1} = 'delay';
reducedParams.paramNameCell{2} = 'gammaTau';
reducedParams.paramNameCell{3} = 'persistentGammaTau';
reducedParams.paramNameCell{4} = 'exponentialTau';
reducedParams.paramNameCell{5} = 'amplitudeTransient';
reducedParams.paramNameCell{6} = 'amplitudeSustained';
reducedParams.paramNameCell{7} = 'amplitudePersistent';

% make stimulus struct
stimulusStruct = makeStimulusStruct;

% compute new modeled response with increased percent persistent
% instantiate the TPUP object
temporalFit = tfeTPUP('verbosity','full');
[ reducedExponentialTauModelResponseStruct ] = temporalFit.computeResponse(reducedParams, stimulusStruct, []);

% compute increaseed exponential tau repsonse
increasedParams.paramMainMatrix(1) = -206.1377;
increasedParams.paramMainMatrix(2) = 500.4936;
increasedParams.paramMainMatrix(3) = 213.888;
increasedParams.paramMainMatrix(4) = 10.0222 + exponentialTauDetectableEffectSize/2;
increasedParams.paramMainMatrix(5) = -0.40153;
increasedParams.paramMainMatrix(6) = -0.15851;
increasedParams.paramMainMatrix(7) = -2.4391;

increasedParams.paramNameCell{1} = 'delay';
increasedParams.paramNameCell{2} = 'gammaTau';
increasedParams.paramNameCell{3} = 'persistentGammaTau';
increasedParams.paramNameCell{4} = 'exponentialTau';
increasedParams.paramNameCell{5} = 'amplitudeTransient';
increasedParams.paramNameCell{6} = 'amplitudeSustained';
increasedParams.paramNameCell{7} = 'amplitudePersistent';

% make stimulus struct
stimulusStruct = makeStimulusStruct;

% compute new modeled response with increased percent persistent
% instantiate the TPUP object
temporalFit = tfeTPUP('verbosity','full');
[ increasedExponentialTauModelResponseStruct ] = temporalFit.computeResponse(increasedParams, stimulusStruct, []);
figure; hold on;
% plot reduced exponential tau response
plot(reducedExponentialTauModelResponseStruct.timebase, reducedExponentialTauModelResponseStruct.values);
% plot increased exponential tau response, scaled to match peak amplitude
% of reduced response
plot(increasedExponentialTauModelResponseStruct.timebase, increasedExponentialTauModelResponseStruct.values .* min(reducedExponentialTauModelResponseStruct.values)/min(increasedExponentialTauModelResponseStruct.values));
xlabel('Time (ms)');
ylabel('Pupil Area (% Change from Baseline)');
legend(['Exponential Tau = ', num2str(10.0222 - exponentialTauDetectableEffectSize/2)], ['Exponential Tau = ', num2str(10.0222 + exponentialTauDetectableEffectSize/2)]);
ylim([-0.4 0.05])