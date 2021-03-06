function trackSubject(subjectID, sessionID, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('experimentNumber', [] ,@isstr);
p.addParameter('Protocol', 'SquintToPulse' ,@isstr);
p.addParameter('resume', false, @islogical);
p.addParameter('skipProcessing', false, @islogical);

p.parse(varargin{:})

[ defaultFitParams, ~, pathParams, ~ ] = getDefaultParams('approach', 'Squint','Protocol', p.Results.Protocol);


if strcmp(p.Results.Protocol, 'Deuteranopes')
    pathParams.experimentName = p.Results.experimentNumber;
else
    pathParams.experimentName = [];
end

if isnumeric(sessionID)
    if strcmp(p.Results.Protocol, 'Deuteranopes')
        sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, pathParams.experimentName, ['2*session_', num2str(sessionID)]));
        sessionID = sessionDir(end).name;
    else
        sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, p.Results.experimentNumber, ['2*session_', num2str(sessionID)]));
        sessionID = sessionDir(end).name;
    end
end

pathParams.subject = subjectID;
pathParams.Protocol = p.Results.Protocol;
pathParams.session = sessionID;




% figure out if we're resuming a session, which dictates whether we're
% figuring out the initialParameters
if strcmp(p.Results.Protocol, 'Screening')
    trialsToEstimate = 2;
elseif strcmp(p.Results.Protocol, 'SquintToPulse') || strcmp(p.Results.Protocol, 'Deuteranopes')
    trialsToEstimate = [2+4, 12+4, 22+4, 32+4, 42+4, 52+4, 61];
end

if ~p.Results.resume
    % grab trial list
    for tt = trialsToEstimate
        fitParams = defaultFitParams;
        [runNamesList, subfoldersList] = getTrialList(pathParams, varargin{:});
        
        if strcmp(p.Results.Protocol, 'Deuteranopes')
                    grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.experimentName, pathParams.session, subfoldersList{tt}, runNamesList{tt});

        else
            grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfoldersList{tt}, runNamesList{tt});
        end
        [initialParams] = estimatePipelineParamsGUI(grayVideoName, 'SquintToPulse', 'pupilRangeContractor', 0.5, 'pupilRangeDilator', 2, 'pupilMaskDilationFactor', 3, varargin{:});
        
        % incorporate new initialParams
        initialParamsFieldNames = fieldnames(initialParams);
        for ff = 1:length(initialParamsFieldNames)
            fitParams.(initialParamsFieldNames{ff}) = initialParams.(initialParamsFieldNames{ff});
        end
        

        % save the new params        
        if ~exist(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfoldersList{tt}), 'dir')
            mkdir(fullfile(pathParams.dataOutputDirBase, subjectID, pathParams.experimentName, sessionID, subfoldersList{tt}));
        end
        save(fullfile(pathParams.dataOutputDirBase, subjectID, pathParams.experimentName, sessionID, subfoldersList{tt}, 'fitParams.mat'),'fitParams', '-v7.3');
    end
else
    pathParams.resume = true;
end

if ~p.Results.skipProcessing
    % do the tracking
    pupilPipelineWrapper(pathParams, varargin{:});
end

close all


end

