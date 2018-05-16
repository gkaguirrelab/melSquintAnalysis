function [medianResponses, trialStruct] = analyzeAudioResponses(subjectID, varargin)

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('resume',false,@islogical);
p.addParameter('confidenceInterval', [10 90], @isnumeric);


% Parse and check the parameters
p.parse(varargin{:});



%% Find the data
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID);
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

% figure out the number of completed sessions
potentialSessions = dir(fullfile(analysisBasePath, '*session*'));
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
trialStruct.metaData.session = [];
trialStruct.metaData.acquisition = [];
trialStruct.metaData.trial = [];

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
    potentialSessions = dir(fullfile(analysisBasePath, sprintf('*session_%d*', ss)));
    % in the event of more than one entry for a given session (which would
    % happen if something weird happened with a session and it was
    % restarted on a different day), it'll grab the later dated session,
    % which should always be the one we want
    sessionIDs{ss} = potentialSessions(end).name;
end

%% Load in the data for each session
% figure out where we're starting from
if p.Results.resume
    load(fullfile(analysisBasePath, 'audioTrialStruct.mat'))
    startingSession = trialStruct.metaData.session;
    startingAcquisition = trialStruct.metaData.acquisition;
    startingTrial = trialStruct.metaData.trial + 1;
else
    startingSession = 1;
    startingAcquisition = 1;
    startingTrial = 1;
    
    
    
end

for ss = startingSession:completedSessions(end)
    for aa = startingAcquisition:6
        acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', ss,aa)));
        for tt = startingTrial:10
            
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
                        trialStruct.metaData.session = ss;
                        trialStruct.metaData.acquisition = aa;
                        trialStruct.metaData.trial = tt-1;
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
            
            
            
        end
    end
end

%% make median responses
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        
        
        medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}) '_median']) = nanmedian(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]));
        
        sortedVector = sort(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]));
        
        medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(1))]) = sortedVector(round(p.Results.confidenceInterval(1)/100*length((trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])))));
        medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(2))]) = sortedVector(round(p.Results.confidenceInterval(2)/100*length((trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])))));
        
        
    end
end

end % end function
