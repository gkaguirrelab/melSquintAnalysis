function [ trialStruct ] = calculateEMGResponseOverTime(subjectID, varargin)
% Analyzes a single subject's EMG data from the OLApproach_Squint,
% SquintToPulse Experiment
%
% Syntax:
%  [ medianRMS, trialStruct ] = calculateRMSforEMG(subjectID)
% Description:
%   This function analyzes the EMG data from the OLApproach_Squint
%   Experiment, ultimately providing the root mean square (RMS) over the
%   designated squint window. Basically we first figure out how many
%   sessions a given subject has completed. Then we loop over each trial
%   and calculate the RMS over the designated window for each trial, and
%   compile that result according to stimulus type and contrast level. The
%   median RMS value across all trials, as well as the confidence interval
%   bounds, are outputted as well.
%   A couple of words on our chosen EMG metric, root mean square: We define
%   a window 1s after the stimulus onset until 1s after stimulus offset.
%   This window was chosen based on work by Stringham and colleagues
%   ('Action spetrcum for photophobia'). Within this window, we calculate
%   the square root of the sum of the squared voltage values. We then take
%   the median value across all trials for each stimulus type.
% Inputs:
%   subjectID             - A string describing the subjectID (e.g.
%                           MELA_0121) to be analyzed)
% Optional Key-Value Pairs:
%   windowOnset           - A number identifying the timepoint
%                           corresponding to the beginning of our squint
%                           window. The default is 2.5 s, which corresponds
%                           to 1 s after the stimulus is presented (both
%                           EMG and pupil data begin recording 1.5 s prior
%                           to stimulus onset, so 2.5 - 1.5 = 1 s).
%   windowOffset          - A number identifying the timepoint
%                           correspodning to the end of our squint window.
%                           The default is 6.5 s, which corresponds to 1 s
%                           after the stimulus offset (the stimulus is
%                           presented for 4 s)
%   makePlots             - A logical that controls plotting behavior. If
%                           set to true, plots showing the basic contrast
%                           response function are saved out in the
%                           subject's folder found in MELA_analysis
%   confidenceInterval    - A vector of length 1x2 that provides the
%                           percentile bounds for the confidence interval
%                           saved as part of the medianRMS struct
% Outputs:
%   medianRMS             - A 3x1 structure, where each subfield
%                           corresponds to the stimulus type (LMS,
%                           Melanopsin, or Light flux). Each subfield is
%                           itself a 9x1 structure, with each nested
%                           subfield named after the contrast levels (100%,
%                           200%, and 400%) and whether the content refers
%                           to the median value, or confidence interval
%                           boundary. The ultimate value contained is the
%                           root-mean square
%  trialStruct            - A nested structure similar in format to
%                           averageResponseStruct, where the first layer
%                           describes the stimulus type and second layer
%                           describes the contrast level. The innermost
%                           layer, however, is a vector containing the
%                           RMS from each trial
%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('makePlots',true,@islogical);
p.addParameter('makeDebugPlots',false,@islogical);
p.addParameter('normalize',true,@islogical);
p.addParameter('STDWindowSizeInMSecs',500,@isnumeric);
p.addParameter('delayInSecs',1.1,@isnumeric);
p.addParameter('timebase',0:0.1:17.5,@isnumeric);
p.addParameter('windowOnset',2.5,@isnumeric);
p.addParameter('windowOffset',6.5,@isnumeric);
p.addParameter('baselineOnset',0,@isnumeric);
p.addParameter('baselineOffset',0.5,@isnumeric);
p.addParameter('confidenceInterval', [10 90], @isnumeric);
p.addParameter('sessions', {}, @iscell);
p.addParameter('contrasts', {100, 200, 400}, @iscell);
p.addParameter('stimuli', {'Melanopsin', 'LMS', 'LightFlux'}, @iscell);
p.addParameter('nTimePointsToSkipPlotting', 40, @isnumeric);
p.addParameter('savePath', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG/responseOverTime'), @ischar);
p.addParameter('plotShift', 0, @isnumeric);
p.addParameter('pulseOnset', 1.5, @isnumeric);
p.addParameter('pulseOffset', 5.5, @isnumeric);
% Parse and check the parameters
p.parse(varargin{:});
%% Find the data
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID);
dataBasePath = getpref('melSquintAnalysis','melaDataPath');
% figure out the number of completed sessions
potentialSessions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, '2*session*'));
potentialNumberOfSessions = length(potentialSessions);
% initialize outputStruct
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]).left = [];
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]).right = [];
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]).combined = [];
        
    end
end
if isempty(p.Results.sessions)
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
    
    numberOfCompletedSessions = sessions;
    % get session IDs
    sessionIDs = [];
    for ss = numberOfCompletedSessions
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
else
    sessionIDs = p.Results.sessions;
    numberOfCompletedSessions = 1:length(sessionIDs);
end
%% Load in the data for each session
sessionIDs = sessionIDs(~cellfun('isempty',sessionIDs));
for ss = 1:length(sessionIDs)
    sessionNumber = strsplit(sessionIDs{ss}, 'session_');
    sessionNumber = sessionNumber{2};
    availableAcquisitions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, 's*acquisition*_emg.mat'));
    
    acquisitions = [];
    for aa = 1:length(availableAcquisitions)
        acquisitionLongName = availableAcquisitions(aa).name;
        acquisitionLongName = strsplit(acquisitionLongName, '_emg.mat');
        acquisition = acquisitionLongName{1}(end-1:end);
        acquisition = str2num(acquisition);
        acquisitions = [acquisitions, acquisition];
    end
    
    
    for aa = acquisitions
        stimulusDataFile = fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_base.mat', str2num(sessionNumber),aa));
        if exist(stimulusDataFile)
            acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_StP_acquisition%02d_emg.mat', str2num(sessionNumber),aa)));
            stimulusData = load(stimulusDataFile);
            
            if p.Results.makeDebugPlots
                figure;
            end
            
            voltages = [];
            for tt = 1:10
                
                if tt ~= 1 % we're discarding the first trial of each acquisition
                    % assemble packet
                    trialData.response.timebase = acquisitionData.responseStruct.data(tt).emg.timebase;
                    trialData.response.values.right = acquisitionData.responseStruct.data(tt).emg.response(1,:);
                    trialData.response.values.left = acquisitionData.responseStruct.data(tt).emg.response(2,:);
                    
                    % adjust timebase for the delay in issuing the
                    % beginning recording command and the actual beginning
                    % of data recording
                    trialData.response.timebase = trialData.response.timebase + p.Results.delay;
                    
                    % center the voltages at 0. we've noticed that for whatever
                    % reason, the baseline EMG results are not centered around
                    % 0, but are in fact shifted a bit negative. even more
                    % confusing, this is worse for the left EMG leads relative
                    % to the right. centering at 0 should take care of this
                    
                    trialData.response.values.right = trialData.response.values.right - mean(trialData.response.values.right);
                    trialData.response.values.left = trialData.response.values.left - mean(trialData.response.values.left);
                    
                    
                    if p.Results.makeDebugPlots
                        subplot(2,5,tt)
                        hold on
                        plot(trialData.response.timebase, trialData.response.values.right);
                        plot(trialData.response.timebase, trialData.response.values.left);
                    end
                    
                    % calculate jumping window STD
                    timepoint = 1;
                    EMGResponseOverTime.left = [];
                    EMGResponseOverTime.right = [];
                    resampledTimebase = p.Results.timebase;
                    
                    %
                    samplingRate = 1/(trialData.response.timebase(2) - trialData.response.timebase(1));
                    STDWindowSizeInIndices = samplingRate * p.Results.STDWindowSizeInMSecs/1000;
                    
                    for timepoint = resampledTimebase
                        
                        if timepoint - floor(STDWindowSizeInIndices/2) < 1 || timepoint + floor(STDWindowSizeInIndices/2) > length(trialData.response.timebase)
                            EMGResponseOverTime.left(end+1) = NaN;
                            EMGResponseOverTime.right(end+1) = NaN;
                            
                        else
                            EMGResponseOverTime.left(end+1) = std(trialData.response.values.left((timepoint-floor(STDWindowSizeInIndices/2)):(timepoint+floor(STDWindowSizeInIndices/2))));
                            EMGResponseOverTime.right(end+1) = std(trialData.response.values.right((timepoint-floor(STDWindowSizeInIndices/2)):(timepoint+floor(STDWindowSizeInIndices/2))));
                            
                        end
                        
                        
                        
                    end
                    
                    
                    % left-over code when doing a true sliding window
                    %                     for timepoint = 1:length(trialData.response.timebase)
                    %
                    %                         if timepoint - floor(STDWindowSizeInIndices/2) < 1 || timepoint + floor(STDWindowSizeInIndices/2) > length(trialData.response.timebase)
                    %                             EMGResponseOverTime.left(timepoint) = NaN;
                    %                             EMGResponseOverTime.right(timepoint) = NaN;
                    %
                    %                         else
                    %                             EMGResponseOverTime.left(timepoint) = std(trialData.response.values.left((timepoint-floor(STDWindowSizeInIndices/2)):(timepoint+floor(STDWindowSizeInIndices/2))));
                    %                             EMGResponseOverTime.right(timepoint) = std(trialData.response.values.right((timepoint-floor(STDWindowSizeInIndices/2)):(timepoint+floor(STDWindowSizeInIndices/2))));
                    %
                    %                         end
                    %
                    %                     end
                    
                    
                    % determine indices for normalization window
                    
                    [~, baselineOnsetIndex ] = min(abs(p.Results.baselineOnset-resampledTimebase));
                    [~, baselineOffsetIndex ] = min(abs(p.Results.baselineOffset-resampledTimebase));
                    
                    
                    
                    
                    
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
                    nItems = size((trialStruct.(directionName).(['Contrast', contrast]).left),1);
                    if (p.Results.normalize)
                        baselineActivityLeft = nanmean(EMGResponseOverTime.left(baselineOnsetIndex:baselineOffsetIndex));
                        baselineActivityRight = nanmean(EMGResponseOverTime.right(baselineOnsetIndex:baselineOffsetIndex));
                        
                        
                        trialStruct.(directionName).(['Contrast', contrast]).left(nItems+1,:) = (EMGResponseOverTime.left - baselineActivityLeft)/baselineActivityLeft;
                        trialStruct.(directionName).(['Contrast', contrast]).right(nItems+1,:) = (EMGResponseOverTime.right - baselineActivityRight)/baselineActivityRight;
                        
                        trialStruct.(directionName).(['Contrast', contrast]).combined(nItems+1,:) = nanmean([trialStruct.(directionName).(['Contrast', contrast]).left(nItems+1,:); trialStruct.(directionName).(['Contrast', contrast]).right(nItems+1,:)],1);
                    else
                        trialStruct.(directionName).(['Contrast', contrast]).left(nItems+1,:) = EMGResponseOverTime.left;
                        trialStruct.(directionName).(['Contrast', contrast]).right(nItems+1,:) = EMGResponseOverTime.right;
                        
                        trialStruct.(directionName).(['Contrast', contrast]).combined(nItems+1,:) = nanmean([trialStruct.(directionName).(['Contrast', contrast]).left(nItems+1,:); trialStruct.(directionName).(['Contrast', contrast]).right(nItems+1,:)],1);
                        
                        
                    end
                    
                end
                
            end
        end
    end
end

% save out trialStruct
fullSavePath = fullfile(p.Results.savePath, ['WindowLength_', p.Results.STDWindowLengthInMSecs, 'MSecs'], 'trialStructs');
if ~exist(fullSavePath)
    mkdir(fullSavePath);
end
save(fullfile(fullSavePath, subjectID), 'trialStruct');
%% Plot to summarize
makePlots = p.Results.makePlots;
if makePlots
    plotFig = figure;
    
    nStimuli = length(p.Results.stimuli);
    nContrasts = length(p.Results.contrasts);
    
    % set up color palette
    colorPalette.Melanopsin{1} = [220/255, 237/255, 200/255];
    colorPalette.Melanopsin{2} = [66/255, 179/255, 213/255];
    colorPalette.Melanopsin{3} = [26/255, 35/255, 126/255];
    
    grayColorMap = colormap(gray);
    colorPalette.LMS{1} = grayColorMap(50,:);
    colorPalette.LMS{2} = grayColorMap(25,:);
    colorPalette.LMS{3} = grayColorMap(1,:);
    colorPalette.LS = colorPalette.LMS;
    
    colorPalette.LightFlux{1} = [254/255, 235/255, 101/255];
    colorPalette.LightFlux{2} = [228/255, 82/255, 27/255];
    colorPalette.LightFlux{3} = [77/255, 52/255, 47/255];
    
    for ss = 1:nStimuli
        
        % pick the right subplot for the right stimuli
        ax.(['ax', num2str(ss)]) = subplot(nStimuli,1,ss);
        title(p.Results.stimuli{ss})
        hold on
        
        for cc = 1:nContrasts
            
            % make thicker plot lines
            lineProps.width = 1;
            
            % adjust color
            lineProps.col{1} = colorPalette.(p.Results.stimuli{ss}){cc};
            
            % plot
            axis.(['ax', num2str(cc)]) = mseb(resampledTimebase, nanmean(trialStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})]).combined), std(trialStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})]).combined)/size(trialStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})]).combined,1), lineProps);
            
            legendText{cc} = ([num2str(p.Results.contrasts{cc}), '% Contrast, N = ', num2str(size(trialStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})]).combined, 1))]);
            
        end
        
        legend(legendText, 'Location', 'NorthEast')
        legend('boxoff')
        
        % add line for pulse onset
        line([p.Results.pulseOnset-p.Results.plotShift,  p.Results.pulseOffset-p.Results.plotShift], [-0.5, -0.5], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
        
        % spruce up axes
        
        
        xlabel('Time (s)')
        ylabel('EMG Activity (STD)')
        
    end
    
    linkaxes([ax.ax1, ax.ax2, ax.ax3]);
    
    fullSavePath = fullfile(p.Results.savePath, ['WindowLength_', p.Results.STDWindowLengthInMSecs, 'MSecs']);
    
    if ~exist(fullSavePath)
        mkdir(fullSavePath)
    end
    
    print(plotFig, fullfile(fullSavePath, subjectID), '-dpdf', '-fillpage')
    
end
end % end function