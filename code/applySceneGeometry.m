function applySceneGeometry(subjectID, session, acquisitionNumber, trialNumber)

%% Get some params
[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

if isnumeric(session)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, ['2*session_', num2str(session)]));
    session = sessionDir(end).name;
end

pathParams.subject = subjectID;
pathParams.session = session;
pathParams.protocol = 'SquintToPulse';

[pathParams.runNames, subfoldersList] = getTrialList(pathParams);


acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
runName = sprintf('trial_%03d', trialNumber);

%% Specify where to find additional files

grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber});
perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_correctedPerimeter.mat']);
pupilFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_pupil.mat']);
glintFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_glint.mat']);
controlFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_controlFile.csv']);
outVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_fitStage7.avi']);

if exist(fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']))
    sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
    performSceneGeometryAdjustment = false;
else
    sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
    performSceneGeometryAdjustment = true;
    
end

%% Adjust the scene geometry, if necessary
if performSceneGeometryAdjustment
    % load in the pupil file
    load(pupilFileName);
    
    % use the center of the found ellipses to say where the center of the
    % pupil is
    pupilCenterXThisTrial = nanmean(pupilData.initial.ellipses.values(:,1));
    pupilCenterYThisTrial = nanmean(pupilData.initial.ellipses.values(:,2));
    
    clear pupilData
    
    % load in the pupil file for the calibration run
    load(fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}, '_pupil.mat']));
    pupilCenterXCalibration = nanmean(pupilData.initial.ellipses.values(:,1));
    pupilCenterYCalibration = nanmean(pupilData.initial.ellipses.values(:,2));
    
    % calculate the X and Y displacement, in pixels
    xDisplacement = pupilCenterXCalibration - pupilCenterXThisTrial;    
    yDisplacement = pupilCenterYCalibration - pupilCenterYThisTrial;
    
    % convert displacement in pixels to displacement in mm
    % load calibration scene geometry
    load(sceneGeometryFileName);
    eyePose1 = [-10 5 0 3];
    [pupilEllipseOnImagePlane, ~, worldPoints, ~, ~, pointLabels, ~, ~] = pupilProjection_fwd(eyePose1, sceneGeometry);

    
end

%% Re-run fitting of pupil ellipse with scene geometry

%fitPupilPerimeter(perimeterFileName, pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'verbose', true);
runStages(subjectID, session, acquisitionNumber, trialNumber, [8], [8]);

%% Perform smoothing

%smoothPupilRadius(perimeterFileName, pupilFileName, sceneGeometryFileName, 'verbose', true);
runStages(subjectID, session, acquisitionNumber, trialNumber, [9], []);

%% Make fit video
runStages(subjectID, session, acquisitionNumber, trialNumber, [10], [10]);
%makeFitVideo(grayFileName, outVideoName, 'pupilFileName', pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'glintFileName', glintFileName, 'perimeterFileName', perimeterFileName, 'controlFileName', controlFileName, 'modelEyeMaxAlpha', 1)

end