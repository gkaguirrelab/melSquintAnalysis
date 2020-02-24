subjectStruct = getDeuteranopeSubjectStruct;
stimuli = {'LightFlux', 'Melanopsin',  'LS'};

%% Summarize pupillometry
fitType = 'radiusSmoothed';
saveNameSuffix = '';

experiments = 1:2;
subjectIndices = 1:5;
subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(1)]));

runMakeSubjectAverageResponses = false;

 for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                meanPupilResponse.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            end
 end

for experiment = experiments
    experimentName = ['experiment_', num2str(experiment)];
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = subjectIndices
        subjectID = subjectIDs{ss};
        if runMakeSubjectAverageResponses

            makeSubjectAverageResponses(subjectID, 'experimentName', experimentName, 'stimuli', stimuli, 'contrasts', contrasts, 'Protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes','blinkBufferFrames', [3 6], 'saveNameSuffix', saveNameSuffix, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectID), 'fitLabel', fitType)
            load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));

        else
            load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));
        end
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                meanPupilResponse.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            end
        end
        
    end
end

% Compare 400% responses in high and low contrast sessions
resampledTimebase = 0:1/60:18.5;
pulseOnset = 1.5;
pulseOffset = 5.5;
plotShift = 1;
nTimePointsToSkipPlotting = 40;
yLims = [-0.8 0.3];
xLims = [0 17];

plotFig = figure;

for stimulus = 1:length(stimuli)
    
    experiment1PupilResponse = nanmean(meanPupilResponse.experiment_1.(stimuli{stimulus}).Contrast400);
    experiment2PupilResponse = nanmean(meanPupilResponse.experiment_2.(stimuli{stimulus}).Contrast400);

    experiment1SEM = nanstd(meanPupilResponse.experiment_1.(stimuli{stimulus}).Contrast400)./sqrt(size(meanPupilResponse.experiment_1.(stimuli{stimulus}).Contrast400,1));
    experiment2SEM = nanstd(meanPupilResponse.experiment_2.(stimuli{stimulus}).Contrast400)./sqrt(size(meanPupilResponse.experiment_2.(stimuli{stimulus}).Contrast400,1));

    
    subplot(1,3,stimulus); hold on;
    
    % make thicker plot lines
            lineProps.width = 1;
            transparent = 1;
            
            % adjust color
    lineProps.col{1} = 'k';    
    axis.ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment1PupilResponse(1:end-nTimePointsToSkipPlotting), experiment1SEM(1:end-nTimePointsToSkipPlotting), lineProps, transparent);
    
    lineProps.col{1} = 'r';
    axis.ax2 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment2PupilResponse(1:end-nTimePointsToSkipPlotting), experiment2SEM(1:end-nTimePointsToSkipPlotting), lineProps, transparent);

    %plot(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment1PupilResponse(1:end-nTimePointsToSkipPlotting), 'Color', 'k');
    %plot(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift,experiment2PupilResponse(1:end-nTimePointsToSkipPlotting), 'Color', 'r');
    
    if stimulus == 3
       legend('Low Contrast Experiment', 'High Contrast Experiment') 
    end
    xlim(xLims);
    ylim(yLims);
    
    title(stimuli{stimulus});
    
end



%% Summarize discomfort ratings

fileName = 'audioTrialStruct_final.mat';
discomfort = [];

% pre-allocate results variable
for experiment = 1:2
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
    end
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            discomfort.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
        
    end
end

% pool results
for experiment = 1:2
    experimentName = ['experiment_', num2str(experiment)];
    subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = 1:5
        analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles/', subjectIDs{ss}, ['experiment_', num2str(experiment)]);
        load(fullfile(analysisBasePath, fileName));
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                discomfort.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            end
        end
        
    end
end

% plot results
for experiment = 1:2
    discomfortRating.Controls = discomfort.(['experiment', num2str(experiment)]);
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'deuteranopes');
    plotSpreadResults(discomfortRating, 'stimuli', stimuli, 'contrasts', contrasts, 'saveName', fullfile(savePath, ['groupSummary_experiment', num2str(experiment), '.pdf']))
    
    
end

plotFig = figure; 
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    data = [discomfort.experiment1.(stimuli{stimulus}).Contrast100; discomfort.experiment1.(stimuli{stimulus}).Contrast200; discomfort.experiment1.(stimuli{stimulus}).Contrast400];
    plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
    plot([log10(100), log10(200), log10(400)], [median(discomfort.experiment1.(stimuli{stimulus}).Contrast100), median(discomfort.experiment1.(stimuli{stimulus}).Contrast200), median(discomfort.experiment1.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
    experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(discomfort.experiment1.(stimuli{stimulus}).Contrast100), median(discomfort.experiment1.(stimuli{stimulus}).Contrast200), median(discomfort.experiment1.(stimuli{stimulus}).Contrast400)], 'Color', 'k');

    
    data = [discomfort.experiment2.(stimuli{stimulus}).Contrast400; discomfort.experiment2.(stimuli{stimulus}).Contrast800; discomfort.experiment2.(stimuli{stimulus}).Contrast1200];
    plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
    plot([log10(400), log10(800), log10(1200)], [median(discomfort.experiment2.(stimuli{stimulus}).Contrast400), median(discomfort.experiment2.(stimuli{stimulus}).Contrast800), median(discomfort.experiment2.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
    experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(discomfort.experiment2.(stimuli{stimulus}).Contrast400), median(discomfort.experiment2.(stimuli{stimulus}).Contrast800), median(discomfort.experiment2.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');

    
    xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
    xticklabels({'100%', '200%', '400%', '800%', '1200%'});
    xtickangle(45);
    xlabel('Contrast')
    
    ylim([-0.5 10]);
    ylabel('Discomfort Rating')
    
    if stimulus == 3
       legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2'); 
       legend('boxoff')
    end
end
set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(savePath, 'combinedExperimentsSummary.pdf'));

%% Summarize EMG
fileName = 'audioTrialStruct_final.mat';
RMS = [];
normalize = false;

% pre-allocate results variable
for experiment = 1:2
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
    end
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            RMS.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
        
    end
end

% pool results
for experiment = 1:2
    experimentName = ['experiment_', num2str(experiment)];
    subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    for ss = 1:5

        medianStruct = calculateRMSforEMG(subjectIDs{ss}, 'experimentName', ['experiment_', num2str(experiment)], 'protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes', 'stimuli', stimuli, 'makePlots', true, 'contrasts', contrasts, 'normalize', normalize, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectIDs{ss}));
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                RMS.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_median']).left, medianStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_median']).right]);
            end
        end
        
    end
end

% plot results
if normalize
    yLims = [-0.5 1];
else
    yLims = [0.5 3];
end
for experiment = 1:2
    RMSForPlotting.Controls = RMS.(['experiment', num2str(experiment)]);
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'Deuteranopes');
    if normalize
        saveNameSuffix = '_normalized';
    else
        saveNameSuffix = [];
    end
    plotSpreadResults(RMSForPlotting, 'stimuli', stimuli, 'contrasts', contrasts, 'saveName', fullfile(savePath, ['groupSummary_experiment', num2str(experiment), saveNameSuffix, '.pdf']), 'yLims', yLims)
    
    
end

plotFig = figure; 
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    data = [RMS.experiment1.(stimuli{stimulus}).Contrast100; RMS.experiment1.(stimuli{stimulus}).Contrast200; RMS.experiment1.(stimuli{stimulus}).Contrast400];
    plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
    plot([log10(100), log10(200), log10(400)], [median(RMS.experiment1.(stimuli{stimulus}).Contrast100), median(RMS.experiment1.(stimuli{stimulus}).Contrast200), median(RMS.experiment1.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
    experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(RMS.experiment1.(stimuli{stimulus}).Contrast100), median(RMS.experiment1.(stimuli{stimulus}).Contrast200), median(RMS.experiment1.(stimuli{stimulus}).Contrast400)], 'Color', 'k');

    
    data = [RMS.experiment2.(stimuli{stimulus}).Contrast400; RMS.experiment2.(stimuli{stimulus}).Contrast800; RMS.experiment2.(stimuli{stimulus}).Contrast1200];
    plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
    plot([log10(400), log10(800), log10(1200)], [median(RMS.experiment2.(stimuli{stimulus}).Contrast400), median(RMS.experiment2.(stimuli{stimulus}).Contrast800), median(RMS.experiment2.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
    experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(RMS.experiment2.(stimuli{stimulus}).Contrast400), median(RMS.experiment2.(stimuli{stimulus}).Contrast800), median(RMS.experiment2.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');

    
    xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
    xticklabels({'100%', '200%', '400%', '800%', '1200%'});
    xtickangle(45);
    xlabel('Contrast')
    
    ylim(yLims);
    ylabel('Discomfort Rating')
    
    if stimulus == 3
       legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2'); 
       legend('boxoff')
    end
end
set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(savePath, ['combinedExperimentsSummary', saveNameSuffix, '.pdf']));

