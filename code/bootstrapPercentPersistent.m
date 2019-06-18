function [ percentPersistentDistribution ] = bootstrapPercentPersistent(subjectList, varargin)

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
p.addParameter('makePlots',true,@islogical);
p.addParameter('saveName', [], @ischar);
p.addParameter('nBootstrapIterations', 1000, @isnumeric);
p.addParameter('nSubjectsInBootstrapSample', 20, @isnumeric);
p.addParameter('pathToAverageResponseMatrix', [], @ischar);
p.addParameter('methodToIncreasePercentPersistent', 'sameAUC', @ischar);
p.addParameter('responseTimebase', 0:1/60:18.5, @isnumeric);
p.addParameter('debugBootstrapPlots', false, @islogical);
p.parse(varargin{:});

%% Get average response matrix
if isempty(p.Results.pathToAverageResponseMatrix)
    contrasts = {'400'};
    stimuli = {'Melanopsin'};
    
    for cc = 1:length(contrasts)
        for stimulus = 1:length(stimuli)
            averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}]) = [];
        end
    end
    
    for cc = 1:length(contrasts)
        for stimulus = 1:length(stimuli)
            for ss = 1:length(subjectList)
                clear trialStruct
                subjectID = subjectList{ss};
                
                load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', subjectID, 'trialStruct_postSpotcheck.mat'));
                for tt = 1:length(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(1,:))
                    averageResponse(tt) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt));
                    STD(tt) = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt));
                    SEM(tt) = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt))/(length(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt)) - sum(isnan((trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt)))));
                end
                
                
                averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}])(ss,:) = averageResponse;
                averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}, '_STD'])(ss,:) = STD;
                averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}, '_SEM'])(ss,:) = SEM;
                
                
            end
        end
    end
else
    load(fullfile(p.Results.pathToAverageResponseMatrix));
end


%% Perform the bootstrapping
% set some variables
nSubjects = length(subjectList);
percentPersistentDistribution = [];


for ii = 1:p.Results.nBootstrapIterations
    
    % get the draw of subjects, with replacement
    bootstrappedSubjectIndices = datasample(1:nSubjects, p.Results.nSubjectsInBootstrapSample);
    
    % get the mean response of this bootstrap samples
    bootstrappedMelanopsinResponse = nanmean(averageResponseMatrix.Melanopsin.Contrast400(bootstrappedSubjectIndices, :));
    
    bootstrappedLMSResponse = nanmean(averageResponseMatrix.LMS.Contrast400(bootstrappedSubjectIndices, :));
    
    bootstrappedLightFluxResponse = nanmean(averageResponseMatrix.LightFlux.Contrast400(bootstrappedSubjectIndices, :));
    
    [modelResponses, averageResponses] = fitTPUP([], 'methodForDeterminingPersistentGammaTau', [213.888, 0, 0], 'LMSResponse', bootstrappedLMSResponse, 'MelanopsinResponse', bootstrappedMelanopsinResponse, 'LightFluxResponse', bootstrappedLightFluxResponse, 'savePath', []);
    close all
    % calculate percent persistent
    percentPersistent = modelResponses.Melanopsin.params.paramMainMatrix(6)/(modelResponses.Melanopsin.params.paramMainMatrix(4) + modelResponses.Melanopsin.params.paramMainMatrix(5) + modelResponses.Melanopsin.params.paramMainMatrix(6));
    
    % stash the result
    percentPersistentDistribution = [percentPersistentDistribution, percentPersistent];
    
    if p.Results.debugBootstrapPlots
        close all
        figure;
        plot(modelResponses.Melanopsin.timebase, modelResponses.Melanopsin.values);
        hold on
        plot(averageResponses.Melanopsin.timebase, averageResponses.Melanopsin.values);
        ylim([-0.8 0.1])
        xlim([0 17])
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)')
        title(['Percent Persistent: ', num2str(percentPersistent*100), '%']);
    end
    
    
end

%% Do some summary plotting
if p.Results.makePlots
    plotFig = figure;
    histogram(percentPersistentDistribution)
    xlabel('Percent Persistent')
    ylabel('Frequency')
    
    if ~isempty(p.Results.saveName)
        set(plotFig, 'Renderer','painters');
        print(plotFig, [p.Results.saveName, '_N', num2str(p.Results.nSubjectsInBootstrapSample)], '-dpdf');
        save([p.Results.saveName, '_N', num2str(p.Results.nSubjectsInBootstrapSample)], 'percentPersistentDistribution', '-v7.3');
    end
    close plotFig
    
    % compute group mean model fit
    [modeledResponses] = fitTPUP('group');
    plotFig = figure; hold on
    plot(modeledResponses.Melanopsin.timebase, modeledResponses.Melanopsin.values);
    xlabel('Time (ms)');
    ylabel('Pupil area (% change from baseline');
    
    percentPersistent = modeledResponses.Melanopsin.params.paramMainMatrix(7)/(modeledResponses.Melanopsin.params.paramMainMatrix(7) + modeledResponses.Melanopsin.params.paramMainMatrix(5) + modeledResponses.Melanopsin.params.paramMainMatrix(6));
    minimumDetectableIncreasedPercentPersistent = prctile(percentPersistentDistribution, 95);
    
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
        newParams.paramMainMatrix(6) = newPersistentAmplitude;
        newParams.paramMainMatrix(4) = (meanTotalAUC - newPersistentAmplitude) * transientToTransientPlusSustained;
        newParams.paramMainMatrix(5) = (meanTotalAUC - newPersistentAmplitude) * (1-transientToTransientPlusSustained);
    
        % fill out the rest of the parameters
        newParams.paramMainMatrix(1) = modeledResponses.Melanopsin.params.paramMainMatrix(1);
        newParams.paramMainMatrix(2) = modeledResponses.Melanopsin.params.paramMainMatrix(2);
        newParams.paramMainMatrix(3) = modeledResponses.Melanopsin.params.paramMainMatrix(4);
        newParams.paramMainMatrix(7) = modeledResponses.Melanopsin.params.paramMainMatrix(3);
        
        newParams.paramNameCell{1} = 'delay';
        newParams.paramNameCell{2} = 'gammaTau';
        newParams.paramNameCell{3} = 'exponentialTau';
        newParams.paramNameCell{4} = 'amplitudeTransient';
        newParams.paramNameCell{5} = 'amplitudeSustained';
        newParams.paramNameCell{6} = 'amplitudePersistent';
        newParams.paramNameCell{7} = 'persistentGammaTau';

       
        
        % make stimulus struct
        stimulusStruct = makeStimulusStruct;
        
        % compute new modeled response with increased percent persistent
        % instantiate the TPUP object
        temporalFit = tfeTPUP('verbosity','full');
        [ newModelResponseStruct ] = temporalFit.computeResponse(newParams, stimulusStruct, []);
        
        % verify new AUC
        newAUC = (newParams.paramMainMatrix(4) + newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6));
        % verify increase in percent persistent
        newPercentPersistent = newParams.paramMainMatrix(6)./newAUC;
        
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
        newParams.paramMainMatrix(6) = newPersistentAmplitude;
        newParams.paramMainMatrix(4) = modeledResponses.Melanopsin.params.paramMainMatrix(5);
        newParams.paramMainMatrix(5) = modeledResponses.Melanopsin.params.paramMainMatrix(6);
    
        % fill out the rest of the parameters
        newParams.paramMainMatrix(1) = modeledResponses.Melanopsin.params.paramMainMatrix(1);
        newParams.paramMainMatrix(2) = modeledResponses.Melanopsin.params.paramMainMatrix(2);
        newParams.paramMainMatrix(3) = modeledResponses.Melanopsin.params.paramMainMatrix(4);
        newParams.paramMainMatrix(7) = modeledResponses.Melanopsin.params.paramMainMatrix(3);
        
        newParams.paramNameCell{1} = 'delay';
        newParams.paramNameCell{2} = 'gammaTau';
        newParams.paramNameCell{3} = 'exponentialTau';
        newParams.paramNameCell{4} = 'amplitudeTransient';
        newParams.paramNameCell{5} = 'amplitudeSustained';
        newParams.paramNameCell{6} = 'amplitudePersistent';
        newParams.paramNameCell{7} = 'persistentGammaTau';
        
           
        % make stimulus struct
        stimulusStruct = makeStimulusStruct;
        
        % compute new modeled response with increased percent persistent
        % instantiate the TPUP object
        temporalFit = tfeTPUP('verbosity','full');
        [ newModelResponseStruct ] = temporalFit.computeResponse(newParams, stimulusStruct, []);
        
        % verify new AUC
        newAUC = (newParams.paramMainMatrix(4) + newParams.paramMainMatrix(5) + newParams.paramMainMatrix(6));
        % verify increase in percent persistent
        newPercentPersistent = newParams.paramMainMatrix(6)./newAUC;
        
        % plot
        plot(newModelResponseStruct.timebase, newModelResponseStruct.values);
        
        legend('Mean Model Fit', 'Increased Percent Persistent')
        
    end
    
    if ~isempty(p.Results.saveName)
        set(plotFig, 'Renderer','painters');
        print(plotFig, [p.Results.saveName, '_N', num2str(p.Results.nSubjectsInBootstrapSample), '_increasedPercentPersistent'], '-dpdf');
    end
    
  
end

end