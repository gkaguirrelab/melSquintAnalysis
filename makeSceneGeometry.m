function makeSceneGeometry(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('resume', false, @islogical);
p.addParameter('skipProcessing', false, @islogical);

p.parse(varargin{:})

[ defaultFitParams, cameraParams, pathParams ] = getDefaultParams(varargin{:});


pathParams.subject = subjectID;
pathParams.protocol = 'SquintToPulse';
pathParams.session = sessionID;

%cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
%cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthMean = 24;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

[runNamesList, subfoldersList] = getTrialList(pathParams, varargin{:});
grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfoldersList{end}, runNamesList{end});

sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'sceneGeometry.mat');
pupilFileName = strrep(grayVideoName, '.mp4', '_pupil.mat');

estimateSceneParams(pupilFileName, sceneGeometryFileName)
end