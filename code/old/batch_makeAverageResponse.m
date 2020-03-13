subjectListDirs = dir(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', 'MELA*'));

subjectIDs = [];
badSubjects = {'MELA_0127', 'MELA_0168'};

for ss = 1:length(subjectListDirs)
    
   subjectIDs{ss} = subjectListDirs(ss).name;
   
end

subjectIDs = setdiff(subjectIDs, badSubjects);

for ss = 1:length(subjectIDs)
   subjectID = subjectIDs{ss};
   
   [ averageResponseMatrix.(subjectID), trialStruct ] = makeSubjectAverageResponses(subjectID, 'debugNumberOfNaNValuesPerTrial', true, 'blinkBufferFrames', [0 0], 'trialNaNThreshold', 2);
    
end

%% Do some summary plotting
% subjectListDirs = dir(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', 'MELA*'));
% 
% subjectIDs = [];
% badSubjects = {'MELA_0127', 'MELA_0168'};
% 
% for ss = 1:length(subjectListDirs)
%     
%    subjectIDs{ss} = subjectListDirs(ss).name;
%    
% end
% 
% subjectIDs = setdiff(subjectIDs, badSubjects);

contrasts = {'100', '200', '400'};
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

for cc = 1:length(contrasts)
    for stimulus = 1:length(stimuli)
        averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}]) = [];
    end
end

for cc = 1:length(contrasts)
    for stimulus = 1:length(stimuli)
        for ss = 1:length(subjectIDs)
            clear trialStruct
               subjectID = subjectIDs{ss};

            load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', subjectID, 'trialStruct_postSpotcheck.mat'));
            for tt = 1:length(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(1,:))
                averageResponse(tt) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt));
                STD(tt) = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt));
                SEM(tt) = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt))/(length(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt)) - sum(isnan((trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt)))));
            end

            
            averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}])(ss,:) = averageResponse;
            averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}, '_STD'])(ss,:) = STD;
            averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}, '_SEM'])(ss,:) = SEM;


        end
    end
end
%% Do the plotting;
resampledTimebase = 0:1/60:18.5;
% plotFig = figure; hold on;
% subplot(3,1,1); hold on;
% plot(nanmean(averageResponseMatrix.Melanopsin.Contrast100,1))
% plot(nanmean(averageResponseMatrix.Melanopsin.Contrast200,1))
% plot(nanmean(averageResponseMatrix.Melanopsin.Contrast400,1))
% 
% subplot(3,1,2); hold on;
% plot(nanmean(averageResponseMatrix.LMS.Contrast100,1))
% plot(nanmean(averageResponseMatrix.LMS.Contrast200,1))
% plot(nanmean(averageResponseMatrix.LMS.Contrast400,1))
% 
% subplot(3,1,3); hold on;
% plot(nanmean(averageResponseMatrix.LightFlux.Contrast100,1))
% plot(nanmean(averageResponseMatrix.LightFlux.Contrast200,1))
% plot(nanmean(averageResponseMatrix.LightFlux.Contrast400,1))
nTimePointsToSkipPlotting = 40;

plotFig = figure;
subplot(3,1,1)
title('Melanopsin')
hold on

lineProps.width = 1;
lineProps.col{1} = [220/255, 237/255, 200/255];
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.Melanopsin.Contrast100(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.Melanopsin.Contrast100(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.Melanopsin.Contrast100(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = [66/255, 179/255, 213/255];
ax2 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.Melanopsin.Contrast200(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.Melanopsin.Contrast200(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.Melanopsin.Contrast200(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = [26/255, 35/255, 126/255];
ax3 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.Melanopsin.Contrast400(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.Melanopsin.Contrast400(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.Melanopsin.Contrast400(:,1:end-nTimePointsToSkipPlotting)))), lineProps);
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change, +/- SEM)')
legend(['100% Contrast, N = ' num2str(size(averageResponseMatrix.Melanopsin.Contrast100,1))], ['200% Contrast, N = ' num2str(size(averageResponseMatrix.Melanopsin.Contrast200,1))], ['400% Contrast, N = ' num2str(size(averageResponseMatrix.Melanopsin.Contrast400,1))], 'Location', 'southeast')
legend('boxoff')
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');

%saveas(plotFig, fullfile(analysisBasePath, 'melanopsin.pdf'), 'pdf');
%close(plotFig)

subplot(3,1,2)
title('LMS')
hold on

grayColorMap = colormap(gray);
lineProps.width = 1;
lineProps.col{1} = grayColorMap(50,:);
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LMS.Contrast100(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LMS.Contrast100(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LMS.Contrast100(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = grayColorMap(25,:);
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LMS.Contrast200(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LMS.Contrast200(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LMS.Contrast200(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = grayColorMap(1,:);
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LMS.Contrast400(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LMS.Contrast400(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LMS.Contrast400(:,1:end-nTimePointsToSkipPlotting)))), lineProps);
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change, +/- SEM)')
legend(['100% Contrast, N = ' num2str(size(averageResponseMatrix.LMS.Contrast100,1))], ['200% Contrast, N = ' num2str(size(averageResponseMatrix.LMS.Contrast200,1))], ['400% Contrast, N = ' num2str(size(averageResponseMatrix.LMS.Contrast400,1))], 'Location', 'southeast')
legend('boxoff')
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
%saveas(plotFig, fullfile(analysisBasePath, 'LMS.pdf'), 'pdf');
%close(plotFig)

subplot(3,1,3)
title('LightFlux')
hold on

lineProps.width = 1;
lineProps.col{1} = [254/255, 235/255, 101/255];
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LightFlux.Contrast100(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LightFlux.Contrast100(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LightFlux.Contrast100(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = [228/255, 82/255, 27/255];
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LightFlux.Contrast200(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LightFlux.Contrast200(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LightFlux.Contrast200(:,1:end-nTimePointsToSkipPlotting)))), lineProps);

lineProps.col{1} = [77/255, 52/255, 47/255];
ax1 = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-1, nanmean(averageResponseMatrix.LightFlux.Contrast400(:,1:end-nTimePointsToSkipPlotting),1), nanstd(averageResponseMatrix.LightFlux.Contrast400(:,1:end-nTimePointsToSkipPlotting))./sqrt(sum(~isnan(averageResponseMatrix.LightFlux.Contrast400(:,1:end-nTimePointsToSkipPlotting)))), lineProps);
ylim([-0.8 0.1])
xlim([0 17])
xlabel('Time (s)')
ylabel('Pupil Area (% Change, +/- SEM)')
legend(['100% Contrast, N = ' num2str(size(averageResponseMatrix.LightFlux.Contrast100,1))], ['200% Contrast, N = ' num2str(size(averageResponseMatrix.LightFlux.Contrast200,1))], ['400% Contrast, N = ' num2str(size(averageResponseMatrix.LightFlux.Contrast400,1))], 'Location', 'southeast')
legend('boxoff')
line([0.5 4.5], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');

print(plotFig, fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles','averageResponsePlots', 'groupAverageResponse'), '-dpdf', '-fillpage')
close(plotFig)



