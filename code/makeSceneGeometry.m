function makeSceneGeometry(subjectID, session, varargin)
%% collect some inputs
p = inputParser; p.KeepUnmatched = true;

p.addParameter('pickVideo',[],@isnumeric);
p.addParameter('adjust', false, @islogical);

% Parse and check the parameters
p.parse(varargin{:});
%% Get some params
[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

pathParams.subject = subjectID;
if isnumeric(session)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(session)]));
    session = sessionDir(end).name;
end
pathParams.session = session;
pathParams.protocol = 'SquintToPulse';

[pathParams.runNames, subfoldersList] = getTrialList(pathParams);

if ~isempty(p.Results.pickVideo)
    acquisitionNumber = p.Results.pickVideo(1);
    trialNumber = p.Results.pickVideo(2);
    
    acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
    runName = sprintf('trial_%03d', trialNumber);
end

if isempty(p.Results.pickVideo)
    grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, subfoldersList{end}, pathParams.runNames{end});
    perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_correctedPerimeter.mat']);
else
    grayFileName = fullfile(pathParams.dataSourceDirFull, subjectID, session, acquisitionFolderName, [runName, '.mp4']);
    perimeterFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, [runName, '_correctedPerimeter.mat']);
    
end



%% Make default scene geometry file
if ~p.Results.adjust
    % determine spherical ametropia
    sphericalAmetropia = getSphericalAmetropia(subjectID);
    
    % load measured distance away from camera
    cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', 'SquintToPulse', 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
    
    
    if isempty(sphericalAmetropia)
        sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
            'radialDistortionVector', cameraParams.radialDistortionVector, ...
            'sensorResolution', cameraParams.sensorResolution, ...
            'cameraTranslation', [0; 0; cameraDepthMean.distanceFromCornealApexToIRLens]);
    else
        
        sceneGeometry = createSceneGeometry('intrinsicCameraMatrix', cameraParams.intrinsicCameraMatrix, ...
            'radialDistortionVector', cameraParams.radialDistortionVector, ...
            'sensorResolution', cameraParams.sensorResolution, ...
            'cameraTranslation', [0; 0; cameraDepthMean.distanceFromCornealApexToIRLens], ...
            'sphericalAmetropia', sphericalAmetropia);
    end
    
    % save scene geometry file, even though this version just serves as a
    % template
    if isempty(p.Results.pickVideo)
        sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
    else
        sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
    end
    save(sceneGeometryFileName, 'sceneGeometry');
else
    if isempty(p.Results.pickVideo)
        sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, 'pupilCalibration', 'sceneGeometry.mat');
    else
        sceneGeometryFileName = fullfile(pathParams.dataOutputDirBase, subjectID, session, acquisitionFolderName, [runName, '_sceneGeometry.mat']);
    end
end

%% Make ellipseArrayList

if isempty(p.Results.pickVideo)
    processedVideoName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, [pathParams.runNames{end}(1:end-4), '_fitStage6.avi']);
    elliseArrayListFileName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfoldersList{end}, 'ellipseArrayList.mat');
    
    
    if ~exist(elliseArrayListFileName)
        
        [ellipseArrayList, fixationTargetArray] = pickFramesForSceneEstimation(processedVideoName, 'saveName', elliseArrayListFileName, 'loadEllipseArrayList', false);
    else
        load(elliseArrayListFileName);
    end
else
    ellipseArrayList = [1:100:1000];
    load(perimeterFileName)
    badIndices = [];
    for ii = 1:length(ellipseArrayList)
        if isempty(perimeter.data{ellipseArrayList(ii)}.Xp)
            badIndices(end+1) = ellipseArrayList(ii);
        end
    end
    
    ellipseArrayList = setdiff(ellipseArrayList, badIndices);
    
end
%% Use GUI to adjust scene geometry file
% specify where to find additional files


[ ~, sceneGeometry] = ...
    estimateSceneParamsGUI(sceneGeometryFileName,'ellipseArrayList',ellipseArrayList,'grayVideoName',grayFileName,'perimeterFileName',perimeterFileName,'videoSuffix', '.mp4');

% save adjusted scene geometry file
save(sceneGeometryFileName, 'sceneGeometry');

end