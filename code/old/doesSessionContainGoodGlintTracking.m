function [ status] = doesSessionContainGoodGlintTracking(subjectID, sessionID, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('pickTrial',[],@isnumeric);

% Parse and check the parameters
p.parse(varargin{:});


if isnumeric(sessionID)
    [ sessionID ] = getSessionID(subjectID, sessionID);
end

[ ~, ~, pathParams ] = getDefaultParams('Protocol', 'SquintToPulse');

% first look for a trial specific

if ~isempty(p.Results.pickTrial)
    acquisitionNumber = p.Results.pickTrial(1);
    trialNumber = p.Results.pickTrial(2);
    acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
    
    if ~isnumeric(trialNumber)
        runName = trialNumber;
    else
        runName = sprintf('trial_%03d', trialNumber);
    end
    
    
    if exist((fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, acquisitionFolderName, ['fitParams_', runName, '.mat'])))
        load(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, acquisitionFolderName, ['fitParams_', runName, '.mat']));
    elseif exist((fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, acquisitionFolderName, ['fitParams.mat'])))
        load(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, acquisitionFolderName, ['fitParams.mat']));
    else
        load(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, ['fitParams.mat']));
    end
else
    load(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, 'pupilCalibration', ['fitParams.mat']));
end

if isfield(fitParams, 'threshold')
    status = true;
else
    status = false;
end

end



