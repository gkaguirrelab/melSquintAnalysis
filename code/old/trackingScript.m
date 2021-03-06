%% test for calibration tracking


%% setup the basic path params

% get data and analysis directory prefs
projectName = 'melSquintAnalysis';
pathParams.dataBasePath =  getpref(projectName,'melaDataPath');
pathParams.analysisBasePath = getpref(projectName,'melaProcessingPath');



%% Parameters common to all subjects
cameraParams.intrinsicCameraMatrix =  [1347.76, 0, 658.90;...
    0, 1345.48, 365.68;...
    0, 0, 1];
cameraParams.sensorResolution = [1280 720];
cameraParams.radialDistortionVector = [0.21524, -1.5616];
pathParams.verbose = true;
pathParams.useParallel = true;

%% default fitParams

defaultFitParams.skipStageByNumber = [1, 7:11];
defaultFitParams.glintFrameMask = [300 600 250 400];
defaultFitParams.glintGammaCorrection = 15;
defaultFitParams.numberOfGlints = 2;
defaultFitParams.pupilRange = [30 200];
defaultFitParams.pupilFrameMask = [100 400 150 300];
defaultFitParams.pupilCircleThresh = 0.05;
defaultFitParams.pupilGammaCorrection = 0.7;
defaultFitParams.maskBox = [2 2];
defaultFitParams.cutErrorThreshold = 10;
defaultFitParams.badFrameErrorThreshold = 6;
defaultFitParams.glintPatchRadius = 35;
defaultFitParams.ellipseTransparentUB = [1280, 720, 90000, 0.6, pi];
defaultFitParams.ellipseTransparentLB = [0, 0, 1000, 0, 0];
defaultFitParams.constraintTolerance = 0.03;
defaultFitParams.minRadiusProportion = 0;
defaultFitParams.makeFitVideoByNumber = [3 6 8];
defaultFitParams.overwriteControlFile = true;
defaultFitParams.resume = false;



%% analyze each subject

%% MELA_0124
pathParams.subject = 'MELA_0124';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-12_session_1';
pathParams.eyeLaterality = 'left';


cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
% fitParams.glintFrameMask = [300 600 250 400];
% fitParams.pupilFrameMask = [200 450 150 300];
fitParams.pupilFrameMask = [176.6201 552.9986 183.7526 357.2165];
          fitParams.pupilRange = [round(107.8882) round(131.8633)];
       fitParams.glintFrameMask = [307 716.5000 286 463.5000];
    fitParams.pupilCircleThresh = 0.0480;



pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0125
pathParams.subject = 'MELA_0125';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-13_session_1';
pathParams.eyeLaterality = 'left';
observedIrisDiamPixels = 550;

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0119
pathParams.subject = 'MELA_0119';
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

fitParams = defaultFitParams;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
%% MELA_0126
pathParams.subject = 'MELA_0126';
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

fitParams = defaultFitParams;

% for the calibration at least:
fitParams.glintFrameMask = [150 600 250 400];
fitParams.pupilFrameMask = [50 400 150 300];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;
       fitParams.pupilFrameMask =  [225 541 254 490];
           fitParams.pupilRange = [72 88];
       fitParams.glintFrameMask = [280 617 316 563];
    fitParams.pupilCircleThresh = 0.0180;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;
fitParams.glintFrameMask = [180 600 250 400];



pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

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

fitParams = defaultFitParams;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;
fitParams.glintFrameMask = [250 340 300 500];
fitParams.ellipseTransparentUB = [1280,720,90000,0.2,pi];
fitParams.pupilFrameMask = [100 400 150 300];
fitParams.maskBox = [3 3];
fitParams.badFrameErrorThreshold = 10;
fitParams.minRadiusProportion = -0.5;
fitParams.cutErrorThreshold = 4;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;
fitParams.ellipseTransparentUB = [1280, 720, 70000, 0.6, pi];


pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
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

fitParams = defaultFitParams;
fitParams.glintFrameMask = [300 500 200 300];
fitParams.pupilFrameMask = [200 450 150 300];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0132
pathParams.subject = 'MELA_0132';
pathParams.protocol = 'Screening';
pathParams.session = '2018-04-26_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
fitParams.ellipseTransparentUB = [1280, 720, 90000, 0.2, pi];
fitParams.glintFrameMask = [250 400 250 400];
fitParams.pupilFrameMask = [150 420 200 400];
fitParams.minRadiusProportion = -0.5;
fitParams.cutErrorThreshold = 4;


pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);


%% MELA_0134
pathParams.subject = 'MELA_0134';
pathParams.protocol = 'Screening';
pathParams.session = '2018-05-03_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
fitParams.glintFrameMask = [300 400 250 400];
fitParams.pupilFrameMask = [200 420 200 400];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0136
pathParams.subject = 'MELA_0136';
pathParams.protocol = 'Screening';
pathParams.session = '2018-05-09_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;

fitParams.ellipseTransparentUB = [1280, 720, 90000, 0.2, pi];
fitParams.glintFrameMask = [300 400 250 400];
fitParams.pupilFrameMask = [180 350 200 450];
fitParams.pupilRange = [60 200];
fitParams.maskBox = [1.1, 1.1];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0137
pathParams.subject = 'MELA_0137';
pathParams.protocol = 'Screening';
pathParams.session = '2018-05-10_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
fitParams.glintFrameMask = [300 400 250 400];
fitParams.pupilFrameMask = [140 350 180 450];
fitParams.pupilRange = [60 200];
fitParams.maskBox = [1.1, 1.1];

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);

%% MELA_0138
pathParams.subject = 'MELA_0138';
pathParams.protocol = 'Screening';
pathParams.session = '2018-05-14_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
fitParams.glintFrameMask = [250 400 250 400];
fitParams.pupilFrameMask = [80 350 300 450];
fitParams.pupilRange = [60 200];
fitParams.maskBox = [1.1, 1.1];
fitParams.glintPatchRadius = 55;


pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
%% MELA_0140
pathParams.subject = 'MELA_0140';
pathParams.protocol = 'Screening';
pathParams.session = '2018-06-05_session_1';
pathParams.eyeLaterality = 'left';

cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

fitParams = defaultFitParams;
% fitParams.glintFrameMask = [300 550 250 500];
% fitParams.pupilFrameMask = [100 350 150 300];
% fitParams.pupilCircleThresh = 0.04;
% fitParams.pupilRange = [100 200];
% fitParams.maskBox = [1 1];


       fitParams.pupilFrameMask= [174.7702 383.4261 171.3281 511.5843];
       fitParams.glintFrameMask= [307 559 282 621];
    fitParams.pupilCircleThresh= 0.0470;

pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
%% SQUINT TO PULSE DATA
%% MELA_0130

pathParams.subject = 'MELA_0130';
pathParams.protocol = 'SquintToPulse';
pathParams.eyeLaterality = 'left';


cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds


fitParams = defaultFitParams;


for ss = 1:4
    pathParams.session = ['2018-05-04_session_', num2str(ss)];
    if ss == 1
        fitParams.glintFrameMask = [300 500 200 500];
        fitParams.pupilFrameMask = [200 450 150 450];
        fitParams.pupilCircleThresh = 0.02;
    end
    if ss == 2
        fitParams.glintFrameMask = [300 800 200 150];
        fitParams.pupilFrameMask = [250 750 100 150];
    end
    if ss == 3
        fitParams.glintFrameMask = [300 500 200 500];
        fitParams.pupilFrameMask = [200 450 150 450];
    end
    if ss == 4
        fitParams.resume = true;
    end
    
    
    cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
    cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
    
    sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
    sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
    sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
    sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
    pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
end

%% MELA_0121

pathParams.subject = 'MELA_0121';
pathParams.protocol = 'SquintToPulse';
pathParams.eyeLaterality = 'left';


cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds


fitParams = defaultFitParams;


for ss = 3:4
    if ss == 1
        pathParams.session = '2018-05-02_session_1';
        
        fitParams.glintFrameMask = [280 500 200 500];
        fitParams.pupilFrameMask = [150 420 150 480];
    end
    if ss == 2
        pathParams.session = '2018-05-09_session_2';
        
        fitParams.glintFrameMask = [280 500 200 500];
        fitParams.pupilFrameMask = [150 420 150 480];
        fitParams.pupilRange = [60 200];
        
    end
    if ss == 3
        pathParams.session = '2018-05-09_session_3';
        
        fitParams.glintFrameMask = [280 500 200 500];
        fitParams.pupilFrameMask = [150 420 150 480];
        fitParams.pupilRange = [60 200];
        fitParams.resume = true;
    end
    if ss == 4
        fitParams = defaultFitParams;
        
        pathParams.session = '2018-05-16_session_4';
        fitParams.glintFrameMask = [300 550 250 550];
        fitParams.resume = true;
    end
    
    cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
    cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
    
    sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
    sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
    sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
    sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
    pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
end

%% MELA_0120

pathParams.subject = 'MELA_0120';
pathParams.protocol = 'SquintToPulse';
pathParams.eyeLaterality = 'left';


cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds




for ss = 1:2
    pathParams.session = ['2018-05-11_session_', num2str(ss)];
    if ss == 1
        fitParams = defaultFitParams;
        
        fitParams.glintFrameMask = [300 500 200 500];
        fitParams.pupilFrameMask = [200 420 150 450];
        fitParams.pupilCircleThresh = 0.06;
    end
    if ss == 2
        fitParams = defaultFitParams;
        
        fitParams.glintFrameMask = [300 500 200 500];
        fitParams.pupilFrameMask = [200 390 110 450];
        fitParams.pupilCircleThresh = 0.06;
    end
    
    
    
    cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
    cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
    
    sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
    sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
    sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
    sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
    pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams);
end

%%