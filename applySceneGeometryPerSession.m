function applySceneGeometryPerSession(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('resume', true ,@islogical);
p.addParameter('checkStatus', false ,@islogical);
p.addParameter('reprocessEverything', false ,@islogical);



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
    firstRunIndex = 1;
else
    sessions = [];
    for rr = 1:length(pathParams.runNames) - 1
        if ~strcmp(pathParams.runNames{rr}, 'trial_001.mp4')
            if ~exist(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfolders{rr}, [pathParams.runNames{rr}(1:end-4), '_finalFit.avi']), 'file')
                firstRunIndex = rr;
                break
            end
        end
    end
end

if ~(exist('firstRunIndex', 'var'))
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


for rr = firstRunIndex:length(pathParams.runNames) - 1
    if ~strcmp(pathParams.runNames{rr}, 'trial_001.mp4')
        acquisitionNumber = ceil(rr/10);
        trialNumber = rr - (acquisitionNumber-1)*10;
        
        stillTrying = true; tryAttempt = 0;
        fprintf('Processing %s, %s, acquisition %d, trial %d\n', subjectID, sessionID, acquisitionNumber, trialNumber);
        while stillTrying
            try
                if p.Results.reprocessEverything
                    
                    stagesToRun = [2 3];
                    stagesToWriteToVideo = [];
                    runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'Protocol', 'SquintToPulse');

                end
                performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, 'cutErrorThreshold', 1.5);
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
        
    end
end




end