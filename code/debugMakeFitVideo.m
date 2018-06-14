function debugMakeFitVideo

pathParams.subject = 'MELA_0124';
pathParams.sessionID = '2018-06-12_session_1';
subfolder = 'videoFiles_acquisition_01';
pathParams.runName = 'trial_006';
    projectName = 'melSquintAnalysis';
    pathParams.dataBasePath =  getpref(projectName,'melaDataPath');
    pathParams.analysisBasePath = getpref(projectName,'melaAnalysisPath');
    pathParams.dataSourceDirFull = fullfile(pathParams.dataBasePath,'Experiments','OLApproach_Squint','SquintToPulse','DataFiles');

pathParams.dataOutputDirBase = fullfile(pathParams.analysisBasePath,'Experiments','OLApproach_Squint','SquintToPulse','DataFiles');
    pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.sessionID, subfolder);
    
grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.sessionID, subfolder, [pathParams.runName, '.mp4']);

    glintFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_glint.mat']);
initialPerimeterFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_perimeter.mat']);
controlFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_controlFile.csv']);
perimeterFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_correctedPerimeter.mat']);
pupilFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_pupil.mat']);
fitVideoFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_fitStage6.avi']);
sceneGeometryFileNameInput = [];


makeFitVideo(grayVideoName, fitVideoFileName, ...
    'glintFileName', glintFileName, 'perimeterFileName', perimeterFileName,...
    'controlFileName',controlFileName, 'pupilFileName', pupilFileName, ...
    'sceneGeometryFileName', sceneGeometryFileNameInput, 'fitLabel', 'initial');

end