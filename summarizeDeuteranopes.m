subjectStruct = getDeuteranopeSubjectStruct;
stimuli = {'LightFlux', 'Melanopsin',  'LS'};

%% Summarize pupillometry
fitType = 'radiusSmoothed';
saveNameSuffix = '';

experiments = 1:2;
subjectIndices = 1:5;
subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(1)]));

runMakeSubjectAverageResponses = false;

for experiment = experiments
    experimentName = ['experiment_', num2str(experiment)];
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            subjectAveragePupilResponses.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
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
                subjectAveragePupilResponses.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            end
        end
        
    end
end

% make group average response for all stimulus types
for experiment = experiments
    experimentName = ['experiment_', num2str(experiment)];
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            groupAveragePupilResponses.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = nanmean(subjectAveragePupilResponses.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
        end
    end
end

save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes','combinedGroupAverageResponse_radiusSmoothed.mat'), 'groupAveragePupilResponses', '-v7.3');

%% Compare 400% responses in high and low contrast sessions
resampledTimebase = 0:1/60:18.5;
pulseOnset = 1.5;
pulseOffset = 5.5;
plotShift = 1;
nTimePointsToSkipPlotting = 40;
yLims = [-0.8 0.3];
xLims = [0 17];

plotFig = figure;

for stimulus = 1:length(stimuli)
    
    experiment1PupilResponse = nanmean(subjectAveragePupilResponses.experiment_1.(stimuli{stimulus}).Contrast400);
    experiment2PupilResponse = nanmean(subjectAveragePupilResponses.experiment_2.(stimuli{stimulus}).Contrast400);

    experiment1SEM = nanstd(subjectAveragePupilResponses.experiment_1.(stimuli{stimulus}).Contrast400)./sqrt(size(subjectAveragePupilResponses.experiment_1.(stimuli{stimulus}).Contrast400,1));
    experiment2SEM = nanstd(subjectAveragePupilResponses.experiment_2.(stimuli{stimulus}).Contrast400)./sqrt(size(subjectAveragePupilResponses.experiment_2.(stimuli{stimulus}).Contrast400,1));

    
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
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change from Baseline)');
    
end

% thoughts on this plot: there seems to bee a consistent reduction in amplitude
% of constriction to 400% contrast in the high contrast, as compared with
% th low contrast sessions

% to explain whether this difference is due to a DECREASE in constriction
% in the high contrast session or an INCREASE in the low contrast session,
% let's compare to controls from the squint study

%% Compare 400% between high and low contrast sessions with the squint study 400% results
deuteranopeResults = load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes','combinedGroupAverageResponse_radiusSmoothed.mat')); 
migraineResults = load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs', 'averageResponsesByGroup.mat'), 'groupAveragePupilResponses');
deuteranopeResults.groupAveragePupilResponses.experiment_1.LMS = deuteranopeResults.groupAveragePupilResponses.experiment_1.LS;
deuteranopeResults.groupAveragePupilResponses.experiment_2.LMS = deuteranopeResults.groupAveragePupilResponses.experiment_2.LS;


resampledTimebase = 0:1/60:18.5;
pulseOnset = 1.5;
pulseOffset = 5.5;
plotShift = 1;
nTimePointsToSkipPlotting = 40;
yLims = [-0.8 0.3];
xLims = [0 17];

plotFig = figure;

migraineStimuli = {'LightFlux', 'Melanopsin', 'LMS'};
for stimulus = 1:length(migraineStimuli)
    subplot(1,3, stimulus); hold on;
    experiment1PupilResponse = deuteranopeResults.groupAveragePupilResponses.experiment_1.(migraineStimuli{stimulus}).Contrast400;
    experiment2PupilResponse = deuteranopeResults.groupAveragePupilResponses.experiment_2.(migraineStimuli{stimulus}).Contrast400;
    migrainePupilResponse = migraineResults.groupAveragePupilResponses.Control.(migraineStimuli{stimulus}).Contrast400;
    
    plot(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment1PupilResponse(1:end-nTimePointsToSkipPlotting), 'Color', 'k');
    plot(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment2PupilResponse(1:end-nTimePointsToSkipPlotting), 'Color', 'r');
    plot(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, migrainePupilResponse(1:end-nTimePointsToSkipPlotting), 'Color', 'b');

    if stimulus == 3
       legend('Low Contrast Experiment', 'High Contrast Experiment', 'Squint Experiment') 
    end
    xlim(xLims);
    ylim(yLims);
    
    title(migraineStimuli{stimulus});
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change from Baseline)');
    
    
end

% Thoughts: If we include all subjects, the amount of constriction is less
% for both high and low contrast sessions -- consistent with some weird
% notion that deuteranopes constrict less across the board, and we have no
% idea why we're constricting less in high contrast sessions

% However, if we remove one subject who had strikingly reduced pupil
% constrction relative to everyone else, the low contrast sessions behave
% quite similarly to the control study run previously -- as expected
% because the stimuli are essentially the same!
% This analysis suggests we have one weirdo, but ignoring him for now, the
% pupil constriction is attenuated relative to normal in high contrast
% sessions
%% Fit TPUP to all subject averages
for experiment = experiments
    experimentName = ['experiment_', num2str(experiment)];
    
    if experiment == 1
        contrasts = {100, 200, 400};
        [modeledResponses] = fitTPUP('group', 'protocol', 'Deuteranopes', 'experimentName', 'experiment_1');
        persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        [modeledResponses] = fitTPUP('group', 'protocol', 'Deuteranopes', 'experimentName', 'experiment_2');
        persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
    end
    
    for contrast = 1:length(contrasts)
        summarizeTPUP(persistentGammaTau, 'protocol', 'Deuteranopes', 'experimentName', ['experiment_', num2str(experiment)], 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
    end
    
end

%% also load up control total response amplitude results
dataBasePath = getpref('melSquintAnalysis','melaDataPath');
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
migraineSubjectIDs = fieldnames(subjectListStruct);

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
%% Plot some TPUP results
for experiment = 1:2
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
    end
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            totalResponseAmplitude.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
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
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/TPUP/Deuteranopes', ['experiment_', num2str(experiment)], ['TPUPParams_', num2str(contrasts{contrast}),  'Contrast.csv']);
                
                TPUPParamsTable = readtable(csvFileName);
                columnsNames = TPUPParamsTable.Properties.VariableNames;
                subjectRow = find(contains(TPUPParamsTable{:,1}, subjectIDs{ss}));
                
                if strcmp(stimuli{stimulus}, 'LS')
                    transientAmplitudeColumn = find(contains(columnsNames, ['LMSTransientAmplitude']));
                    sustainedAmplitudeColumn = find(contains(columnsNames, ['LMSSustainedAmplitude']));
                    persistentAmplitudeColumn = find(contains(columnsNames, ['LMSPersistentAmplitude']));
                else
                    transientAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'TransientAmplitude']));
                    sustainedAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'SustainedAmplitude']));
                    persistentAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'PersistentAmplitude']));
                end
                
                transientAmplitude = TPUPParamsTable{subjectRow, transientAmplitudeColumn};
                sustainedAmplitude = TPUPParamsTable{subjectRow, sustainedAmplitudeColumn};
                persistentAmplitude = TPUPParamsTable{subjectRow, persistentAmplitudeColumn};
                
                
                
                totalResponseAmplitude.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = abs(transientAmplitude + sustainedAmplitude + persistentAmplitude);
            end
        end
        
        
        
        
        
    end
end

% plot results
for experiment = 1:2
    totalResponseAmplitudeRating.Controls = totalResponseAmplitude.(['experiment', num2str(experiment)]);
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP', 'Deuteranopes');
    plotSpreadResults(totalResponseAmplitudeRating, 'stimuli', stimuli, 'contrasts', contrasts, 'saveName', fullfile(savePath, ['groupSummary_experiment', num2str(experiment), '.pdf']), 'yLims', [0 10.1])
    
    
end


plotFig = figure; 
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    data = [totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100; totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200; totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400];
    plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
    plot([log10(100), log10(200), log10(400)], [median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
    experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400)], 'Color', 'k');

    
    data = [totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400; totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800; totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200];
    plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
    plot([log10(400), log10(800), log10(1200)], [median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
    experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');

    
    xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
    xticklabels({'100%', '200%', '400%', '800%', '1200%'});
    xtickangle(45);
    xlabel('Contrast')
    
    ylim([0 10.1]);
    ylabel('Response Amplitude')
    
    if stimulus == 3
       legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2'); 
       legend('boxoff')
    end
end
set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(savePath, 'combinedExperimentsSummary.pdf'));

plotFig = figure; 
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    data = [totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100; totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200; totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400];
    plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
    plot([log10(100), log10(200), log10(400)], [median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
    experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast100), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast200), median(totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400)], 'Color', 'k');

    
    data = [totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400; totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800; totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200];
    plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
    plot([log10(400), log10(800), log10(1200)], [median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
    experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast800), median(totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');
    
    % add trichomat data in blue
    lineProps.col{1} = 'b';
    errorUpper = [abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast100, 25)), abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast200, 25)), abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast400, 25))] - [abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast100)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast200)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast400))];
    errorLower = abs([abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast100, 75)), abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast200, 75)), abs(prctile(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast400, 75))] - [abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast100)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast200)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast400))]);

    errorToPlot(1,1:3, 1) = errorUpper;
    errorToPlot(1,1:3, 2) = errorLower;
    mseb([log10(100), log10(200), log10(400)], [abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast100)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast200)), abs(median(controlTotalResponseAmplitude.(stimuli{stimulus}).Contrast400))], ...
        errorToPlot, lineProps, 1);
        

    
    xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
    xticklabels({'100%', '200%', '400%', '800%', '1200%'});
    xtickangle(45);
    xlabel('Contrast')
    
    ylim([0 10.1]);
    ylabel('Response Amplitude')
    
    if stimulus == 3
       legend([experiment1Plot, experiment2Plot], 'Low Contrast', 'High Contrast', 'Trichromats'); 
       legend('boxoff')
    end
end
set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(savePath, 'combinedExperimentsSummary_withTrichromatControls.pdf'));


plotFig = figure;
for stimulus = 1:length(stimuli)
    ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus})
    for ss = 1:5
        plot([1, 2], [totalResponseAmplitude.experiment1.(stimuli{stimulus}).Contrast400(ss), totalResponseAmplitude.experiment2.(stimuli{stimulus}).Contrast400(ss)], 'Color', 'k') 
    end
    
    xlim([0.75 2.25])
    xticks([1 2])
    xticklabels({'Low Contrast', 'High Contrast'});
    xtickangle(30)
    ylabel('Amplitude of Constriction to 400% Contrast')
    
end
linkaxes([ax.ax1, ax.ax2, ax.ax3]);

%% Total area under the curve
numberOfIndicesToExclude = 40;
for experiment = 1:2
    
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
    end
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            AUC.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
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
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)

                
                AUC.(['experiment', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = abs(trapz(subjectAveragePupilResponses.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,numberOfIndicesToExclude:end-numberOfIndicesToExclude)));
            end
        end
        
        
        
        
        
    end
end

% plot results
for experiment = 1:2
    AUCRating.Controls = AUC.(['experiment', num2str(experiment)]);
    if experiment == 1
        contrasts = {100, 200, 400};
    elseif experiment == 2
        contrasts = {400, 800, 1200};
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP', 'Deuteranopes');
    plotSpreadResults(AUCRating, 'stimuli', stimuli, 'contrasts', contrasts, 'saveName', fullfile(savePath, ['AUC_groupSummary_experiment', num2str(experiment), '.pdf']), 'yLims', [0 400])
    
    
end

plotFig = figure; 
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    data = [AUC.experiment1.(stimuli{stimulus}).Contrast100; AUC.experiment1.(stimuli{stimulus}).Contrast200; AUC.experiment1.(stimuli{stimulus}).Contrast400];
    plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
    plot([log10(100), log10(200), log10(400)], [median(AUC.experiment1.(stimuli{stimulus}).Contrast100), median(AUC.experiment1.(stimuli{stimulus}).Contrast200), median(AUC.experiment1.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
    experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(AUC.experiment1.(stimuli{stimulus}).Contrast100), median(AUC.experiment1.(stimuli{stimulus}).Contrast200), median(AUC.experiment1.(stimuli{stimulus}).Contrast400)], 'Color', 'k');

    
    data = [AUC.experiment2.(stimuli{stimulus}).Contrast400; AUC.experiment2.(stimuli{stimulus}).Contrast800; AUC.experiment2.(stimuli{stimulus}).Contrast1200];
    plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
    plot([log10(400), log10(800), log10(1200)], [median(AUC.experiment2.(stimuli{stimulus}).Contrast400), median(AUC.experiment2.(stimuli{stimulus}).Contrast800), median(AUC.experiment2.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
    experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(AUC.experiment2.(stimuli{stimulus}).Contrast400), median(AUC.experiment2.(stimuli{stimulus}).Contrast800), median(AUC.experiment2.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');

    
    xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
    xticklabels({'100%', '200%', '400%', '800%', '1200%'});
    xtickangle(45);
    xlabel('Contrast')
    
    ylim([0 400]);
    ylabel('Area Under the Curve')
    
    if stimulus == 3
       legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2'); 
       legend('boxoff')
    end
end
set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(savePath, 'AUC_combinedExperimentsSummary.pdf'));


plotFig = figure;
for stimulus = 1:length(stimuli)
    ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus})
    for ss = 1:5
        plot([1, 2], [AUC.experiment1.(stimuli{stimulus}).Contrast400(ss), AUC.experiment2.(stimuli{stimulus}).Contrast400(ss)], 'Color', 'k') 
    end
    
    xlim([0.75 2.25])
    xticks([1 2])
    xticklabels({'Low Contrast', 'High Contrast'});
    xtickangle(30)
    ylabel('Amplitude of Constriction to 400% Contrast')
    
end
linkaxes([ax.ax1, ax.ax2, ax.ax3]);

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



