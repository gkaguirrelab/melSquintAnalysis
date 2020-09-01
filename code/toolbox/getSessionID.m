function [ sessionIDString ] = getSessionID(subjectID, sessionNumber, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('Protocol', 'SquintToPulse' ,@isstr);

p.parse(varargin{:})

[ ~, ~, pathParams ] = getDefaultParams('approach', 'Squint','Protocol', p.Results.Protocol);

if isnumeric(sessionNumber)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, ['2*session_', num2str(sessionNumber)]));
    sessionIDString = sessionDir(end).name;
end