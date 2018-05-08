function [ passStatus, percentGoodFramesPerTrial ] = analyzeScreening(subjectID)


threshold = 5;
%% find the relevant DataFiles dir
projectName = 'melSquintAnalysis';
dataDirBase = fullfile(getpref(projectName, 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/Screening/DataFiles');

% determine the session for this subject
sessions = dir(fullfile(dataDirBase, subjectID));

if length(sessions) == 0
    sprintf('No session found');
    return
else
    for ss = 1:length(sessions)
        if contains(sessions(ss).name, 'session')
            sessionID = sessions(ss).name;
        end
    end
end
dataDir = fullfile(dataDirBase, subjectID, sessionID, 'videoFiles_acquisition_01');

%% loop over the trials, determine how many good and bad frames within each trial
nTrials = 12;
figure;
for tt = 1:nTrials
    
    % load the trial data
    trialDataStruct = load(fullfile(dataDir, sprintf('trial_%03d_pupil.mat',tt)));
    trialData = trialDataStruct.pupilData.initial.ellipses.values(:, 3);
    
    % plot the RMSE
    subplot(2,6,tt)
    title(sprintf('Trial %0d', tt))
    plot(trialDataStruct.pupilData.initial.ellipses.RMSE)
    
    % identify and report poor fit frames
    % poot fit frames here are defined as RMSE of the fit between the
    % ellipse and pupil perimeter greater than some threshold (5 seems
    % reasonable looking at the data)
    poorFitFramesIndices = find(trialDataStruct.pupilData.initial.ellipses.RMSE > threshold);
    
    if length(poorFitFramesIndices) ~= 0
        fprintf([fprintf('Trial %0d: %0d poor fit frames at ', tt, length(poorFitFramesIndices)), mat2str(poorFitFramesIndices) '\n']);
    end
    
    
    % identify and report duplicate frames
    % duplicate frames are identified as when the consecutive frame's RMSE
    % has not changed
    differential = diff(trialDataStruct.pupilData.initial.ellipses.RMSE);
    duplicateFrameIndices = find(differential == 0);
    
    if length(duplicateFrameIndices) ~= 0
        fprintf([fprintf('Trial %0d: %0d duplicate frames at ', tt, length(duplicateFrameIndices)), mat2str(duplicateFrameIndices) '\n']);
    end
    
    % determine how many frames are "bad". bad frames include: no ellipse
    % (blink), poor ellipse fit (RMSE > threshold), and duplicate frames
    numberBadFrames = sum(isnan(trialData)) + length(poorFitFramesIndices) + length(duplicateFrameIndices);
    goodFramesPercentage = (length(trialData) - numberBadFrames)/length(trialData);
    percentGoodFramesPerTrial(tt) = goodFramesPercentage;
    
    
    
    
    
    
    
end

%% determine if the subject passes screening
% a trial passes if at least 75% of frames are good. if at least 75% of all
% trials are good, then the session is deemed good

% percentage of frames within a trial which must be good
percentageOfGoodFramesWithinTrialCriteria = 0.75;

% percentage of total trials which must be good
percentageOfGoodTrialsCriteria = 0.75;

% loop through the trials, determine how many of them are good
nGoodTrials = 0;
for tt = 1:nTrials
    if percentGoodFramesPerTrial(tt) >= percentageOfGoodFramesWithinTrialCriteria
        nGoodTrials = nGoodTrials + 1;
    end
end

% see if enough trials are good so that we avoid exclusion criteria
if nGoodTrials/nTrials >= percentageOfGoodTrialsCriteria
    passStatus = 1;
else
    passStatus = 0;
end



end