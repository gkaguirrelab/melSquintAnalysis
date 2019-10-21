function pupilPipelineWrapper(pathParams, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('Protocol', 'SquintToPulse' ,@isstr);
p.addParameter('expandPupilRange', true ,@islogical);
p.addParameter('candidateThetas', pi/2:pi/16:pi,@isnumeric);



p.parse(varargin{:})

%% Get the list of trials for the relevant Protocol

[pathParams.runNames, subfolders] = getTrialList(pathParams, 'Protocol', p.Results.Protocol);

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
    
    
    
    if strcmp(p.Results.Protocol, 'SquintToPulse') || strcmp(p.Results.Protocol, 'Deuteranopes')
        acquisitionNumber = ceil(rr/10);
        trialNumber = rr - (acquisitionNumber-1)*10;
    elseif strcmp(p.Results.Protocol, 'Screening')
        acquisitionNumber = 1;
        trialNumber = strsplit(pathParams.runNames{rr}, '.mp4');
        trialNumber = strsplit(trialNumber{1}, '_');
        trialNumber = str2num(trialNumber{2});
    end
    fprintf('Processing %s, %s, acquisition %d, trial %d\n', pathParams.subject, pathParams.session, acquisitionNumber, trialNumber);
    
    stagesToRun = setdiff(1:11, [1 7 8 9 10 11]);
    stagesToWriteToVideo = [6];
    
    runStages(pathParams.subject, pathParams.session, acquisitionNumber, trialNumber, stagesToRun, stagesToWriteToVideo, 'experimentNumber', pathParams.experimentName, varargin{:});
    
end