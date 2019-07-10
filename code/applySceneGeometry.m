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

%% Specify where to find additional files

grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber});
perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_correctedPerimeter.mat']);
sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
pupilFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_pupil.mat']);
glintFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_glint.mat']);
controlFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_controlFile.csv']);
outVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_fitStage7.avi']);

%% Re-run fitting of pupil ellipse with scene geometry

fitPupilPerimeter(perimeterFileName, pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'verbose', true);


%% Perform smoothing

smoothPupilRadius(perimeterFileName, pupilFileName, sceneGeometryFileName, 'verbose', true);

%% Make fit video
makeFitVideo(grayFileName, outVideoName, 'pupilFileName', pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'glintFileName', glintFileName, 'perimeterFileName', perimeterFileName, 'controlFileName', controlFileName)

end