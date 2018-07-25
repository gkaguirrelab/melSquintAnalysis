function pupilPipelineWrapper(pathParams, sceneParams, cameraParams, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);

p.parse(varargin{:})

%% Get the list of trials for the relevant protocol

[pathParams.runNames, subfolders] = getTrialList(pathParams, 'protocol', p.Results.protocol);

%% if we're resuming the analysis, figure out which trial we're resuming on
if ~pathParams.resume
    firstRunIndex = 1;
else    
    sessions = [];
    for rr = 1:length(pathParams.runNames)        
        if ~exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr}, [pathParams.runNames{rr}(1:end-4), '_pupil.mat']), 'file')
            firstRunIndex = rr;
            break
        end        
    end 
end
if ~(exist('firstRunIndex', 'var'))
    fprintf('All videos have been processed for this session\n')
    return
end

%% assemble the fit params cell array
% most runs will be processed according by the same fitParams, so prepare a
% cell array that lists these fitParams for each run
if exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, 'fitParams.mat'), 'file')
    fitParams_new = load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, 'fitParams.mat'));
    for rr = 1:length(pathParams.runNames)
        fitParamsCellArray{rr} = fitParams_new;
    end
end

if strcmp(pathParams.protocol, 'SquintToPulse')
    for aa = 1:7
        if exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{(aa-1)*10+1}, ['fitParams.mat']), 'file')
            fitParams_new = load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{(aa-1)*10+1}, ['fitParams.mat']));
            if aa ~= 7
                relevantIndices = [((aa-1)*10+1):(aa*10)];
            else
                relevantIndices = [61];
            end
            for rr = relevantIndices
                
                
                
                fitParamsCellArray{rr} = fitParams_new;
            end
        end
    end
end

if strcmp(pathParams.protocol, 'Screening')
    for tt = 1:12
        fitParamsCellArray{tt} = load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{tt}, 'fitParams.mat'));
    end
end

% however, some runs might benefit from different params. for these runs,
% swap the relevant fitParams in place of the default fitParams
for rr = 1:length(pathParams.runNames)
    if exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr}, ['fitParams_', pathParams.runNames{rr}(1:end-4), '.mat']), 'file')
        fitParams_new = load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr}, ['fitParams_', pathParams.runNames{rr}(1:end-4), '.mat']));
        fitParamsCellArray{rr} = fitParams_new;
    end
end

fitParams = [];
%% Run the video pipeline
for rr = firstRunIndex:length(pathParams.runNames)
    fitParams = fitParamsCellArray{rr}.fitParams;
    fprintf('Analyzing subject %s, session %s, acquisition %s, %s\n', pathParams.subject, pathParams.session, subfolders{rr}(end-1:end), pathParams.runNames{rr}(1:end-4));

    pathParams.grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfolders{rr}, pathParams.runNames{rr});

    
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr});
    runName = strsplit(pathParams.runNames{rr}, '.');
    pathParams.runName = runName{1};
    
    if ~isfield(fitParams, 'expandPupilRange')
        fitParams.expandPupilRange = true;
    end
        
    
    runVideoPipeline(pathParams,...
    'skipStageByNumber', fitParams.skipStageByNumber,...
    'useParallel', pathParams.useParallel,...
    'verbose', pathParams.verbose, ...
    'glintFrameMask',fitParams.glintFrameMask,'glintGammaCorrection', fitParams.glintGammaCorrection, 'numberOfGlints', fitParams.numberOfGlints, ...
    'pupilRange', fitParams.pupilRange,'pupilFrameMask', fitParams.pupilFrameMask,'pupilCircleThresh', fitParams.pupilCircleThresh,'pupilGammaCorrection', fitParams.pupilGammaCorrection,'maskBox', fitParams.maskBox,...
    'cutErrorThreshold', fitParams.cutErrorThreshold, 'badFrameErrorThreshold', fitParams.badFrameErrorThreshold,'glintPatchRadius', fitParams.glintPatchRadius, 'ellipseTransparentUB',fitParams.ellipseTransparentUB, ...
    'ellipseTransparentLB',fitParams.ellipseTransparentLB, 'sceneParamsLB',sceneParams.LB, 'sceneParamsUB',sceneParams.UB, ...
    'sceneParamsLBp',sceneParams.LBp,'sceneParamsUBp',sceneParams.UBp,...
    'intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
    'sensorResolution', cameraParams.sensorResolution, ...
    'radialDistortionVector',cameraParams.radialDistortionVector, ...
    'constraintTolerance', fitParams.constraintTolerance, ...
    'eyeLaterality',pathParams.eyeLaterality, ...
    'makeFitVideoByNumber',fitParams.makeFitVideoByNumber, ...
    'overwriteControlFile', fitParams.overwriteControlFile, ...
    'minRadiusProportion', fitParams.minRadiusProportion, ...
    'expandPupilRange', fitParams.expandPupilRange);

end