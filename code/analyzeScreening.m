function [ passStatus, percentGoodFramesPerTrial ] = analyzeScreening(subjectID)

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
    trialDataStruct = load(fullfile(dataDir, sprintf('trial_%03d_pupil.mat',tt)));
    trialData = trialDataStruct.pupilData.initial.ellipses.values(:, 3);
    numberBadFrames = sum(isnan(trialData));
    goodFramesPercentage = (length(trialData) - numberBadFrames)/length(trialData);
    percentGoodFramesPerTrial(tt) = goodFramesPercentage;
    
    subplot(2,6,tt)
    title(sprintf('Trial %0d', tt))
    plot(trialDataStruct.pupilData.initial.ellipses.RMSE)
    
    differential = diff(trialDataStruct.pupilData.initial.ellipses.RMSE);
    duplicateFrameIndices = find(differential == 0);
    
    if length(duplicateFrameIndices) ~= 0
        fprintf([fprintf('Trial %0d: %0d duplicate frames at ', tt, length(duplicateFrameIndices)), mat2str(duplicateFrameIndices) '\n']);
    end
        
    

    


    
    
end

%% determine if the subject passes screening
% a trial passes if at least 75% of frames are good. if at least 75% of all
% trials are good, then the session is deemed good

% percentage of frames within a trial which must be good
percentageOfGoodFramesWithinTrialCriteria = 0.75;

% percentage of total trials which must be good
percentageOfGoodTrialsCriteria = 0.75;

nGoodTrials = 0;
for tt = 1:nTrials
    if percentGoodFramesPerTrial(tt) >= percentageOfGoodFramesWithinTrialCriteria
        nGoodTrials = nGoodTrials + 1;
    end
end

if nGoodTrials/nTrials >= percentageOfGoodTrialsCriteria
    passStatus = 1;
else
    passStatus = 0;
end



end