function applySceneGeometryPerSession(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('resume', true ,@islogical);
p.addParameter('Protocol', 'SquintToPulse' ,@isstr);
p.addParameter('experimentNumber', []);
p.addParameter('checkStatus', false ,@islogical);
p.addParameter('debug', false ,@islogical);
p.addParameter('reprocessEverything', false ,@islogical);
p.addParameter('forceApplySceneGeometryOnly', true ,@islogical);
p.addParameter('videoRange', [] );
p.addParameter('cutErrorThreshold', 2, @isnumeric);





p.parse(varargin{:})

%% Convert session ID from numerical value to the entire string, if inputted as number
if isnumeric(sessionID)
    [ sessionID ] = getSessionID(subjectID, sessionID, 'Protocol', p.Results.Protocol);
end

%% Get some params

[~, ~, pathParams] = getDefaultParams('approach', 'Squint', 'Protocol', p.Results.Protocol);
pathParams.subject = subjectID;
pathParams.session = sessionID;
pathParams.experimentName = p.Results.experimentNumber;
[pathParams.runNames, subfolders] = getTrialList(pathParams, 'Protocol', p.Results.Protocol);


%% If we're resuming, figure out which trial we're resuming from
if ~p.Results.resume
    runsToBeProcessed = 1:length(pathParams.runNames) - 1;
    
    
else
    runsToBeProcessed = [];
    for rr = 1:length(pathParams.runNames) - 1
        if ~strcmp(pathParams.runNames{rr}, 'trial_001.mp4')
            if ~exist(fullfile(pathParams.dataOutputDirBase, subjectID, p.Results.experimentNumber, sessionID, subfolders{rr}, [pathParams.runNames{rr}(1:end-4), '_finalFit.avi']), 'file')
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
    runsToBeProcessed = firstRunIndex:lastRunIndex;
end




if isempty(runsToBeProcessed)
    fprintf('All videos have been processed for this session\n')
    return
end

if p.Results.checkStatus
    
    if isempty(p.Results.experimentNumber)
        fprintf('For subject %s, %s, need to process:\n', subjectID, sessionID)
    else
        fprintf('For subject %s, %s, %s, need to process:\n', p.Results.experimentNumber, subjectID, sessionID)
    end
    for ii = 1:length(runsToBeProcessed)
        acquisitionNumber = ceil(runsToBeProcessed(ii)/10);
        trialNumber = runsToBeProcessed(ii) - (acquisitionNumber-1)*10;
        fprintf(' - acquisition %d, trial %d\n', acquisitionNumber, trialNumber);
    end
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
        if isempty(p.Results.experimentNumber)
            fprintf('Processing %s, %s, acquisition %d, trial %d\n', subjectID, sessionID, acquisitionNumber, trialNumber);
        else
            fprintf('Processing %s %s, %s, acquisition %d, trial %d\n', subjectID, p.Results.experimentNumber, sessionID, acquisitionNumber, trialNumber);
        end
        if ~p.Results.debug
            while stillTrying
                try
                    if ~p.Results.forceApplySceneGeometryOnly
                        status = doesSessionContainGoodGlintTracking(subjectID, sessionID, 'pickTrial', [acquisitionNumber, trialNumber]);
                        if p.Results.reprocessEverything || ~status
                            
                            stagesToRun = [2 3];
                            stagesToWriteToVideo = [];
                            runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'Protocol', p.Results.Protcol, 'experimentNumber', p.Results.experimentNumber);
                            fitParams = getDefaultParams;
                            editFitParams(subjectID, sessionID, acquisitionNumber, 'trialNumber', trialNumber, 'paramName', 'threshold', 'paramValue', fitParams.threshold);
                        end
                        % only perform aggressive cutting if it hasn't been
                        % performed yet
                        controlFileName = fopen(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/', p.Results.Protocol, 'DataFiles/', subjectID, p.Results.experimentNumber, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)));
                        if p.Results.reprocessEverything
                            performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                        else
                            
                            if exist(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint', p.Results.Protocol, 'DataFiles/', subjectID, p.Results.experimentNumber, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)))
                                controlFileContents = textscan(controlFileName,'%s', 'Delimiter',',');
                                indices = strfind(controlFileContents{1}, 'cutErrorThreshold');
                                cutErrorThresholdIndex = find(~cellfun(@isempty,indices));
                                cutErrorThresholdFromControlFile = (controlFileContents{1}(cutErrorThresholdIndex+1));
                                cutErrorThresholdFromControlFile = str2num(cutErrorThresholdFromControlFile{1});
                                
                                if cutErrorThresholdFromControlFile > p.Results.cutErrorThreshold
                                    
                                    performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                                end
                            else
                                performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                                
                            end
                        end
                    end
                    applySceneGeometry(subjectID, sessionID, acquisitionNumber, trialNumber, 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);
                    stillTrying = false;
                catch
                    tryAttempt = tryAttempt + 1;
                    if tryAttempt > 5
                        stillTrying = false;
                        if isempty(p.Results.experimentNumber)
                            warning(sprintf('Failed to process %s, %s, acquisition %d, trial %d', subjectID, sessionID, acquisitionNumber, trialNumber));
                        else
                            warning(sprintf('Failed to process %s, %s, %s, acquisition %d, trial %d', subjectID, p.Results.experimentNumber, sessionID, acquisitionNumber, trialNumber));
                        end
                            
                        spacesAdjustErrorLogPath = strrep(errorLogPath, 'Dropbox (Aguirre-Brainard Lab)', 'Dropbox\ \(Aguirre-Brainard\ Lab\)');
                        if isempty(p.Results.experimentNumber)
                            system(['echo "', sprintf('Failed to process %s, %s, acquisition %d, trial %d', subjectID, sessionID, acquisitionNumber, trialNumber), '" >> ', [spacesAdjustErrorLogPath, errorLogFileName]]);
                        else
                            system(['echo "', sprintf('Failed to process %s, %s, %s, acquisition %d, trial %d', subjectID, p.Results.experimentNumber, sessionID, acquisitionNumber, trialNumber), '" >> ', [spacesAdjustErrorLogPath, errorLogFileName]]);
                        end
                    end
                    
                end
            end
        else
            if ~p.Results.forceApplySceneGeometryOnly
                status = doesSessionContainGoodGlintTracking(subjectID, sessionID, 'pickTrial', [acquisitionNumber, trialNumber]);
                if p.Results.reprocessEverything || ~status
                    
                    stagesToRun = [2 3];
                    stagesToWriteToVideo = [];
                    runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'Protocol', p.Results.Protocol', 'experimentNumber', p.Results.experimentNumber);
                    fitParams = getDefaultParams;
                    editFitParams(subjectID, sessionID, acquisitionNumber, 'trialNumber', trialNumber, 'paramName', 'threshold', 'paramValue', fitParams.threshold, 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);
                end
                % only perform aggressive cutting if it hasn't been
                % performed yet
                controlFileName = fopen(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/', p.Results.Protocol, 'DataFiles', subjectID, p.Results.experimentNumber, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)));
                if p.Results.reprocessEverything
                    performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                else
                    
                    if exist(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles/', subjectID, p.Results.experimentNumber, sessionID, sprintf('videoFiles_acquisition_%02d', acquisitionNumber), sprintf('trial_%03d_controlFile.csv', trialNumber)))
                        controlFileContents = textscan(controlFileName,'%s', 'Delimiter',',');
                        indices = strfind(controlFileContents{1}, 'cutErrorThreshold');
                        cutErrorThresholdIndex = find(~cellfun(@isempty,indices));
                        cutErrorThresholdFromControlFile = (controlFileContents{1}(cutErrorThresholdIndex+1));
                        cutErrorThresholdFromControlFile = str2num(cutErrorThresholdFromControlFile{1});
                        
                        if cutErrorThresholdFromControlFile > p.Results.cutErrorThreshold
                            
                            performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                        end
                    else
                        performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', p.Results.cutErrorThreshold);
                        
                    end
                end
            end
            applySceneGeometry(subjectID, sessionID, acquisitionNumber, trialNumber, 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);
            stillTrying = false;
            
        end
        
    end
end




end