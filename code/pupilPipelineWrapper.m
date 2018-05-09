function pupilPipelineWrapper(pathParams, sceneParams, cameraParams, fitParams, varargin)


%
% 'pupilFrameMask', [100 400 240 300]

pathParams.dataSourceDirFull = fullfile(pathParams.dataBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');
pathParams.dataOutputDirBase = fullfile(pathParams.analysisBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');

 



% figure out the relevant calibration video -- we want the last one created
% first see if any were made after the session. if so, that's the one we
% want
potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*post.mp4'));
if ~isempty(potentialCalibrationVideos)
    calibrationRunName = [potentialCalibrationVideos(end).name];
    calibrationSubfolder = 'pupilCalibration';
else
    potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*.mp4'));
    calibrationRunName = [potentialCalibrationVideos(end).name];
    calibrationSubfolder = 'pupilCalibration';
end

% now figure out the paths of the pulse trial videos
if strcmp(pathParams.protocol, 'Screening')
    for ii = 1:12
        runNames{ii} = sprintf('trial_%03d.mp4',ii);
        trialsSubfolders{ii} = 'videoFiles_acquisition_01';
    end
end

counter = 1;
if strcmp(pathParams.protocol, 'SquintToPulse')
    for aa = 1:6
        for ii = 1:10
            runNames{counter} = sprintf('trial_%03d.mp4', ii);
            trialsSubfolders{counter} = sprintf('videoFiles_acquisition_%02d', aa);
            counter = counter + 1;
        end
    end
end

%package all of the runNames up so now we have a list of all of the video
pathParams.runNames = [runNames, calibrationRunName];
subfolders = [trialsSubfolders, calibrationSubfolder];

for rr = 1:length(pathParams.runNames)
    fprintf('Analyzing subject %s, session %s, trial %s\n', pathParams.subject, pathParams.session, pathParams.runNames{rr});

    pathParams.grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfolders{rr}, pathParams.runNames{rr});

    
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr});
    runName = strsplit(pathParams.runNames{rr}, '.');
    pathParams.runName = runName{1};
    
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
    'overwriteControlFile', fitParams.overwriteControlFile);

end