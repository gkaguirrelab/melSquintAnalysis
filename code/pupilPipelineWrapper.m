function pupilPipelineWrapper(pathParams, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('expandPupilRange', true ,@islogical);
p.addParameter('candidateThetas', pi/2:pi/16:pi,@isnumeric);



p.parse(varargin{:})

%% Get the list of trials for the relevant protocol

[pathParams.runNames, subfolders] = getTrialList(pathParams, 'protocol', p.Results.protocol);

%% if we're resuming the analysis, figure out which trial we're resuming on
if ~pathParams.resume
    firstRunIndex = 1;
else
    sessions = [];
    for rr = 1:length(pathParams.runNames)
        if ~exist(fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, subfolders{rr}, [pathParams.runNames{rr}(1:end-4), '_pupil.mat']), 'file')
            firstRunIndex = rr;
            break
        end
    end
end
if ~(exist('firstRunIndex', 'var'))
    fprintf('All videos have been processed for this session\n')
    return
end

%% Run the video pipeline
for rr = firstRunIndex:length(pathParams.runNames)
    
    acquisitionNumber = ceil(rr/10);
    trialNumber = rr - (acquisitionNumber-1)*10;
    
    stagesToRun = setdiff(1:11, [1 7 8 9 10 11]);
    stagesToWriteToVideo = [6];
    
    runStages(pathParams.subject, pathParams.session, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, varargin{:});
    
end