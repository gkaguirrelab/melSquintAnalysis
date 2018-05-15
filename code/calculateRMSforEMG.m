function [ medianRMS, trialStruct ] = calculateRMSforEMG(subjectID, varargin)

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('makePlots',false,@islogical);
p.addParameter('windowOnset',2.5,@isnumeric);
p.addParameter('windowOffset',6.5,@isnumeric);
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
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]).left = [];
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]).right = [];
    end
end

sessions = [];
for ss = 1:potentialNumberOfSessions
    acquisitions = [];
    for aa = 1:6
        trials = [];
        for tt = 1:10
            if exist(fullfile(analysisBasePath, potentialSessions(ss).name, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)), 'file');
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
for ss = completedSessions
    for aa = 1:6
        acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_emg.mat', ss,aa)));
        stimulusData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', ss,aa)));
        
        if p.Results.makePlots
            figure;
        end
        
        voltages = [];
        for tt = 1:10
            
            if tt ~= 1 % we're discarding the first trial of each acquisition
                % assemble packet
                trialData.response.timebase = acquisitionData.responseStruct.data(tt).emg.timebase;
                trialData.response.values.right = acquisitionData.responseStruct.data(tt).emg.response(1,:);
                trialData.response.values.left = acquisitionData.responseStruct.data(tt).emg.response(2,:);
                
                if p.Results.makePlots
                    subplot(2,5,tt)
                    hold on
                    plot(trialData.response.timebase, trialData.response.values.right);
                    plot(trialData.response.timebase, trialData.response.values.left);
                end
                
                % calculate RMS for the trial
                onsetIndex = find(trialData.response.timebase == p.Results.windowOnset);
                offsetIndex = find(trialData.response.timebase == p.Results.windowOffset);
                voltages.left = trialData.response.values.left(onsetIndex:offsetIndex);
                voltages.right = trialData.response.values.right(onsetIndex:offsetIndex);
                
                RMS.left = (sum(((voltages.left).^2)))^(1/2);
                RMS.right = (sum(((voltages.right).^2)))^(1/2);
                
                % stash the trial
                % first figure out what type of trial we're working with
                directionNameLong = stimulusData.trialList(tt).modulationData.modulationParams.direction;
                directionNameSplit = strsplit(directionNameLong, ' ');
                if strcmp(directionNameSplit{1}, 'Light')
                    directionName = 'LightFlux';
                else
                    directionName = directionNameSplit{1};
                end
                contrastLong = strsplit(directionNameLong, '%');
                contrast = contrastLong{1}(end-2:end);
                % pool the results
                nItems = length((trialStruct.(directionName).(['Contrast', contrast]).left));
                trialStruct.(directionName).(['Contrast', contrast]).left(nItems+1) = RMS.left;
                trialStruct.(directionName).(['Contrast', contrast]).right(nItems+1) = RMS.right;
            end
            
            
        end
    end
end

%% make median RMS struct
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        
        for ll = 1:2
            if ll == 1
                laterality = 'left';
            elseif ll == 2
                laterality = 'right';
            end
            medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}) '_median']).(laterality) = nanmedian(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]).(laterality));
            
            sortedVector = sort(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})]).(laterality));
            
            medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(1))]).(laterality) = sortedVector(round(p.Results.confidenceInterval(1)/100*length((trialStruct.(directionName).(['Contrast', contrast]).(laterality)))));
            medianRMS.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_', num2str(p.Results.confidenceInterval(2))]).(laterality) = sortedVector(round(p.Results.confidenceInterval(2)/100*length((trialStruct.(directionName).(['Contrast', contrast]).(laterality)))));
            
        end
    end
end

%% save out some summary plots
plotFig = figure;
set(gcf,'un','n','pos',[.05,.05,.7,.6])
for ss = 1:length(stimuli)
    x = [];
    for ll = 1:2
        if ll == 1
            laterality = 'left';
        elseif ll == 2
            laterality = 'right';
        end
        subplot(1,2,ll)
        hold on

        title(laterality)
        
        x = [1:3] + 3*(ss-1);
        y = [medianRMS.(stimuli{ss}).Contrast100_median.(laterality), medianRMS.(stimuli{ss}).Contrast200_median.(laterality), medianRMS.(stimuli{ss}).Contrast400_median.(laterality)];
        yneg = y - [medianRMS.(stimuli{ss}).Contrast100_10.(laterality), medianRMS.(stimuli{ss}).Contrast200_10.(laterality), medianRMS.(stimuli{ss}).Contrast400_10.(laterality)];
        ypos = [medianRMS.(stimuli{ss}).Contrast100_90.(laterality), medianRMS.(stimuli{ss}).Contrast200_90.(laterality), medianRMS.(stimuli{ss}).Contrast400_90.(laterality)] - y;
        
        
        errorbar(x, y, yneg, ypos)
        xlim([ 0 10])
        
        xticks([1:9])
        xticklabels({'100%', '200%', '400%', '100%', '200%', '400%', '100%', '200%', '400%'})
        legend(stimuli)
        
        ylabel('Median RMS (+/- 90% CI)')
        xlabel('Contrast')
    end
end

print(plotFig, fullfile(analysisBasePath, 'EMG_RMS.pdf'), '-dpdf', '-bestfit');
close(plotFig)


end % end function