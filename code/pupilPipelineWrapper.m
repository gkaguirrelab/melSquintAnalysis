function pupilPipelineWrapper(pathParams, varargin)


pathParams.dataSourceDirFull = fullfile(MELA_dataBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');
pathParams.dataOutputDirFull = fullfile(MELA_analysisBasePath,'Experiments','OLApproach_Squint',pathParams.protocol,'DataFiles');

 

% determine it on the basis of the specific runName we're working with

pathParams.grayVideoName

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
        runNames{ii} = sprintf('videoFiles_acqusition_01/trial_%03d.mp4',ii);
    end
end

if strcmp(pathParams.protocol, 'SquintToPulse')
    for aa = 1:6
        for ii = 1:10
            runNames{ii} = sprintf('videoFiles_acqusition_%02d/trial_%03d.mp4',aa, ii);
        end
    end
end

%package all of the runNames up so now we have a list of all of the video
pathParams.runNames = [calibrationRunName, runNames];


pathParams.runNames

for rr = 1:length(pathParams.runNames)
    pathParams.grayVideoName = fullfile(pathParams.dataSourceDirFull, subject, session, pathParams.runNames{rr});
    
    
    runVideoPipeline(pathParams,...
    'skipStageByNumber',[1],...
    'useParallel', useParallel,...
    'verbose', verbose, ...
    'glintFrameMask',[180 340 350 500],'glintGammaCorrection', 15, 'numberOfGlints', 2, ...
    'pupilRange', [60 200],'pupilFrameMask', [100 400 240 300],'pupilCircleThresh', 0.02,'pupilGammaCorrection', 0.7,'maskBox', [1 1],...
    'cutErrorThreshold', 10, 'badFrameErrorThreshold', 6,'glintPatchRadius', 35, 'ellipseTransparentUB',[1280,720,20000,0.6,pi], ...
    'sceneParamsLB',sceneParamsLB, 'sceneParamsUB',sceneParamsUB, ...
    'sceneParamsLBp',sceneParamsLBp,'sceneParamsUBp',sceneParamsUBp,...
    'intrinsicCameraMatrix', intrinsicCameraMatrix, ...
    'sensorResolution', sensorResolution, ...
    'radialDistortionVector',radialDistortionVector, ...
    'constraintTolerance',0.03, ...
    'eyeLaterality',eyeLaterality, ...
    'makeFitVideoByNumber',[3 6 8]);

end