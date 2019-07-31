function [ status] = doesSessionContainGoodGlintTracking(subjectID, sessionID)

if isnumeric(sessionID)
    [ sessionID ] = getSessionID(subjectID, sessionID);
end

[ ~, ~, pathParams ] = getDefaultParams('Protocol', 'SquintToPulse');

load(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, 'pupilCalibration', 'fitParams.mat'));

if isfield(fitParams, 'threshold')
    status = true;
else
    status = false;
end

end



