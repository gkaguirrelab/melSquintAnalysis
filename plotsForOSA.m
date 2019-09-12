%% control individuals perceive increased contrast light flux stimuli as
% more uncomfortable

dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

controlDiscomfort = [];
mwaDiscomfort = [];
mwoaDiscomfort = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};



for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(analysisBasePath, fileName));
                controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            elseif strcmp(group, 'mwa')
                load(fullfile(analysisBasePath, fileName));
                mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                
            elseif strcmp(group, 'mwoa')
                load(fullfile(analysisBasePath, fileName));
                mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end


discomfortRatings = [];
stimuli = {'LightFlux'};
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        %discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        %discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings,  'stimuli', stimuli, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'controls_lightFlux.pdf'))

%% controls find all stimulus types increasingly uncomfortable with more contrast
discomfortRatings = [];
stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        %discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        %discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings,  'stimuli', stimuli, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'controls_allStimuli.pdf'))

%% comparing migaineurs to headache free controls
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
    for cc = 3
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.LMS{cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        lineProps.col{1} = [.5 0 .5];
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        
        legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(400)]),1))]);
        
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
    end
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
export_fig(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareCombinedMigrainuersAndControls_unstretched.pdf']), '-painters')
print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareCombinedMigrainuersAndControls.pdf']), '-dpdf', '-fillpage')
close all

plotFig = figure; hold on;
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
    for cc = 3
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.LMS{cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        lineProps.col{1} = 'r';
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        
        lineProps.col{1} = 'b';
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);

        
        legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(400)]),1))]);
        
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
    end
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
export_fig(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareMigraineGroupsAndControls_unstretched.pdf']), '-painters')
print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareMigraineGroupsAndControls.pdf']), '-dpdf', '-fillpage')
close all

% same plots, without SEM
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
    for cc = 3
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.LMS{cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        lineProps.col{1} = [.5 0 .5];
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.CombinedMigraine.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        
        legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(400)]),1))]);
        
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
    end
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
export_fig(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareCombinedMigrainuersAndControls_unstretched_noSEM.pdf']), '-painters')
print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareCombinedMigrainuersAndControls_noSEM.pdf']), '-dpdf', '-fillpage')
close all

plotFig = figure; hold on;
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
    for cc = 3
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.LMS{cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.Control.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        lineProps.col{1} = 'r';
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.MwoA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);
        
        lineProps.col{1} = 'b';
        axis.(['ax', num2str(cc)]) = mseb(timebase(1:end-nTimePointsToSkipPlotting)-plotShift, groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), 0*groupAveragePupilResponses.MwA.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps, 1);

        
        legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledResponses.(stimuli{stimulus}).(['Contrast', num2str(400)]),1))]);
        
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
    end
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
export_fig(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareMigraineGroupsAndControls_unstretched_noSEM.pdf']), '-painters')
print(plotFig, fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'averageResponsePlots', ['compareMigraineGroupsAndControls_noSEM.pdf']), '-dpdf', '-fillpage')
close all

