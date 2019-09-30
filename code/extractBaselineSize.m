function extractBaselineSize(subjectID, varargin)

% Extract baseline size per trial
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
p.addParameter('baselineWindowOnsetTimeForNormalization', 1, @isnumeric);
p.addParameter('baselineWindowOffsetTimeForNormalization', 1.5, @isnumeric);
p.addParameter('baselineWindowOnsetTime', 0, @isnumeric);
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


% initialize outputStruct
stimuli = p.Results.stimuli;
contrasts = p.Results.contrasts;
for ss = 1:length(stimuli)
    acquisitionsByStimulus.(stimuli{ss}) = [];
    for cc = 1:length(contrasts)
        trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]) = [];
    end
end

%% figure out sessions
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
sessionIDs = subjectListStruct.(subjectID);

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
            
            % figure out which direction type the acquisition is
            directionNameLong = stimulusData.trialList(1).modulationData.modulationParams.direction;
            directionNameSplit = strsplit(directionNameLong, ' ');
            if strcmp(directionNameSplit{1}, 'Light')
                directionName = 'LightFlux';
            elseif strcmp(directionNameSplit{1}, 'L+S')
                directionName = 'LS';
            else
                directionName = directionNameSplit{1};
            end
            nRowForAcquisitionStruct = size(acquisitionsByStimulus.(directionName),1);

                            
            for tt = 2:10
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
                [~, baselineWindowOnsetIndex ] = min(abs(p.Results.baselineWindowOnsetTimeForNormalization-trialData.response.timebase));
                [~, baselineWindowOffsetIndex ] = min(abs(p.Results.baselineWindowOffsetTimeForNormalization-trialData.response.timebase));
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
                
                if p.Results.baselineWindowOnsetTime == 0
                    baselineWindowOnsetIndex = 1;
                else
                    [~, baselineWindowOnsetIndex ] = min(abs(p.Results.baselineWindowOnsetTime-trialData.response.timebase));
                    
                end
                
                [~, baselineWindowOffsetIndex ] = min(abs(p.Results.baselineWindowOffsetTime-trialData.response.timebase));
                
                cleanedBaselineSize = nanmean(trialData.response.values(baselineWindowOnsetIndex:baselineWindowOffsetIndex));
                
                
                % get information about the trial
                
                contrastLong = strsplit(directionNameLong, '%');
                contrastLong = strsplit(contrastLong{1}, ' ');
                contrast = contrastLong{end};
                nRow = size(trialStruct.(directionName).(['Contrast', contrast]),1);
                
                
                trialStruct.(directionName).(['Contrast', contrast])(nRow+1,:) = cleanedBaselineSize;
                
                subjectStruct.(['session', num2str(sessionNumber)]).(['acquisition', num2str(aa)])(tt) = cleanedBaselineSize;
                
                
                acquisitionsByStimulus.(directionName)(nRowForAcquisitionStruct+1,tt) = cleanedBaselineSize;
                
            end
            
        end
    end
end

% save out results
saveDir = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'baselineSize');
if ~exist(saveDir)
    mkdir(saveDir);
end

%% make average responses
for ss = 1:length(stimuli)
    averageBaselineSizeTrend.(stimuli{ss}) = nanmean(acquisitionsByStimulus.(stimuli{ss}),1);
end

save(fullfile(saveDir, [subjectID, '_baselineSize.mat']), 'trialStruct', 'subjectStruct', 'acquisitionsByStimulus');





end



