function [droppedFramesMeanStruct, blinksOverTime] = analyzeDroppedFrames(varargin)

% Function used to analyze frames in which subject is not receiving the
% intended light stimulus (AKA dropped frames)

% Syntax:
%   [ droppedFramesMeanStruct ] = analyzeDroppedFrames
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
% Output:
%   - droppedFramesMeanStruct   - a struct, with first level subfield that
%                                 displays group, second level subfield that
%                                 describes stimulus direction, and third
%                                 level subfield that describes contrast
%                                 level. At the innermost level, the mean
%                                 number of dropped frames for a given
%                                 subject for trials of that type with good
%                                 pupillometry, are presented.
%
% Key-value pairs:
%   - range:                    - a string which defines the time window
%                                 over which to analyze the number of
%                                 dropped frames. The default behavior,
%                                 'shiftedPulse', looks at dropped frames
%                                 during only the 4-s window during which
%                                 the pulse was presented to the subject,
%                                 shifted later in time by 1-s. Other
%                                 inputs here include defining the window
%                                 as the entire trial, or defining the
%                                 actual pulse window.
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

p.addParameter('range','shiftedPulse');
p.addParameter('subjectIDs',[],@ischar);
p.addParameter('sessions',[],@iscell);
p.addParameter('whichBadFrames','blinks',@ischar);
p.addParameter('makePlots',false, @islogical);
p.addParameter('saveOutput',false, @islogical);
p.addParameter('runResponseOverTime',true, @islogical);
p.addParameter('saveName','droppedFramesAnalysis', @ischar);


% Parse and check the parameters
p.parse(varargin{:});


%% Get subject list
if isempty(p.Results.subjectIDs)
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
else
    subjectIDs = {p.Results.subjectIDs};
end




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
            blinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            groupSmoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            smoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
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
            
            droppedFramesForStimulusType = [];
            %blinksOverTime.(groupLabel).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            blinksVectorAcrossTrials = [];
            for tt = 1:nTrials
                
                if isempty(p.Results.sessions)
                    sessions = subjectListStruct.(subjectIDs{ss});
                    
                else
                    sessions = p.Results.sessions;
                end
                
                % figure out index range over which we're looking for
                % dropped pulses
                if sum(contains(sessions, trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.session)) > 0
                    if strcmp(p.Results.range, 'pulse')
                        rangeIndices = [trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.pulseOnsetIndex, trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.pulseOffsetIndex];
                    elseif strcmp(p.Results.range, 'shiftedPulse')
                        [~, beginningIndex ] = min(abs(2.5-trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase));
                        [~, endingIndex ] = min(abs(6.5-trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase));
                        rangeIndices = [beginningIndex, endingIndex];
                    elseif strcmp(p.Results.range, 'wholeTrial')
                        rangeIndices = [1 length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase)];
                    else
                        [~, beginningIndex ] = min(abs(p.Results.range(1)-trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase));
                        [~, endingIndex ] = min(abs(p.Results.range(2)-trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase));
                        rangeIndices = [beginningIndex, endingIndex];
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
                    
                    droppedFramesForStimulusType = [100*length(droppedFrames)/(rangeIndices(2) - rangeIndices(1)), droppedFramesForStimulusType];
                    
                    % make blinks over time binary vector
                    newTimebase = 0:1/60:20;
                    
                    blinkVector = zeros(1, length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase))';
                    blinkVector(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.blinkIndices) = 1;
                    blinksVectorAcrossTrials(end+1,:) = interp1(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.originalTimebase,blinkVector,newTimebase,'linear');
                end
            end
            
            % save out average results for all trials of the same stimulus
            % type
            droppedFramesMeanStruct.(groupLabel).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean(droppedFramesForStimulusType);
            
            blinksOverTime.(groupLabel).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){end+1} = blinksVectorAcrossTrials;
            
        end
    end
end

% save out results
if p.Results.saveOutput
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', p.Results.saveName, 'droppedFramesResults.mat'), 'droppedFramesMeanStruct');
end
%% Do some summary plotting
if p.Results.makePlots
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
    
    if strcmp(p.Results.range, 'pulse') || strcmp(p.Results.range, 'shiftedPulse')
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

%% working on thi spart
% response over time analysis
if p.Results.runResponseOverTime
    for group = 1:length(groups)
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                nSubjects = length(blinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                
                for ss = 1:nSubjects
                    
                    subjectMeanResponse = nanmean(blinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){ss});
                    meanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){ss} = subjectMeanResponse;
                    
                    smoothedTimebase = 0:0.1:17.5;
                    STDWindowSizeInMSecs = 500;
                    STDWindowSizeInIndices = 60 * STDWindowSizeInMSecs/1000;
                    
                    smoothedSubjectMeanResponse = [];
                    for timepoint = smoothedTimebase
                        
                        [~, timepointIndex ]  = min(abs(newTimebase-timepoint));
                        if timepointIndex - floor(STDWindowSizeInIndices/2) < 1 || timepointIndex + floor(STDWindowSizeInIndices/2) > length(newTimebase)
                            smoothedSubjectMeanResponse(end+1) = NaN;
                            
                        else
                            smoothedSubjectMeanResponse(end+1) = nanmean(subjectMeanResponse((timepointIndex-floor(STDWindowSizeInIndices/2)):(timepointIndex+floor(STDWindowSizeInIndices/2))));
                            
                        end
                        
                        
                    end
                    
                    smoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:) = smoothedSubjectMeanResponse;
                end
            end
        end
    end
    
    for group = 1:length(groups)
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                groupSmoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = nanmean(            smoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                %smoothedMeanBlinksOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])
                
            end
        end
    end
end

if p.Results.makePlots
    plotFig = figure;
    groups = {'controls', 'mwa', 'mwoa'};
    colorToPlot = {'k', 'b', 'r'};
    for contrast = 1:length(contrasts)
        subplot(1,3,contrast); hold on;
        for group = 1:length(groups)
            title(['Contrast ', num2str(contrasts{contrast}), '%']);
            meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]) = (smoothedMeanBlinksOverTime.(groups{group}).LightFlux.(['Contrast', num2str(contrasts{contrast})])+smoothedMeanBlinksOverTime.(groups{group}).LMS.(['Contrast', num2str(contrasts{contrast})])+smoothedMeanBlinksOverTime.(groups{group}).Melanopsin.(['Contrast', num2str(contrasts{contrast})]))./3;
            
            groupMean = nanmean(meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]),1);
            groupSEM = nanstd(meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(20);
            %ax.(['ax', num2str(group)]) = plot(timebase, groupMean, 'Color', colorToPlot{group});
            lineProps.col = [];
            lineProps.col{1} = colorToPlot{group};
            ax.(['ax', num2str(group)]) = mseb(smoothedTimebase, groupMean, groupSEM, lineProps, 1);
        end
        ylim([0 0.5]);
        yticks([0 0.25 0.5]);
        yticklabels({'0%', '25%', '50%'});
        ylabel('% Trials with Blink');
        xlim([0 17]);
        xticks([0 5 10 15])
        xticklabels([0 5 10 15])
        xlabel('Time (s)');
        
        if contrast == 3
            legend('Controls', 'MwA', 'MwoA', 'Location', 'NorthEast');
            legend('boxoff');
        end
        
    end
    
    set(gcf, 'Position', [52 529 1375 269], 'DefaultFigureRenderer', 'painters');
    export_fig(gcf, fullfile('~/Desktop', 'blinksOverTime_collapsedAcrossStimuli.pdf'));
    set(gcf, 'Renderer', 'painters');
    print(gcf, '-dpdf', '~/Desktop/blinks_responseOverTime_byGroup_collapsedAcrossStimuli.pdf', '-bestfit');
    
end



end