function spotCheckVideo(subjectID, sessionID, acquisitionNumber, trialNumber, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('resume', false, @islogical);
p.addParameter('skipProcessing', false, @islogical);

p.parse(varargin{:})

%% Load up the current params for this video
acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
videoName = sprintf('trial_%03d.mp4', trialNumber);

if ~isnumeric(trialNumber)
    runName = trialNumber;
else
    runName = sprintf('trial_%03d', trialNumber);
end
[ defaultFitParams, cameraParams, pathParams ] = getDefaultParams(varargin{:});
pathParams.subject = subjectID;
pathParams.protocol = p.Results.protocol;
pathParams.session = sessionID;
% first look for a trial specific
if exist((fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat'])))
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']));
else
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams.mat']));
end
% if no trial-specific params exist, get the acquisition-specific params




grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, acquisitionFolderName, videoName);

%% Ask user which params we'd like to modify

% Including ability to look at additional params

%% Test new params
framesToCheck = GetWithDefault('Test findPupilPerimeter on which frames: ', '');
if ~isempty(framesToCheck)
    videoInObj = VideoReader(grayVideoName);
    
    counter = 1;
    for ii = framesToCheck
        perimeter = [];
        plotFig = figure;
        hold on
        
        %subplot(2, round(nFrames/2), counter)
        counter = counter + 1;
        string = [];
        string = (['Frame ', num2str(ii)]);
        
        videoInObj.CurrentTime = (ii - 1)/(videoInObj.FrameRate);
        thisFrameDiagnostics = readFrame(videoInObj);
        thisFrameDiagnostics = rgb2gray(thisFrameDiagnostics);
        thisFrameDiagnostics = squeeze(thisFrameDiagnostics);
        
        
        perimeter = findPupilPerimeter(grayVideoName, 'temp', ...
            'startFrame', ii, ...
            'nFrames', 1, ...
            'ellipseTransparentUB', ellipseTransparentUB, ...
            'ellipseTransparentLB', ellipseTransparentLB, ...
            'pupilGammaCorrection', pupilGammaCorrection, ...
            'frameMaskValue', frameMaskValue, ...
            'pupilFrameMask', initialParams.pupilFrameMask, ...
            'pupilRange', initialParams.pupilRange, ...
            'pupilCircleThresh', initialParams.pupilCircleThresh, ...
            'maskBox', maskBox, ...
            'smallObjThresh', smallObjThresh);
        displayFrame=thisFrameDiagnostics;
        if ~isempty(perimeter.data{1}.Xp)
            displayFrame(sub2ind(size(thisFrameDiagnostics),perimeter.data{1}.Yp,perimeter.data{1}.Xp))=255;
        end
        if isempty(perimeter.data{1}.Xp)
            string = 'No pupil found';
            text(350, 200, string);
        end
        imshow(displayFrame, 'Border', 'tight')
        dText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
        delete('temp.mat')
    end
    
    %% allow the user to adjust certain parameters, then test finding the pupil perimeter again
    adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
    if ~strcmp(adjustParamsChoice, 'y')
        close all
        adjustParamsFlag = false;
        while ~adjustParamsFlag
            
            fprintf('Select the parameter you would like to adjust:\n')
            fprintf('\t1. ellipseTransparentUB: %g %g %g %g %g \n', ellipseTransparentUB(:));
            fprintf('\t2. ellipseTransparentLB: %g %g %g %g %g \n', ellipseTransparentLB(:));
            fprintf('\t3. pupilGammaCorrection: %g\n', pupilGammaCorrection);
            fprintf('\t4. frameMaskValue: %g\n', frameMaskValue);
            fprintf('\t5. pupilFrameMask: %g %g %g %g\n', initialParams.pupilFrameMask(:));
            fprintf('\t6. pupilCircleThresh: %g\n', initialParams.pupilCircleThresh);
            fprintf('\t7. maskBox: %g %g\n', maskBox(:));
            fprintf('\t8. pupilRange: %g %g\n', initialParams.pupilRange(:));
            fprintf('\t9. smallObjThresh: %g\n', smallObjThresh);
            
            
            choice = input('\nYour choice: ', 's');
            
            switch choice
                case '1'
                    ellipseTransparentUB = input('Enter new ellipseTransparentUB:     ');
                    initialParams.ellipseTransparentUB = ellipseTransparentUB;
                case '2'
                    ellipseTransparentLB = input('Enter new ellipseTransparentLB:     ');
                    initialParams.ellipseTransparentLB = ellipseTransparentLB;
                case '3'
                    pupilGammaCorrection = input('Enter new pupilGammaCorrection:     ');
                    initialParams.pupilGammaCorrection = pupilGammaCorrection;
                case '4'
                    frameMaskValue = input('Enter new frameMaskValue:     ');
                    initialParams.frameMaskValue = frameMaskValue;
                case '5'
                    initialParams.pupilFrameMask = input('Enter new pupilFrameMask:     ');
                case '6'
                    initialParams.pupilCircleThresh = input('Enter new pupilCircleThresh:     ');
                case '7'
                    maskBox = input('Enter new maskBox:     ');
                    initialParams.maskBox = maskBox;
                case '8'
                    initialParams.pupilRange = input('Enter new pupilRange:     ');
                case '9'
                    smallObjThresh = input('Enter new smallObjThresh:       ');
            end
            
            fprintf('New parameters:\n')
            fprintf('\tellipseTransparentUB: %g %g %g %g %g \n', ellipseTransparentUB(:));
            fprintf('\tellipseTransparentLB: %g %g %g %g %g \n', ellipseTransparentLB(:));
            fprintf('\tpupilGammaCorrection: %g\n', pupilGammaCorrection);
            fprintf('\tframeMaskValue: %g\n', frameMaskValue);
            fprintf('\tpupilFrameMask: %g %g %g %g\n', initialParams.pupilFrameMask(:));
            fprintf('\tpupilCircleThresh: %g\n', initialParams.pupilCircleThresh);
            fprintf('\tmaskBox: %g %g\n', maskBox(:));
            fprintf('\tpupilRange: %g %g\n', initialParams.pupilRange(:));
            
            
            
            
            
            counter = 1;
            for ii = framesToCheck
                perimeter = [];
                plotFig = figure;
                hold on
                
                %subplot(2, round(nFrames/2), counter)
                counter = counter + 1;
                string = [];
                string = (['Frame ', num2str(ii)]);
                
                videoInObj.CurrentTime = (ii - 1)/(videoInObj.FrameRate);
                thisFrameDiagnostics = readFrame(videoInObj);
                thisFrameDiagnostics = rgb2gray(thisFrameDiagnostics);
                thisFrameDiagnostics = squeeze(thisFrameDiagnostics);
                
                
                perimeter = findPupilPerimeter(grayVideoName, 'temp', ...
                    'startFrame', ii, ...
                    'nFrames', 1, ...
                    'ellipseTransparentUB', ellipseTransparentUB, ...
                    'ellipseTransparentLB', ellipseTransparentLB, ...
                    'pupilGammaCorrection', pupilGammaCorrection, ...
                    'frameMaskValue', frameMaskValue, ...
                    'pupilFrameMask', initialParams.pupilFrameMask, ...
                    'pupilRange', initialParams.pupilRange, ...
                    'pupilCircleThresh', initialParams.pupilCircleThresh, ...
                    'maskBox', maskBox, ...
                    'smallObjThresh', smallObjThresh);
                displayFrame=thisFrameDiagnostics;
                if ~isempty(perimeter.data{1}.Xp)
                    displayFrame(sub2ind(size(thisFrameDiagnostics),perimeter.data{1}.Yp,perimeter.data{1}.Xp))=255;
                end
                if isempty(perimeter.data{1}.Xp)
                    string = 'No pupil found';
                    text(350, 200, string);
                end
                imshow(displayFrame, 'Border', 'tight')
                dText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
                delete('temp.mat')
            end
            adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
            switch adjustParamsChoice
                case 'y'
                    adjustParamsFlag = true;
                case 'n'
                    adjustParamsFlag = false;
                    close all
            end
            
            
        end
    end
end
% save out new params
% save according to trial number

%% Process the video, if desired
if p.Results.processVideo
    fprintf('Analyzing subject %s, session %s, acquisition %s, %s\n', pathParams.subject, pathParams.session, acquisitionNumber, trialNumber);
    
    pathParams.grayVideoName = grayVideoName;
    
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr});
    runName = strsplit(pathParams.runNames{rr}, '.');
    pathParams.runName = runName{1};
    
    if ~isfield(fitParams, 'expandPupilRange')
        fitParams.expandPupilRange = p.Results.expandPupilRange;
    end
    if ~isfield(fitParams, 'candidateThetas')
        fitParams.candidateThetas = p.Results.candidateThetas;
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
        'expandPupilRange', fitParams.expandPupilRange, ...
        'candidateThetas', fitParams.candidateThetas, ...
        'smallObjThresh', 5000);
end

end