function [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses(subjectID, varargin)

% Analyzes a single subject's pupillometry data from the OLApproach_Squint,
% SquintToPulse Experiment
%
% Syntax:
%  [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses(subjectID)
%
% Description:
%   This function analyzes the pupillometry data across all sessions for a
%   given subject as part of the OLApproach_Squint main experiment. The
%   ultimate output of the function is the average pupil response for each
%   stimulus type, at each contrast level, for the inputted subject as well
%   as the response of each individual trial organized according to trial
%   type.

%   This routine first figures out how many sessions of data have been
%   preprocessed for the inputted subject. The routine loops through each
%   session and ensures that the transparentTrack output for all trials is
%   present. If so, this session is regarded as a completed session and
%   these preprocessed pupillometry data are incorporated into further
%   analysis.

%   This routine also performs some additional preprocessing of the pupil
%   data. The steps include: identifying bad pupil frames (bad pupil frames
%   as defined by duplicate frames, frames in which the RMSE of the fit to
%   the pupil perimeter is too high, or blinks), adjusting each time series
%   according to the delay from issue of video capture command to first
%   frame of captured data, and interpolation to a common timebase. This
%   procedure is performed on each trial, and the data from these cleaned
%   trials is stored as well as averaged together across all trials.
%   Finally some summary plotting is performed.
%
% Inputs:
%	subjectID             - A string describing the subjectID (e.g.
%                           MELA_0121) to be analyzed)
%
% Optional Key-Value Pairs:
%   debugSpikeRemover     - A logical. If set to true, the routine will
%                           display a plot of each trial's response and
%                           which points have been identified as spikes to
%                           be removed.
%
% Outputs:
%   averageResponseStruct - A 3x1 structure, where each subfield
%                           corresponds to the stimulus type (LMS,
%                           Melanopsin, or Light flux). Each subfield is
%                           itself a 3x1 structure, with each nested
%                           subfield named after the contrast levels (100%,
%                           200%, and 400%). The contents of this nested
%                           layer is the average value across all trials at
%                           each timepoint. The corresponding timebase of
%                           these result values is 0:0.001:18.5.
%  trialStruct            - A nested structure similar in format to
%                           averageResponseStruct, where the first layer
%                           describes the stimulus type and second layer
%                           describes the contrast level. The innermost
%                           layer, however, is a matrix instead of a
%                           vector. Each row describes a different trial,
%                           while columns refer to the timepoint. These
%                           timeseries share the same timebase
%                           (0:0.001:18.5)

% Example command for deuteranopes: [ averageResponseStruct, trialStruct ] = makeSubjectAverageResponses('MELA_3009', 'Protocol', 'Deuteranopes', 'contrasts', {400, 800, 1200}, 'stimuli', {'Melanopsin', 'LS', 'LightFlux'}, 'protocolShortName', 'Deuteranopes', 'debugNumberOfNaNValuesPerTrial', true, 'performSpikeRemoval', true, 'blinkVelocityThreshold', 0.15, 'trialNaNThreshold', 0.25, 'blinkBufferFrames', [3 6], 'interpolateThroughRuns', false, 'RMSEThreshold', 5, 'interpolateThroughRuns', false, 'fitLabel', 'initial')

%% Parse the input

p = inputParser; p.KeepUnmatched = true;
p.addParameter('debugSpikeRemover',false,@islogical);
p.addParameter('debugNumberOfNaNValuesPerTrial', false, @islogical);
p.addParameter('sessions', {}, @iscell);
p.addParameter('Protocol', 'SquintToPulse', @ischar);
p.addParameter('protocolShortName', 'StP', @ischar);
p.addParameter('contrasts', {100, 200, 400}, @iscell);
p.addParameter('stimuli', {'Melanopsin', 'LMS', 'LightFlux'}, @iscell);

% Fixed experimental parameters
p.addParameter('baselineWindowOnsetTime', 1, @isnumeric);
p.addParameter('baselineWindowOffsetTime', 1.5, @isnumeric);
p.addParameter('pulseOnset', 1.5, @isnumeric);
p.addParameter('pulseOffset', 5.5, @isnumeric);
p.addParameter('frameRate', 60, @isnumeric);
p.addParameter('trialNaNThreshold', 0.2, @isnumeric); % meaning 20%

% Parameters that may vary between subjects
p.addParameter('blinkBufferFrames', [2 4], @isnumeric);
p.addParameter('RMSEThreshold', 5, @isnumeric);
p.addParameter('blinkVelocityThreshold', 0.02, @isnumeric);
p.addParameter('spikeWindowLength', 5, @isnumeric);
p.addParameter('nTimePointsToSkipPlotting', 40, @isnumeric);
p.addParameter('performSpikeRemoval', false, @islogical);
p.addParameter('performControlFileBlinkRemoval', true, @islogical);
p.addParameter('interpolateThroughRuns', false, @islogical);
p.addParameter('interpolationLimitInFrames', 30, @isnumeric);
p.addParameter('extremePercentageChangeThreshold', 4, @isnumeric);
p.addParameter('interpolate', true, @islogical);
p.addParameter('fitLabel', 'initial', @ischar);
p.addParameter('forceExcludeTrials', [], @isnumeric);

% Plotting parameters
p.addParameter('plotShift', 1, @isnumeric);
p.addParameter('xLims', [0 17], @isnumeric);
p.addParameter('yLims', [-0.8 0.1], @isnumeric);




p.parse(varargin{:});

%% Find the data
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles/', subjectID);
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

% figure out the number of completed sessions
potentialSessions = dir(fullfile(analysisBasePath, '2*session*'));
potentialNumberOfSessions = length(potentialSessions);

% initialize outputStruct
stimuli = p.Results.stimuli;
contrasts = p.Results.contrasts;
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]) = [];
    end
end

if isempty(p.Results.sessions)
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
            sessionName = strsplit(potentialSessions(ss).name, 'session_');
            sessionNumber = str2num(sessionName{2});
            sessions = [sessions, sessionNumber];
        end
    end
    
    completedSessions = sort(sessions);
    % get session IDs
    sessionIDs = [];
    for ss = completedSessions
        potentialSessions = dir(fullfile(analysisBasePath, sprintf('2*session_%d*', ss)));
        % in the event of more than one entry for a given session (which would
        % happen if something weird happened with a session and it was
        % restarted on a different day), it'll grab the later dated session,
        % which should always be the one we want
        for ii = 1:length(potentialSessions)
            if ~strcmp(potentialSessions(ii).name(1), 'x')
                sessionIDs{ss} = potentialSessions(ii).name;
            end
        end
        sessionIDs = sessionIDs(~cellfun('isempty',sessionIDs));
    end
else
    sessionIDs = p.Results.sessions;
    numberOfCompletedSessions = 1:length(sessionIDs);
end

% prep output debugging dir
if ~exist(fullfile(analysisBasePath,'allTrials'))
    mkdir(fullfile(analysisBasePath,'allTrials'));
else
    if ~exist(fullfile(analysisBasePath,'old'))
        mkdir(fullfile(analysisBasePath,'old'));
    end
    system(['mv "', fullfile(analysisBasePath,'allTrials'), '" "', fullfile(analysisBasePath,'old'), '"']);
    mkdir(fullfile(analysisBasePath,'allTrials'));
    
    
end


%% Load in the data for each session
for ss = 1:length(sessionIDs)
    sessionNumber = strsplit(sessionIDs{ss}, 'session_');
    sessionNumber = sessionNumber{2};
    for aa = 1:6
        system(['touch -a "', fullfile(dataBasePath, 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_%s_acquisition%02d_pupil.mat', str2num(sessionNumber),p.Results.protocolShortName, aa)), '"']);
        system(['touch -a "', fullfile(dataBasePath, 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_%s_acquisition%02d_base.mat', str2num(sessionNumber),p.Results.protocolShortName,aa)), '"']);
        
        acquisitionData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_%s_acquisition%02d_pupil.mat', str2num(sessionNumber), p.Results.protocolShortName, aa)));
        if exist(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_%s_acquisition%02d_base.mat', str2num(sessionNumber),p.Results.protocolShortName,aa)))
            stimulusData = load(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/', p.Results.Protocol, '/DataFiles', subjectID, sessionIDs{ss}, sprintf('session_%d_%s_acquisition%02d_base.mat', str2num(sessionNumber),p.Results.protocolShortName,aa)));
            
            for tt = 1:10
                if tt ~= 1
                    trialData.response = [];
                    
                    system(['touch -a "', fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)), '"']);
                    trialData = load(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_pupil.mat', tt)));
                    
                    % gather into memory the pupil area, RMSE, and timebase
                    if strcmp(p.Results.fitLabel, 'radiusSmoothed')
                        trialData.response.values = ((trialData.pupilData.radiusSmoothed.eyePoses.values(:,4)).^2)*pi;
                        initialResponse = ((trialData.pupilData.radiusSmoothed.eyePoses.values(:,4)).^2)*pi;
                        trialData.response.RMSE = trialData.pupilData.radiusSmoothed.ellipses.RMSE;
                    elseif strcmp(p.Results.fitLabel, 'initial')
                        
                        trialData.response.values = trialData.pupilData.initial.ellipses.values(:,3);
                        initialResponse = trialData.pupilData.initial.ellipses.values(:,3);
                        trialData.response.RMSE = trialData.pupilData.initial.ellipses.RMSE;
                        
                    end
                    trialData.response.timebase = acquisitionData.responseStruct.data(tt).pupil.timebase;
                    
                    initialNaNFrames = find(isnan(trialData.response.values));
                    
                    % identify duplicate frames
                    differential = [];
                    differential = diff(trialData.response.RMSE);
                    duplicateFrameIndices = [];
                    duplicateFrameIndices = find(differential == 0);
                    % censor duplicate frames
                    for dd = duplicateFrameIndices
                        trialData.response.values(dd+1) = NaN;
                    end
                    
                    % mean-center:
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    % adjust the timebase by adding the delay
                    cameraCommandOutput = acquisitionData.responseStruct.data(tt).pupil.consoleOutput;
                    consoleOutput = strsplit(cameraCommandOutput, 'start: ');
                    startTimeFromConsoleOutput = strsplit(consoleOutput{2}, ',');
                    startTimeFromConsoleOutput = str2num(startTimeFromConsoleOutput{1});
                    % determine the delay from when ffmpeg thinks we launched video
                    % acquisition and the UDP command thinks we went our command
                    delay = startTimeFromConsoleOutput - acquisitionData.responseStruct.events(tt).tRecordingStart;
                    % adjust the timebase
                    trialData.response.timebase = trialData.response.timebase + delay;
                    
                    % find the indices corresponding to 1 and 1.5 s with the
                    % new timebase
                    [~, baselineWindowOnsetIndex ] = min(abs(p.Results.baselineWindowOnsetTime-trialData.response.timebase));
                    [~, baselineWindowOffsetIndex ] = min(abs(p.Results.baselineWindowOffsetTime-trialData.response.timebase));
                    baselineSize = nanmean(trialData.response.values(baselineWindowOnsetIndex:baselineWindowOffsetIndex));
                    trialData.response.values = (trialData.response.values - baselineSize)./baselineSize;
                    
                    % remove blinks
                    controlFile = loadControlFile(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_controlFile.csv', tt)));
                    blinkIndices = [];
                    if p.Results.performControlFileBlinkRemoval
                        % determine if blinkBufferFrames were used in original
                        % processing
                        controlFileName = fopen(fullfile(analysisBasePath, sessionIDs{ss}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_controlFile.csv', tt)));
                        controlFileContents = textscan(controlFileName,'%s', 'Delimiter',',');
                        indices = strfind(controlFileContents{1}, 'extendBlinkWindow');
                        blinkWindowIndex = find(~cellfun(@isempty,indices));
                        blinkWindowFromControlFile = (controlFileContents{1}(blinkWindowIndex+1));
                        blinkWindowFromControlFile = str2num(blinkWindowFromControlFile{1});
                        
                        if sum(blinkWindowFromControlFile == [0 0]) == 2 % if the control file processed this trial with blinkBufferFrames of [0 0], then apply the inputted range
                            blinkBufferFrames = p.Results.blinkBufferFrames;
                        else
                            blinkBufferFrames = [0 0]; % otherwise, don't further extend the window
                        end
                        
                        
                        for ii = 1:length(controlFile)
                            if strcmp(controlFile(ii).type, 'blink')
                                blinkFrame = controlFile(ii).frame;
                                if blinkFrame - blinkBufferFrames(1) < 1
                                    beginningOfBlinkFrame = 1;
                                else
                                    beginningOfBlinkFrame = blinkFrame - blinkBufferFrames(1);
                                end
                                if blinkFrame + blinkBufferFrames(2) > length(trialData.response.values)
                                    endingOfBlinkFrame = length(trialData.response.values);
                                else
                                    endingOfBlinkFrame = blinkFrame + blinkBufferFrames(2);
                                end
                                blinkIndices = [blinkIndices, beginningOfBlinkFrame:endingOfBlinkFrame];
                                
                                trialData.response.values(beginningOfBlinkFrame:endingOfBlinkFrame) = NaN;
                            end
                        end
                    end
                    controlFileBlinkIndices = unique(blinkIndices);
                    % identify frames that were NaN initially (prior to this
                    % routine assigning them as NaN) that were not assigned so
                    % because they were blinks (i.e. we couldn't find the pupil
                    % to begin with);
                    initialNaNFrames = setdiff(initialNaNFrames,controlFileBlinkIndices);
                    
                    spikeRemoverBlinkIndices = [];
                    if p.Results.performSpikeRemoval
                        [iy, spikeRemoverBlinkIndices] = PupilAnalysisToolbox_SpikeRemover(trialData.response.values, p.Results.blinkVelocityThreshold, p.Results.spikeWindowLength);
                        if p.Results.debugSpikeRemover
                            figure; hold on;
                            plot(trialData.response.values)
                            plot(spikeRemoverBlinkIndices, trialData.response.values(spikeRemoverBlinkIndices), 'o', 'Color', 'r')
                        end
                        trialData.response.values(spikeRemoverBlinkIndices) = NaN;
                        spikeRemoverBlinkIndices = unique(spikeRemoverBlinkIndices);
                    end
                    blinkIndices = [controlFileBlinkIndices, spikeRemoverBlinkIndices];
                    blinkIndices = unique(blinkIndices);
                    
                    % identify poor ellipse fits
                    threshold = p.Results.RMSEThreshold; % set the threshold for a bad fit as RMSE > 5
                    poorFitFrameIndices = [];
                    poorFitFrameIndices = find(trialData.response.RMSE > threshold);
                    % censor poor ellipse fits
                    for pp = poorFitFrameIndices
                        trialData.response.values(pp) = NaN;
                    end
                    poorFitFrameIndices = setdiff(poorFitFrameIndices, blinkIndices);
                    
                    % identify extreme frames
                    extremeFrameIndices = find(abs(trialData.response.values) > p.Results.extremePercentageChangeThreshold);
                    trialData.response.values(extremeFrameIndices) = NaN;
                    
                    % undo, then re-do mean-centering. this is because
                    % sometimes a blink occurs in the original baseline window,
                    % which leads to improper estimation of the baseline size.
                    % after these poor frames have been dealt with, we can
                    % revert to the original units of pupil size, then re-mean
                    % center
                    % undo mean-centering
                    trialData.response.values = (trialData.response.values*baselineSize)+baselineSize;
                    
                    baselineSizePartTwo = nanmean(trialData.response.values(baselineWindowOnsetIndex:baselineWindowOffsetIndex));
                    trialData.response.values = (trialData.response.values - baselineSizePartTwo)./baselineSizePartTwo;
                    
                    
                    
                    % resample the timebase so we can put all trials on the same
                    % timebase
                    stepSize = 1/p.Results.frameRate;
                    resampledTimebase = 0:stepSize:18.5;
                    
                    resampledValues = [];
                    resampledRMSE = [];
                    
                    if ~(p.Results.interpolateThroughRuns)
                        numberOfBadFrames = sum(isnan(trialData.response.values));
                        percentageBadFrames = numberOfBadFrames/(length(trialData.response.values));
                        % interpolate across all NaN values
                        theNans = isnan(trialData.response.values);
                        if numberOfBadFrames ~= length(trialData.response.values)
                            if p.Results.interpolate
                                if sum(theNans) > 1
                                    x = trialData.response.values;
                                    x(theNans) = interp1(trialData.response.timebase(~theNans), trialData.response.values(~theNans), trialData.response.timebase(theNans)', 'linear');
                                    trialData.response.values = x;
                                end
                            end
                            
                            % interpolate onto common timebase across trials
                            resampledValues = interp1(trialData.response.timebase,trialData.response.values,resampledTimebase,'linear');
                            
                            
                            trialData.responseResampled = [];
                            trialData.responseResampled.values = resampledValues;
                            trialData.responseResampled.timebase = resampledTimebase;
                            
                        else
                            resampledValues = nan(1,length(resampledTimebase));
                            trialData.responseResampled.values = resampledValues;
                        end
                        
                    else
                        
                        % interpolate through runs of duration shorter than
                        % interpolationLimit
                        TotalNaNIndices = find(isnan(trialData.response.values));
                        
                        NaNRunsCellArray = identifyRuns(TotalNaNIndices);
                        interpolationLimitInFrames = p.Results.interpolationLimitInFrames;
                        for rr = 1:length(NaNRunsCellArray)
                            if length(NaNRunsCellArray{rr}) <= interpolationLimitInFrames
                                theNans = zeros(1,length(trialData.response.values));
                                theNans(NaNRunsCellArray{rr}) = 1;
                                theNans = logical(theNans);
                                x = trialData.response.values;
                                x(theNans) = interp1(trialData.response.timebase(~theNans), trialData.response.values(~theNans), trialData.response.timebase(theNans)', 'linear');
                                trialData.response.values = x;
                            end
                        end
                        
                        % tally up unrecoverable frames
                        numberOfBadFrames = sum(isnan(trialData.response.values));
                        percentageBadFrames = numberOfBadFrames/(length(trialData.response.values));
                        
                        % interpolate onto common timebase, but leave the NaNs
                        % intact
                        resampledValues = interp1(trialData.response.timebase,trialData.response.values,resampledTimebase,'linear');
                        
                        
                        trialData.responseResampled = [];
                        trialData.responseResampled.values = resampledValues;
                        trialData.responseResampled.timebase = resampledTimebase;
                        
                    end
                    
                    
                    % stash the trial
                    % first figure out what type of trial we're working with
                    directionNameLong = stimulusData.trialList(tt).modulationData.modulationParams.direction;
                    directionNameSplit = strsplit(directionNameLong, ' ');
                    if strcmp(directionNameSplit{1}, 'Light')
                        directionName = 'LightFlux';
                    elseif strcmp(directionNameSplit{1}, 'L+S')
                        directionName = 'LS';
                    else
                        directionName = directionNameSplit{1};
                    end
                    contrastLong = strsplit(directionNameLong, '%');
                    contrastLong = strsplit(contrastLong{1}, ' ');
                    contrast = contrastLong{end};
                    % pool the results
                    nRow = size(trialStruct.(directionName).(['Contrast', contrast]),1);
                    
                    
                    trialNaNThreshold = p.Results.trialNaNThreshold;
                    
                    if p.Results.debugNumberOfNaNValuesPerTrial
                        close all;
                        plotFig = figure; hold on;
                        plot(trialData.response.timebase, (initialResponse-baselineSize)./baselineSize); hold on; plot(resampledTimebase, resampledValues)
                        
                        if ~isempty(controlFileBlinkIndices)
                            plot(trialData.response.timebase(controlFileBlinkIndices), trialData.response.values(controlFileBlinkIndices), 'o', 'Color', 'b')
                        end
                        if ~isempty(spikeRemoverBlinkIndices)
                            
                            plot(trialData.response.timebase(spikeRemoverBlinkIndices), trialData.response.values(spikeRemoverBlinkIndices), '+', 'Color', 'b')
                        end
                        if ~isempty(duplicateFrameIndices)
                            
                            plot(trialData.response.timebase(duplicateFrameIndices), trialData.response.values(duplicateFrameIndices),'o',  'Color', 'k')
                        end
                        if ~isempty(poorFitFrameIndices)
                            
                            plot(trialData.response.timebase(poorFitFrameIndices), trialData.response.values(poorFitFrameIndices), 'o', 'Color', 'g')
                        end
                        if ~isempty(initialNaNFrames)
                            
                            plot(trialData.response.timebase(initialNaNFrames), trialData.response.values(initialNaNFrames), 'o', 'Color', 'r')
                        end
                        
                        string = sprintf('Session %d, Acquisition %d, Trial %d: %f\n\tBlink frames: %d (%d from CF, %d from SR)\n\tDuplicate frames: %d\n\tPoor fit frames: %d\n\tInitial NaN frames: %d\n\tExtreme frames: %d', str2num(sessionNumber), aa, tt, percentageBadFrames, length(blinkIndices), length(controlFileBlinkIndices), length(spikeRemoverBlinkIndices), length(duplicateFrameIndices), length(poorFitFrameIndices), length(initialNaNFrames), length(extremeFrameIndices));
                        ax = gca;
                        axesRange = ax.YLim(2) - ax.YLim(1);
                        ogYLowerLimit = ax.YLim(1);
                        ax.YLim(1) = ogYLowerLimit - 0.25*axesRange;
                        text(0.3, ogYLowerLimit - 0.1*axesRange, string);
                        
                        
                        fprintf('Session %d, Acquisition %d, Trial %d: %f\n', str2num(sessionNumber), aa, tt, percentageBadFrames);
                        fprintf('\tBlink frames: %d (%d from CF, %d from SR)\n', length(blinkIndices), length(controlFileBlinkIndices), length(spikeRemoverBlinkIndices));
                        fprintf('\tDuplicate frames: %d\n', length(duplicateFrameIndices));
                        fprintf('\tPoor fit frames: %d\n', length(poorFitFrameIndices));
                        fprintf('\tInitial NaN frames: %d\n', length(initialNaNFrames));
                        
                        
                        saveas(plotFig, fullfile(analysisBasePath,'allTrials', [sessionIDs{ss}, '_a', num2str(aa), '_t', num2str(tt), '_', p.Results.fitLabel, '.png']));
                        if percentageBadFrames >= trialNaNThreshold
                            if ~exist(fullfile(analysisBasePath,'allTrials', 'failedTrials'))
                                mkdir(fullfile(analysisBasePath,'allTrials', 'failedTrials'));
                            end
                            saveas(plotFig, fullfile(analysisBasePath,'allTrials', 'failedTrials', [sessionIDs{ss}, '_a', num2str(aa), '_t', num2str(tt),'_', p.Results.fitLabel, '.png']));
                            
                        end
                        
                        
                    end
                    
                    if percentageBadFrames >= trialNaNThreshold
                        %trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = nan(1,length(trialData.responseResampled.values));
                        badTrial = tt;
                    else
                        trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = trialData.responseResampled.values;
                        %                     if nRow > 24
                        %                         pause
                        %                     end
                    end
                end
                
            end
        end
    end
end
close all;

%% make average responses
for ss = 1:length(stimuli)
    for cc = 1:length(contrasts)
        for tt = 1:length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,:))
            averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,tt) = nanmean(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt));
            averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_SEM'])(1,tt) = nanstd(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt))/sqrt((length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt)) - sum(isnan((trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt))))));
        end
    end
end

% save out trial responses
fileName = ['trialStruct_', p.Results.fitLabel];
save(fullfile(analysisBasePath, fileName), 'trialStruct', '-v7.3');


%% Do some plotting
% set up plot
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
    subplot(nStimuli,1,ss)
    title(p.Results.stimuli{ss})
    hold on
    
    for cc = 1:nContrasts
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.(p.Results.stimuli{ss}){cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(resampledTimebase(1:end-p.Results.nTimePointsToSkipPlotting)-p.Results.plotShift, averageResponseStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})])(1:end-p.Results.nTimePointsToSkipPlotting), averageResponseStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc}), '_SEM'])(1:end-p.Results.nTimePointsToSkipPlotting), lineProps);
        
        legendText{cc} = ([num2str(p.Results.contrasts{cc}), '% Contrast, N = ', num2str(size(trialStruct.(p.Results.stimuli{ss}).(['Contrast', num2str(p.Results.contrasts{cc})]), 1))]);
        
    end
    
    legend(legendText, 'Location', 'SouthEast')
    legend('boxoff')
    
    % add line for pulse onset
    line([p.Results.pulseOnset-p.Results.plotShift,  p.Results.pulseOffset-p.Results.plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
    
    % spruce up axes
    ylim(p.Results.yLims)
    xlim(p.Results.xLims)
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change)')
    
end

% save out plots
print(plotFig, fullfile(analysisBasePath, ['averageResponse_', p.Results.fitLabel]), '-dpdf', '-fillpage')

if ~exist(fullfile(analysisBasePath, '..', 'averageResponsePlots'), 'dir')
    mkdir(fullfile(analysisBasePath, '..', 'averageResponsePlots'));
end
print(plotFig, fullfile(analysisBasePath, '..', 'averageResponsePlots', [subjectID, '_averageResponse_', p.Results.fitLabel]), '-dpdf', '-fillpage')

close(plotFig)



end



