function [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses_interpolateLast(subjectID, varargin)

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
%
% Optional Key-Value Pairs:
%   debugSpikeRemover     - A logical. If set to true, the routine will
%                           display a plot of each trial's response and
%                           which points have been identified as spikes to
%                           be removed.
%
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

%% Parse the input

p = inputParser; p.KeepUnmatched = true;
p.addParameter('debugSpikeRemover',false,@islogical);
p.addParameter('debugNumberOfNaNValuesPerTrial', false, @islogical);
p.addParameter('sessions', {}, @iscell);

p.parse(varargin{:});

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

if isempty(p.Results.sessions)
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
        for ii = 1:length(potentialSessions)
            if ~strcmp(potentialSessions(ii).name(1), 'x')
                sessionIDs{ss} = potentialSessions(ii).name;
            end
        end
    end
else
    sessionIDs = p.Results.sessions;
    numberOfCompletedSessions = 1:length(sessionIDs)
end

%% Load in the data for each session
for ss = 1:length(sessionIDs)
    sessionNumber = strsplit(sessionIDs{ss}, 'session_');
    sessionNumber = sessionNumber{2};
    for aa = 1:6
        acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_pupil.mat', str2num(sessionNumber),aa)));
        stimulusData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', str2num(sessionNumber),aa)));
        
        for tt = 1:10
            if tt ~= 1
                trialData.response = [];
                trialData = load(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)));
                
                % gather into memory the pupil area, RMSE, and timebase
                trialData.response.values = trialData.pupilData.initial.ellipses.values(:,3);
                trialData.response.timebase = acquisitionData.responseStruct.data(tt).pupil.timebase;
                trialData.response.RMSE = trialData.pupilData.initial.ellipses.RMSE;
                
                % identify duplicate frames
                differential = [];
                differential = diff(trialData.response.RMSE);
                duplicateFrameIndices = [];
                duplicateFrameIndices = find(differential == 0);
                % censor duplicate frames
                for dd = duplicateFrameIndices
                    trialData.response.values(dd+1) = NaN;
                end
                
                % mean-center:
                
                
                
                
                
                
                
                
                
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
                
                % find the indices corresponding to 1 and 1.5 s with the
                % new timebase
                [~, baselineWindowOnsetIndex ] = min(abs(1-trialData.response.timebase));
                [~, baselineWindowOffsetIndex ] = min(abs(1.5-trialData.response.timebase));
                baselineSize = nanmean(trialData.response.values(baselineWindowOnsetIndex:baselineWindowOffsetIndex));
                trialData.response.values = (trialData.response.values - baselineSize)./baselineSize;
                
                % remove blinks
                controlFile = loadControlFile(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_controlFile.csv', tt)));
                blinkIndices = [];
                for ii = 1:length(controlFile)
                    if strcmp(controlFile(ii).type, 'blink')
                        blinkFrame = controlFile(ii).frame;
                        blinkIndices = [blinkIndices, blinkFrame];
                        trialData.response.values((blinkFrame-5):(blinkFrame+5)) = NaN;
                    end
                end
                    
                
                removePoints = [];
                [iy, removePoints] = PupilAnalysisToolbox_SpikeRemover(trialData.response.values);
                if p.Results.debugSpikeRemover
                    figure; hold on;
                    plot(trialData.response.values)
                    plot(removePoints, trialData.response.values(removePoints), 'o', 'Color', 'r')
                end
                trialData.response.values(removePoints) = NaN;
                
                % identify poor ellipse fits
                threshold = 5; % set the threshold for a bad fit as RMSE > 5
                poorFitFrameIndices = [];
                poorFitFrameIndices = find(trialData.response.RMSE > threshold);
                % censor poor ellipse fits
                for pp = poorFitFrameIndices
                    trialData.response.values(pp) = NaN;
                end
                
                numberOfBadFrames = sum(isnan(trialData.response.values));
                percentageBadFrames = numberOfBadFrames/(length(trialData.response.values));
                
                % resample the timebase so we can put all trials on the same
                % timebase
                stepSize = 1/60;
                resampledTimebase = 0:stepSize:18.5;
                
                resampledValues = [];
                resampledRMSE = [];
                
                % interpolate across all NaN values
                theNans = isnan(trialData.response.values);
                if sum(~theNans) > 1
                    x = trialData.response.values;
                    x(theNans) = interp1(trialData.response.timebase(~theNans), trialData.response.values(~theNans), trialData.response.timebase(theNans)', 'linear');
                    trialData.response.values = x;
                end
                
                % interpolate onto common timebase across trials
                resampledValues = interp1(trialData.response.timebase,trialData.response.values,resampledTimebase,'linear');
                
                
                trialData.responseResampled = [];
                trialData.responseResampled.values = resampledValues;
                trialData.responseResampled.timebase = resampledTimebase;
                
                % normalize by baseline pupil size
                % the 4 second pulse of light begins at 1.5 s, so we're
                % taking the 0.5 seconds before that as our normalization
                % window
                baselineWindow = 1/stepSize+1:1.5/stepSize+1;
                %baselineSize = nanmean(trialData.responseResampled.values(baselineWindow));
                %trialData.responseResampled.values = (trialData.responseResampled.values-baselineSize)./baselineSize;
                
                
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
                
                % throw out a trial if we have too many bad points
                % find all indices that are NaN
                nonNanIndices = [];
                nonNanIndices = find(~isnan(trialData.responseResampled.values));
                
                if isempty(nonNanIndices)
                    nonNanIndices = [1, length(trialData.responseResampled.values)];
                end
                
                trialNanThreshold = 0.2;
                
                if p.Results.debugNumberOfNaNValuesPerTrial
                    close all;
                    figure; plot(trialData.response.timebase, (trialData.pupilData.initial.ellipses.values(:,3)-baselineSize)./baselineSize); hold on; plot(resampledTimebase, resampledValues)

                    
                    fprintf('Session %d, Acquisition %d, Trial %d: %f\n', str2num(sessionNumber), aa, tt, percentageBadFrames);
                    fprintf('\tBlink frames: %d\n', length(blinkIndices));
                    fprintf('\tDuplicate frames: %d\n', length(duplicateFrameIndices));
                    fprintf('\tPoor fit frames: %d\n', length(poorFitFrameIndices));

                end
                
                if percentageBadFrames >= trialNanThreshold;
                    %trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = nan(1,length(trialData.responseResampled.values));
                    badTrial = tt;
                else
                    trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = trialData.responseResampled.values;
                end
            end
            
        end
    end
end

% make average responses
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        for tt = 1:length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,:))
            averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,tt) = nanmean(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt));
            averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_SEM'])(1,tt) = nanstd(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt))/(length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt)) - sum(isnan((trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt)))));
        end
    end
end

fileName = 'trialStruct';
save(fullfile(analysisBasePath, fileName), 'trialStruct', 'trialStruct', '-v7.3');



plotFig = figure;
subplot(3,1,1)
title('Melanopsin')
hold on
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5)

lineProps.width = 1;
lineProps.col{1} = [220/255, 237/255, 200/255];
mseb(resampledTimebase-1, averageResponseStruct.Melanopsin.Contrast100, averageResponseStruct.Melanopsin.Contrast100_SEM, lineProps)

lineProps.col{1} = [66/255, 179/255, 213/255];
mseb(resampledTimebase-1, averageResponseStruct.Melanopsin.Contrast200, averageResponseStruct.Melanopsin.Contrast200_SEM, lineProps)

lineProps.col{1} = [26/255, 35/255, 126/255];
mseb(resampledTimebase-1, averageResponseStruct.Melanopsin.Contrast400, averageResponseStruct.Melanopsin.Contrast400_SEM, lineProps)
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
%saveas(plotFig, fullfile(analysisBasePath, 'melanopsin.pdf'), 'pdf');
%close(plotFig)

subplot(3,1,2)
title('LMS')
hold on
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5)

grayColorMap = colormap(gray);
lineProps.width = 1;
lineProps.col{1} = grayColorMap(50,:);
mseb(resampledTimebase-1, averageResponseStruct.LMS.Contrast100, averageResponseStruct.LMS.Contrast100_SEM, lineProps)

lineProps.col{1} = grayColorMap(25,:);
mseb(resampledTimebase-1, averageResponseStruct.LMS.Contrast200, averageResponseStruct.LMS.Contrast200_SEM, lineProps)

lineProps.col{1} = grayColorMap(1,:);
mseb(resampledTimebase-1, averageResponseStruct.LMS.Contrast400, averageResponseStruct.LMS.Contrast400_SEM, lineProps)
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
%saveas(plotFig, fullfile(analysisBasePath, 'LMS.pdf'), 'pdf');
%close(plotFig)

subplot(3,1,3)
title('LightFlux')
hold on
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5)

lineProps.width = 1;
lineProps.col{1} = [254/255, 235/255, 101/255];
mseb(resampledTimebase-1, averageResponseStruct.LightFlux.Contrast100, averageResponseStruct.LightFlux.Contrast100_SEM, lineProps)

lineProps.col{1} = [228/255, 82/255, 27/255];
mseb(resampledTimebase-1, averageResponseStruct.LightFlux.Contrast200, averageResponseStruct.LightFlux.Contrast200_SEM, lineProps)

lineProps.col{1} = [77/255, 52/255, 47/255];
mseb(resampledTimebase-1, averageResponseStruct.LightFlux.Contrast400, averageResponseStruct.LightFlux.Contrast400_SEM, lineProps)
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
print(plotFig, fullfile(analysisBasePath,'averageResponse_interpolateLast'), '-dpdf', '-fillpage')
close(plotFig)



end



