function [ modeledResponses, averageResponses ] = fitTPUP(subjectID, varargin)
%{
subjectID = 'MELA_0126';

%}

%% Parse the input

p = inputParser; p.KeepUnmatched = true;

p.addParameter('method','HPUP',@ischar);
p.addParameter('methodForDeterminingPersistentGammaTau','fitToGroupAverage');
p.addParameter('numberOfResponseIndicesToExclude', 40, @isnumeric);
p.addParameter('plotGroupAverageFits', false, @islogical);
p.addParameter('plotFits', true, @islogical);
p.addParameter('plotComponents', true, @islogical);
p.addParameter('printParams', true, @islogical);
p.addParameter('savePath', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'TPUP', 'nonYokedPersistentGamma_300gammaLB'), @ischar);


p.parse(varargin{:});

%% Get the responses

if strcmp(subjectID, 'group') || strcmp(p.Results.methodForDeterminingPersistentGammaTau, 'fitToGroupAverage')
    % load average responses across all subjects
    load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat'));
    
    % compute group average responses, including NaNing poor indices (at
    % the beginning and the end)
    groupMelanopsinResponse = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
    groupMelanopsinResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    groupMelanopsinResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    groupLMSResponse = nanmean(averageResponseMatrix.LMS.Contrast400);
    groupLMSResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    groupLMSResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
    
    groupLightFluxResponse = nanmean(averageResponseMatrix.LightFlux.Contrast400);
    groupLightFluxResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
    groupLightFluxResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
end

if ~strcmp(subjectID, 'group')
    % load average responses across all subjects
    load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, 'trialStruct_postSpotcheck.mat'));
    
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
end


%% Fit with HPUP
if strcmp(p.Results.method, 'HPUP')
    %% Determine persistentGammaTau to be used for fitting
    if strcmp(p.Results.methodForDeterminingPersistentGammaTau, 'fitToGroupAverage') || strcmp(subjectID, 'group')
        
        
        
        % assemble the responseStruct of the packet. To fix parameters,
        % we'll be concatenating these responses together.
        thePacket.response.values = [groupLMSResponse, groupMelanopsinResponse, groupLightFluxResponse];
        thePacket.response.timebase = 0:1/60*1000:length(thePacket.response.values)*1/60 * 1000 - 1/60 * 1000;
        
        % assemble the stimuluStruct of the packet.
        stimulusStruct = makeStimulusStruct;
        % resample stimulus to match response
        resampledStimulusTimebase = 0:1/60*1000:1/60*length(groupMelanopsinResponse)*1000-1/60*1000;
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
            1, ...          % 'LMSPersistentGammaTau'
            -500, ...       % 'LMSDelay'
            1, ...          % 'LMSExponentialTau'
            -10, ...        % 'LMSTransient'
            -10, ...        % 'LMSSustained'
            -10,...         % 'LMSPersistent'
            1, ...          % 'MelanopsinPersistentGammaTau'
            -500, ...       % 'MelanopsinDelay'
            1, ...          % 'MelanopsinExponentialTau'
            -10, ...        % 'MelanopsinTransient'
            -10, ...        % 'MelanopsinSustained'
            -10,...         % 'MelanopsinPersistent'
            1, ...          % 'LightFluxPersistentGammaTau'
            -500, ...       % 'LightFluxDelay'
            1, ...          % 'LightFluxExponentialTau'
            -10, ...        % 'LightFluxTransient'
            -10, ...        % 'LightFluxSustained'
            -10];           % 'LightFluxPersistent'
        
        vub = ...
            [1000, ...      % 'gammaTau',
            1000, ...       % 'LMSPersistentGammaTau'
            0, ...          % 'LMSDelay'
            20, ...         % 'LMSExponentialTau'
            0, ...          % 'LMSTransient'
            0, ...          % 'LMSSustained'
            0,...           % 'LMSPersistent'
            1000, ...       % 'MelanopsinPersistentGammaTau'
            0, ...          % 'MelanopsinDelay'
            20, ...         % 'MelanopsinExponentialTau'
            0, ...          % 'MelanopsinTransient'
            0, ...          % 'MelanopsinSustained'
            0,...           % 'MelanopsinPersistent'
            1000, ...       % 'LightFluxPersistentGammaTau'
            0, ...          % 'LightFluxDelay'
            20, ...         % 'LightFluxExponentialTau'
            0, ...          % 'LightFluxTransient'
            0, ...          % 'LightFluxSustained'
            0];             % 'LightFluxPersistent'
        
        initialValues = ...
            [600, ...       % 'gammaTau',
            106.494, ...       % 'LMSPersistentGammaTau'
            -200, ...      % 'LMSDelay'
            10, ...        % 'LMSExponentialTau'
            -1, ...        % 'LMSTransient'
            -1, ...        % 'LMSSustained'
            -1,...         % 'LMSPersistent'
            495.852, ...       % 'MelanopsinPersistentGammaTau'            
            -200, ...      % 'MelanopsinDelay'
            10, ...        % 'MelanopsinExponentialTau'
            -1, ...        % 'MelanopsinTransient'
            -1, ...        % 'MelanopsinSustained'
            -1,...         % 'MelanopsinPersistent'
            173.53, ...       % 'LightFluxPersistentGammaTau'           
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
        groupAverageLMSPersistentGammaTau = paramsFit.paramMainMatrix(find(contains(paramsFit.paramNameCell,'LMSPersistentGammaTau')));
        groupAverageMelanopsinPersistentGammaTau = paramsFit.paramMainMatrix(find(contains(paramsFit.paramNameCell,'MelanopsinPersistentGammaTau')));
        groupAverageLightFluxPersistentGammaTau = paramsFit.paramMainMatrix(find(contains(paramsFit.paramNameCell,'LightFluxPersistentGammaTau')));

        
        % summarizing the group average model fit
        LMSFit = modelResponseStruct.values(1:length(modelResponseStruct.values)/3);
        MelanopsinFit = modelResponseStruct.values(length(modelResponseStruct.values)/3+1:length(modelResponseStruct.values)/3*2);
        LightFluxFit = modelResponseStruct.values(length(modelResponseStruct.values)/3*2+1:end);
        
        if p.Results.plotGroupAverageFits || strcmp(subjectID, 'group')
            plotFig = figure;
            ax1 = subplot(1,3,1); hold on;
            plot(resampledStimulusTimebase, groupLMSResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, LMSFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('LMS')
            legend('Group average response', 'Model fit')
            xlim([0 17*1000])
            
            
            ax2 = subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase, groupMelanopsinResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, MelanopsinFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('Melanopsin')
            legend('Group average response', 'Model fit')
            xlim([0 17*1000])
            
            
            ax3 = subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase, groupLightFluxResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, LightFluxFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('Light Flux')
            legend('Group average response', 'Model fit')
            xlim([0 17*1000])
            
            
            linkaxes([ax1, ax2, ax3]);
            
            set(gcf, 'Position', [29 217 1661 761]);
            legend('Average response', 'Model fit', 'Location', 'SouthEast')

            
            if p.Results.plotComponents
                
                persistentAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudePersistent'));
                sustainedAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudeSustained'));
                transientAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudeTransient'));
                
                % plot the transient component
                transientParams = paramsFit;
                transientParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                transientParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                
                computedTransientResponse = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(1:length(computedTransientResponse.values)/3));
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(length(computedTransientResponse.values)/3+1:length(computedTransientResponse.values)/3*2));
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(length(computedTransientResponse.values)/3*2+1:end));
                
                % plot the sustained component
                sustainedParams = paramsFit;
                sustainedParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                sustainedParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                
                computedSustainedResponse = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(1:length(computedSustainedResponse.values)/3));
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(length(computedSustainedResponse.values)/3+1:length(computedSustainedResponse.values)/3*2));
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(length(computedSustainedResponse.values)/3*2+1:end));
                
                
                % plot the persistent component
                persistentParams = paramsFit;
                persistentParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                persistentParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                
                computedPersistentResponse = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(1:length(computedPersistentResponse.values)/3));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component', 'Location', 'SouthEast')
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(length(computedPersistentResponse.values)/3+1:length(computedPersistentResponse.values)/3*2));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component', 'Location', 'SouthEast')
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(length(computedPersistentResponse.values)/3*2+1:end));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component', 'Location', 'SouthEast')
                
            end
            
            if strcmp(subjectID, 'group')
                saveas(plotFig, fullfile(p.Results.savePath, 'groupModelFits.png')), 
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
            modeledResponses.LMS.params.paramNameCell = {'gammaTau', 'LMSPersistentGammaTau', 'LMSExponentialTau', 'LMSAmplitudeTransient', 'LMSAmplitudeSustained', 'LMSAmplitudePersistent'};
            for ii = 1:length(modeledResponses.LMS.params.paramNameCell)
                modeledResponses.LMS.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LMS.params.paramNameCell{ii}));
            end
            modeledResponses.Melanopsin.timebase = resampledStimulusTimebase;
            modeledResponses.Melanopsin.values = MelanopsinFit;
            modeledResponses.Melanopsin.params.paramNameCell = {'gammaTau', 'MelanopsinPersistentGammaTau', 'MelanopsinExponentialTau', 'MelanopsinAmplitudeTransient', 'MelanopsinAmplitudeSustained', 'MelanopsinAmplitudePersistent'};
            for ii = 1:length(modeledResponses.Melanopsin.params.paramNameCell)
                modeledResponses.Melanopsin.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.Melanopsin.params.paramNameCell{ii}));
            end
            modeledResponses.LightFlux.timebase = resampledStimulusTimebase;
            modeledResponses.LightFlux.values = LightFluxFit;
            modeledResponses.LightFlux.params.paramNameCell = {'gammaTau', 'LightFluxPersistentGammaTau', 'LightFluxExponentialTau', 'LightFluxAmplitudeTransient', 'LightFluxAmplitudeSustained', 'LightFluxAmplitudePersistent'};
            for ii = 1:length(modeledResponses.LightFlux.params.paramNameCell)
                modeledResponses.LightFlux.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LightFlux.params.paramNameCell{ii}));
            end
            
            
            averageResponses.LMS = groupLMSResponse;
            averageResponses.Melanopsin = groupMelanopsinResponse;
            averageResponses.LightFlux = groupLightFluxResponse;
        end
        
        % explicitly stash persistentGammaTau, and corresponding bounds
        LMSPersistentGammaTau = groupAverageLMSPersistentGammaTau;
        LMSPersistentGammaTauUB = groupAverageLMSPersistentGammaTau;
        LMSPersistentGammaTauLB = groupAverageLMSPersistentGammaTau;

        MelanopsinPersistentGammaTau = groupAverageMelanopsinPersistentGammaTau;
        MelanopsinPersistentGammaTauUB = groupAverageMelanopsinPersistentGammaTau;
        MelanopsinPersistentGammaTauLB = groupAverageMelanopsinPersistentGammaTau;

        LightFluxPersistentGammaTau = groupAverageLightFluxPersistentGammaTau;
        LightFluxPersistentGammaTauUB = groupAverageLightFluxPersistentGammaTau;
        LightFluxPersistentGammaTauLB = groupAverageLightFluxPersistentGammaTau;
        
        
    elseif isnumeric(p.Results.methodForDeterminingPersistentGammaTau)
        
        LMSPersistentGammaTau = p.Results.methodForDeterminingPersistentGammaTau(1);
        LMSPersistentGammaTauUB = p.Results.methodForDeterminingPersistentGammaTau(1);
        LMSPersistentGammaTauLB = p.Results.methodForDeterminingPersistentGammaTau(1);

        MelanopsinPersistentGammaTau = p.Results.methodForDeterminingPersistentGammaTau(2);
        MelanopsinPersistentGammaTauUB = p.Results.methodForDeterminingPersistentGammaTau(2);
        MelanopsinPersistentGammaTauLB = p.Results.methodForDeterminingPersistentGammaTau(2);

        LightFluxPersistentGammaTau = p.Results.methodForDeterminingPersistentGammaTau(3);
        LightFluxPersistentGammaTauUB = p.Results.methodForDeterminingPersistentGammaTau(3);
        LightFluxPersistentGammaTauLB = p.Results.methodForDeterminingPersistentGammaTau(3);
        
    elseif strcmp(p.Results.methodForDeterminingPersistentGammaTau, 'fitToIndividualSubject')
        
        LMSPersistentGammaTau = 200;
        LMSPersistentGammaTauUB = 1000;
        LMSPersistentGammaTauLB = 1;

        MelanopsinPersistentGammaTau = 200;
        MelanopsinPersistentGammaTauUB = 1000;
        MelanopsinPersistentGammaTauLB = 1;

        LightFluxPersistentGammaTau = 200;
        LightFluxPersistentGammaTauUB = 1000;
        LightFluxPersistentGammaTauLB = 1;
    end
    
    %% perform the search the average responses for the individual subject
    % with our newly established persistentGammaTau
    if ~strcmp(subjectID, 'group')
        
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
            [300, ...         % 'gammaTau',
            LMSPersistentGammaTauLB, ...          % 'persistentGammaTau'
            -500, ...       % 'LMSDelay'
            1, ...          % 'LMSExponentialTau'
            -10, ...        % 'LMSTransient'
            -10, ...        % 'LMSSustained'
            -10,...         % 'LMSPersistent'
            MelanopsinPersistentGammaTauLB, ...          % 'persistentGammaTau'
            -500, ...       % 'MelanopsinDelay'
            1, ...          % 'MelanopsinExponentialTau'
            -10, ...        % 'MelanopsinTransient'
            -10, ...        % 'MelanopsinSustained'
            -10,...         % 'MelanopsinPersistent'
            LightFluxPersistentGammaTauLB, ...          % 'persistentGammaTau'
            -500, ...       % 'LightFluxDelay'
            1, ...          % 'LightFluxExponentialTau'
            -10, ...        % 'LightFluxTransient'
            -10, ...        % 'LightFluxSustained'
            -10];           % 'LightFluxPersistent'
        
        vub = ...
            [1000, ...      % 'gammaTau',
            LMSPersistentGammaTauUB, ...       % 'persistentGammaTau'
            0, ...          % 'LMSDelay'
            20, ...         % 'LMSExponentialTau'
            0, ...          % 'LMSTransient'
            0, ...          % 'LMSSustained'
            0,...           % 'LMSPersistent'
            MelanopsinPersistentGammaTauUB, ...       % 'persistentGammaTau'
            0, ...          % 'MelanopsinDelay'
            20, ...         % 'MelanopsinExponentialTau'
            0, ...          % 'MelanopsinTransient'
            0, ...          % 'MelanopsinSustained'
            0,...           % 'MelanopsinPersistent'
            LightFluxPersistentGammaTauUB, ...       % 'persistentGammaTau'
            0, ...          % 'LightFluxDelay'
            20, ...         % 'LightFluxExponentialTau'
            0, ...          % 'LightFluxTransient'
            0, ...          % 'LightFluxSustained'
            0];             % 'LightFluxPersistent'
        
        initialValues = ...
            [900, ...       % 'gammaTau',
            LMSPersistentGammaTau, ...       % 'persistentGammaTau'
            -200, ...      % 'LMSDelay'
            10, ...        % 'LMSExponentialTau'
            -1, ...        % 'LMSTransient'
            -1, ...        % 'LMSSustained'
            -1,...         % 'LMSPersistent'
            MelanopsinPersistentGammaTau, ...       % 'persistentGammaTau'
            -200, ...      % 'MelanopsinDelay'
            10, ...        % 'MelanopsinExponentialTau'
            -1, ...        % 'MelanopsinTransient'
            -1, ...        % 'MelanopsinSustained'
            -1,...         % 'MelanopsinPersistent'
            LightFluxPersistentGammaTau, ...       % 'persistentGammaTau'
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
            plot(resampledStimulusTimebase, LMSResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, LMSFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('LMS')
            legend('Average response', 'Model fit')
            xlim([0 17*1000])
            
            
            ax2 = subplot(1,3,2); hold on;
            plot(resampledStimulusTimebase, MelanopsinResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, MelanopsinFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('Melanopsin')
            legend('Average response', 'Model fit')
            xlim([0 17*1000])
            
            
            ax3 = subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase, LightFluxResponse, 'Color', 'k');
            plot(resampledStimulusTimebase, LightFluxFit, 'Color', 'r');
            xlabel('Time (ms)')
            ylabel('Pupil Area (% Change)');
            title('Light Flux')
            legend('Average response', 'Model fit')
            xlim([0 17*1000])
            
            
            linkaxes([ax1, ax2, ax3]);
            
            set(gcf, 'Position', [29 217 1661 761]);
            
            if p.Results.plotComponents
                
                persistentAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudePersistent'));
                sustainedAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudeSustained'));
                transientAmplitudeIndices = find(contains(paramsFit.paramNameCell,'AmplitudeTransient'));
                
                % plot the transient component
                transientParams = paramsFit;
                transientParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                transientParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                
                computedTransientResponse = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(1:length(computedTransientResponse.values)/3));
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(length(computedTransientResponse.values)/3+1:length(computedTransientResponse.values)/3*2));
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedTransientResponse.values(length(computedTransientResponse.values)/3*2+1:end));
                
                % plot the sustained component
                sustainedParams = paramsFit;
                sustainedParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                sustainedParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                
                computedSustainedResponse = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(1:length(computedSustainedResponse.values)/3));
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(length(computedSustainedResponse.values)/3+1:length(computedSustainedResponse.values)/3*2));
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedSustainedResponse.values(length(computedSustainedResponse.values)/3*2+1:end));
                
                
                % plot the persistent component
                persistentParams = paramsFit;
                persistentParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                persistentParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                
                computedPersistentResponse = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
                subplot(1,3,1); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(1:length(computedPersistentResponse.values)/3));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
                subplot(1,3,2); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(length(computedPersistentResponse.values)/3+1:length(computedPersistentResponse.values)/3*2));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
                subplot(1,3,3); hold on;
                plot(resampledStimulusTimebase, computedPersistentResponse.values(length(computedPersistentResponse.values)/3*2+1:end));
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component')
                
            end
            
        end
        
        % save out plot
        saveas(plotFig, fullfile(p.Results.savePath, [subjectID, '.png'])),

        
        
        % stash out results
        modeledResponses.LMS.timebase = resampledStimulusTimebase;
        modeledResponses.LMS.values = LMSFit;
        modeledResponses.LMS.params.paramNameCell = {'gammaTau', 'LMSPersistentGammaTau', 'LMSExponentialTau', 'LMSAmplitudeTransient', 'LMSAmplitudeSustained', 'LMSAmplitudePersistent'};
        for ii = 1:length(modeledResponses.LMS.params.paramNameCell)
            modeledResponses.LMS.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LMS.params.paramNameCell{ii}));
        end
        modeledResponses.Melanopsin.timebase = resampledStimulusTimebase;
        modeledResponses.Melanopsin.values = MelanopsinFit;
        modeledResponses.Melanopsin.params.paramNameCell = {'gammaTau', 'MelanopsinPersistentGammaTau', 'MelanopsinExponentialTau', 'MelanopsinAmplitudeTransient', 'MelanopsinAmplitudeSustained', 'MelanopsinAmplitudePersistent'};
        for ii = 1:length(modeledResponses.Melanopsin.params.paramNameCell)
            modeledResponses.Melanopsin.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.Melanopsin.params.paramNameCell{ii}));
        end
        modeledResponses.LightFlux.timebase = resampledStimulusTimebase;
        modeledResponses.LightFlux.values = LightFluxFit;
        modeledResponses.LightFlux.params.paramNameCell = {'gammaTau', 'LightFluxPersistentGammaTau', 'LightFluxExponentialTau', 'LightFluxAmplitudeTransient', 'LightFluxAmplitudeSustained', 'LightFluxAmplitudePersistent'};
        for ii = 1:length(modeledResponses.LightFlux.params.paramNameCell)
            modeledResponses.LightFlux.params.paramMainMatrix(ii) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.LightFlux.params.paramNameCell{ii}));
        end
        
        averageResponses.LMS.values = LMSResponse;
        averageResponses.Melanopsin.values = MelanopsinResponse;
        averageResponses.LightFlux.values = LightFluxResponse;
        
        
        
        
    end
    
elseif strcmp(p.Results.method, 'TPUP')
    stimuli = {'LMS', 'Melanopsin', 'LightFlux'};
    
    % set some boundaries and initial conditions
    vlb=[-500, 1, 1, -10, -10, -10, 1];
    vub=[0, 1000, 20, -0, -0, -0, 900];
    initialValues = [-200, 600, 5, -1, -1,0, 100];
    
    % instantiate the TPUP object
    temporalFit = tfeTPUP('verbosity','full');
    
    % start making the packet
    stimulusStruct = makeStimulusStruct;
    thePacket.stimulus = stimulusStruct;
    
    thePacket.kernel = [];
    thePacket.metaData = [];
    
    defaultParamsInfo.nInstances = 1;
    
    % set up plotting
    if p.Results.plotFits
        plotFig = figure;
    end
    
    % loop over stimuli, as for standard TPUP each is fit separately
    for ii = 1:length(stimuli)
        
        % create the response subfield
        if strcmp(stimuli{ii}, 'LMS')
            thePacket.response.values = LMSResponse;
        elseif strcmp(stimuli{ii}, 'Melanopsin')
            thePacket.response.values = MelanopsinResponse;
        elseif strcmp(stimuli{ii}, 'LightFlux')
            thePacket.response.values = LightFluxResponse;
        end
        thePacket.response.timebase = 0:1/60*1000:length(thePacket.response.values)*1/60*1000 - 1/60*1000;
        
        [paramsFit,fVal,modelResponseStruct] = ...
            temporalFit.fitResponse(thePacket, ...
            'defaultParamsInfo', defaultParamsInfo, ...
            'vlb', vlb, 'vub',vub, ...
            'initialValues',initialValues, ...
            'fminconAlgorithm','sqp');
        
        if p.Results.printParams
            fprintf(' <strong>Fitting %s response for %s stimulation </strong>\n', subjectID, stimuli{ii});
            temporalFit.paramPrint(paramsFit);
            fprintf('\n');
        end
        
        if p.Results.plotFits
            ax.(['ax', num2str(ii)]) = subplot(1,3,ii); hold on;
            plot(thePacket.response.timebase, thePacket.response.values, 'Color', 'k')
            plot(modelResponseStruct.timebase, modelResponseStruct.values, 'Color', 'r')
            legend('Average response', 'Model fit',  'Location', 'SouthEast')
            
            
            if p.Results.plotComponents
                persistentAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Persistent'));
                sustainedAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Sustained'));
                transientAmplitudeIndices = find(contains(paramsFit.paramNameCell,'Transient'));
                
                
                % plot the transient component
                transientParams = paramsFit;
                transientParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                transientParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                computedTransientResponse = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
                plot(thePacket.stimulus.timebase, computedTransientResponse.values);
                
                
                % plot the sustained component
                sustainedParams = paramsFit;
                sustainedParams.paramMainMatrix(persistentAmplitudeIndices) = 0;
                sustainedParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                computedSustainedResponse = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
                plot(thePacket.stimulus.timebase, computedSustainedResponse.values);
                
                % plot the persistent component
                persistentParams = paramsFit;
                persistentParams.paramMainMatrix(sustainedAmplitudeIndices) = 0;
                persistentParams.paramMainMatrix(transientAmplitudeIndices) = 0;
                computedPersistentResponse = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
                plot(thePacket.stimulus.timebase, computedPersistentResponse.values);
                legend('Average response', 'Model fit', 'Transient Component', 'Sustained Component', 'Persistent Component', 'Location', 'SouthEast')
                xlabel('Time (ms)')
                ylabel('Pupil Area (% Change)')
                xlim([0 17*1000])
                
                
            end
            title(stimuli{ii});
            
            
        end
        
        % stash out results
        modeledResponses.(stimuli{ii}).timebase = modelResponseStruct.timebase;
        modeledResponses.(stimuli{ii}).values = modelResponseStruct.values;
        modeledResponses.(stimuli{ii}).params.paramNameCell = {'gammaTau', 'persistentGammaTau', 'exponentialTau', 'amplitudeTransient', 'amplitudeSustained', 'amplitudePersistent'};
        for nn = 1:length(modeledResponses.(stimuli{ii}).params.paramNameCell)
            modeledResponses.(stimuli{ii}).params.paramMainMatrix(nn) =  paramsFit.paramMainMatrix(:,strcmp(paramsFit.paramNameCell,modeledResponses.(stimuli{ii}).params.paramNameCell{nn}));
        end
        
        averageResponses.(stimuli{ii}).timebase = thePacket.response.timebase;
        averageResponses.(stimuli{ii}).values = thePacket.response.values;
        
        
        
        
    end
    if p.Results.plotFits
        linkaxes([ax.ax1, ax.ax2, ax.ax3]);
        set(gcf, 'Position', [29 217 1661 761]);
        
    end
    
    
    
    
end








end