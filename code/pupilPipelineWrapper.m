function pupilPipelineWrapper(pathParams, sceneParams, cameraParams, varargin)


pathParams.dataSourceDirFull = fullfile(pathParams.dataBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');
pathParams.dataOutputDirBase = fullfile(pathParams.analysisBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');

 



% figure out the relevant calibration video -- we want the last one created
% first see if any were made after the session. if so, that's the one we
% want
potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*post.mp4'));
if ~isempty(potentialCalibrationVideos)
    calibrationRunName = ['pupilCalibration/', potentialCalibrationVideos(end).name];
else
    potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*.mp4'));
    calibrationRunName = ['pupilCalibration/', potentialCalibrationVideos(end).name];
end

% now figure out the paths of the pulse trial videos
if strcmp(pathParams.protocol, 'Screening')
    for ii = 1:12
        runNames{ii} = sprintf('videoFiles_acquisition_01/trial_%03d.mp4',ii);
    end
end

counter = 1;
if strcmp(pathParams.protocol, 'SquintToPulse')
    for aa = 1:6
        for ii = 1:10
            runNames{counter} = sprintf('videoFiles_acquisition_%02d/trial_%03d.mp4',aa, ii);
            counter = counter + 1;
        end
    end
end

%package all of the runNames up so now we have a list of all of the video
pathParams.runNames = [runNames, calibrationRunName];

for rr = 1:length(pathParams.runNames)
    pathParams.grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, pathParams.runNames{rr});
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session);
    runName = strsplit(pathParams.runNames{rr}, '.');
    pathParams.runName = runName{1};
    
    runVideoPipeline(pathParams,...
    'skipStageByNumber', [1,7:11],...
    'useParallel', pathParams.useParallel,...
    'verbose', pathParams.verbose, ...
    'glintFrameMask',[180 340 350 500],'glintGammaCorrection', 15, 'numberOfGlints', 2, ...
    'pupilRange', [60 200],'pupilFrameMask', [100 400 240 300],'pupilCircleThresh', 0.02,'pupilGammaCorrection', 0.7,'maskBox', [1 1],...
    'cutErrorThreshold', 10, 'badFrameErrorThreshold', 6,'glintPatchRadius', 35, 'ellipseTransparentUB',[1280,720,40000,0.6,pi], ...
    'ellipseTransparentLB',[0,0,1000,0,0], 'sceneParamsLB',sceneParams.LB, 'sceneParamsUB',sceneParams.UB, ...
    'sceneParamsLBp',sceneParams.LBp,'sceneParamsUBp',sceneParams.UBp,...
    'intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
    'sensorResolution', cameraParams.sensorResolution, ...
    'radialDistortionVector',cameraParams.radialDistortionVector, ...
    'constraintTolerance',0.03, ...
    'eyeLaterality',pathParams.eyeLaterality, ...
    'makeFitVideoByNumber',[3 6 8]);

end