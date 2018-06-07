function [medianResponseStruct, trialStruct] = analyzeAudioResponses(subjectID, varargin)
% Analyzes a single subject's verbal discomfort ratings  from the OLApproach_Squint,
% SquintToPulse Experiment
%
% Syntax:
%  [medianResponses, trialStruct] = analyzeAudioResponses(subjectID)

% Description:
%   This function compiles the verbal discomfort ratings from the
%   OLApproach_Squint Experiment. Basically we first figure out how many
%   sessions a given subject has completed. Then we loop over each trial
%   completed -- the audio response is played, and the operator is prompted
%   to enter the heard rating. After completion of all trials, these
%   ratings are compiled and summarized.

% Inputs:
%	subjectID             - A string describing the subjectID (e.g.
%                           MELA_0121) to be analyzed)

% Optional Key-Value Pairs:
%   resume                - A logical statement. If false, the routine
%                           starts at Session 1, Acquisition 1, Trial 1. If
%                           true, the routine assumes the operator has
%                           started analyzing this subject. It then finds
%                           the saved intermediate data, and resumes from
%                           the trial left off.

% Outputs:
%   medianResponseStruct - A 3x1 structure, where each subfield
%                           corresponds to the stimulus type (LMS,
%                           Melanopsin, or Light flux). Each subfield is
%                           itself a 9x1 structure, with each nested
%                           subfield named after the contrast levels (100%,
%                           200%, and 400%) and whether the content refers
%                           to the median value, or confidence interval
%                           boundary.
%  trialStruct            - A nested structure similar in format to
%                           averageResponseStruct, where the first layer
%                           describes the stimulus type and second layer
%                           describes the contrast level. The innermost
%                           layer, however, is a vector containing the
%                           verbal responses from each trial

% Usage:
%   If no data has been analyzed yet for the given subject, call the
%   function as [medianResponses, trialStruct] =
%   analyzeAudioResponses(subjectID) with the 'resume' behavior as the
%   default 'false.' This will then start the analysis at Session 1,
%   Acquisition 1, Trial 1. If data analysis had previously begun for this
%   subject, use [medianResponses, trialStruct] =
%   analyzeAudioResponses(subjectID, 'resume', true) and now the user will
%   be prompted to begin from wherever left off.
%
%   As the routine begins looping over trials, the verbal discomfort rating
%   will be played aloud through whatever default audio output is
%   configured on the operator's computer. At the end of teh audio clip,
%   the operator will be prompted to enter the verbal rating into the
%   console. If the operator desires to repeat the trial, the operator
%   should simply hit enter without inputting any value. If the operator
%   wishes to quit and resume later, simply enter the string 'quit' rather
%   than a value, and the intermediate data will be saved within the
%   relevant subject's directory as part of MELA_analysis.



%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('resume',false,@islogical);
p.addParameter('nTrials',10,@isnumeric);
p.addParameter('nAcquisitions',6,@isnumeric);
p.addParameter('nSessions',4,@isnumeric);



p.addParameter('confidenceInterval', [10 90], @isnumeric);


% Parse and check the parameters
p.parse(varargin{:});



%% Find the data
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID);
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

% figure out the number of completed sessions
potentialSessions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, '*session*'));
potentialNumberOfSessions = length(potentialSessions);

% initialize outputStruct
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]) = [];
    end
end
trialStruct.metaData = [];
% trialStruct.metaData.session = [];
% trialStruct.metaData.acquisition = [];
% trialStruct.metaData.trial = [];
trialStruct.metaData.index = [];

sessions = [];
for ss = 1:potentialNumberOfSessions
    acquisitions = [];
    for aa = 1:6
        trials = [];
        for tt = 1:10
            if exist(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, potentialSessions(ss).name, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d.mp4', tt)), 'file');
                trials = [trials, tt];
            end
        end
        if isequal(trials, 1:10)
            acquisitions = [acquisitions, aa];
        end
    end
    if isequal(acquisitions, 1:6)
        sessions = [sessions, ss];
    end
end

completedSessions = sessions;
% get session IDs
sessionIDs = [];
for ss = completedSessions
    potentialSessions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sprintf('*session_%d*', ss)));
    % in the event of more than one entry for a given session (which would
    % happen if something weird happened with a session and it was
    % restarted on a different day), it'll grab the later dated session,
    % which should always be the one we want
    for ii = 1:length(potentialSessions)
        if ~strcmp(potentialSessions(ii).name(1), 'x')
            sessionIDs{ss} = potentialSessions(ii).name;
        end
    end
end

%% Load in the data for each session
% figure out where we're starting from
if p.Results.resume
    load(fullfile(analysisBasePath, 'audioTrialStruct.mat'))
    %     startingSession = trialStruct.metaData.session;
    %     startingAcquisition = trialStruct.metaData.acquisition;
    %     startingTrial = trialStruct.metaData.trial + 1;
    startingIndex = trialStruct.metaData.index;
else
    %startingSession = 1;
    %startingAcquisition = 1;
    %startingTrial = 1;
    startingIndex = 1;
    
    
end

totalTrials = p.Results.nTrials * p.Results.nAcquisitions * p.Results.nSessions;

for ii = startingIndex:totalTrials
    
    [ss, aa, tt] = ind2sub([4;6;10], ii);
    
    
    
    acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', ss,aa)));
    
    
    fprintf('Session %d, Acquisition %d, Trial %d\n', ss, aa, tt);
    
    trialData.response.values = acquisitionData.responseStruct.data(tt).audio;
    
    % listen to the audio
    trialDoneFlag = false;
    while ~trialDoneFlag
        sound(trialData.response.values, 16000)
        pause(5)
        % prompt user to input rating
        discomfortRating = GetWithDefault('>><strong>Enter discomfort rating:</strong>', '');
        switch discomfortRating
            % play the clip over again if necessary
            case ''
                
            case 'quit'
                %trialStruct.metaData.session = ss;
                %trialStruct.metaData.acquisition = aa;
                %trialStruct.metaData.trial = tt-1;
                
                trialStruct.metaData.index = ii;
                save(fullfile(analysisBasePath, 'audioTrialStruct.mat'), 'trialStruct', 'trialStruct', '-v7.3');
                return
                
            otherwise
                trialDoneFlag = true;
        end
    end
    
    %stashing the result
    % first figure out the stimulus type
    directionNameLong = acquisitionData.trialList(tt).modulationData.modulationParams.direction;
    directionNameSplit = strsplit(directionNameLong, ' ');
    if strcmp(directionNameSplit{1}, 'Light')
        directionName = 'LightFlux';
    else
        directionName = directionNameSplit{1};
    end
    contrastLong = strsplit(directionNameLong, '%');
    contrast = contrastLong{1}(end-2:end);
    % pool the results
    nItems = length((trialStruct.(directionName).(['Contrast', contrast])));
    trialStruct.(directionName).(['Contrast', contrast])(nItems+1) = str2num(discomfortRating);
    save(fullfile(analysisBasePath, 'audioTrialStruct.mat'), 'trialStruct', 'trialStruct', '-v7.3');
    
    
    
    
end

save(fullfile(analysisBasePath, 'audioTrialStruct.mat'), 'trialStruct', 'trialStruct', '-v7.3');

%% make median responses
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        
        
        medianResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}) '_median']) = nanmedian(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]));
        
        sortedVector = sort(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]));
        
        medianResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(1))]) = sortedVector(round(p.Results.confidenceInterval(1)/100*length((trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])))));
        medianResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(2))]) = sortedVector(round(p.Results.confidenceInterval(2)/100*length((trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])))));
        
        
    end
end

end % end function