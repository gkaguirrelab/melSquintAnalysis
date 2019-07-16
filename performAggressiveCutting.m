function performAggressiveCutting(subjectID, sessionID, acquisitionNumber, trialNumber, varargin)
%% collect some inputs
p = inputParser; p.KeepUnmatched = true;

p.addParameter('cutErrorThreshold',[],@isnumeric);

% Parse and check the parameters
p.parse(varargin{:});

%% adjust the fitParams
if ~isempty(p.Results.cutErrorThreshold)
    editFitParams(subjectID, sessionID, acquisitionNumber, 'paramName', 'cutErrorThreshold', 'paramValue', p.Results.cutErrorThreshold)
end

%% Redo the cutting
runStages(subjectID, sessionID, acquisitionNumber, trialNumber, [4 5 6], [6]);

end