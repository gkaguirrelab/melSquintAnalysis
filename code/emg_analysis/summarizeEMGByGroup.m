%% Set up some preferences
resultsDir = '~/Desktop';

%% Load up EMG Data
EMGStruct = loadEMG;

%% First plot: response over time by stimulus condition group
close all;

% define some experimental conditions
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
groups = {'controls', 'mwa', 'mwoa'};
colorToPlot = {'k', 'b', 'r'};

% basic plotting parameters

timebase = 0:0.1:17.5;


% do the plotting
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        cellNumber = ((stimulus-1)*3)+contrast;
        subplot(3,3,cellNumber); hold on;
        for group = 1:length(groups)
            title([stimuli{stimulus}, ' Contrast ', num2str(contrasts{contrast}), '%']);
            groupMean = nanmean(EMGStruct.responseOverTime.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            ax.(['ax', num2str(group)]) = plot(timebase, groupMean, 'Color', colorToPlot{group});
            
        end
        ylim([0 1]);
        yticks([0 0.5 1]);
        yticklabels({'0%', '50%', '100%'});
        ylabel('Squint (% Change from Baseline)');
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
export_fig(gcf, fullfile(resultsDir, 'EMG_responseOverTime_byGroup.pdf'));

%% Second plot: response over time by group, collapsing across stimuli
close all;

% define some experimental conditions
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
groups = {'controls', 'mwoa', 'mwa'};
colorToPlot = {'k', 'r', 'b'};

% basic plotting parameters

timebase = 0:0.1:17.5;


% do the plotting
%for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        subplot(1,3,contrast); hold on;
        for group = 1:length(groups)
            title(['Contrast ', num2str(contrasts{contrast}), '%']);
            
            meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]) = (EMGStruct.responseOverTime.(groups{group}).LMS.(['Contrast', num2str(contrasts{contrast})]) + EMGStruct.responseOverTime.(groups{group}).Melanopsin.(['Contrast', num2str(contrasts{contrast})]) + EMGStruct.responseOverTime.(groups{group}).LightFlux.(['Contrast', num2str(contrasts{contrast})]))./3;
            
            
            groupMean = nanmean(meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]));
            groupSEM = nanstd(meanAcrossStimuli.(groups{group}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(20);
            %ax.(['ax', num2str(group)]) = plot(timebase, groupMean, 'Color', colorToPlot{group});
            lineProps.col = [];
            lineProps.col{1} = colorToPlot{group};
            ax.(['ax', num2str(group)]) = mseb(timebase, groupMean, groupSEM, lineProps, 1);
        end
        ylim([0 1]);
        yticks([0 0.5 1]);
        yticklabels({'0%', '50%', '100%'});
        ylabel('Squint (% Change from Baseline)');
        xlim([0 17]);
        xticks([0 5 10 15])
        xticklabels([0 5 10 15])
        xlabel('Time (s)');
        
        if contrast == 3
            legend('Controls', 'MwoA', 'MwA', 'Location', 'NorthEast');
            legend('boxoff');
        end
        
    end
%end

set(gcf, 'Position', [52 529 1375 269]);
%export_fig(gcf, fullfile(resultsDir, 'EMG_responseOverTime_byGroup_collapsedAcrossStimuli.pdf'));
print(gcf, '-dpdf', '/Users/harrisonmcadams/Desktop/EMG_responseOverTime_byGroup_collapsedAcrossStimuli.pdf', '-bestfit'); 

%% Second plot: EMG AUC during the pulse by stimulus condition by group
close all;

makeStimulusByGroupPlot('emg', 'normalizedPulseAUC');

export_fig(gcf, fullfile(resultsDir, 'EMG_normalizedPulseAUC_contrastXgroup_pulse.pdf'));
% note here the axes are going to be a bit different than what eric shared
% recently in the chart -- they're the same plot, but in order to see all
% subjects need to widen yLims up to 300%

%% Dropped frames by stimulus condition by group
close all

makeStimulusByGroupPlot('droppedFrames', []);
export_fig(gcf, fullfile(resultsDir, 'droppedFrames_contrastXgroup_pulse.pdf'));

%% Compare dropped frames and squint:
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {100, 200, 400};
groups = {'controls', 'mwa', 'mwoa'};
plotFig = figure;
for group = 1:length(groups)
    x = [];
    y = [];
   subplot(1,3,group); hold on
   for stimulus = 1:length(stimuli)
       for contrast = 1:length(contrasts)
   
             x = [x, EMGStruct.normalizedPulseAUC.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
             y = [y, droppedFramesMeanStruct.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
       end
   end
   
   plot(x,y, 'o')
   
   coeffs = polyfit(x, y, 1);
   fittedX = linspace(min(x), max(x), 200);
   fittedY = polyval(coeffs, fittedX);
   plot(fittedX, fittedY, '--', 'Color', 'k');
   
   r2 = corr2(x,y);
   
   xlabel('EMG Squint')
   ylabel('Blinks')
   xlim([-0.3 3]);
   ylim([0 80]);
             
   title([groups{group}, ' r2 = ', num2str(r2)]);
   
   
   
end
    

%% Old
% %% Determine list of studied subjects
% dataBasePath = getpref('melSquintAnalysis','melaDataPath');
% 
% 
% load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
% 
% subjectIDs = fieldnames(subjectListStruct);
% 
% calculateRMS = false;
% 
% %% Pool results
% controlRMS = [];
% mwaRMS = [];
% mwoaRMS = [];
% 
% stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
% contrasts = {100, 200, 400};
% 
% for stimulus = 1:length(stimuli)
%     for contrast = 1:length(contrasts)
%         controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         
%         controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         combinedMigraineResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%     end
% end
% 
% controlSubjects = [];
% mwaSubjects = [];
% mwoaSubjects = [];
% 
% useNormalized = true;
% 
% if useNormalized
%    saveStem = '_normalized';
% else
%     saveStem = '';
% end
% 
% for ss = 1:length(subjectIDs)
%     
%     
%     group = linkMELAIDToGroup(subjectIDs{ss});
%     
%     resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
%     
%     if calculateRMS
%         calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true);
%         calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', false);
%         
%     end
%     close all;
%     for stimulus = 1:length(stimuli)
%         for contrast = 1:length(contrasts)
%             if strcmp(group, 'c')
%                 load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
%                 controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
%                 controlSubjects{end+1} = subjectIDs{ss};
%             elseif strcmp(group, 'mwa')
%                 load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
%                 mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
%                 mwaSubjects{end+1} = subjectIDs{ss};
%             elseif strcmp(group, 'mwoa')
%                 load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
%                 mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
%                 mwoaSubjects{end+1} = subjectIDs{ss};
%             else
%                 fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
%             end
%         end
%     end
%     
% end
% 
% mwaSubjects = unique(mwaSubjects);
% mwoaSubjects = unique(mwoaSubjects);
% controlSubjects = unique(controlSubjects);
% %% Analyze EMG responses over time
% windowLength = 500;
% stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
% contrasts = {100, 200, 400};
% for stimulus = 1:length(stimuli)
%     for contrast = 1:length(contrasts)
%         pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%     end
% end
% for ss = 1:length(subjectIDs)
%     load(fullfile(fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs'], 'trialStructs', [subjectIDs{ss}, '.mat'])));
%     for stimulus = 1:length(stimuli)
%         for contrast = 1:length(contrasts)
%             pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).combined);
%         end
%     end
%     
% end
% 
% plotFig = figure;
% resampledTimebase = 0:1/5000*windowLength:1/5000*windowLength*length(pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:)) - 1/5000*windowLength;
% 
% nStimuli = length(stimuli);
% nContrasts = length(contrasts);
% 
% % set up color palette
% colorPalette.Melanopsin{1} = [220/255, 237/255, 200/255];
% colorPalette.Melanopsin{2} = [66/255, 179/255, 213/255];
% colorPalette.Melanopsin{3} = [26/255, 35/255, 126/255];
% 
% grayColorMap = colormap(gray);
% colorPalette.LMS{1} = grayColorMap(50,:);
% colorPalette.LMS{2} = grayColorMap(25,:);
% colorPalette.LMS{3} = grayColorMap(1,:);
% colorPalette.LS = colorPalette.LMS;
% 
% colorPalette.LightFlux{1} = [254/255, 235/255, 101/255];
% colorPalette.LightFlux{2} = [228/255, 82/255, 27/255];
% colorPalette.LightFlux{3} = [77/255, 52/255, 47/255];
% 
% for ss = 1:nStimuli
%     
%     % pick the right subplot for the right stimuli
%     ax.(['ax', num2str(ss)]) = subplot(nStimuli,1,ss);
%     title(stimuli{ss})
%     hold on
%     
%     for cc = 1:nContrasts
%         
%         % make thicker plot lines
%         lineProps.width = 1;
%         
%         % adjust color
%         lineProps.col{1} = colorPalette.(stimuli{ss}){cc};
%         
%         % plot
%         axis.(['ax', num2str(cc)]) = mseb(resampledTimebase, nanmean(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])), std(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]))/(sqrt(size(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]),1))), lineProps);
%         
%         legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]), 1))]);
%         
%     end
%     
%     legend(legendText, 'Location', 'NorthEast')
%     legend('boxoff')
%     
%     % add line for pulse onset
%     line([1.5,  5.5], [-0.1, -0.1], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
%     
%     % spruce up axes
%     
%     
%     xlabel('Time (s)')
%     ylabel('EMG Activity (STD)')
%     
% end
% 
% linkaxes([ax.ax1, ax.ax2, ax.ax3]);
% 
% fullSavePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs']);
% 
% if ~exist(fullSavePath)
%     mkdir(fullSavePath);
% end
% 
% print(plotFig, fullfile(fullSavePath, 'combinedGroupAverage'), '-dpdf', '-fillpage')
% 
% 
% %% Calculate EMG responses over time by group
% 
% for stimulus = 1:length(stimuli)
%     for contrast = 1:length(contrasts)
%  
%         controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%         combinedMigraineResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
%     end
% end
% 
% windowLength = 500;
% 
% % set up color palette
% colorPalette.Melanopsin{1} = [220/255, 237/255, 200/255];
% colorPalette.Melanopsin{2} = [66/255, 179/255, 213/255];
% colorPalette.Melanopsin{3} = [26/255, 35/255, 126/255];
% 
% grayColorMap = colormap(gray);
% colorPalette.LMS{1} = grayColorMap(50,:);
% colorPalette.LMS{2} = grayColorMap(25,:);
% colorPalette.LMS{3} = grayColorMap(1,:);
% colorPalette.LS = colorPalette.LMS;
% 
% colorPalette.LightFlux{1} = [254/255, 235/255, 101/255];
% colorPalette.LightFlux{2} = [228/255, 82/255, 27/255];
% colorPalette.LightFlux{3} = [77/255, 52/255, 47/255];
% 
% nStimuli = length(stimuli);
% nContrasts = length(contrasts);
% 
% for ss = 1:length(subjectIDs)
%     
%     
%     group = linkMELAIDToGroup(subjectIDs{ss});
%     
%     resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
%     
%     load(fullfile(fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs'], 'trialStructs', [subjectIDs{ss}, '.mat'])));
%     
%     
%     for stimulus = 1:length(stimuli)
%         for contrast = 1:length(contrasts)
%             subjectMeanResult = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).combined);
%             
%             if strcmp(group, 'c')
%                 controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectMeanResult;
%                 controlSubjects{end+1} = subjectIDs{ss};
%             elseif strcmp(group, 'mwa')
%                 load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
%                 mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectMeanResult;
%                 combinedMigraineResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectMeanResult;
%                 mwaSubjects{end+1} = subjectIDs{ss};
%             elseif strcmp(group, 'mwoa')
%                 load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
%                 mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectMeanResult;
%                 combinedMigraineResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectMeanResult;
%                 mwoaSubjects{end+1} = subjectIDs{ss};
%             else
%                 fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
%             end
%         end
%     end
%     
% end
% 
% for group = 1:4
%     plotFig = figure;
%     resampledTimebase = 0:0.1:size(controlResponseOverTime.Melanopsin.Contrast100,2)*0.1-0.1;
% 
%     if group == 1
%         
%         response = controlResponseOverTime;
%         groupName = 'Controls';
%         
%     elseif group == 2
%         response = mwaResponseOverTime;
%         groupName = 'MwA';
%         
%         
%     elseif group == 3
%         response = mwoaResponseOverTime;
%         groupName = 'MwoA';
%         
%     elseif group == 4
%         
%         response = combinedMigraineResponseOverTime;
%         groupName = 'CombinedMigraine';
%         
%     end
%     for ss = 1:nStimuli
%         
%         % pick the right subplot for the right stimuli
%         ax.(['ax', num2str(ss)]) = subplot(nStimuli,1,ss);
%         title(stimuli{ss})
%         hold on
%         
%         for cc = 1:nContrasts
%             
%             % make thicker plot lines
%             lineProps.width = 1;
%             
%             % adjust color
%             lineProps.col{1} = colorPalette.(stimuli{ss}){cc};
%             
%             % plot
%             axis.(['ax', num2str(cc)]) = mseb(resampledTimebase, nanmean(response.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])), std(response.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]))/(sqrt(size(response.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]),1))), lineProps);
%             
%             legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(response.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]), 1))]);
%             
%         end
%         
%         legend(legendText, 'Location', 'NorthEast')
%         legend('boxoff')
%         
%         % add line for pulse onset
%         line([1.5,  5.5], [-0.1, -0.1], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
%         
%         % spruce up axes
%         
%         
%         xlabel('Time (s)')
%         ylabel('EMG Activity (STD)')
%         ylim([-0.1 1]);
%         
%     end
%     
%     linkaxes([ax.ax1, ax.ax2, ax.ax3]);
%     
%     fullSavePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs']);
%     
%     if ~exist(fullSavePath)
%         mkdir(fullSavePath);
%     end
%     
%     print(plotFig, fullfile(fullSavePath, [groupName, '_groupAverage']), '-dpdf', '-fillpage')
% end
% 
% %% Display results
% 
% EMG = [];
% for stimulus = 1:length(stimuli)
%     for contrast = 1:length(contrasts)
%         EMG.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
%         
%         EMG.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
%         EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
%     end
% end
% if useNormalized
%     yLims = [-.5 1.25];
% else
%     yLims = [0 4];
% end
% plotSpreadResults(EMG, 'yLims', yLims, 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['groupAverage', saveStem, '.pdf']))
% 
% 
% 
% EMG = [];
% for stimulus = 1:length(stimuli)
%     for contrast = 1:length(contrasts)
%         EMG.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
%         EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
%     end
% end
% 
% plotSpreadResults(EMG, 'yLims', yLims, 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['groupAverage_combinedMigraineurs', saveStem, '.pdf']))
% 
% %% Use label permutation testing to understand significance of group differences between MwA and MwoA
% stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
% contrasts = {100, 200, 400};
% 
% fprintf('<strong>For comparison of MwA vs. MwoA</strong>\n', stimuli{stimulus});
% 
% for stimulus = 1:length(stimuli)
%             fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
% 
%     for contrast = 1:length(contrasts)
%                 fprintf('\tContrast: %s%%\n', num2str(contrasts{contrast}));
% 
%         [ significance ] = evaluateSignificanceOfMedianDifference(mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), '~/Desktop', 'sidedness', 2);
%         
%         fprintf('\t\tP-value: %4.4f\n', significance);
% 
%         
%         
%     end
%     
% end