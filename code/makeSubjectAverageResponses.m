function [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses(subjectID)

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
end



