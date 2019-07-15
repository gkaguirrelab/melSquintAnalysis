function trackSubject(subjectID, sessionID, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('resume', false, @islogical);
p.addParameter('skipProcessing', false, @islogical);

p.parse(varargin{:})

[ ~, cameraParams, pathParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

if isnumeric(sessionID)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, subjectID, ['2*session_', num2str(sessionID)]));
    sessionID = sessionDir(end).name;
end

pathParams.subject = subjectID;
pathParams.protocol = p.Results.protocol;
pathParams.session = sessionID;

%cameraDepthMean = load(fullfile(pathParams.dataBasePath, 'Experiments/OLApproach_Squint', pathParams.protocol, 'DataFiles', pathParams.subject, pathParams.session, 'pupilCalibration', 'distance.mat'));
%cameraDepthMean = cameraDepthMean.distanceFromCornealApexToIRLens;
cameraDepthMean = 24;
cameraDepthSD = 1.4; % just a value on the order of what depthFromIrisDiameter would provide


% Set up scene parameter bounds
sceneParams.LB = [-15; 1; -5; cameraDepthMean-2*cameraDepthSD; .75; 0.9];
sceneParams.LBp = [-12; 1.5; -4; cameraDepthMean-1*cameraDepthSD; .85; 0.95];
sceneParams.UBp = [-8; 2; -3; cameraDepthMean+1*cameraDepthSD; 1.15; 1.05 ];
sceneParams.UB = [-5; 2.5; -2; cameraDepthMean+2*cameraDepthSD; 1.25; 1.10];

% figure out if we're resuming a session, which dictates whether we're
% figuring out the initialParameters
if strcmp(p.Results.protocol, 'Screening')
    trialsToEstimate = 2;
elseif strcmp(p.Results.protocol, 'SquintToPulse')
    trialsToEstimate = [2+4, 12+4, 22+4, 32+4, 42+4, 52+4, 61];
end

if ~p.Results.resume
    % grab trial list
    for tt = trialsToEstimate
        fitParams = defaultFitParams;
        [runNamesList, subfoldersList] = getTrialList(pathParams, varargin{:});
        
        grayVideoName = fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, subfoldersList{tt}, runNamesList{tt});
        
        [initialParams] = estimatePipelineParamsGUI(grayVideoName, 'SquintToPulse', 'pupilRangeContractor', 0.5, 'pupilRangeDilator', 2, 'pupilMaskDilationFactor', 3, varargin{:});
        
        % incorporate new initialParams
        initialParamsFieldNames = fieldnames(initialParams);
        for ff = 1:length(initialParamsFieldNames)
            fitParams.(initialParamsFieldNames{ff}) = initialParams.(initialParamsFieldNames{ff});
        end
        

        % save the new params        
        if ~exist(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfoldersList{tt}), 'dir')
            mkdir(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfoldersList{tt}));
        end
        save(fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, subfoldersList{tt}, 'fitParams.mat'),'fitParams', '-v7.3');
    end
else
    pathParams.resume = true;
end

if ~p.Results.skipProcessing
    % do the tracking
    pupilPipelineWrapper(pathParams, sceneParams, cameraParams, varargin{:});
end

close all


end

