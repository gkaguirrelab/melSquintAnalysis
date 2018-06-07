function trackSubject(subjectID, sessionID, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);

p.parse(varargin{:})

% grab generic info
[ fitParams, cameraParams, pathParams ] = getDefaultParams(varargin{:});


pathParams.subject = subjectID;
pathParams.protocol = p.Results.protocol;
pathParams.session = sessionID;

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

% grab trial list
[runNamesList, subfoldersList] = getTrialList(pathParams, varargin{:});

grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfoldersList{1}, runNamesList{1});

[initialParams] = transparentTrackGUI(grayVideoName, varargin{:});
% incorporate new initialParams
fitParams.pupilFrameMask = initialParams.pupilFrameMask;
fitParams.pupilRange = initialParams.pupilRange;
fitParams.glintFrameMask = initialParams.glintFrameMask;
fitParams.pupilCircleThresh = initialParams.pupilCircleThresh;

% save the new params
save(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, 'fitParams.mat'),'fitParams', '-v7.3');


% do the tracking
pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);



end

