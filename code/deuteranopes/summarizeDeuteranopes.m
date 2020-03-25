subjectStruct = getDeuteranopeSubjectStruct;
stimuli = {'LightFlux', 'Melanopsin',  'LS'};

%% Summarize pupillometry
% load responses over time
[subjectAveragePupilResponses] = loadPupilResponses('protocol', 'Deuteranopes');

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
    
    experiment1PupilResponse = nanmean(subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400);
    experiment2PupilResponse = nanmean(subjectAveragePupilResponses.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400);
    
    experiment1SEM = nanstd(subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400)./sqrt(size(subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400,1));
    experiment2SEM = nanstd(subjectAveragePupilResponses.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400)./sqrt(size(subjectAveragePupilResponses.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400,1));
    
    
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

    set(gcf, 'Position', [260 419 1187 566]);
    export_fig(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes', '400Comparison', ['groupAverage.pdf']))
   

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
    set(gcf, 'Position', [260 419 1187 566]);
    export_fig(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes', '400Comparison', ['groupAverage_withTrichromats.pdf']))
    
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

%% now for each subject
stimuli = {'LightFlux', 'Melanopsin', 'LS'};
for ss = 1:5
    plotFig = figure;
    
    for stimulus = 1:length(stimuli)
        subplot(1,3, stimulus); hold on;
        experiment1PupilResponse = subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400(ss,:);
        experiment2PupilResponse = subjectAveragePupilResponses.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400(ss,:);
        
        experiment1SEM = subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400_SEM(ss,:);
        experiment2SEM = subjectAveragePupilResponses.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400_SEM(ss,:);
        
        subplot(1,3,stimulus); hold on;
        
        % make thicker plot lines
        lineProps.width = 1;
        transparent = 1;
        
        % adjust color
        lineProps.col{1} = 'k';
        axis.ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment1PupilResponse(1:end-nTimePointsToSkipPlotting), experiment1SEM(1:end-nTimePointsToSkipPlotting), lineProps, transparent);
        
        lineProps.col{1} = 'r';
        axis.ax2 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, experiment2PupilResponse(1:end-nTimePointsToSkipPlotting), experiment2SEM(1:end-nTimePointsToSkipPlotting), lineProps, transparent);
        
        if stimulus == 3
            legend('Low Contrast Experiment', 'High Contrast Experiment')
        end
        xlim(xLims);
        ylim(yLims);
        
        title(stimuli{stimulus});
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change from Baseline)');
    end
    
    set(gcf, 'Position', [260 419 1187 566]);
    export_fig(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes', '400Comparison', [subjectIDs{ss}, '.pdf']))
    
    
end
%% Plot some TPUP results
[deuteranopeResultsStruct] = loadPupilResponses('protocol', 'Deuteranopes');
totalResponseAmplitude = deuteranopeResultsStruct.amplitude;

savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP', 'Deuteranopes');

% Plot experiment 1 results alone
plotDeuteranopeResult(totalResponseAmplitude.experiment_1, [], [], 'savePath', savePath, 'saveName', 'experiment1.pdf', 'yLims', [0 10.1], 'yLabel', 'Constriction Amplitude');

% Plot experiment 2 results alone
plotDeuteranopeResult([], totalResponseAmplitude.experiment_2, [], 'savePath', savePath, 'saveName', 'experiment2.pdf', 'yLims', [0 10.1], 'yLabel', 'Constriction Amplitude');


% Plot comparison between high and low contrast experiments
plotDeuteranopeResult(totalResponseAmplitude.experiment_1, totalResponseAmplitude.experiment_2, [], 'savePath', savePath, 'saveName', 'combinedExperiments.pdf', 'yLims', [0 10.1], 'yLabel', 'Constriction Amplitude');

% Add trichomats for comparison
[trichromatResultsStruct] = loadPupilResponses('protocol', 'SquintToPulse');
trichromatAmplitudeStruct = trichromatResultsStruct.amplitude.controls;

plotDeuteranopeResult(totalResponseAmplitude.experiment_1, [], trichromatAmplitudeStruct, 'savePath', savePath, 'saveName', 'experiment1_withTrichromats.pdf', 'yLims', [0 10.1], 'yLabel', 'Constriction Amplitude');
plotDeuteranopeResult(totalResponseAmplitude.experiment_1, totalResponseAmplitude.experiment_2, trichromatAmplitudeStruct, 'savePath', savePath, 'saveName', 'combinedExperiments_withTrichromats.pdf', 'yLims', [0 10.1], 'yLabel', 'Constriction Amplitude');



plotDeuteranopeResult(totalResponseAmplitude.experiment_1, totalResponseAmplitude.experiment_2, trichromatAmplitudeStruct, 'savePath', savePath, 'saveName', '400ContrastComparison.pdf', 'whichPlot', '400Comparison', 'ylabel', 'Amplitude of Constriction to 400% Contrast');


%% Total area under the curve
[deuteranopeResultsStruct] = loadPupilResponses('protocol', 'Deuteranopes');
AUC = deuteranopeResultsStruct.AUC;

savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP', 'Deuteranopes');

% Plot experiment 1 results alone
plotDeuteranopeResult(AUC.experiment_1, [], [], 'savePath', savePath, 'saveName', 'AUC_experiment1.pdf', 'yLims', [0 400], 'yLabel', 'Constriction AUC');

% Plot experiment 2 results alone
plotDeuteranopeResult([], AUC.experiment_2, [], 'savePath', savePath, 'saveName', 'AUC_experiment2.pdf', 'yLims', [0 400], 'yLabel', 'Constriction AUC');


% Plot comparison between high and low contrast experiments
plotDeuteranopeResult(AUC.experiment_1, AUC.experiment_2, [], 'savePath', savePath, 'saveName', 'AUC_combinedExperiments.pdf', 'yLims', [0 400], 'yLabel', 'Constriction AUC');

% Add trichomats for comparison
[trichromatResultsStruct] = loadPupilResponses('protocol', 'SquintToPulse');
trichromatAUCStruct = trichromatResultsStruct.AUC.controls;

plotDeuteranopeResult(AUC.experiment_1, [], trichromatAUCStruct, 'savePath', savePath, 'saveName', 'AUC_experiment1_withTrichromats.pdf', 'yLims', [0 400], 'yLabel', 'Constriction AUC');
plotDeuteranopeResult(AUC.experiment_1, AUC.experiment_2, trichromatAUCStruct, 'savePath', savePath, 'saveName', 'AUC_combinedExperiments_withTrichromats.pdf', 'yLims', [0 400], 'yLabel', 'Constriction AUC');


% 400% comparison
plotDeuteranopeResult(AUC.experiment_1, AUC.experiment_2, trichromatAUCStruct, 'savePath', savePath, 'saveName', 'AUC_400ContrastComparison.pdf', 'whichPlot', '400Comparison', 'ylabel', 'AUC of Constriction to 400% Contrast');



%% Summarize discomfort ratings
% Load in ratings
[ discomfortRatingsStruct ] = loadDiscomfortRatings('protocol', 'Deuteranopes');

savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'deuteranopes');

% Plot experiment 1 results alone
plotDeuteranopeResult(discomfortRatingsStruct.experiment_1, [], [], 'savePath', savePath, 'saveName', 'experiment1', 'yLims', [-0.5 10.1], 'yLabel', 'Discomfort Rating');

% Plot experiment 2 results alone
plotDeuteranopeResult([], discomfortRatingsStruct.experiment_2, [], 'savePath', savePath, 'saveName', 'experiment2', 'yLims', [-0.5 10.1], 'yLabel', 'Discomfort Rating');


% Plot comparison between high and low contrast experiments
plotDeuteranopeResult(discomfortRatingsStruct.experiment_1, discomfortRatingsStruct.experiment_2, [], 'savePath', savePath, 'saveName', 'combinedExperiments', 'yLims', [-0.5 10.1], 'yLabel', 'Discomfort Rating');

% Add trichomats for comparison
[trichromatResultsStruct] = loadDiscomfortRatings('protocol', 'SquintToPulse');
trichromatDiscomfortStruct = trichromatResultsStruct.controls;

plotDeuteranopeResult(discomfortRatingsStruct.experiment_1, [], trichromatDiscomfortStruct, 'savePath', savePath, 'saveName', 'experiment1_withTrichromats', 'yLims', [-0.5 10.1], 'yLabel', 'Discomfort Rating');
plotDeuteranopeResult(discomfortRatingsStruct.experiment_1, discomfortRatingsStruct.experiment_2, trichromatDiscomfortStruct, 'savePath', savePath, 'saveName', 'combinedExperiments_withTrichromats', 'yLims', [-0.5 10.1], 'yLabel', 'Discomfort Rating');


% 400% comparison
plotDeuteranopeResult(discomfortRatingsStruct.experiment_1, discomfortRatingsStruct.experiment_2, trichromatDiscomfortStruct, 'savePath', savePath, 'saveName', '400ContrastComparison', 'yLims', [-0.5 10.1], 'whichPlot', '400Comparison', 'ylabel', 'Discomfort Rating to 400% Contrast');




%% Summarize EMG
[ emgStruct ] = loadEMG('protocol', 'Deuteranopes');

savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'Deuteranopes');

% Plot experiment 1 results alone
plotDeuteranopeResult(emgStruct.experiment_1, [], [], 'savePath', savePath, 'saveName', 'experiment1.pdf', 'yLims', [-0.5 1], 'yLabel', 'RMS % Change from Baseline');

% Plot experiment 2 results alone
plotDeuteranopeResult([], emgStruct.experiment_2, [], 'savePath', savePath, 'saveName', 'experiment2.pdf', 'yLims', [-0.5 1], 'yLabel', 'RMS % Change from Baseline');


% Plot comparison between high and low contrast experiments
plotDeuteranopeResult(emgStruct.experiment_1, emgStruct.experiment_2, [], 'savePath', savePath, 'saveName', 'combinedExperiments.pdf', 'yLims', [-0.5 1], 'yLabel', 'RMS % Change from Baseline');

% Add trichomats for comparison
[trichromatResultsStruct] = loadEMG('protocol', 'SquintToPulse');
trichromatEMGStruct = trichromatResultsStruct.controlRMS;

plotDeuteranopeResult(emgStruct.experiment_1, [], trichromatEMGStruct, 'savePath', savePath, 'saveName', 'experiment1_withTrichromats.pdf', 'yLims', [-0.5 1], 'yLabel', 'RMS % Change from Baseline');
plotDeuteranopeResult(emgStruct.experiment_1, emgStruct.experiment_2, trichromatEMGStruct, 'savePath', savePath, 'saveName', 'combinedExperiments_withTrichromats.pdf', 'yLims', [-0.5 1], 'yLabel', 'RMS % Change from Baseline');


% 400% comparison
plotDeuteranopeResult(emgStruct.experiment_1, emgStruct.experiment_2, trichromatEMGStruct, 'savePath', savePath, 'saveName', '400ContrastComparison.pdf', 'whichPlot', '400Comparison', 'ylabel', 'RMS % Change from Baseline to 400% Contrast');



