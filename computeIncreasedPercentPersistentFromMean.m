function computeIncreasedPercentPersistentFromMean(newPercentPersistent, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('methodToIncreasePercentPersistent', 'sameAUC', @ischar);

p.parse(varargin{:});


%% compute group mean model fit
[modeledResponses] = fitTPUP('group', 'closePlots', true);
plotFig = figure; hold on
plot(modeledResponses.Melanopsin.timebase, modeledResponses.Melanopsin.values);
xlabel('Time (ms)');
ylabel('Pupil area (% change from baseline');

percentPersistent = modeledResponses.Melanopsin.params.paramMainMatrix(7)/(modeledResponses.Melanopsin.params.paramMainMatrix(7) + modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6));
minimumDetectableIncreasedPercentPersistent = newPercentPersistent;

%% Compute the increased percent persistent
if strcmp(p.Results.methodToIncreasePercentPersistent, 'sameAUC')
    % determine total area under the curve for the group mean model
    % fit, which we will fix as the AUC for the model fit for the
    % increased percent persistent
    meanTotalAUC = (modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6) + modeledResponses.Melanopsin.params.paramMainMatrix(7));
    % based on AUC, determine the amplitude of the persistent component
    % for the increased percentPersistent response
    newPersistentAmplitude = minimumDetectableIncreasedPercentPersistent * meanTotalAUC;
    
    % figure out the rest of the amplitudes
    transientToTransientPlusSustained = modeledResponses.Melanopsin.params.paramMainMatrix(5)/(modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6));
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = (meanTotalAUC - newPersistentAmplitude) * transientToTransientPlusSustained;
    newParams.paramMainMatrix(6) = (meanTotalAUC - newPersistentAmplitude) * (1-transientToTransientPlusSustained);
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = modeledResponses.Melanopsin.params.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = modeledResponses.Melanopsin.params.paramMainMatrix(2);
    newParams.paramMainMatrix(4) = modeledResponses.Melanopsin.params.paramMainMatrix(4);
    newParams.paramMainMatrix(3) = modeledResponses.Melanopsin.params.paramMainMatrix(3);
    
    newParams.paramNameCell{1} = 'delay';
    newParams.paramNameCell{2} = 'gammaTau';
    newParams.paramNameCell{3} = 'persistentGammaTau';
    
    newParams.paramNameCell{4} = 'exponentialTau';
    newParams.paramNameCell{5} = 'amplitudeTransient';
    newParams.paramNameCell{6} = 'amplitudeSustained';
    newParams.paramNameCell{7} = 'amplitudePersistent';
    
    
    
    % make stimulus struct
    stimulusStruct = makeStimulusStruct;
    
    % compute new modeled response with increased percent persistent
    % instantiate the TPUP object
    temporalFit = tfeTPUP('verbosity','full');
    [ newModelResponseStruct ] = temporalFit.computeResponse(newParams, stimulusStruct, []);
    
    % verify new AUC
    newAUC = (newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6) + newParams.paramMainMatrix(7));
    % verify increase in percent persistent
    newPercentPersistent = newParams.paramMainMatrix(7)./newAUC;
    
    % plot
    plot(newModelResponseStruct.timebase, newModelResponseStruct.values);
    
    legend('Mean Model Fit', 'Increased Percent Persistent')
    
elseif strcmp(p.Results.methodToIncreasePercentPersistent, 'increasePersistentComponentOnly')
    % for this method, only increase the amplitude of the persistent
    % component, leaving the amplitudes of the transient and sustained
    % unchanged to make our new model fit
    newPersistentAmplitude = (minimumDetectableIncreasedPercentPersistent*(modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6)))/(1 - minimumDetectableIncreasedPercentPersistent);
    
    % fill out the rest of the params, everything else unchanged
    % figure out the rest of the amplitudes
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = modeledResponses.Melanopsin.params.paramMainMatrix(5);
    newParams.paramMainMatrix(6) = modeledResponses.Melanopsin.params.paramMainMatrix(6);
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = modeledResponses.Melanopsin.params.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = modeledResponses.Melanopsin.params.paramMainMatrix(2);
    newParams.paramMainMatrix(3) = modeledResponses.Melanopsin.params.paramMainMatrix(3);
    newParams.paramMainMatrix(4) = modeledResponses.Melanopsin.params.paramMainMatrix(4);
    
    newParams.paramNameCell{1} = 'delay';
    newParams.paramNameCell{2} = 'gammaTau';
    newParams.paramNameCell{3} = 'persistentGammaTau';
    newParams.paramNameCell{4} = 'exponentialTau';
    newParams.paramNameCell{5} = 'amplitudeTransient';
    newParams.paramNameCell{6} = 'amplitudeSustained';
    newParams.paramNameCell{7} = 'amplitudePersistent';
    
    
    % make stimulus struct
    stimulusStruct = makeStimulusStruct;
    
    % compute new modeled response with increased percent persistent
    % instantiate the TPUP object
    temporalFit = tfeTPUP('verbosity','full');
    [ newModelResponseStruct ] = temporalFit.computeResponse(newParams, stimulusStruct, []);
    
    % verify new AUC
    newAUC = (newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6) + newParams.paramMainMatrix(7));
    % verify increase in percent persistent
    newPercentPersistent = newParams.paramMainMatrix(7)./newAUC;
    
    % plot
    plot(newModelResponseStruct.timebase, newModelResponseStruct.values);
    
    legend('Mean Model Fit', 'Increased Percent Persistent')
    
end