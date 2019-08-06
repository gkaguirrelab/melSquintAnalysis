function applySceneGeometryPerSession(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('resume', true ,@islogical);
p.addParameter('checkStatus', false ,@islogical);
p.addParameter('debug', false ,@islogical);
p.addParameter('reprocessEverything', false ,@islogical);
p.addParameter('videoRange', [] );




p.parse(varargin{:})

%% Convert session ID from numerical value to the entire string, if inputted as number
if isnumeric(sessionID)
    [ sessionID ] = getSessionID(subjectID, sessionID, 'Protocol', 'SquintToPulse');
end

%% Get some params

[~, ~, pathParams] = getDefaultParams('approach', 'Squint', 'Protocol', 'SquintToPulse');
pathParams.subject = subjectID;
pathParams.session = sessionID;
[pathParams.runNames, subfolders] = getTrialList(pathParams, 'Protocol', 'SquintToPulse');


%% If we're resuming, figure out which trial we're resuming from
if ~p.Results.resume
    runsToBeProcessed = 1:length(pathParams.runNames) - 1;
else
    runsToBeProcessed = [];
    for rr = 1:length(pathParams.runNames) - 1
        if ~strcmp(pathParams.runNames{rr}, 'trial_001.mp4')
            if ~exist(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfolders{rr}, [pathParams.runNames{rr}(1:end-4), '_finalFit.avi']), 'file')
                runsToBeProcessed = [runsToBeProcessed, rr];
                
            end
        end
    end
end


if ~isempty(p.Results.videoRange)
    firstAcquisitionNumber = p.Results.videoRange{1}(1);
    firstTrialNumber = p.Results.videoRange{1}(2);
    
    firstRunIndex = (firstAcquisitionNumber-1)*10 + firstTrialNumber;
    
    
    secondAcquisitionNumber = p.Results.videoRange{2}(1);
    secondTrialNumber = p.Results.videoRange{2}(2);

    lastRunIndex = (secondAcquisitionNumber-1)*10 + secondTrialNumber;

    
end

if isempty(runsToBeProcessed)
    fprintf('All videos have been processed for this session\n')
    return
end

if p.Results.checkStatus
    acquisitionNumber = ceil(rr/10);
    trialNumber = rr - (acquisitionNumber-1)*10;
    
    fprintf('Processed up until %s, %s, acquisition %d, trial %d\n', subjectID, sessionID, acquisitionNumber, trialNumber);
    return
end
    

%% Do the processing

% set up error log
errorLogPath = fullfile(pathParams.dataOutputDirBase, 'errorLogs');
if ~exist(fullfile(pathParams.dataOutputDirBase, 'errorLogs'), 'dir')
    mkdir(fullfile(pathParams.dataOutputDirBase, 'errorLogs'));
end
currentTime = clock;
errorLogFileName = ['errorLog_applySceneGeometry_', num2str(currentTime(1)), '-', num2str(currentTime(2)), '-', num2str(currentTime(3)), '_', num2str(currentTime(4)), num2str(currentTime(5))];


for rr = runsToBeProcessed
    if ~strcmp(pathParams.runNames{rr}, 'trial_001.mp4')
        acquisitionNumber = ceil(rr/10);
        trialNumber = rr - (acquisitionNumber-1)*10;
        
        stillTrying = true; tryAttempt = 0;
        fprintf('Processing %s, %s, acquisition %d, trial %d\n', subjectID, sessionID, acquisitionNumber, trialNumber);
        
        if ~p.Results.debug
            while stillTrying
                try
                    status = doesSessionContainGoodGlintTracking(subjectID, sessionID, 'pickTrial', [acquisitionNumber, trialNumber]);
                    if p.Results.reprocessEverything || ~status
                        
                        stagesToRun = [2 3];
                        stagesToWriteToVideo = [];
                        runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'Protocol', 'SquintToPulse');
                        fitParams = getDefaultParams;
                        editFitParams(subjectID, sessionID, acquisitionNumber, 'trialNumber', trialNumber, 'paramName', 'threshold', 'paramValue', fitParams.threshold);
                    end
                    % only perform aggressive cutting if it hasn't been
                    % performed yet
                    controlFileName = fopen(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)));
                    if exist(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)))
                        controlFileContents = textscan(controlFileName,'%s', 'Delimiter',',');
                        indices = strfind(controlFileContents{1}, 'cutErrorThreshold');
                        cutErrorThresholdIndex = find(~cellfun(@isempty,indices));
                        cutErrorThresholdFromControlFile = (controlFileContents{1}(cutErrorThresholdIndex+1));
                        cutErrorThresholdFromControlFile = str2num(cutErrorThresholdFromControlFile{1});
                        
                        if cutErrorThresholdFromControlFile > 1
                            
                            performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', 1);
                        end
                    else
                        performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', 1);
                        
                    end
                    applySceneGeometry(subjectID, sessionID, acquisitionNumber, trialNumber);
                    stillTrying = false;
                catch
                    tryAttempt = tryAttempt + 1;
                    if tryAttempt > 5
                        stillTrying = false;
                        warning(sprintf('Failed to process %s, %s, acquisition %d, trial %d', subjectID, sessionID, acquisitionNumber, trialNumber));
                        
                        spacesAdjustErrorLogPath = strrep(errorLogPath, 'Dropbox (Aguirre-Brainard Lab)', 'Dropbox\ \(Aguirre-Brainard\ Lab\)');
                        system(['echo "', sprintf('Failed to process %s, %s, acquisition %d, trial %d', subjectID, sessionID, acquisitionNumber, trialNumber), '" >> ', [spacesAdjustErrorLogPath, errorLogFileName]]);
                    end
                    
                end
            end
        else
            status = doesSessionContainGoodGlintTracking(subjectID, sessionID, 'pickTrial', [acquisitionNumber, trialNumber]);
            if p.Results.reprocessEverything || ~status
                stagesToRun = [2 3];
                stagesToWriteToVideo = [];
                runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'Protocol', 'SquintToPulse');
                
            end
            % only perform aggressive cutting if it hasn't been
            % performed yet
            controlFileName = fopen(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)));
            if exist(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)))
                controlFileContents = textscan(controlFileName,'%s', 'Delimiter',',');
                indices = strfind(controlFileContents{1}, 'cutErrorThreshold');
                cutErrorThresholdIndex = find(~cellfun(@isempty,indices));
                cutErrorThresholdFromControlFile = (controlFileContents{1}(cutErrorThresholdIndex+1));
                cutErrorThresholdFromControlFile = str2num(cutErrorThresholdFromControlFile{1});
                
                if cutErrorThresholdFromControlFile > 1
                    
                    performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', 1);
                end
            else
                performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', 1);
                
            end
            applySceneGeometry(subjectID, sessionID, acquisitionNumber, trialNumber);
            stillTrying = false;
            
        end
        
    end
end




end