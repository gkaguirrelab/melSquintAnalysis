%% summarizePupilByGroup.m
% This routine is intended to produce the summary plots for the
% pupillometry data collected in the squint study. The main purpose is to
% produce the three figures we intend to use in the initial squint paper.

paperDir = '~/Desktop';

%% Load up the pupil responses
[ pupilResponses, subjectIDsStruct ] = loadPupilResponses;

%% Figure 4a. Group average pupil responses over time by stimulus condition and contrast level
close all;

% define some experimental conditions
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
groups = {'controls', 'mwa', 'mwoa'};
colorToPlot = {'k', 'b', 'r'};

% basic plotting parameters
initialPlotPointsToCensor = 40;
endingPlotPointsToCensor = 40;
timebase = 0:1/60:18.5;


% do the plotting
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        cellNumber = ((stimulus-1)*3)+contrast;
        subplot(3,3,cellNumber); hold on;
        for group = 1:length(groups)
            title([stimuli{stimulus}, ' Contrast ', num2str(contrasts{contrast}), '%']);
            groupMean = nanmean(pupilResponses.responseOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            ax.(['ax', num2str(group)]) = plot(timebase(initialPlotPointsToCensor:end-endingPlotPointsToCensor)-1, groupMean(initialPlotPointsToCensor:end-endingPlotPointsToCensor), 'Color', colorToPlot{group});
            
        end
        ylim([-0.8 0.1]);
        yticks([-0.5 0]);
        yticklabels({'50%', '0%'});
        ylabel('Pupil Area (% Change from Baseline)');
        xlim([0 17]);
        xticks([0 5 10 15])
        xticklabels([0 5 10 15])
        xlabel('Time (s)');
        
        if cellNumber == 3
            legend('Controls', 'MwA', 'MwoA', 'Location', 'SouthEast');
            legend('boxoff');
        end
        
    end
end

set(gcf, 'Position', [440 86 987 712]);
export_fig(gcf, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'contrastXstimulus_byGroup.pdf'))

%% Figure 4b and c. Fitting pupil response amplitude with two-stage model 
[figHandle1, figHandle2] = fitTwoStageModel('modality','pupil','rngSeed',1000);
export_fig(figHandle2, fullfile(paperDir, '4b.pdf'));
export_fig(figHandle1, fullfile(paperDir, '4c.pdf'));

%% Supplementary Figure 1
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
groups = {'controls', 'mwa', 'mwoa'};

[ slope, intercept, meanRating ] = fitLineToResponseModality('pupil', 'makePlots', false, 'makeCSV', false, 'responseMetric', 'normalizedAUC');

x = [log10(100), log10(200), log10(400)];

counter = 1;
[ha, pos] = tight_subplot(3,3, 0.04);

for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
        end
        
        
        axes(ha(counter)); hold on;
        result = pupilResponses.normalizedAUC.([groups{group}]);
        data = [result.(stimuli{stimulus}).Contrast100; result.(stimuli{stimulus}).Contrast200; result.(stimuli{stimulus}).Contrast400];
        
        plotSpread(data', 'xValues', x, 'xNames', {'100%', '200%', '400%'}, 'distributionColors', color)
        set(findall(gcf,'type','line'),'markerSize',13)
        
        
        if group  == 1
            if stimulus == 1
                ylabel({'{\bf\fontsize{15} Light Flux}'; 'Amplitude of Constriction'})
            elseif stimulus == 2
                ylabel({'{\bf\fontsize{15} Melanopsin}'; 'Amplitude of Constriction'})
                
            elseif stimulus == 3
                ylabel({'{\bf\fontsize{15} LMS}'; 'Amplitude of Constriction'})
                
            end
            
            
            yticks([0, 0.25, 0.5]);
            yticklabels({'0' '25%' '50%'});
        end
        ylim([0 0.5]);
        yticks([0, 0.25, 0.5]);
        
        counter = counter + 1;
        
        
        
    end
end

% add titles to the columns
axes(ha(1));
title({'\fontsize{15} Controls'});
axes(ha(2));
title({'\fontsize{15} MwA'});
axes(ha(3));
title({'\fontsize{15} MwoA'});


% add means
counter = 1;
for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
        end
        
        axes(ha(counter)); hold on;
        result = pupilResponses.normalizedAUC.([groups{group}]);
        
        plot(x, [mean(result.(stimuli{stimulus}).Contrast100), mean(result.(stimuli{stimulus}).Contrast200), mean(result.(stimuli{stimulus}).Contrast400)], '.', 'Color', color, 'MarkerSize', 25)
        counter = counter + 1;
    end
end

% add line fits
counter = 1;
for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
            groupName = 'controls';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
            groupName = 'mwa';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
            groupName = 'mwoa';
        end
        y = x*mean(slope.(groupName).(stimuli{stimulus})) + mean(intercept.(groupName).(stimuli{stimulus}));
        axes(ha(counter)); hold on;
        plot(x,y, 'Color', color)
        counter = counter + 1;
        
        
    end
end



% to make the markers transparent. for whatever reason, the effect doesn't
% stick so you have to run it manually?
drawnow()
test = findall(gcf,'type','line');
for ii = 1:length(test)
    if strcmp(test(ii).DisplayName, '100%') ||  strcmp(test(ii).DisplayName, '200%') ||  strcmp(test(ii).DisplayName, '400%')
        hMarkers = [];
        hMarkers = test(ii).MarkerHandle;
        hMarkers.EdgeColorData(4) = 75;
    end
end
set(gcf, 'Position', [600 558 1060 620]);
set(gcf, 'Renderer', 'painters');

export_fig(gcf, fullfile(paperDir, '4a.pdf'));


%% BONUS FIGURES:
% What follows is some related summary figures that I made at one point,
% and although might be useful again eventually, are not going to end up in
% the immediate squint paper. Leaving here for posterity, but running this
% routine with default settings will not produce the plots below.

makeBonusPlots = false;

if makeBonusPlots
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); ...
                pupilResponses.responseOverTime.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); ...
                pupilResponses.responseOverTime.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            
            groupAveragePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = nanmean(combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            groupAveragePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = (nanstd(combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])))/(sqrt(size(combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1)));
        end
    end
    
    plotFig = figure;
    nStimuli = length(stimuli);
    nContrasts = length(contrasts);
    
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
    
    % plotting params
    timebase = 0:1/60:18.5;
    pulseOnset = 1.5;
    pulseOffset = 5.5;
    plotShift = 1;
    yLims = [-0.8 0.1];
    xLims = [0 17];
    nTimePointsToSkipPlotting = 40;
    
    for ss = 1:nStimuli
        
        % pick the right subplot for the right stimuli
        subplot(nStimuli,1,ss)
        title(stimuli{ss})
        hold on
        
        for cc = 1:nContrasts
            
            % make thicker plot lines
            lineProps.width = 1;
            
            % adjust color
            lineProps.col{1} = colorPalette.(stimuli{ss}){cc};
            
            % plot
            axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]);
            
        end
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
        
        % add line for pulse onset
        line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
        
        % spruce up axes
        ylim(yLims)
        xlim(xLims)
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)')
        
    end
    
    print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', 'combinedGroupAverage_radiusSmoothed.pdf'), '-dpdf', '-fillpage')
    save(fullfile(resultsDir, 'combinedGroupAverageResponse_radiusSmoothed.mat'), 'groupAveragePupilResponses')
    
    % Plot average response by group
    groupAveragePupilResponses= [];
    stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
    for groupNumber = 1:4
        if groupNumber == 1
            pooledResponses = pupilResponses.responseOverTime.controls;
            color = 'k';
            groupName = 'Control';
        elseif groupNumber == 2
            pooledResponses = pupilResponses.responseOverTime.mwoa;
            color = 'r';
            groupName = 'MwoA';
        elseif groupNumber == 3
            pooledResponses = pupilResponses.responseOverTime.mwa;
            color = 'b';
            groupName = 'MwA';
        elseif groupNumber == 4
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [pupilResponses.responseOverTime.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); pupilResponses.responseOverTime.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
                end
            end
            combinedMigrainePupilResponses = pooledResponses;
            color = 'r';
            groupName = 'CombinedMigraine';
        end
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                groupAveragePupilResponses.(groupName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = nanmean(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                groupAveragePupilResponses.(groupName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = (nanstd(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])))/(sqrt(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1)));
            end
        end
        
        plotFig = figure; hold on;
        nStimuli = length(stimuli);
        nContrasts = length(contrasts);
        
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
        
        % plotting params
        timebase = 0:1/60:18.5;
        pulseOnset = 1.5;
        pulseOffset = 5.5;
        plotShift = 1;
        
        xLims = [0 17];
        nTimePointsToSkipPlotting = 40;
        
        [ha, pos] = tight_subplot(nStimuli,1, 0.01);
        
        
        for ss = 1:nStimuli
            if ss == 1
                yLims = [-0.4 0.3];
                
            elseif ss == 2
                yLims = [-0.65 0.05];
                
            elseif ss == 3
                yLims = [-0.675 0.025];
            end
            % pick the right subplot for the right stimuli
            %subplot(nStimuli,1,ss)
            axes(ha(ss)); hold on;
            title(stimuli{ss})
            hold on
            
            for cc = 1:nContrasts
                
                % make thicker plot lines
                lineProps.width = 1;
                
                % adjust color
                lineProps.col{1} = colorPalette.(stimuli{ss}){cc};
                
                % plot
                axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.(groupName).(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.(groupName).(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
                
                legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]);
                
            end
            
            legend(legendText, 'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            if ss == 1
                line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            end
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            
        end
        set(ha(1:3),'XTickLabel',''); set(ha(1:3),'YTickLabel','')
        export_fig(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [groupName, '_averageResponse_unstretched.pdf']), '-painters')
        print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [groupName, '_averageResponse.pdf']), '-dpdf', '-fillpage')
        close all
        
        
        
        
        
    end
    
    for ss = 1:length(stimuli)
        for cc = 1:length(contrasts)
            
            % plotting each migraine group seprately
            plotFig = figure; hold on;
            
            lineProps.col{1} = 'k';
            axis.Controls = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'r';
            axis.MwoA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'b';
            axis.MwA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legend({['Controls, N = ', num2str(size(pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(pupilResponses.responseOverTime.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(pupilResponses.responseOverTime.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            title([stimuli{ss}, ', ', num2str(contrasts{cc}), '% Contrast']);
            
            print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [stimuli{ss}, 'Contrast', num2str(contrasts{cc}), '_averageResponse.pdf']), '-dpdf', '-fillpage')
            close all
            
            
            % plotting both migraine groups together
            plotFig = figure; hold on;
            
            lineProps.col{1} = 'k';
            axis.Controls = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'r';
            axis.MwoA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legend({['Controls, N = ', num2str(size(pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['Combined Migraine, N = ', num2str(size(combinedMigrainePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]},  'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            title([stimuli{ss}, ', ', num2str(contrasts{cc}), '% Contrast']);
            
            
            print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [stimuli{ss}, 'Contrast', num2str(contrasts{cc}), '_combinedMigraineurs_averageResponse.pdf']), '-dpdf', '-fillpage')
            close all
            
            
            
            
        end
    end
    
    % Plots comparing pupil constriciton between groups, this time no SEM
    for ss = 1:length(stimuli)
        for cc = 1:length(contrasts)
            
            % plotting each migraine group seprately
            plotFig = figure; hold on;
            
            lineProps.col{1} = 'k';
            axis.Controls = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'r';
            axis.MwoA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'b';
            axis.MwA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legend({['Controls, N = ', num2str(size(pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(pupilResponses.responseOverTime.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(pupilResponses.responseOverTime.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            title([stimuli{ss}, ', ', num2str(contrasts{cc}), '% Contrast']);
            
            print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [stimuli{ss}, 'Contrast', num2str(contrasts{cc}), '_averageResponse_noSEM.pdf']), '-dpdf', '-fillpage')
            close all
            
            
            % plotting both migraine groups together
            plotFig = figure; hold on;
            
            lineProps.col{1} = 'k';
            axis.Controls = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'r';
            axis.MwoA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legend({['Controls, N = ', num2str(size(pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['Combined Migraine, N = ', num2str(size(combinedMigrainePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]},  'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            title([stimuli{ss}, ', ', num2str(contrasts{cc}), '% Contrast']);
            
            
            print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', [stimuli{ss}, 'Contrast', num2str(contrasts{cc}), '_combinedMigraineurs_averageResponse_noSEM.pdf']), '-dpdf', '-fillpage')
            close all
            
            
            
            
        end
    end
    
    % Plotting pupil constriction by group, but comparing stimuli across subplots
    
    for cc = 1:length(contrasts)
        plotFig = figure;
        for ss = 1:length(stimuli)
            
            subplot(1,3,ss)
            % plotting each migraine group seprately
            
            lineProps.col{1} = 'k';
            axis.Controls = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'r';
            axis.MwoA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            lineProps.col{1} = 'b';
            axis.MwA = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legend({['Controls, N = ', num2str(size(pupilResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(pupilResponses.responseOverTime.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(pupilResponses.responseOverTime.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
            legend('boxoff')
            
            % add line for pulse onset
            line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
            
            % spruce up axes
            ylim(yLims)
            xlim(xLims)
            xlabel('Time (s)')
            ylabel('Pupil Area (% Change)')
            title([stimuli{ss}, ', ', num2str(contrasts{cc}), '% Contrast']);
            
            print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['Contrast', num2str(contrasts{cc}), '_averageResponse.pdf']), '-dpdf', '-fillpage')
            
            
            
            
            
            
        end
    end
    
    pupilAUC = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            pupilAUC.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.AUC.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            pupilAUC.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.AUC.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            pupilAUC.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.AUC.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        end
    end
    
    plotSpreadResults(pupilAUC, 'yLims', [-250 0], 'yLabel', 'AUC', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'AUC_groupAverage.pdf'))
    
    % Next by combine migraineurs
    pupilAUC = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            pupilAUC.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [pupilResponses.AUC.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), pupilResponses.AUC.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            pupilAUC.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.AUC.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        end
    end
    
    plotSpreadResults(pupilAUC, 'yLims', [-250, 0], 'yLabel', 'AUC', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'AUC_groupAverage_combinedMigraineurs.pdf'))
    
    
    
    
    
    % Fit TPUP to individual subject responses
    
   
    
    stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
    contrasts = {100, 200, 400};
    amplitudes = {'Transient', 'Sustained', 'Persistent'};
    
    
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            pupilResponses.percentPersistent.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pupilResponses.percentPersistent.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pupilResponses.percentPersistent.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            pupilResponses.amplitude.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pupilResponses.amplitude.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pupilResponses.amplitude.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end
    
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/TPUP/', ['TPUPParams_Contrast', num2str(contrasts{contrast}),  '.csv']);
                TPUPParamsTable = readtable(csvFileName);
                columnsNames = TPUPParamsTable.Properties.VariableNames;
                subjectRow = find(contains(TPUPParamsTable{:,1}, subjectIDs{ss}));
                
                transientAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'TransientAmplitude']));
                sustainedAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'SustainedAmplitude']));
                persistentAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'PersistentAmplitude']));
                
                transientAmplitude = TPUPParamsTable{subjectRow, transientAmplitudeColumn};
                sustainedAmplitude = TPUPParamsTable{subjectRow, sustainedAmplitudeColumn};
                persistentAmplitude = TPUPParamsTable{subjectRow, persistentAmplitudeColumn};
                
                percentPersistent = (persistentAmplitude)/(transientAmplitude + sustainedAmplitude + persistentAmplitude)*100;
                
                totalResponseAmplitude = (transientAmplitude + sustainedAmplitude + persistentAmplitude);
                
                if strcmp(group, 'c')
                    pupilResponses.percentPersistent.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    pupilResponses.amplitude.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                    
                elseif strcmp(group, 'mwa')
                    pupilResponses.percentPersistent.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    pupilResponses.amplitude.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                    
                    
                elseif strcmp(group, 'mwoa')
                    pupilResponses.percentPersistent.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    pupilResponses.amplitude.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                    
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
    end
    
    
    % plot percent persistent and total response amplitdue
    percentPersistent = [];
    totalResponseAmplitude = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            percentPersistent.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.percentPersistent.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            percentPersistent.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.percentPersistent.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.percentPersistent.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            
            totalResponseAmplitude.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.amplitude.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])*-1;
            totalResponseAmplitude.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.amplitude.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])*-1;
            totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.amplitude.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])*-1;
            
            
        end
    end
    
    plotSpreadResults(percentPersistent, 'contrasts', {100,200,400}, 'yLims', [-5 100], 'yLabel', 'Percent Persistent (%)', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'percentPersistentByGroup.pdf'))
    plotSpreadResults(totalResponseAmplitude, 'contrasts', {100,200,400}, 'yLims', [0 11], 'yLabel', 'Total Response Amplitude', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'totalResponseAmplitdueByGroup.pdf'))
    
    % combined migraineurs
    percentPersistent = [];
    totalResponseAmplitude = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            percentPersistent.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [pupilResponses.percentPersistent.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), pupilResponses.percentPersistent.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.percentPersistent.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            
            totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [pupilResponses.amplitude.mwa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), pupilResponses.amplitude.mwoa.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])].*-1;
            totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = pupilResponses.amplitude.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).*-1;
            
            
        end
    end
    
    plotSpreadResults(percentPersistent, 'contrasts', {100,200, 400}, 'yLims', [-5 100], 'yLabel', 'Percent Persistent (%)', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'percentPersistentByGroup_combinedMigraine.pdf'))
    plotSpreadResults(totalResponseAmplitude, 'contrasts', {100,200, 400}, 'yLims', [0 10], 'yLabel', 'Total Response Amplitude', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'totalResponseAmplitdueByGroup_combinedMigraine.pdf'))
    
    
end
