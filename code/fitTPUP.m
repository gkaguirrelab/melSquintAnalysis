function [ modeledResponses, averageResponses ] = fitTPUP(subjectID, varargin)
%{
subjectID = 'MELA_0126';

%}

%% Parse the input

p = inputParser; p.KeepUnmatched = true;

p.addParameter('method','fixGamma',@ischar);
p.addParameter('methodForDeterminingPersistentGammaTau','fitToGroupAverage');
p.addParameter('numberOfResponseIndicesToExclude', 40, @isnumeric);
p.addParameter('plotGroupAverageFits', false, @islogical);
p.addParameter('plotFits', true, @islogical);
p.addParameter('plotComponents', true, @islogical);
p.addParameter('printParams', true, @islogical);


p.parse(varargin{:});

%% Get the average responses


%% Determine persistentGammaTau to be used for fitting
if strcmp(p.Results.methodForDeterminingPersistentGammaTau, 'fitToGroupAverage') || strcmp(subjectID, 'group')
    % load average responses across all subjects
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat'));
    
    % compute group average responses, including NaNing poor indices (at
    % the beginning and the end)
    
    MelanopsinResponse = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
    MelanopsinResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    MelanopsinResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    LMSResponse = nanmean(averageResponseMatrix.LMS.Contrast400);
    LMSResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    LMSResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    LightFluxResponse = nanmean(averageResponseMatrix.LightFlux.Contrast400);
    LightFluxResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    LightFluxResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    % assemble the responseStruct of the packet. To fix parameters,
    % we'll be concatenating these responses together.
    thePacket.response.values = [LMSResponse, MelanopsinResponse, LightFluxResponse];
    thePacket.response.timebase = 0:1/60*1000:length(thePacket.response.values)*1/60 * 1000 - 1/60 * 1000;
    
    % assemble the stimuluStruct of the packet.
    stimulusStruct = makeStimulusStruct;
    % resample stimulus to match response
    resampledStimulusTimebase = 0:1/60*1000:1/60*length(nanmean(averageResponseMatrix.Melanopsin.Contrast400))*1000-1/60*1000;
    resampledStimulusProfile = interp1(stimulusStruct.timebase, stimulusStruct.values, resampledStimulusTimebase);
    thePacket.stimulus = [];
    thePacket.stimulus.timebase = thePacket.response.timebase;
    thePacket.stimulus.values = resampledStimulusProfile;
    thePacket.stimulus.values(length(resampledStimulusProfile)+1:length(thePacket.stimulus.timebase)) = 0;
    
    % assemble the rest of the packet
    thePacket.kernel = [];
    thePacket.metaData = [];
    defaultParamsInfo.nInstances = 1;
    
    % Construct the model object
    temporalFit = tfeHPUP('verbosity','full');
    
    % set up initial parameters. This is how we're going to fix the
    % persistentGammaTau
    vlb = ...
        [600, ...         % 'gammaTau',
        1, ...          % 'persistentGammaTau'
        -500, ...       % 'LMSDelay'
        1, ...          % 'LMSExponentialTau'
        -10, ...        % 'LMSTransient'
        -10, ...        % 'LMSSustained'
        -10,...         % 'LMSPersistent'
        -500, ...       % 'MelanopsinDelay'
        1, ...          % 'MelanopsinExponentialTau'
        -10, ...        % 'MelanopsinTransient'
        -10, ...        % 'MelanopsinSustained'
        -10,...         % 'MelanopsinPersistent'
        -500, ...       % 'LightFluxDelay'
        1, ...          % 'LightFluxExponentialTau'
        -10, ...        % 'LightFluxTransient'
        -10, ...        % 'LightFluxSustained'
        -10];           % 'LightFluxPersistent'
    
    vub = ...
        [1000, ...      % 'gammaTau',
        1000, ...       % 'persistentGammaTau'
        0, ...          % 'LMSDelay'
        20, ...         % 'LMSExponentialTau'
        0, ...          % 'LMSTransient'
        0, ...          % 'LMSSustained'
        0,...           % 'LMSPersistent'
        0, ...          % 'MelanopsinDelay'
        20, ...         % 'MelanopsinExponentialTau'
        0, ...          % 'MelanopsinTransient'
        0, ...          % 'MelanopsinSustained'
        0,...           % 'MelanopsinPersistent'
        0, ...          % 'LightFluxDelay'
        20, ...         % 'LightFluxExponentialTau'
        0, ...          % 'LightFluxTransient'
        0, ...          % 'LightFluxSustained'
        0];             % 'LightFluxPersistent'
    
    initialValues = ...
        [600, ...       % 'gammaTau',
        200, ...       % 'persistentGammaTau'
        -200, ...      % 'LMSDelay'
        10, ...        % 'LMSExponentialTau'
        -1, ...        % 'LMSTransient'
        -1, ...        % 'LMSSustained'
        -1,...         % 'LMSPersistent'
        -200, ...      % 'MelanopsinDelay'
        10, ...        % 'MelanopsinExponentialTau'
        -1, ...        % 'MelanopsinTransient'
        -1, ...        % 'MelanopsinSustained'
        -1,...         % 'MelanopsinPersistent'
        -200, ...      % 'LightFluxDelay'
        1, ...         % 'LightFluxExponentialTau'
        -1, ...        % 'LightFluxTransient'
        -1, ...        % 'LightFluxSustained'
        -1];           % 'LightFluxPersistent'
    
    % perform the fit
    [paramsFit,fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'vlb', vlb, 'vub', vub, 'initialValues', initialValues, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'fminconAlgorithm','sqp');
    
    % extract the persistent gamma tau that best describes the combined group
    % response
    groupAveragePersistentGammaTau = paramsFit.paramMainMatrix(2);
    
    % summarizing the group average model fit
    LMSFit = modelResponseStruct.values(1:length(modelResponseStruct.values)/3);
    MelanopsinFit = modelResponseStruct.values(length(modelResponseStruct.values)/3+1:length(modelResponseStruct.values)/3*2);
    LightFluxFit = modelResponseStruct.values(length(modelResponseStruct.values)/3*2+1:end);
    
    if p.Results.plotGroupAverageFits || strcmp(subjectID, 'group')
        plotFig = figure;
        ax1 = subplot(1,3,1); hold on;
        plot(resampledStimulusTimebase/1000, LMSResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, LMSFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('LMS')
        legend('Group average response', 'Model fit')
        
        ax2 = subplot(1,3,2); hold on;
        plot(resampledStimulusTimebase/1000, MelanopsinResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, MelanopsinFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('Melanopsin')
        legend('Group average response', 'Model fit')
        
        ax3 = subplot(1,3,3); hold on;
        plot(resampledStimulusTimebase/1000, LightFluxResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, LightFluxFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('Light Flux')
        legend('Group average response', 'Model fit')
        
        linkaxes([ax1, ax2, ax3]);
        
        set(gcf, 'Position', [29 217 1661 761]);
        
        if p.Results.plotComponents
            
            persistentAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Persistent'));
            sustainedAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Sustained'));
            transientAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Transient'));
            
            % plot the transient component
            transientParams = paramsFit;
            transientParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
            transientParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
            
            computedTransientResponse = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(1:length(computedTransientResponse.values)/3));
            subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(length(computedTransientResponse.values)/3+1:length(computedTransientResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(length(computedTransientResponse.values)/3*2+1:end));
            
            % plot the sustained component
            sustainedParams = paramsFit;
            sustainedParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
            sustainedParams.paramMainMatrix(transientAmplitudeIndices) = 0;
            
            computedSustainedResponse = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(1:length(computedSustainedResponse.values)/3));
            subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(length(computedSustainedResponse.values)/3+1:length(computedSustainedResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(length(computedSustainedResponse.values)/3*2+1:end));
            
            
            % plot the persistent component
            persistentParams = paramsFit;
            persistentParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
            persistentParams.paramMainMatrix(transientAmplitudeIndices) = 0;
            
            computedPersistentResponse = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(1:length(computedPersistentResponse.values)/3));
            subplot(1,3,2); hold on;
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(length(computedPersistentResponse.values)/3+1:length(computedPersistentResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(length(computedPersistentResponse.values)/3*2+1:end));
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
        end
        
        fprintf(' <strong>Fitting group average response </strong>\n');
        temporalFit.paramPrint(paramsFit);
        fprintf('\n');
        
    end
    
    % stash out results if we're just looking for the group average
    % response
    if strcmp(subjectID, 'group')
        modeledResponses.LMS.timebase = resampledStimulusTimebase;
        modeledResponses.LMS.values = LMSFit;
        modeledResponses.LMS.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'LMSExponentialTau', 'LMSAmplitudeTransient', 'LMSAmplitudeSustained', 'LMSAmplitudePersistent'};
        for ii = 1:length(modeledResponses.LMS.params.paramNameCell)
            modeledResponses.LMS.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LMS.params.paramNameCell{ii}));
        end
        modeledResponses.Melanopsin.timebase = resampledStimulusTimebase;
        modeledResponses.Melanopsin.values = MelanopsinFit;
        modeledResponses.Melanopsin.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'MelanopsinExponentialTau', 'MelanopsinAmplitudeTransient', 'MelanopsinAmplitudeSustained', 'MelanopsinAmplitudePersistent'};
        for ii = 1:length(modeledResponses.Melanopsin.params.paramNameCell)
            modeledResponses.Melanopsin.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.Melanopsin.params.paramNameCell{ii}));
        end
        modeledResponses.LightFlux.timebase = resampledStimulusTimebase;
        modeledResponses.LightFlux.values = LightFluxFit;
        modeledResponses.LightFlux.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'LightFluxExponentialTau', 'LightFluxAmplitudeTransient', 'LightFluxAmplitudeSustained', 'LightFluxAmplitudePersistent'};
        for ii = 1:length(modeledResponses.LightFlux.params.paramNameCell)
            modeledResponses.LightFlux.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LightFlux.params.paramNameCell{ii}));
        end
        
        
        averageResponses.LMS = LMSResponse;
        averageResponses.Melanopsin = MelanopsinResponse;
        averageResponses.LightFlux = LightFluxResponse;
    end
    
    % explicitly stash persistentGammaTau, and corresponding bounds
    persistentGammaTau = groupAveragePersistentGammaTau;
    persistentGammaTauUB = groupAveragePersistentGammaTau;
    persistentGammaTauLB = groupAveragePersistentGammaTau;
    
    
elseif isnumeric(p.Results.methodForDeterminingPersistentGammaTau)
    
    persistentGammaTau = p.Results.methodForDeterminingPersistentGammaTau;
    persistentGammaTauLB = p.Results.methodForDeterminingPersistentGammaTau;
    persistentGammaTauUB = p.Results.methodForDeterminingPersistentGammaTau;
    
elseif strcmp(p.Results.methodForDeterminingPersistentGammaTau, 'fitToIndividualSubject')
    
    persistentGammaTau = 200;
    persistentGammaTauLB = 1;
    persistentGammaTauUB = 1000;
    
end

%% perform the search the average responses for the individual subject
% with our newly established persistentGammaTau
if ~strcmp(subjectID, 'group')
    
    % load average responses across all subjects
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, 'trialStruct_postSpotcheck.mat'));
    
    % compute group average responses, including NaNing poor indices (at
    % the beginning and the end)
    
    MelanopsinResponse = nanmean(trialStruct.Melanopsin.Contrast400);
    MelanopsinResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    MelanopsinResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    LMSResponse = nanmean(trialStruct.LMS.Contrast400);
    LMSResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    LMSResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    LightFluxResponse = nanmean(trialStruct.LightFlux.Contrast400);
    LightFluxResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    LightFluxResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    % assemble the responseStruct of the packet. To fix parameters,
    % we'll be concatenating these responses together.
    thePacket.response.values = [LMSResponse, MelanopsinResponse, LightFluxResponse];
    thePacket.response.timebase = 0:1/60*1000:length(thePacket.response.values)*1/60 * 1000 - 1/60 * 1000;
    
    % assemble the stimuluStruct of the packet.
    stimulusStruct = makeStimulusStruct;
    % resample stimulus to match response
    resampledStimulusTimebase = 0:1/60*1000:1/60*length(nanmean(trialStruct.Melanopsin.Contrast400))*1000-1/60*1000;
    resampledStimulusProfile = interp1(stimulusStruct.timebase, stimulusStruct.values, resampledStimulusTimebase);
    thePacket.stimulus = [];
    thePacket.stimulus.timebase = thePacket.response.timebase;
    thePacket.stimulus.values = resampledStimulusProfile;
    thePacket.stimulus.values(length(resampledStimulusProfile)+1:length(thePacket.stimulus.timebase)) = 0;
    
    % assemble the rest of the packet
    thePacket.kernel = [];
    thePacket.metaData = [];
    defaultParamsInfo.nInstances = 1;
    
    % Construct the model object
    temporalFit = tfeHPUP('verbosity','full');
    
    % set up initial parameters. This is how we're going to fix the
    % persistentGammaTau
    vlb = ...
        [1, ...         % 'gammaTau',
        persistentGammaTauLB, ...          % 'persistentGammaTau'
        -500, ...       % 'LMSDelay'
        1, ...          % 'LMSExponentialTau'
        -10, ...        % 'LMSTransient'
        -10, ...        % 'LMSSustained'
        -10,...         % 'LMSPersistent'
        -500, ...       % 'MelanopsinDelay'
        1, ...          % 'MelanopsinExponentialTau'
        -10, ...        % 'MelanopsinTransient'
        -10, ...        % 'MelanopsinSustained'
        -10,...         % 'MelanopsinPersistent'
        -500, ...       % 'LightFluxDelay'
        1, ...          % 'LightFluxExponentialTau'
        -10, ...        % 'LightFluxTransient'
        -10, ...        % 'LightFluxSustained'
        -10];           % 'LightFluxPersistent'
    
    vub = ...
        [1000, ...      % 'gammaTau',
        persistentGammaTauUB, ...       % 'persistentGammaTau'
        0, ...          % 'LMSDelay'
        20, ...         % 'LMSExponentialTau'
        0, ...          % 'LMSTransient'
        0, ...          % 'LMSSustained'
        0,...           % 'LMSPersistent'
        0, ...          % 'MelanopsinDelay'
        20, ...         % 'MelanopsinExponentialTau'
        0, ...          % 'MelanopsinTransient'
        0, ...          % 'MelanopsinSustained'
        0,...           % 'MelanopsinPersistent'
        0, ...          % 'LightFluxDelay'
        20, ...         % 'LightFluxExponentialTau'
        0, ...          % 'LightFluxTransient'
        0, ...          % 'LightFluxSustained'
        0];             % 'LightFluxPersistent'
    
    initialValues = ...
        [200, ...       % 'gammaTau',
        persistentGammaTau, ...       % 'persistentGammaTau'
        -200, ...      % 'LMSDelay'
        10, ...        % 'LMSExponentialTau'
        -1, ...        % 'LMSTransient'
        -1, ...        % 'LMSSustained'
        -1,...         % 'LMSPersistent'
        -200, ...      % 'MelanopsinDelay'
        10, ...        % 'MelanopsinExponentialTau'
        -1, ...        % 'MelanopsinTransient'
        -1, ...        % 'MelanopsinSustained'
        -1,...         % 'MelanopsinPersistent'
        -200, ...      % 'LightFluxDelay'
        1, ...         % 'LightFluxExponentialTau'
        -1, ...        % 'LightFluxTransient'
        -1, ...        % 'LightFluxSustained'
        -1];           % 'LightFluxPersistent'
    
    % perform the fit
    [paramsFit,fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'vlb', vlb, 'vub', vub, 'intialValues', initialValues, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'fminconAlgorithm','sqp');
    
    if p.Results.printParams
        fprintf(' <strong>Fitting %s response </strong>\n', subjectID);
        temporalFit.paramPrint(paramsFit);
        fprintf('\n');
    end
    
    % extract the persistent gamma tau that best describes the combined group
    % response
    groupAveragePersistentGammaTau = paramsFit.paramMainMatrix(2);
    
    % summarizing the group average model fit
    LMSFit = modelResponseStruct.values(1:length(modelResponseStruct.values)/3);
    MelanopsinFit = modelResponseStruct.values(length(modelResponseStruct.values)/3+1:length(modelResponseStruct.values)/3*2);
    LightFluxFit = modelResponseStruct.values(length(modelResponseStruct.values)/3*2+1:end);
    
    if p.Results.plotFits
        plotFig = figure;
        ax1 = subplot(1,3,1); hold on;
        plot(resampledStimulusTimebase/1000, LMSResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, LMSFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('LMS')
        legend('Average response', 'Model fit')
        
        ax2 = subplot(1,3,2); hold on;
        plot(resampledStimulusTimebase/1000, MelanopsinResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, MelanopsinFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('Melanopsin')
        legend('Average response', 'Model fit')
        
        ax3 = subplot(1,3,3); hold on;
        plot(resampledStimulusTimebase/1000, LightFluxResponse, 'Color', 'k');
        plot(resampledStimulusTimebase/1000, LightFluxFit, 'Color', 'r');
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)');
        title('Light Flux')
        legend('Average response', 'Model fit')
        
        linkaxes([ax1, ax2, ax3]);
        
        set(gcf, 'Position', [29 217 1661 761]);
        
        if p.Results.plotComponents
            
            persistentAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Persistent'));
            sustainedAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Sustained'));
            transientAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Transient'));
            
            % plot the transient component
            transientParams = paramsFit;
            transientParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
            transientParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
            
            computedTransientResponse = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(1:length(computedTransientResponse.values)/3));
            subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(length(computedTransientResponse.values)/3+1:length(computedTransientResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedTransientResponse.values(length(computedTransientResponse.values)/3*2+1:end));
            
            % plot the sustained component
            sustainedParams = paramsFit;
            sustainedParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
            sustainedParams.paramMainMatrix(transientAmplitudeIndices) = 0;
            
            computedSustainedResponse = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(1:length(computedSustainedResponse.values)/3));
            subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(length(computedSustainedResponse.values)/3+1:length(computedSustainedResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedSustainedResponse.values(length(computedSustainedResponse.values)/3*2+1:end));
            
            
            % plot the persistent component
            persistentParams = paramsFit;
            persistentParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
            persistentParams.paramMainMatrix(transientAmplitudeIndices) = 0;
            
            computedPersistentResponse = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
            subplot(1,3,1); hold on;
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(1:length(computedPersistentResponse.values)/3));
            subplot(1,3,2); hold on;
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(length(computedPersistentResponse.values)/3+1:length(computedPersistentResponse.values)/3*2));
            subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, computedPersistentResponse.values(length(computedPersistentResponse.values)/3*2+1:end));
            legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
            
        end
        
    end
    
    % stash out results
    modeledResponses.LMS.timebase = resampledStimulusTimebase;
    modeledResponses.LMS.values = LMSFit;
    modeledResponses.LMS.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'LMSExponentialTau', 'LMSAmplitudeTransient', 'LMSAmplitudeSustained', 'LMSAmplitudePersistent'};
    for ii = 1:length(modeledResponses.LMS.params.paramNameCell)
        modeledResponses.LMS.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LMS.params.paramNameCell{ii}));
    end
    modeledResponses.Melanopsin.timebase = resampledStimulusTimebase;
    modeledResponses.Melanopsin.values = MelanopsinFit;
    modeledResponses.Melanopsin.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'MelanopsinExponentialTau', 'MelanopsinAmplitudeTransient', 'MelanopsinAmplitudeSustained', 'MelanopsinAmplitudePersistent'};
    for ii = 1:length(modeledResponses.Melanopsin.params.paramNameCell)
        modeledResponses.Melanopsin.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.Melanopsin.params.paramNameCell{ii}));
    end
    modeledResponses.LightFlux.timebase = resampledStimulusTimebase;
    modeledResponses.LightFlux.values = LightFluxFit;
    modeledResponses.LightFlux.params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'LightFluxExponentialTau', 'LightFluxAmplitudeTransient', 'LightFluxAmplitudeSustained', 'LightFluxAmplitudePersistent'};
    for ii = 1:length(modeledResponses.LightFlux.params.paramNameCell)
        modeledResponses.LightFlux.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LightFlux.params.paramNameCell{ii}));
    end
    
    averageResponses.LMS.values = LMSResponse;
    averageResponses.Melanopsin.values = MelanopsinResponse;
    averageResponses.LightFlux.values = LightFluxResponse;
    
    
    
    
end










end