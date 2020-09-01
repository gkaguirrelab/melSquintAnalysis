function applySceneGeometry(subjectID, session, acquisitionNumber, trialNumber, varargin)
% Function to apply scene geometry to an individual trial

% Description:
%   This routine is intended to apply scene geometry constraints to an 
%   individual trial. The routine first loads the relative scene geometry file 
%   corresponding tthat should previously have been hand-tuned to the
%   individual session. This scene geometry is then shifted vertically and
%   horizontally depending on how much the center of the pupil has moved
%   from the trial of interest with reference to the initial trial (most
%   often the pupil calibration run) in which the reference scene geometry
%   was created. Finally, transparentTrack stages 8 through 10 are implied:
%   8 to apply the scene geomtry, 9 to perform bayesian smoothing, and 0 to
%   make the fit video.
%
% Inputs:
%   - subjectID             - a string corresponding to the MELA_ID of the
%                             subject of interest
%   - session               - a string or number specifying the session of
%                             interst. If a number is provided, the routine
%                             tries to determine the string corresponding
%                             to the full session label.
%   - acquisitionNumber     - a number specifying which acquisition the
%                             trial of interest occurs in
%   - trialNumber           - a number specifying the trial number of
%                             interest
%
% Optional key-value pairs:
%   - Protocol              - a string specifying which protocol the video
%                             to be processed belongs to. The default is
%                             SquintToPulse for the migraine squint study,
%                             but Deuteranopes is another workable
%                             protocol.
%   - experimentNumber      - a string specifying the experiment number
%                             to which the video to be processed belongs.
%                             The default is an empty variable, which is
%                             appropriate because some protocols
%                             (SquintToPulse) do not have an
%                             experimentNumber. For deuteranopes, the
%                             workable options include 'experiment_1' and
%                             'experiment_2'

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;

p.addParameter('Protocol', 'SquintToPulse', @ischar);
p.addParameter('experimentNumber', []);

% Parse and check the parameters
p.parse(varargin{:});
%% Get some params
[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', p.Results.Protocol);

if isnumeric(session)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, p.Results.experimentNumber, ['2*session_', num2str(session)]));
    session = sessionDir(end).name;
end

pathParams.subject = subjectID;
pathParams.session = session;
pathParams.protocol = 'SquintToPulse';
pathParams.experimentName = p.Results.experimentNumber;

[pathParams.runNames, subfoldersList] = getTrialList(pathParams, 'Protocol', p.Results.Protocol);


acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
runName = sprintf('trial_%03d', trialNumber);

%% Specify where to find additional files

grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, p.Results.experimentNumber,  session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber});
perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, p.Results.experimentNumber,  pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_correctedPerimeter.mat']);
pupilFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, p.Results.experimentNumber,  pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_pupil.mat']);
glintFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, p.Results.experimentNumber,  pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_glint.mat']);
controlFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, p.Results.experimentNumber,  pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_controlFile.csv']);
outVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, p.Results.experimentNumber,  pathParams.session, subfoldersList{((acquisitionNumber-1)*10)+trialNumber}, [pathParams.runNames{((acquisitionNumber-1)*10)+trialNumber}(1:end-4), '_fitStage7.avi']);

% if exist(fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']))
%     sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
%     performSceneGeometryAdjustment = true;
% else
    sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID,  p.Results.experimentNumber, session, 'pupilCalibration', 'sceneGeometry.mat');
    performSceneGeometryAdjustment = true;
    
% end

%% Adjust the scene geometry, if necessary
if performSceneGeometryAdjustment
    % load in the pupil file
    load(pupilFileName);
    
    % use the center of the found ellipses to say where the center of the
    % pupil is
    pupilCenterXThisTrial = nanmean(pupilData.initial.ellipses.values(:,1));
    pupilCenterYThisTrial = nanmean(pupilData.initial.ellipses.values(:,2));
    
    clear pupilData
    
    % load in the pupil file for the calibration run
    load(fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.experimentName, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_pupil.mat']));
    pupilCenterXCalibration = nanmean(pupilData.initial.ellipses.values(:,1));
    pupilCenterYCalibration = nanmean(pupilData.initial.ellipses.values(:,2));
    
    % calculate the X and Y displacement, in pixels
    xDisplacementInPixels = pupilCenterXCalibration - pupilCenterXThisTrial;    
    yDisplacementInPixels = pupilCenterYCalibration - pupilCenterYThisTrial;
    
    % convert displacement in pixels to displacement in mm
    % load calibration scene geometry
    load(sceneGeometryFileName);
    
    % create forward model of the eye with the same eye pose, but two
    % different translations of the camera. we'll use the camera
    % translations and the resulting change in center of the pupil to
    % convert from units of pixels to mm.
    fakeSceneGeometry1 = sceneGeometry;
    fakeSceneGeometry1.cameraPosition.translation = [1; 1; 25.1];
    fakeSceneGeometry2 = sceneGeometry;
    fakeSceneGeometry2.cameraPosition.translation = [-2; -2; 25.1];
    eyePose = [0.01 0.01 0.01 3];
    [pupilEllipseOnImagePlane1] = projectModelEye(eyePose, fakeSceneGeometry1, 'fullEyeModelFlag', true);
    [pupilEllipseOnImagePlane2] = projectModelEye(eyePose, fakeSceneGeometry2, 'fullEyeModelFlag', true);
    xyzInPixels = pupilEllipseOnImagePlane2 - pupilEllipseOnImagePlane1;
    
    pixelsPerMM = abs(xyzInPixels(1)/(fakeSceneGeometry1.cameraPosition.translation(1) - fakeSceneGeometry2.cameraPosition.translation(1)));
    
    % based on this conversion factor, convert the X and Y displacement of
    % the pupil center from the calibration to the trial of inteest from
    % units of pixels to units of mm
    
    xDisplacementInMM = xDisplacementInPixels / pixelsPerMM;
    yDisplacementInMM = yDisplacementInPixels / pixelsPerMM;
    
    % adjust the scene geometry file appropriately
    sceneGeometry.cameraPosition.translation(1) = sceneGeometry.cameraPosition.translation(1) + xDisplacementInMM;
    sceneGeometry.cameraPosition.translation(2) = sceneGeometry.cameraPosition.translation(2) - yDisplacementInMM;
    
    % save the updated scene geometry file
    newSceneGeometryFileName = fullfile(pathParams.dataOutputDirBase,  pathParams.subject, pathParams.experimentName, pathParams.session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
    save(newSceneGeometryFileName, 'sceneGeometry');
    
end

%% Re-run fitting of pupil ellipse with scene geometry

%fitPupilPerimeter(perimeterFileName, pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'verbose', true);
runStages(subjectID, session, acquisitionNumber, trialNumber, [8], [], 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);

%% Perform smoothing

%smoothPupilRadius(perimeterFileName, pupilFileName, sceneGeometryFileName, 'verbose', true);
runStages(subjectID, session, acquisitionNumber, trialNumber, [9], [], 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);

%% Make fit video
runStages(subjectID, session, acquisitionNumber, trialNumber, [10], [10], 'Protocol', p.Results.Protocol, 'experimentNumber', p.Results.experimentNumber);
%makeFitVideo(grayFileName, outVideoName, 'pupilFileName', pupilFileName, 'sceneGeometryFileName', sceneGeometryFileName, 'glintFileName', glintFileName, 'perimeterFileName', perimeterFileName, 'controlFileName', controlFileName, 'modelEyeMaxAlpha', 1)

end