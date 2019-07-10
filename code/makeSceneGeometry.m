function makeSceneGeometry(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('resume', false, @islogical);
p.addParameter('skipProcessing', false, @islogical);
p.addParameter('useGUI', true, @islogical);


p.parse(varargin{:})

[ defaultFitParams, cameraParams, pathParams ] = getDefaultParams(varargin{:});


pathParams.subject = subjectID;
pathParams.protocol = 'SquintToPulse';
pathParams.session = sessionID;






[runNamesList, subfoldersList] = getTrialList(pathParams, varargin{:});
grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfoldersList{end}, runNamesList{end});
processedVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, strrep(runNamesList{end}, '.mp4', '_fitStage6.avi'));
sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'sceneGeometry.mat');
pupilFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, strrep(runNamesList{end}, '.mp4', '_pupil.mat'));
%% load default scene geometry

if ~exist(fullfile(pathParams.dataOutputDirBase, 'defaultSceneGeometry.mat'))
    sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
        'radialDistortionVector', cameraParams.radialDistortionVector, ...
        'sensorResolution', cameraParams.sensorResolution);
    save(fullfile(pathParams.dataOutputDirBase, 'defaultSceneGeometry.mat'), 'sceneGeometry', '-v7.3');
else
    defaultSceneGeometryFileName =  fullfile(pathParams.dataOutputDirBase, 'defaultSceneGeometry.mat');
end

%% create ellipse array list
if p.Results.resume
    loadEllipseArrayList = true;
else
    loadEllipseArrayList = false;
end
saveName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'ellipseArrayList.mat');
[ellipseArrayList, fixationTargetArray] = pickFramesForSceneEstimation(processedVideoName, 'saveName', saveName, 'loadEllipseArrayList', loadEllipseArrayList);
%% create scene param boundaries

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', 'SquintToPulse', 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide

sceneParams.LB = [-30; -15; -15; cameraDepthMean.distanceFromCornealApexToIRLens-2*cameraDepthSD; .75; 0.9];
sceneParams.UB = [30; 15; 15; cameraDepthMean.distanceFromCornealApexToIRLens+2*cameraDepthSD; 1.25; 1.10];

sceneParams.LBp = [-15; -10; -10; cameraDepthMean.distanceFromCornealApexToIRLens-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [15; 10; 10; cameraDepthMean.distanceFromCornealApexToIRLens+1*cameraDepthSD; 1.15; 1.05 ];


if ~p.Results.skipProcessing
    estimateSceneParams(pupilFileName, sceneGeometryFileName, ...
        'ellipseArrayList', ellipseArrayList, ...
        'fixationTargetArray', fixationTargetArray, ...
        'sceneParamsLB', sceneParams.LB, ...
        'sceneParamsUB', sceneParams.UB, ...
        'sceneParamsLBp', sceneParams.LBp, ...
        'sceneParamsUBp', sceneParams.UBp, ...
        'intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
        'radialDistortionVector', cameraParams.radialDistortionVector, ...
        'sensorResolution', cameraParams.sensorResolution, ...
        'verbose', true)
end

end