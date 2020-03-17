function [droppedFramesTrialStruct, droppedFramesMeanStruct] = analyzeDroppedFrames(varargin)

% Function used to analyze frames in which subject is not receiving the
% intended light stimulus (AKA dropped frames)

% Syntax: 
%   [droppedFramesTrialStruct, droppedFramesMeanStruct] = analyzeDroppedFrames
%
% Description:
%   Looking at group average pupil responses to each stimulus condition,
%   there may be a trend to reduced pupil constriction in migraine relative
%   to headache free controls. One hypothesis to explain this trend is that
%   because these patients find the pulses so uncomfortable, they try to
%   look at the stimulus less (meaning they blink more, they look away,
%   they close their eyes). This routien attempts to quantify any behavior
%   which would reduce the amount of light stimulus that they receive,
%   which might then produce less pupil constriction. 
%
%   This routine currently only works with Squint subjects, but should be
%   modified in the future to also analyze Deuteranopes.
%
% Key-value pairs:
%   - range:                    - a string which defines the time window
%                                 over which to analyze the number of
%                                 dropped frames. The default behavior,
%                                 'pulse', looks at dropped frames during
%                                 only the 4-s window during which the
%                                 pulse was presented to the subject. Any
%                                 other input here is interpreted as
%                                 defining the window as the entire trial.
%   - whichBadFrames            - a string which defines which types of bad
%                                 frames to include as "dropped frames".
%                                 The default option is 'blinks', which
%                                 means that only the frames classified as
%                                 blinks are pooled as dropped frames. If
%                                 not 'blinks', the routine looks at
%                                 blinks, poor fit frames, and duplicate
%                                 frames, and frames in which no ellipse
%                                 was initially placed.

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;

p.addParameter('range','pulse',@ischar);
p.addParameter('whichBadFrames','blinks',@ischar);

% Parse and check the parameters
p.parse(varargin{:});


%% Get subject list
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

%% Set up some basic variables about the stimuli and subjects
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
groups = {'controls', 'mwa', 'mwoa'};
groupColors = {'k', 'b', 'r'};

%% Pre-allocate results variable
for group = 1:length(groups)
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            droppedFramesTrialStruct.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];

        end
    end
end


%% Loop over subjects
for ss = 1:length(subjectIDs)

    % load trialStruct with trialInfoStruct
    load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectIDs{ss}, 'trialStruct_radiusSmoothed_droppedFramesAnalysis.mat'));
    
    % determine migraine status
    groupLabel = linkMELAIDToGroup(subjectIDs{ss});
    
    if strcmp(groupLabel, 'c')
        groupLabel = 'controls';
    end
    
    % loop over trials (across stimulus and contrast levels)
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            % figure out the number of frames in the given trial
            nTrials = length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            for tt = 1:nTrials
                
                % figure out index range over which we're looking for
                % dropped pulses
                if strcmp(p.Results.range, 'pulse')
                    rangeIndices = [trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.pulseOnsetIndex, trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.pulseOffsetIndex];
                elseif strcmp(p.Results.range, 'wholeTrial')
                    rangeIndices = [1 length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase)];
                end
                
                % count the number of dropped frames, depending on the
                % definition of dropped frames
                if strcmp(p.Results.whichBadFrames, 'blinks')
                    blinkFrames = find((trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.blinkIndices>=rangeIndices(1)) & (trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.blinkIndices<=rangeIndices(2)));
                    droppedFrames = blinkFrames;
                else
                    blinkFrames = find((trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.blinkIndices>=rangeIndices(1)) & (trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.blinkIndices<=rangeIndices(2)));
                    duplicateFrames = find((trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.duplicateFrameIndices>=rangeIndices(1)) & (trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.duplicateFrameIndices<=rangeIndices(2)));
                    poorFitFrames = find((trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.poorFitFrameIndices>=rangeIndices(1)) & (trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.poorFitFrameIndices<=rangeIndices(2)));
                    initialNaNFrames = find((trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.initialNaNFrames>=rangeIndices(1)) & (trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.initialNaNFrames<=rangeIndices(2)));
                    droppedFrames = [blinkFrames, duplicateFrames', poorFitFrames', initialNaNFrames'];
                    droppedFrames = unique(droppedFrames);
                end
                
                % save out results per trial
                droppedFramesTrialStruct.(groupLabel).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt) = length(droppedFrames);
                


            end
            
            % save out average results for all trials of the same stimulus
            % type
            droppedFramesMeanStruct.(groupLabel).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean(droppedFramesForStimulusType);
            
        end
    end
end

%% Do some summary plotting
close all;
droppedFramesMeanStructForPlotting.Controls = droppedFramesMeanStruct.controls;
droppedFramesMeanStructForPlotting.MwA = droppedFramesMeanStruct.mwa;
droppedFramesMeanStructForPlotting.MwoA = droppedFramesMeanStruct.mwoa;

savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'droppedFramesAnalysis');
if ~exist(savePath)
    mkdir(savePath);
end

if strcmp(p.Results.whichBadFrames, 'blinks')
    saveName = ['droppedFramesAnalysis_blinksOnly_', p.Results.range];
else
    saveName = ['droppedFramesAnalysis_allBadFrames_', p.Results.range];

end

if strcmp(p.Results.range, 'pulse')
    yLims = [0 90];
    
elseif strcmp(p.Results.range, 'wholeTrial')
    yLims = [0 500];
end

plotSpreadResults(droppedFramesMeanStructForPlotting, 'yLims', yLims, 'saveName', fullfile(savePath, saveName))


[ pupilStruct ] = loadPupilResponses;
for group = 1:length(groups)
    plotFig = figure;
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            subplot(3,3, (((stimulus-1)*3)+contrast)); hold on
            x = droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            y = pupilStruct.AUC.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            plot(x, y, 'o', 'Color', groupColors{group});
            
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
            pearsonCorrelation = corr2(x, y);
            
            title([stimuli{stimulus}, ' Contrast ', num2str(contrasts{contrast}), '%, r = ' num2str(pearsonCorrelation)]);

            
            xlabel('Mean Dropped Frames');
            ylabel('Pupil Constriction AUC');
            ylim([0 450]);
            
            if strcmp(p.Results.range, 'pulse')
                xlim([0 100]);
            else
                xlim([0 500]);
            end
            
        end
    end
    set(plotFig, 'Position', [88 180 1152 798]);
    if strcmp(p.Results.whichBadFrames, 'blinks')
        export_fig(plotFig, fullfile(savePath, ['droppedFrames_blinks_', p.Results.range, 'XAUC_', groups{group}, '.pdf']));
    else
        export_fig(plotFig, fullfile(savePath, ['droppedFrames_allBadFrames_', p.Results.range, 'XAUC_', groups{group}, '.pdf']));
    end

end

plotFig = figure;
for group = 1:length(groups)
    
    for stimulus = 1:length(stimuli)
            subplot(1,3, stimulus); hold on
            x = [median(droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).Contrast100), ...
                median(droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).Contrast200), ...
                median(droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).Contrast400)];
            
            y = [median(pupilStruct.AUC.(groups{group}).(stimuli{stimulus}).Contrast100), ...
                median(pupilStruct.AUC.(groups{group}).(stimuli{stimulus}).Contrast200), ...
                median(pupilStruct.AUC.(groups{group}).(stimuli{stimulus}).Contrast400)];
            
            plot(x, y, 'o', 'Color', groupColors{group});
            

            
            title([stimuli{stimulus}]);

            
            xlabel('Mean Dropped Frames');
            ylabel('Pupil Constriction AUC');
            ylim([0 250]);
            
            if strcmp(p.Results.range, 'pulse')
                xlim([0 20]);
            else
                xlim([0 500]);
            end
            
        
    end
    set(plotFig, 'Position', [88 180 1152 798]);
    if strcmp(p.Results.whichBadFrames, 'blinks')
        export_fig(plotFig, fullfile(savePath, ['droppedFrames_blinks_', p.Results.range, 'XAUC','.pdf']));
    else
        export_fig(plotFig, fullfile(savePath, ['droppedFrames_allBadFrames_', p.Results.range, 'XAUC', '.pdf']));
    end

end



end