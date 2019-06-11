function [ modeledResponses, averageResponses ] = fitTPUP(subjectID, varargin)
%{
subjectID = 'MELA_0126';

%}

%% Parse the input

p = inputParser; p.KeepUnmatched = true;

p.addParameter('method','fixGamma',@ischar);
p.addParameter('determineGammaTau',true,@islogical);
p.addParameter('numberOfResponseIndicesToExclude', 40, @isnumeric);
p.addParameter('plotGroupAverageFits', false, @islogical);

p.parse(varargin{:});

%% Get the average responses


%% Perform the fitting
if strcmp(p.Results.method, 'fixGamma')
    
    if p.Results.determineGammaTau || strcmp(subjectID, 'group')
        % load average responses across all subjects
        load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat'));
        
        % compute group average responses, including NaNing poor indices (at
        % the beginning and the end)
        
        melanopsinResponse = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
        melanopsinResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
        melanopsinResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
        
        LMSResponse = nanmean(averageResponseMatrix.LMS.Contrast400);
        LMSResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
        LMSResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
        
        lightFluxResponse = nanmean(averageResponseMatrix.LightFlux.Contrast400);
        lightFluxResponse(1:p.Results.numberOfResponseIndicesToExclude) = NaN;
        lightFluxResponse(end-p.Results.numberOfResponseIndicesToExclude:end) = NaN;
        
        % assemble the responseStruct of the packet. To fix parameters,
        % we'll be concatenating these responses together.
        thePacket.response.values = [LMSResponse, melanopsinResponse, lightFluxResponse];
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
        
        % perform the fit
        [paramsFit,fVal,modelResponseStruct] = ...
            temporalFit.fitResponse(thePacket, ...
            'defaultParamsInfo', defaultParamsInfo, ...
            'fminconAlgorithm','sqp');
        
        % extract the persistent gamma tau that best describes the combined group
        % response
        groupAveragePersistentGammaTau = paramsFit.paramMainMatrix(2);
        
        % summarizing the group average model fit
        LMSFit = modelResponseStruct.values(1:length(modelResponseStruct.values)/3);
        melanopsinFit = modelResponseStruct.values(length(modelResponseStruct.values)/3+1:length(modelResponseStruct.values)/3*2);
        lightFluxFit = modelResponseStruct.values(length(modelResponseStruct.values)/3*2+1:end);
        
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
            plot(resampledStimulusTimebase/1000, melanopsinResponse, 'Color', 'k');
            plot(resampledStimulusTimebase/1000, melanopsinFit, 'Color', 'r');
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)');
            title('Melanopsin')
            legend('Group average response', 'Model fit')
            
            ax3 = subplot(1,3,3); hold on;
            plot(resampledStimulusTimebase/1000, lightFluxResponse, 'Color', 'k');
            plot(resampledStimulusTimebase/1000, lightFluxFit, 'Color', 'r');
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)');
            title('Light Flux')
            legend('Group average response', 'Model fit')
            
            linkaxes([ax1, ax2, ax3]);
            
            set(gcf, 'Position', [29 217 1661 761]);
            
        end
        
        % stash out results if we're just looking for the group average
        % response
        if strcmp(subjectID, 'group')
           modeledResponses.LMS = LMSFit;
           modeledResponses.Melanopsin = melanopsinFit;
           modeledResponses.LightFlux = lightFluxFit;
           
           averageResponses.LMS = LMSResponse;
           averageResponses.Melanopsin = melanopsinResponse;
           averageResponses.LightFlux = lightFluxResponse;
        end
        
        
    end
    
    
    
    
    
else
    
    
    
    
    
end




end