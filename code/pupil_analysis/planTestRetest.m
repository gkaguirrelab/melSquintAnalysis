function testRetestTable = planTestRetest(varargin)    

%% Define some experiment basics
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = [100, 200, 400];

%% load subjects and sessions
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

%% Prep the table


%% Loop over subjects
for ss = 1:length(subjectIDs)
    
    % determine number of different dates in which the subject came in and
    % was studied
    dates = {};
    for session = 1:length(subjectListStruct.(subjectIDs{ss}))
       sessionString = subjectListStruct.(subjectIDs{ss}){session};
       sessionStringSplit = strsplit(sessionString, '_');
       dates{end+1} = sessionStringSplit{1};
    end
    
    % grab only the unique dates:
    dates = unique(dates);    
    
    % load pupil data
    load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectIDs{ss}, 'trialStruct_radiusSmoothed_droppedFramesAnalysis.mat'));

end