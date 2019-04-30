function spotCheckVideo(subjectID, sessionID, acquisitionNumber, trialNumber, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('skipParamsAdjustment', false, @islogical);
p.addParameter('processVideo', false, @islogical);
p.addParameter('openVideo', true, @islogical);
p.addParameter('openPlot', false, @islogical);

p.parse(varargin{:})

%% if sessionID is given out a number, figure out the appropriate string
[ defaultFitParams, cameraParams, pathParams ] = getDefaultParams(varargin{:});
pathParams.subject = subjectID;
pathParams.protocol = p.Results.protocol;
if isnumeric(sessionID)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(sessionID)]));
    sessionID = sessionDir(end).name;
end

%% Load up the current params for this video
acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
videoName = sprintf('trial_%03d.mp4', trialNumber);

if ~isnumeric(trialNumber)
    runName = trialNumber;
else
    runName = sprintf('trial_%03d', trialNumber);
end

pathParams.session = sessionID;
% first look for a trial specific
if exist((fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat'])))
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']));
else
    load(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams.mat']));
end
% if no trial-specific params exist, get the acquisition-specific params
if ~isfield(fitParams, 'smallObjThresh')
    fitParams.smallObjThresh = defaultFitParams.smallObjThresh;
end
if ~isfield(fitParams, 'pickLargestCircle')
    fitParams.pickLargestCircle = defaultFitParams.pickLargestCircle;
end



grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, acquisitionFolderName, videoName);
processedVideoName = strrep(grayVideoName, 'MELA_data', 'MELA_processing');
processedVideoName = strrep(processedVideoName, '.mp4', '_fitStage6.avi');

if p.Results.openVideo
    [recordedErrorFlag, consoleOutput] = system(['open ''' processedVideoName '''']);
end

if p.Results.openPlot
    plotFile = fullfile(pathParams.dataOutputDirBase, pathParams.subject, 'allTrials', [pathParams.session, '_a', num2str(acquisitionNumber), '_t', num2str(trialNumber), '.png']);
    [recordedErrorFlag, consoleOutput] = system(['open ''' plotFile '''']);
end

if ~(p.Results.skipParamsAdjustment)
    
    %% Ask user which params we'd like to modify
    params = fieldnames(fitParams);
    fprintf('Select the parameter you would like to adjust:\n')
    counter = 1;
    for ii = 1:length(params)
        %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
        fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
        fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
        counter = counter + 1;
    end
    fprintf('\t%d. Add additional parameter\n', counter);
    
    
    choice = input('\nYour choice: ', 's');
    if ~isempty(choice)
        if str2num(choice) ~= counter
            paramOfInterest = params{str2num(choice)};
            string = sprintf('Enter new %s:      \n', paramOfInterest);
            answer = input(string, 's');
            if strcmp(answer, 'true') || strcmp(answer, 'false')
                if strcmp(answer, 'true')
                    fitParams.(paramOfInterest) = true;
                elseif strcmp(answer, 'false')
                    fitParams(paramOfInterest) = false;
                end
            else
                fitParams.(paramOfInterest) = str2num(answer);
            end
            
        else
            paramName = input('Enter new param name:       ', 's');
            answer = input(sprintf('Enter %s:       ', paramName), 's');
            if strcmp(answer, 'true') || strcmp(answer, 'false')
                if strcmp(answer, 'true')
                    fitParams.(paramName) = true;
                elseif strcmp(answer, 'false')
                    fitParams.(paramName) = false;
                end
            else
                fitParams.(paramName) = str2num(answer);
            end
            
        end
        
        params = fieldnames(fitParams);
        fprintf('Current params:\n')
        counter = 1;
        for ii = 1:length(params)
            %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
            fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
            fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
            counter = counter + 1;
        end
        adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
        if ~strcmp(adjustParamsChoice, 'y')
            params = fieldnames(fitParams);
            
            adjustParamsFlag = false;
            while ~adjustParamsFlag
                fprintf('Select the parameter you would like to adjust:\n')
                counter = 1;
                for ii = 1:length(params)
                    %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
                    fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
                    fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
                    counter = counter + 1;
                end
                fprintf('\t%d. Add additional parameter\n', counter);
                
                
                choice = input('\nYour choice: ', 's');
                if ~isempty(choice)
                    if str2num(choice) ~= counter
                        paramOfInterest = params{str2num(choice)};
                        string = sprintf('Enter new %s:      \n', paramOfInterest);
                        answer = input(string, 's');
                        if strcmp(answer, 'true') || strcmp(answer, 'false')
                            if strcmp(answer, 'true')
                                fitParams.(paramOfInterest) = true;
                            elseif strcmp(answer, 'false')
                                fitParams(paramOfInterest) = false;
                            end
                        else
                            fitParams.(paramOfInterest) = str2num(answer);
                        end
                        
                    else
                        paramName = input('Enter new param name:       ', 's');
                        answer = input(sprintf('Enter %s:       ', paramName), 's');
                        if strcmp(answer, 'true') || strcmp(answer, 'false')
                            if strcmp(answer, 'true')
                                fitParams.(paramName) = true;
                            elseif strcmp(answer, 'false')
                                fitParams(paramName) = false;
                            end
                        else
                            fitParams.(paramName) = str2num(answer);
                        end
                        
                    end
                    
                    params = fieldnames(fitParams);
                    fprintf('Current params:\n')
                    counter = 1;
                    for ii = 1:length(params)
                        %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
                        fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
                        fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
                        counter = counter + 1;
                    end
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
    
    
    %% Test new params
    framesToCheck = GetWithDefault('Test findPupilPerimeter on which frames: ', '');
    framesToCheck = str2num(framesToCheck);
    if ~isempty(framesToCheck)
        videoInObj = VideoReader(grayVideoName);
        
        counter = 1;
        for ii = framesToCheck
            perimeter = [];
%             plotFig = figure;
%             hold on
%             
%             %subplot(2, round(nFrames/2), counter)
%             counter = counter + 1;
%             string = [];
%             string = (['Frame ', num2str(ii)]);
            
            videoInObj.CurrentTime = (ii - 1)/(videoInObj.FrameRate);
            thisFrameDiagnostics = readFrame(videoInObj);
            thisFrameDiagnostics = rgb2gray(thisFrameDiagnostics);
            thisFrameDiagnostics = squeeze(thisFrameDiagnostics);
            
            
            perimeter = findPupilPerimeter(grayVideoName, 'temp', ...
                'startFrame', ii, ...
                'nFrames', 1, ...
                'ellipseTransparentUB', fitParams.ellipseTransparentUB, ...
                'ellipseTransparentLB', fitParams.ellipseTransparentLB, ...
                'pupilGammaCorrection', fitParams.pupilGammaCorrection, ...
                'frameMaskValue', fitParams.frameMaskValue, ...
                'pupilFrameMask', fitParams.pupilFrameMask, ...
                'pupilRange', fitParams.pupilRange, ...
                'pupilCircleThresh', fitParams.pupilCircleThresh, ...
                'maskBox', fitParams.maskBox, ...
                'pickLargestCircle', fitParams.pickLargestCircle, ...
                'smallObjThresh', fitParams.smallObjThresh, 'displayMode', true);
%             displayFrame=thisFrameDiagnostics;
%             if ~isempty(perimeter.data{1}.Xp)
%                 displayFrame(sub2ind(size(thisFrameDiagnostics),perimeter.data{1}.Yp,perimeter.data{1}.Xp))=255;
%             end
%             if isempty(perimeter.data{1}.Xp)
%                 string = 'No pupil found';
%                 text(350, 200, string);
%             end
%             imshow(displayFrame, 'Border', 'tight')
%             dText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
            delete('temp.mat')
        end
        
        %% allow the user to adjust certain parameters, then test finding the pupil perimeter again
        adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
        if ~strcmp(adjustParamsChoice, 'y')
            close all
            adjustParamsFlag = false;
            while ~adjustParamsFlag
                
                fprintf('Select the parameter you would like to adjust:\n')
                fprintf('\t1. ellipseTransparentUB: %g %g %g %g %g \n', fitParams.ellipseTransparentUB(:));
                fprintf('\t2. ellipseTransparentLB: %g %g %g %g %g \n', fitParams.ellipseTransparentLB(:));
                fprintf('\t3. pupilGammaCorrection: %g\n', fitParams.pupilGammaCorrection);
                fprintf('\t4. frameMaskValue: %g\n', fitParams.frameMaskValue);
                fprintf('\t5. pupilFrameMask: %g %g %g %g\n', fitParams.pupilFrameMask(:));
                fprintf('\t6. pupilCircleThresh: %g\n', fitParams.pupilCircleThresh);
                fprintf('\t7. maskBox: %g %g\n', fitParams.maskBox(:));
                fprintf('\t8. pupilRange: %g %g\n', fitParams.pupilRange(:));
                fprintf('\t9.pickLargestCircle: %g %g\n', fitParams.pickLargestCircle);
                fprintf('\t10. smallObjThresh: %g\n', fitParams.smallObjThresh);
                fprintf('\t11. Choose new frames to test\n');
                
                
                choice = input('\nYour choice: ', 's');
                
                switch choice
                    case '1'
                        ellipseTransparentUB = input('Enter new ellipseTransparentUB:     ');
                        fitParams.ellipseTransparentUB = ellipseTransparentUB;
                    case '2'
                        ellipseTransparentLB = input('Enter new ellipseTransparentLB:     ');
                        fitParams.ellipseTransparentLB = ellipseTransparentLB;
                    case '3'
                        pupilGammaCorrection = input('Enter new pupilGammaCorrection:     ');
                        fitParams.pupilGammaCorrection = pupilGammaCorrection;
                    case '4'
                        frameMaskValue = input('Enter new frameMaskValue:     ');
                        fitParams.frameMaskValue = frameMaskValue;
                    case '5'
                        fitParams.pupilFrameMask = input('Enter new pupilFrameMask:     ');
                    case '6'
                        fitParams.pupilCircleThresh = input('Enter new pupilCircleThresh:     ');
                    case '7'
                        maskBox = input('Enter new maskBox:     ');
                        fitParams.maskBox = maskBox;
                    case '8'
                        fitParams.pupilRange = input('Enter new pupilRange:     ');
                    case '9'
                        fitParams.pickLargestCircle = input('Enter new pickLargestCircle:       ');
                    case '10'
                        fitParams.smallObjThresh = input('Enter new smallObjThresh:       ');
                    case '11'
                        framesToCheck = GetWithDefault('Test on which frames: ', '');
                        framesToCheck = str2num(framesToCheck);
                end
                
                fprintf('New parameters:\n')
                fprintf('\tellipseTransparentUB: %g %g %g %g %g \n', fitParams.ellipseTransparentUB(:));
                fprintf('\tellipseTransparentLB: %g %g %g %g %g \n', fitParams.ellipseTransparentLB(:));
                fprintf('\tpupilGammaCorrection: %g\n', fitParams.pupilGammaCorrection);
                fprintf('\tframeMaskValue: %g\n', fitParams.frameMaskValue);
                fprintf('\tpupilFrameMask: %g %g %g %g\n', fitParams.pupilFrameMask(:));
                fprintf('\tpupilCircleThresh: %g\n', fitParams.pupilCircleThresh);
                fprintf('\tmaskBox: %g %g\n', fitParams.maskBox(:));
                fprintf('\tpupilRange: %g %g\n', fitParams.pupilRange(:));
                fprintf('\pickLargestCircle: %g %g\n', fitParams.pickLargestCircle);
                fprintf('\tsmallObjThresh: %g\n', fitParams.smallObjThresh);
                
                
                
                
                counter = 1;
                for ii = framesToCheck
                    perimeter = [];
%                     plotFig = figure;
%                     hold on
%                     
%                     %subplot(2, round(nFrames/2), counter)
%                     counter = counter + 1;
%                     string = [];
%                     string = (['Frame ', num2str(ii)]);
                    
                    videoInObj.CurrentTime = (ii - 1)/(videoInObj.FrameRate);
                    thisFrameDiagnostics = readFrame(videoInObj);
                    thisFrameDiagnostics = rgb2gray(thisFrameDiagnostics);
                    thisFrameDiagnostics = squeeze(thisFrameDiagnostics);
                    
                    
                    perimeter = findPupilPerimeter(grayVideoName, 'temp', ...
                        'startFrame', ii, ...
                        'nFrames', 1, ...
                        'ellipseTransparentUB', fitParams.ellipseTransparentUB, ...
                        'ellipseTransparentLB', fitParams.ellipseTransparentLB, ...
                        'pupilGammaCorrection', fitParams.pupilGammaCorrection, ...
                        'frameMaskValue', fitParams.frameMaskValue, ...
                        'pupilFrameMask', fitParams.pupilFrameMask, ...
                        'pupilRange', fitParams.pupilRange, ...
                        'pupilCircleThresh', fitParams.pupilCircleThresh, ...
                        'maskBox', fitParams.maskBox, ...
                        'pickLargestCircle', fitParams.pickLargestCircle, ...
                        'smallObjThresh', fitParams.smallObjThresh, 'displayMode', true);
%                     displayFrame=thisFrameDiagnostics;
%                     if ~isempty(perimeter.data{1}.Xp)
%                         displayFrame(sub2ind(size(thisFrameDiagnostics),perimeter.data{1}.Yp,perimeter.data{1}.Xp))=255;
%                     end
%                     if isempty(perimeter.data{1}.Xp)
%                         string = 'No pupil found';
%                         text(350, 200, string);
%                     end
%                     imshow(displayFrame, 'Border', 'tight')
%                     dText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
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
    save(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']), 'fitParams', '-v7.3')
    
    % prep command for ease of use
    newCommand = ['spotCheckVideo(''', pathParams.subject, ''', ''' pathParams.session, ''', ', num2str(acquisitionNumber), ', ', num2str(trialNumber), ', ''skipParamsAdjustment'', true, ''processVideo'', true, ''openVideo'', false);'];
    system(['echo "', newCommand, '" >> ', '~/Documents/MATLAB/projects/melSquintAnalysis/code/newlySpotchecked.m']);
end
%% Process the video, if desired
cameraDepthMean = 24;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];
if p.Results.processVideo
    fprintf('Analyzing subject %s, session %s, acquisition %d, %d\n', pathParams.subject, pathParams.session, acquisitionNumber, trialNumber);
    
    pathParams.grayVideoName = grayVideoName;
    
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, sprintf('videoFiles_acquisition_%02d', acquisitionNumber));
    [extension, runName] = fileparts(grayVideoName);
    pathParams.runName = runName;
    
    if ~isfield(fitParams, 'expandPupilRange')
        fitParams.expandPupilRange = defaultFitParams.expandPupilRange;
    end
    if ~isfield(fitParams, 'candidateThetas')
        fitParams.candidateThetas = defaultFitParams.candidateThetas;
    end
    if ~isfield(fitParams, 'smallObjThresh')
        fitParams.smallObjThresh = defaultFitParams.smallObjThresh;
    end
    if ~isfield(fitParams, 'pickLargestCircle')
        fitParams.smallObjThresh = defaultFitParams.smallObjThresh;
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
        'pickLargestCircle', fitParams.pickLargestCircle, ...
        'smallObjThresh', fitParams.smallObjThresh);
end


if p.Results.openVideo
    [recordedErrorFlag, consoleOutput] = system(['close ''' processedVideoName '''']);
end

if p.Results.openPlot
    plotFile = fullfile(pathParams.dataOutputDirBase, pathParams.subject, 'allTrials', [pathParams.session, '_a', num2str(acquisitionNumber), '_t', num2str(trialNumber), '.png']);
    [recordedErrorFlag, consoleOutput] = system(['close ''' plotFile '''']);
end
close all

end