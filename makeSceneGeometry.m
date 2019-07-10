function makeSceneGeometry(subjectID, session, varargin)

%% Get some params
[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

[pathParams.runNames, subfoldersList] = getTrialList(pathParams);
if isnumeric(session)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(session)]));
    session = sessionDir(end).name;
end

pathParams.subject = subjectID;
pathParams.session = session;
pathParams.protocol = 'SquintToPulse';

%% Make default scene geometry file
sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
        'radialDistortionVector', cameraParams.radialDistortionVector, ...
        'sensorResolution', cameraParams.sensorResolution, ...
        'cameraTranslation', [0; 0; 30], ...
        'sphericalAmetropia', sphericalAmetropia);

% save scene geometry file, even though this version just serves as a
% template
sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
save(sceneGeometryFileName, sceneGeometry);

%% Make ellipseArrayList
if p.Results.resume
    loadEllipseArrayList = true;
else
    loadEllipseArrayList = false;
end
elliseArrayListFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'ellipseArrayList.mat');
[ellipseArrayList, fixationTargetArray] = pickFramesForSceneEstimation(processedVideoName, 'saveName', elliseArrayListFileName, 'loadEllipseArrayList', loadEllipseArrayList);

%% Use GUI to adjust scene geometry file
% specify where to find additional files
grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, subfoldersList{end}, pathParams.runNames{end});
perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_correctedPerimeter.mat']);


[ ~, candidateSceneGeometry] = ...
    estimateSceneParamsGUI(sceneGeometryFileName,'ellipseArrayList',ellipseArrayList,'grayVideoName',grayFileName,'perimeterFileName',perimeterFileName,'videoSuffix', '.mp4');

% save adjusted scene geometry file
save(sceneGeometryFileName, candidateSceneGeometry);

end