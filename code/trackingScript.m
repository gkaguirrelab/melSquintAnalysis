%% test for calibration tracking


%% setup the basic path params

% get data and analysis directory prefs
projectName = 'melSquintAnalysis';
pathParams.dataBasePath =  getpref(projectName,'melaDataPath');
pathParams.analysisBasePath = getpref(projectName,'melaAnalysisPath');



%% Parameters common to all subjects
cameraParams.intrinsicCameraMatrix =  [1347.76, 0, 658.90;...
                          0, 1345.48, 365.68;...
                          0, 0, 1];
cameraParams.sensorResolution = [1280 720];      
cameraParams.radialDistortionVector = [0.21524, -1.5616];
pathParams.verbose = true;
pathParams.useParallel = true;


%% analyze each subject

% %% MELA_0124
% pathParams.subject = 'MELA_0124';
% pathParams.protocol = 'Screening';
% pathParams.session = '2018-04-12_session_1';
% pathParams.eyeLaterality = 'left';
% 
% 
% cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
% cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
% cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide
% 
% 
% % Set up scene parameter bounds
% sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
% sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
% sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
% sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
% 
% pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
% 
% %% MELA_0125
% pathParams.subject = 'MELA_0125';
% pathParams.protocol = 'Screening';
% pathParams.session = '2018-04-13_session_1';
% pathParams.eyeLaterality = 'left';
% observedIrisDiamPixels = 550;
% 
% cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
% cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
% cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide
% 
% 
% % Set up scene parameter bounds
% sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
% sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
% sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
% sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
% 
% pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
% 
% %% MELA_0119
% pathParams.subject = 'MELA_0119';
% pathParams.protocol = 'Screening';
% pathParams.session = '2018-04-16_session_1';
% pathParams.eyeLaterality = 'left';
% 
% cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
% cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
% cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide
% 
% 
% % Set up scene parameter bounds
% sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
% sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
% sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
% sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
% 
% pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
% %% MELA_0126
% pathParams.subject = 'MELA_0126';
% pathParams.protocol = 'Screening';
% pathParams.session = '2018-04-17_session_1';
% pathParams.eyeLaterality = 'left';
% 
% cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
% cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
% cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide
% 
% 
% % Set up scene parameter bounds
% sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
% sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
% sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
% sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
% 
% pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
%% MELA_0121
pathParams.subject = 'MELA_0121';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-17_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
%% MELA_0120
pathParams.subject = 'MELA_0120';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-16_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);

%% MELA_0129
pathParams.subject = 'MELA_0129';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-18_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);


%% MELA_0122
pathParams.subject = 'MELA_0122';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-18_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);

%% MELA_0131
pathParams.subject = 'MELA_0131';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-19_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);

%% MELA_0127
pathParams.subject = 'MELA_0127';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-20_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);

%% MELA_0130
pathParams.subject = 'MELA_0130';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-24_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams);
