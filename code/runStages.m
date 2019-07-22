function runStages(subjectID, sessionID, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo)

%% Summary of stages
% 1) De-interlace videos: not relevant for squint
% 2) findGlint
% 3) findPupilPerimeter
% 4) makeControlFile
% 5) correctPerimeter
% 6) fitEllipse to correctedPerimeter
% 7) estimate scene geometry
% 8) re-fit ellipse using scene geometry
% 9) bayesian smoothing


skipStageByNumber = setdiff(1:11, stagesToRun);
%% Get some params
[ defaultFitParams, cameraParams, pathParams, sceneParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

pathParams.subject = subjectID;
if isnumeric(sessionID)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(sessionID)]));
    sessionID = sessionDir(end).name;
end
pathParams.session = sessionID;
pathParams.protocol = 'SquintToPulse';

[pathParams.runNames, subfolders] = getTrialList(pathParams);

%% Load params for this trial
if acquisitionNumber ~= 7 && ~strcmp(acquisitionNumber, 'pupilCalibration')
    acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
else
    acquisitionFolderName = 'pupilCalibration';
end

videoName = sprintf('trial_%03d.mp4', trialNumber);

if ~isnumeric(trialNumber)
    runName = trialNumber;
elseif acquisitionNumber == 7 || strcmp(acquisitionNumber, 'pupilCalibration')
    runName = pathParams.runNames{end};
else
    runName = sprintf('trial_%03d', trialNumber);
end

pathParams.session = sessionID;
% first look for a trial specific
if exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']))
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']));
elseif exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams.mat']))
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams.mat']));
else
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, ['fitParams.mat']));
end

%% Determine scene geomtry file name
if exist(fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']))
    sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
    customSceneGeometryFileName = [runName, '_sceneGeometry.mat'];
else
    sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, pathParams.session, 'pupilCalibration', 'sceneGeometry.mat');
    customSceneGeometryFileName = 'sceneGeometry.mat';
end
    

%% Fine tune params
pathParams.grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfolders{((acquisitionNumber-1)*10)+trialNumber}, pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber});


pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{((acquisitionNumber-1)*10)+trialNumber});
runName = strsplit(pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}, '.');
pathParams.runName = runName{1};

if ~isfield(fitParams, 'expandPupilRange')
    fitParams.expandPupilRange = defaultFitParams.expandPupilRange;
end
if ~isfield(fitParams, 'candidateThetas')
    fitParams.candidateThetas = defaultFitParams.candidateThetas;
end
if ~isfield(fitParams, 'smallObjThresh')
    fitParams.smallObjThresh = defaultFitParams.smallObjThresh;
end
if ~isfield(fitParams, 'extendBlinkWindow')
    fitParams.extendBlinkWindow = defaultFitParams.extendBlinkWindow;
end
if ~isfield(fitParams, 'pickLargestCircle')
    fitParams.pickLargestCircle = defaultFitParams.pickLargestCircle;
end
if ~isfield(fitParams, 'threshold')
    fitParams.threshold = defaultFitParams.threshold;
end


%% Run the pipeline

runVideoPipeline(pathParams,...
    'skipStageByNumber', setdiff(1:11, stagesToRun),...
    'useParallel', pathParams.useParallel,...
    'verbose', pathParams.verbose, ...
    'glintFrameMask',fitParams.glintFrameMask,'glintGammaCorrection', fitParams.glintGammaCorrection, 'numberOfGlints', fitParams.numberOfGlints, ...
    'pupilRange', fitParams.pupilRange,'pupilFrameMask', fitParams.pupilFrameMask,'pupilCircleThresh', fitParams.pupilCircleThresh,'pupilGammaCorrection', fitParams.pupilGammaCorrection,'maskBox', fitParams.maskBox,...
    'cutErrorThreshold', fitParams.cutErrorThreshold, 'badFrameErrorThreshold', fitParams.badFrameErrorThreshold,'glintPatchRadius', fitParams.glintPatchRadius, 'ellipseTransparentUB',fitParams.ellipseTransparentUB, ...
    'ellipseTransparentLB',fitParams.ellipseTransparentLB, 'sceneParamsLB',sceneParams.LB, 'sceneParamsUB',sceneParams.UB, ...
    'sceneParamsLBp',sceneParams.LBp,'sceneParamsUBp',sceneParams.UBp, 'customSceneGeometryFile', customSceneGeometryFileName, ...
    'intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
    'sensorResolution', cameraParams.sensorResolution, ...
    'radialDistortionVector',cameraParams.radialDistortionVector, ...
    'constraintTolerance', fitParams.constraintTolerance, ...
    'eyeLaterality',pathParams.eyeLaterality, ...
    'makeFitVideoByNumber',[stagesToWriteToVideo], ...
    'overwriteControlFile', fitParams.overwriteControlFile, ...
    'minRadiusProportion', fitParams.minRadiusProportion, ...
    'expandPupilRange', fitParams.expandPupilRange, ...
    'candidateThetas', fitParams.candidateThetas, ...
    'smallObjThresh', fitParams.smallObjThresh, ...
    'pickLargestCircle', fitParams.pickLargestCircle, ...
    'extendBlinkWindow', fitParams.extendBlinkWindow, ...
    'glintsMainDirection', 'both', 'threshold', fitParams.threshold, 'removeIsolatedGlints', true, 'glintFileName', fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_glint.mat']));



end