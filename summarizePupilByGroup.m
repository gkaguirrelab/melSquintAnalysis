dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% Pool pupil traces
controlPupilResponses = [];
mwaPupilResponses = [];
mwoaPupilResponses = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
    load(fullfile(resultsDir, [subjectIDs{ss}, '_trialStruct_radiusSmoothed.mat']));
    
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwoaSubjects{end+1} = subjectIDs{ss};
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end

mwaSubjects = unique(mwaSubjects);
mwoaSubjects = unique(mwoaSubjects);
controlSubjects = unique(controlSubjects);

%% Make combined group average response
% We'll use this combined group average response to set some TPUP
% parameters


for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); ...
            mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); ...
            mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        
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

%% Plot average response by group
groupAveragePupilResponses= [];
stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
for groupNumber = 1:4
    if groupNumber == 1
        pooledResponses = controlPupilResponses;
        color = 'k';
        groupName = 'Control';
    elseif groupNumber == 2
        pooledResponses = mwoaPupilResponses;
        color = 'r';
        groupName = 'MwoA';
    elseif groupNumber == 3
        pooledResponses = mwaPupilResponses;
        color = 'b';
        groupName = 'MwA';
    elseif groupNumber == 4
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
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
        
        legend({['Controls, N = ', num2str(size(controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
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
        
        legend({['Controls, N = ', num2str(size(controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['Combined Migraine, N = ', num2str(size(combinedMigrainePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]},  'Location', 'SouthEast')
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

%% Plots comparing pupil constriciton between groups, this time no SEM
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
        
        legend({['Controls, N = ', num2str(size(controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
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
        
        legend({['Controls, N = ', num2str(size(controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['Combined Migraine, N = ', num2str(size(combinedMigrainePupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]},  'Location', 'SouthEast')
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

%% Plotting pupil constriction by group, but comparing stimuli across subplots

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
        
        legend({['Controls, N = ', num2str(size(controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))],['MwoA, N = ', num2str(size(mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))], ['MwA, N = ', num2str(size(mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1))]}, 'Location', 'SouthEast')
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

%% Summarize response amplitude as area under the curve

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
        
    end
end





group = linkMELAIDToGroup(subjectIDs{ss});

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        for group = 1:3
            if group == 1
                pupilResponses = controlPupilResponses;
            elseif group == 2
                pupilResponses = mwoaPupilResponses;
            elseif group == 3
                pupilResponses = mwaPupilResponses;
            end
            AUC = [];
            for ss = 1:size(pupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1)
                pupilResponse = pupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:);
                pupilResponse = pupilResponse(~isnan(pupilResponse));
                AUC(ss) = trapz(pupilResponse);
                
            end
            
            if group == 1
                controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = AUC;
            elseif group == 2
                mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = AUC;
            elseif group == 3
                mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = AUC;
            end
            
        end
    end
end

pupilAUC = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        pupilAUC.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        pupilAUC.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        pupilAUC.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(pupilAUC, 'yLims', [-250 0], 'yLabel', 'AUC', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'AUC_groupAverage.pdf'))

% Next by combine migraineurs
pupilAUC = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        pupilAUC.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        pupilAUC.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(pupilAUC, 'yLims', [-250, 0], 'yLabel', 'AUC', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'AUC_groupAverage_combinedMigraineurs.pdf'))





%% Fit TPUP to individual subject responses

[ modeledResponses ] = fitTPUP('group');
persistentGamma = modeledResponses.Melanopsin.params.paramMainMatrix(3);

summarizeTPUP(subjectIDs, persistentGamma);

%% Load up percent persisten by group


controlPercentPersistent = [];
mwaPercentPersistent = [];
mwoaPercentPersistent = [];

stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
amplitudes = {'Transient', 'Sustained', 'Persistent'};



for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
        controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
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
                controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
            elseif strcmp(group, 'mwa')
                mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
                
            elseif strcmp(group, 'mwoa')
                mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
end


%% plot percent persistent and total response amplitdue
percentPersistent = [];
totalResponseAmplitude = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        percentPersistent.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        percentPersistent.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        
        totalResponseAmplitude.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        totalResponseAmplitude.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        
        
    end
end

plotSpreadResults(percentPersistent, 'contrasts', {100,200,400}, 'yLims', [-5 100], 'yLabel', 'Percent Persistent (%)', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'percentPersistentByGroup.pdf'))
plotSpreadResults(totalResponseAmplitude, 'contrasts', {100,200,400}, 'yLims', [-11 0], 'yLabel', 'Total Response Amplitude', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'totalResponseAmplitdueByGroup.pdf'))

% combined migraineurs
percentPersistent = [];
totalResponseAmplitude = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        percentPersistent.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        
        totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])].*-1;
        totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).*-1;
        
        
    end
end

plotSpreadResults(percentPersistent, 'contrasts', {100,200, 400}, 'yLims', [-5 100], 'yLabel', 'Percent Persistent (%)', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'percentPersistentByGroup_combinedMigraine.pdf'))
plotSpreadResults(totalResponseAmplitude, 'contrasts', {100,200, 400}, 'yLims', [0 10], 'yLabel', 'Total Response Amplitude', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'totalResponseAmplitdueByGroup_combinedMigraine.pdf'))


