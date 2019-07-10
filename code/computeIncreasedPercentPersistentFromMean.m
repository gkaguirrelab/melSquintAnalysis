function [newModelResponseStruct, centralTendencyResponse] = computeIncreasedPercentPersistentFromMean(newPercentPersistent, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('whichMeanResponse','fromParametesAcrossSubjects', @ischar)
p.addParameter('methodToIncreasePercentPersistent', 'sameAUC', @ischar);
p.addParameter('centralTendencyForParams', 'median', @ischar);
p.addParameter('newExponentialTau', []);


p.parse(varargin{:});


%% compute group mean model fit
if strcmp(p.Results.whichMeanResponse, 'fromGroupAverageResponse')
[modeledResponses] = fitTPUP('group', 'closePlots', true);
    timebase = modeledResponse.Melanopsin.timebase;
    groupResponse = modeledResponse.Melanopsin.values;

    newParams = modeledResponses.params;


elseif strcmp(p.Results.whichMeanResponse, 'fromParametesAcrossSubjects')

    
    % fill out the rest of the parameters
    if strcmp(p.Results.centralTendencyForParams, 'mean')
        newParams.paramMainMatrix(1) = -222.57431;
        newParams.paramMainMatrix(2) = 527.7164;
        newParams.paramMainMatrix(3) = 213.888;
        newParams.paramMainMatrix(4) = 10.7443;
        newParams.paramMainMatrix(5) = -0.4056;
        newParams.paramMainMatrix(6) = -0.2283;
        newParams.paramMainMatrix(7) = -2.7025;
    elseif strcmp(p.Results.centralTendencyForParams, 'median')
        newParams.paramMainMatrix(1) = -206.1377;
        newParams.paramMainMatrix(2) = 500.4936;
        newParams.paramMainMatrix(3) = 213.888;
        newParams.paramMainMatrix(4) = 10.0222;
        newParams.paramMainMatrix(5) = -0.40153;
        newParams.paramMainMatrix(6) = -0.15851;
        newParams.paramMainMatrix(7) = -2.4391;
    end
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
    
    timebase = newModelResponseStruct.timebase;
    groupResponse = newModelResponseStruct.values;

    % determine total area under the curve for the group mean model
    % fit, which we will fix as the AUC for the model fit for the
    % increased percent persistent
    meanTotalAUC = (newParams.paramMainMatrix(5) +newParams.paramMainMatrix(6) + newParams.paramMainMatrix(7));
  
    percentPersistent =  newParams.paramMainMatrix(7)/( newParams.paramMainMatrix(5) +  newParams.paramMainMatrix(6) +  newParams.paramMainMatrix(7));

    centralTendencyResponse = newModelResponseStruct;
end
plotFig = figure; hold on
plot(timebase, groupResponse);
xlabel('Time (ms)');
ylabel('Pupil area (% change from baseline');

% determine total area under the curve for the group mean model
% fit, which we will fix as the AUC for the model fit for the
% increased percent persistent
meanTotalAUC = (newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6) + newParams.paramMainMatrix(7));

percentPersistent = newParams.paramMainMatrix(7)/(newParams.paramMainMatrix(7) + newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6));

minimumDetectableIncreasedPercentPersistent = newPercentPersistent;

fprintf('Percent persistent of mean: %4.2f\n', percentPersistent);
fprintf('AUC of mean: %4.2f\n', meanTotalAUC);

%% Compute the increased percent persistent
if strcmp(p.Results.methodToIncreasePercentPersistent, 'sameAUC')
   % based on AUC, determine the amplitude of the persistent component
    % for the increased percentPersistent response
    newPersistentAmplitude = minimumDetectableIncreasedPercentPersistent * meanTotalAUC;
    
    % figure out the rest of the amplitudes
    transientToTransientPlusSustained =  newParams.paramMainMatrix(5)/( newParams.paramMainMatrix(5) +  newParams.paramMainMatrix(6));
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = (meanTotalAUC - newPersistentAmplitude) * transientToTransientPlusSustained;
    newParams.paramMainMatrix(6) = (meanTotalAUC - newPersistentAmplitude) * (1-transientToTransientPlusSustained);
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = newParams.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = newParams.paramMainMatrix(2);
    newParams.paramMainMatrix(4) = newParams.paramMainMatrix(4);
    newParams.paramMainMatrix(3) = newParams.paramMainMatrix(3);
    
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

    fprintf('Percent persistent of change: %4.2f\n', newPercentPersistent);
    fprintf('AUC of change: %4.2f\n', newAUC);
    
elseif strcmp(p.Results.methodToIncreasePercentPersistent, 'increasePersistentComponentOnly')
    % for this method, only increase the amplitude of the persistent
    % component, leaving the amplitudes of the transient and sustained
    % unchanged to make our new model fit
    newPersistentAmplitude = (minimumDetectableIncreasedPercentPersistent*(newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6)))/(1 - minimumDetectableIncreasedPercentPersistent);
    
    % fill out the rest of the params, everything else unchanged
    % figure out the rest of the amplitudes
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = newParams.paramMainMatrix(5);
    newParams.paramMainMatrix(6) = newParams.paramMainMatrix(6);
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = newParams.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = newParams.paramMainMatrix(2);
    newParams.paramMainMatrix(3) = newParams.paramMainMatrix(3);
    newParams.paramMainMatrix(4) = newParams.paramMainMatrix(4);
    
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
    fprintf('Percent persistent of change: %4.2f\n', newPercentPersistent);
    fprintf('AUC of change: %4.2f\n', newAUC);

elseif strcmp(p.Results.methodToIncreasePercentPersistent, 'sameAUCDecreaseSustained')


    changeToSustained = newPercentPersistent *  newParams.paramMainMatrix(7) + newPercentPersistent *  newParams.paramMainMatrix(6) + newPercentPersistent *  newParams.paramMainMatrix(5) - newParams.paramMainMatrix(7);
    newPersistentAmplitude = newParams.paramMainMatrix(7) + changeToSustained;
    newSustainedAmplitude = newParams.paramMainMatrix(6) - changeToSustained;

    newPercentPersistent = newPersistentAmplitude/(newPersistentAmplitude + newSustainedAmplitude + newParams.paramMainMatrix(5));
    newAUC = (newPersistentAmplitude + newSustainedAmplitude + newParams.paramMainMatrix(5));


  % fill out the rest of the params, everything else unchanged
    % figure out the rest of the amplitudes
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = newParams.paramMainMatrix(5);
    newParams.paramMainMatrix(6) = newSustainedAmplitude;
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = newParams.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = newParams.paramMainMatrix(2);
    newParams.paramMainMatrix(3) = newParams.paramMainMatrix(3);
    newParams.paramMainMatrix(4) = newParams.paramMainMatrix(4);
    
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
    
    % plot
    plot(newModelResponseStruct.timebase, newModelResponseStruct.values);
    
    legend('Mean Model Fit', 'Increased Percent Persistent')

    fprintf('Percent persistent of change: %4.2f\n', newPercentPersistent);
    fprintf('AUC of change: %4.2f\n', newAUC);

elseif strcmp(p.Results.methodToIncreasePercentPersistent, 'alsoChangeExponentialTau')

 % for this method, only increase the amplitude of the persistent
    % component, leaving the amplitudes of the transient and sustained
    % unchanged to make our new model fit
    newPersistentAmplitude = (minimumDetectableIncreasedPercentPersistent*(newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6)))/(1 - minimumDetectableIncreasedPercentPersistent);
    
    % fill out the rest of the params, everything else unchanged
    % figure out the rest of the amplitudes
    newParams.paramMainMatrix(7) = newPersistentAmplitude;
    newParams.paramMainMatrix(5) = newParams.paramMainMatrix(5);
    newParams.paramMainMatrix(6) = newParams.paramMainMatrix(6);
    
    % fill out the rest of the parameters
    newParams.paramMainMatrix(1) = newParams.paramMainMatrix(1);
    newParams.paramMainMatrix(2) = newParams.paramMainMatrix(2);
    newParams.paramMainMatrix(3) = newParams.paramMainMatrix(3);
    newParams.paramMainMatrix(4) = p.Results.newExponentialTau;
    
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

    fprintf('Percent persistent of change: %4.2f\n', newPercentPersistent);
    fprintf('AUC of change: %4.2f\n', newAUC);
    
end