function [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses(subjectID)

% Analyzes a single subject's pupillometry data from the OLApproach_Squint,
% SquintToPulse Experiment
%
% Syntax:
%  [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses(subjectID)
%
% Description:
%   This function analyzes the pupillometry data across all sessions for a
%   given subject as part of the OLApproach_Squint main experiment. The
%   ultimate output of the function is the average pupil response for each
%   stimulus type, at each contrast level, for the inputted subject as well
%   as the response of each individual trial organized according to trial
%   type.

%   This routine first figures out how many sessions of data have been
%   preprocessed for the inputted subject. The routine loops through each
%   session and ensures that the transparentTrack output for all trials is
%   present. If so, this session is regarded as a completed session and
%   these preprocessed pupillometry data are incorporated into further
%   analysis.

%   This routine also performs some additional preprocessing of the pupil
%   data. The steps include: identifying bad pupil frames (bad pupil frames
%   as defined by duplicate frames, frames in which the RMSE of the fit to
%   the pupil perimeter is too high, or blinks), adjusting each time series
%   according to the delay from issue of video capture command to first
%   frame of captured data, and interpolation to a common timebase. This
%   procedure is performed on each trial, and the data from these cleaned
%   trials is stored as well as averaged together across all trials.
%   Finally some summary plotting is performed.
%
% Inputs:
%	subjectID             - A string describing the subjectID (e.g.
%                           MELA_0121) to be analyzed)

% Outputs:
%   averageResponseStruct - A 3x1 structure, where each subfield
%                           corresponds to the stimulus type (LMS,
%                           Melanopsin, or Light flux). Each subfield is
%                           itself a 3x1 structure, with each nested
%                           subfield named after the contrast levels (100%,
%                           200%, and 400%). The contents of this nested
%                           layer is the average value across all trials at
%                           each timepoint. The corresponding timebase of
%                           these result values is 0:0.001:18.5.
%  trialStruct            - A nested structure similar in format to
%                           averageResponseStruct, where the first layer
%                           describes the stimulus type and second layer
%                           describes the contrast level. The innermost
%                           layer, however, is a matrix instead of a
%                           vector. Each row describes a different trial,
%                           while columns refer to the timepoint. These
%                           timeseries share the same timebase
%                           (0:0.001:18.5)


%% Find the data
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID);
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

% figure out the number of completed sessions
potentialSessions = dir(fullfile(analysisBasePath, '*session*'));
potentialNumberOfSessions = length(potentialSessions);

% initialize outputStruct
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]) = [];
    end
end

sessions = [];
for ss = 1:potentialNumberOfSessions
    acquisitions = [];
    for aa = 1:6
        trials = [];
        for tt = 1:10
            if exist(fullfile(analysisBasePath, potentialSessions(ss).name, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)), 'file');
                trials = [trials, tt];
            end
        end
        if isequal(trials, 1:10)
            acquisitions = [acquisitions, aa];
        end
    end
    if isequal(acquisitions, 1:6)
        sessions = [sessions, ss];
    end
end

completedSessions = sessions;
% get session IDs
sessionIDs = [];
for ss = completedSessions
    potentialSessions = dir(fullfile(analysisBasePath, sprintf('*session_%d*', ss)));
    % in the event of more than one entry for a given session (which would
    % happen if something weird happened with a session and it was
    % restarted on a different day), it'll grab the later dated session,
    % which should always be the one we want
    sessionIDs{ss} = potentialSessions(end).name;
end

%% Load in the data for each session
for ss = completedSessions
    for aa = 1:6
        acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_pupil.mat', ss,aa)));
        stimulusData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', ss,aa)));
        
        for tt = 1:10
            if tt ~= 1
                trialData.response = [];
                trialData = load(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)));
                
                % gather into memory the pupil area, RMSE, and timebase
                trialData.response.values = trialData.pupilData.initial.ellipses.values(:,3);
                trialData.response.timebase = acquisitionData.responseStruct.data(tt).pupil.timebase;
                trialData.response.RMSE = trialData.pupilData.initial.ellipses.RMSE;
                
                % censor bad data points. bad data points are 1) blinks
                % identified by transparentTrack (these are already censored),
                % 2) duplicate frames (indicate camera stutter), or 3) poor
                % ellipse fits (as judged by RMSE)
                
                % identify duplicate frames
                differential = diff(trialData.response.RMSE);
                duplicateFrameIndices = find(differential == 0);
                % censor duplicate frames
                for dd = duplicateFrameIndices
                    trialData.response.values(dd+1) = NaN;
                end
                
                % identify poor ellipse fits
                threshold = 5; % set the threshold for a bad fit as RMSE > 5
                poorFitFrameIndices = find(trialData.response.RMSE > threshold);
                % censor poor ellipse fits
                for pp = poorFitFrameIndices
                    trialData.response.values(pp) = NaN;
                end
                
                
                % adjust the timebase by adding the delay
                cameraCommandOutput = acquisitionData.responseStruct.data(tt).pupil.consoleOutput;
                consoleOutput = strsplit(cameraCommandOutput, 'start: ');
                startTimeFromConsoleOutput = strsplit(consoleOutput{2}, ',');
                startTimeFromConsoleOutput = str2num(startTimeFromConsoleOutput{1});
                % determine the delay from when ffmpeg thinks we launched video
                % acquisition and the UDP command thinks we went our command
                delay = startTimeFromConsoleOutput - acquisitionData.responseStruct.events(tt).tRecordingStart;
                % adjust the timebase
                trialData.response.timebase = trialData.response.timebase + delay;
                
                % now that we've found our poor fits, identify time windows
                % that will require censoring
                % the idea is that when we resample our data, these bad frames
                % shuold not be interpolated
                counter = 1;
                NaNIndices = find(isnan(trialData.response.values));
                runLengths = diff(find(diff([nan ; NaNIndices(:) ; nan]) ~= 1));
                relevantNaNIndex = 1;
                badWindowsIndices = [];
                for rr = 1:length(runLengths)
                    
                    badWindowsIndices{counter}(2) = NaNIndices(sum(runLengths(1:counter)));
                    
                    badWindowsIndices{counter}(1) = NaNIndices(sum(runLengths(1:counter)) - runLengths(counter) +1);
                    
                    %relevantNaNIndex = relevantNaNIndex+runLengths(rr)-1;
                    %badWindows{counter}(2) = NaNIndices(relevantNaNIndex+1);
                    counter = counter + 1;
                end
                
                % resample the timebase so we can put all trials on the same
                % timebase
                resampledTimebase = 0:0.001:18.5;
                
                resampledValues = interp1(trialData.response.timebase,trialData.response.values,resampledTimebase,'linear',NaN);
                trialData.responseResampled.values = resampledValues;
                trialData.responseResampled.timebase = resampledTimebase;
                
                
                plot(trialData.responseResampled.timebase, trialData.responseResampled.values)
                
                % censor out poor bad windows from our resampled timeseries
                for bb = 1:length(badWindowsIndices)
                    firstTimePoint = round(trialData.response.timebase(badWindowsIndices{bb}(1)),3);
                    secondTimePoint = round(trialData.response.timebase(badWindowsIndices{bb}(2)),3);
                    if firstTimePoint ~= secondTimePoint
                        trialData.responseResampled.values((firstTimePoint*1000+1):(secondTimePoint*1000+1)) = NaN;
                    end
                end
                
                % normalize by baseline pupil size
                baselineWindow = 1001:1501;
                baselineSize = nanmean(trialData.responseResampled.values(baselineWindow));
                trialData.responseResampled.values = trialData.responseResampled.values./baselineSize;
                
                
                
                % stash the trial
                % first figure out what type of trial we're working with
                directionNameLong = stimulusData.trialList(tt).modulationData.modulationParams.direction;
                directionNameSplit = strsplit(directionNameLong, ' ');
                if strcmp(directionNameSplit{1}, 'Light')
                    directionName = 'LightFlux';
                else
                    directionName = directionNameSplit{1};
                end
                contrastLong = strsplit(directionNameLong, '%');
                contrast = contrastLong{1}(end-2:end);
                % pool the results
                nRow = size(trialStruct.(directionName).(['Contrast', contrast]),1);
                trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = trialData.responseResampled.values;
            end
            
        end
    end
end

% make average responses
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        for tt = 1:length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,:))
            averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,tt) = nanmean(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt));
        end
    end
end


plotFig = figure;
title('Melanopsin')
hold on
plot(resampledTimebase, averageResponseStruct.Melanopsin.Contrast100)
plot(resampledTimebase, averageResponseStruct.Melanopsin.Contrast200)
plot(resampledTimebase, averageResponseStruct.Melanopsin.Contrast400)
ylim([0.4 1.3])
legend('100%', '200%', '400%')
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
saveas(plotFig, fullfile(analysisBasePath, 'melanopsin.pdf'), 'pdf');
close(plotFig)

plotFig = figure;
title('LMS')
hold on
plot(resampledTimebase, averageResponseStruct.LMS.Contrast100)
plot(resampledTimebase, averageResponseStruct.LMS.Contrast200)
plot(resampledTimebase, averageResponseStruct.LMS.Contrast400)
ylim([0.4 1.3])
legend('100%', '200%', '400%')
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
saveas(plotFig, fullfile(analysisBasePath, 'LMS.pdf'), 'pdf');
close(plotFig)

plotFig = figure;
title('LightFlux')
hold on
plot(resampledTimebase, averageResponseStruct.LightFlux.Contrast100)
plot(resampledTimebase, averageResponseStruct.LightFlux.Contrast200)
plot(resampledTimebase, averageResponseStruct.LightFlux.Contrast400)
legend('100%', '200%', '400%')
ylim([0.4 1.3])
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
saveas(plotFig, fullfile(analysisBasePath, 'lightFlux.pdf'), 'pdf');
close(plotFig)



end



