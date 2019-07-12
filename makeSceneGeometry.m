function makeSceneGeometry(subjectID, session, varargin)

%% Get some params
[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

pathParams.subject = subjectID;
if isnumeric(session)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(session)]));
    session = sessionDir(end).name;
end
pathParams.session = session;
pathParams.protocol = 'SquintToPulse';

[pathParams.runNames, subfoldersList] = getTrialList(pathParams);




%% Make default scene geometry file

% determine spherical ametropia
sphericalAmetropia = getSphericalAmetropia(subjectID);

% load measured distance away from camera
cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', 'SquintToPulse', 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));


if isempty(sphericalAmetropia)
    sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
        'radialDistortionVector', cameraParams.radialDistortionVector, ...
        'sensorResolution', cameraParams.sensorResolution, ...
        'cameraTranslation', [0; 0; cameraDepthMean.distanceFromCornealApexToIRLens]);
else
    
    sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
        'radialDistortionVector', cameraParams.radialDistortionVector, ...
        'sensorResolution', cameraParams.sensorResolution, ...
        'cameraTranslation', [0; 0; cameraDepthMean.distanceFromCornealApexToIRLens], ...
        'sphericalAmetropia', sphericalAmetropia);
end

% save scene geometry file, even though this version just serves as a
% template
sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
save(sceneGeometryFileName, 'sceneGeometry');

%% Make ellipseArrayList


processedVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_fitStage6.avi']);
elliseArrayListFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'ellipseArrayList.mat');
if ~exist(elliseArrayListFileName)
    
    [ellipseArrayList, fixationTargetArray] = pickFramesForSceneEstimation(processedVideoName, 'saveName', elliseArrayListFileName, 'loadEllipseArrayList', false);
else
    load(elliseArrayListFileName);
end
%% Use GUI to adjust scene geometry file
% specify where to find additional files
grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, subfoldersList{end}, pathParams.runNames{end});
perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_correctedPerimeter.mat']);


[ ~, sceneGeometry] = ...
    estimateSceneParamsGUI(sceneGeometryFileName,'ellipseArrayList',ellipseArrayList,'grayVideoName',grayFileName,'perimeterFileName',perimeterFileName,'videoSuffix', '.mp4');

% save adjusted scene geometry file
save(sceneGeometryFileName, 'sceneGeometry');

end