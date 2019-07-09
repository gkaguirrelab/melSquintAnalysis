function [ fitParams, cameraParams, pathParams ] = getDefaultParams(varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);

p.parse(varargin{:})

%% define the default params
if strcmp(p.Results.approach, 'Squint')
    
    projectName = 'melSquintAnalysis';
    pathParams.dataBasePath =  getpref(projectName,'melaDataPath');
    pathParams.analysisBasePath = getpref(projectName,'melaProcessingPath');
    pathParams.verbose = true;
    pathParams.useParallel = true;
    pathParams.eyeLaterality = 'left';
    pathParams.resume = false;

    
    pathParams.dataSourceDirFull = fullfile(pathParams.dataBasePath,'Experiments','OLApproach_Squint',p.Results.protocol,'DataFiles');
    pathParams.dataOutputDirBase = fullfile(pathParams.analysisBasePath,'Experiments','OLApproach_Squint',p.Results.protocol,'DataFiles');

    
    fitParams.skipStageByNumber = [1, 7:11];
    fitParams.glintFrameMask = [300 600 250 400];
    fitParams.glintGammaCorrection = 15;
    fitParams.numberOfGlints = 2;
    fitParams.pupilRange = [30 200];
    fitParams.pupilFrameMask = [100 400 150 300];
    fitParams.pupilCircleThresh = 0.05;
    fitParams.pupilGammaCorrection = 0.7;
    fitParams.maskBox = [1 1];
    fitParams.cutErrorThreshold = 4;
    fitParams.badFrameErrorThreshold = 6;
    fitParams.glintPatchRadius = 35;
    fitParams.ellipseTransparentUB = [1280, 720, 90000, 0.6, pi];
    fitParams.ellipseTransparentLB = [0, 0, 1000, 0, 0];
    fitParams.constraintTolerance = 0.03;
    fitParams.minRadiusProportion = 0;
    fitParams.makeFitVideoByNumber = [6];
    fitParams.overwriteControlFile = true;
    fitParams.frameMaskValue = 220;
    fitParams.candidateThetas = 0:pi/16:2*pi;
    fitParams.minRadiusProportion = -0.5;
    fitParams.glintPatchRadius = 40;
    fitParams.smallObjThresh = 3000;
    fitParams.candidateThetas = pi/2:pi/16:3*pi/2;
    fitParams.expandPupilRange = true;
    fitParams.extendBlinkWindow = [0 0];
    fitParams.pickLargestCircle = false;
    fitParams.threshold = 0.10;
    
    cameraParams.intrinsicCameraMatrix =  [1347.76, 0, 658.90; ...
                                            0, 1345.48, 365.68; ...
                                            0, 0, 1];
    cameraParams.sensorResolution = [1280 720];
    cameraParams.radialDistortionVector = [0.21524, -1.5616];
    
    
end