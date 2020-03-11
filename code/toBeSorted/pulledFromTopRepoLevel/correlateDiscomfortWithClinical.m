%% Set up some paths

dataBasePath = getpref('melSquintAnalysis','melaDataPath');
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

pathToSurveyData = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'surveyMelanopsinAnalysis', 'MELA_ScoresSurveyData_Squint.xlsx');
surveyTable = readtable(pathToSurveyData);
columnNames = surveyTable.Properties.VariableNames;


%% Correlate VDS with discomfort rating
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {400};


controlVDS = [];
mwaVDS = [];
mwoaVDS = [];


VDSColumn = find(contains(columnNames, 'VDS'));

for ss = 1:length(subjectIDs)
    for contrast = 1:length(contrasts)
        
        subjectRow = find(contains(surveyTable{:,1}, subjectIDs{ss}));
        VDS = str2num(cell2mat(surveyTable{subjectRow,VDSColumn}));
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        if strcmp(group, 'c')
            controlVDS(end+1) = VDS;
        elseif strcmp(group, 'mwa')
            mwaVDS(end+1) = VDS;
            
        elseif strcmp(group, 'mwoa')
            mwoaVDS(end+1) = VDS;
        else
            fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
        end
    end
    
end

%% wrangle up omnibus summary metric for discomfort ratings
% for each subject, pool all trials together, and grab median values across
% trials

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

omnibusDiscomfort.mwa = [];
omnibusDiscomfort.mwoa = [];
omnibusDiscomfort.controls = [];


for ss = 1:length(subjectIDs)
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    
    load(fullfile(analysisBasePath, fileName));
    
    trialAccumulator = [];
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            trialAccumulator = [trialAccumulator, trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            
        end
    end
    
    if strcmp(group, 'c')
        omnibusDiscomfort.controls(end+1) = nanmedian(trialAccumulator);
    elseif strcmp(group, 'mwa')
        omnibusDiscomfort.mwa(end+1) = nanmedian(trialAccumulator);
    elseif strcmp(group, 'mwoa')
        omnibusDiscomfort.mwoa(end+1) = nanmedian(trialAccumulator);
    end
end

plotFig = figure; hold on;
plot(omnibusDiscomfort.controls, controlVDS, 'o', 'Color', 'k');
x = omnibusDiscomfort.controls;
y = controlVDS;
coeffs = polyfit(x, y, 1);
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
controlR = corr2(x, y);

plot(omnibusDiscomfort.mwa, mwaVDS, 'o', 'Color', 'b');
x = omnibusDiscomfort.mwa;
y = mwaVDS;
coeffs = polyfit(x, y, 1);
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
ax.ax2 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b');
mwaR = corr2(x, y);


plot(omnibusDiscomfort.mwoa, mwoaVDS, 'o', 'Color', 'r');
x = omnibusDiscomfort.mwoa;
y = mwoaVDS;
coeffs = polyfit(x, y, 1);
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
ax.ax3 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r');
mwoaR = corr2(x, y);

xlabel('Omnibus Discomfort Rating')
ylabel('VDS')
legend([ax.ax1, ax.ax2, ax.ax3], ['Controls, r = ' num2str(controlR)], ['MwA, r = ' num2str(mwaR)], ['MwoA, r = ' num2str(mwoaR)], 'Location', 'NorthWest');


%% Plot VDS vs. mean discomfort rating

stimuli = {'LightFlux', 'Melanopsin', 'LMS'};

[ slope, intercept, meanRating ] = fitLineToResponseModality('discomfortRating', 'makePlots', false, 'makeCSV', false);

plotFig = figure;
sgtitle('VDS')

for stimulus = 1:length(stimuli)
    subplot(2,3,stimulus); hold on;
    title(stimuli{stimulus});
    
    plot(meanRating.controls.(stimuli{stimulus}), controlVDS, 'o', 'Color', 'k');
    x = meanRating.controls.(stimuli{stimulus});
    y = controlVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
    controlR = corr2(x, y);

    plot(meanRating.mwa.(stimuli{stimulus}), mwaVDS, 'o', 'Color', 'b');
    x = meanRating.mwa.(stimuli{stimulus});
    y = mwaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax2 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b');
    mwaR = corr2(x, y);


    plot(meanRating.mwoa.(stimuli{stimulus}), mwoaVDS, 'o', 'Color', 'r');
    x = meanRating.mwoa.(stimuli{stimulus});
    y = mwoaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax3 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r');
    mwoaR = corr2(x, y);


    xlabel('Mean Discomfort Rating');
    ylabel('VDS');
    xlim([0 10]);
    ylim([0 45]);
    
  
        legend([ax.ax1, ax.ax2, ax.ax3], ['Controls, r = ' num2str(controlR)], ['MwA, r = ' num2str(mwaR)], ['MwoA, r = ' num2str(mwoaR)], 'Location', 'NorthWest');
    
    
    
end

for stimulus = 1:length(stimuli)
    subplot(2,3,stimulus+3); hold on;
    title(stimuli{stimulus});
    
    plot(slope.controls.(stimuli{stimulus}), controlVDS, 'o', 'Color', 'k');
    x = slope.controls.(stimuli{stimulus});
    y = controlVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
    controlR = corr2(x, y);

    plot(slope.mwa.(stimuli{stimulus}), mwaVDS, 'o', 'Color', 'b');
    x = slope.mwa.(stimuli{stimulus});
    y = mwaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax2 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b');
    mwaR = corr2(x, y);


    plot(slope.mwoa.(stimuli{stimulus}), mwoaVDS, 'o', 'Color', 'r');
    x = slope.mwoa.(stimuli{stimulus});
    y = mwoaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax3 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r');
    mwoaR = corr2(x, y);


    xlabel('Slope');
    ylabel('VDS');
    xlim([-1 12]);
    ylim([0 45]);
    
  
        legend([ax.ax1, ax.ax2, ax.ax3], ['Controls, r = ' num2str(controlR)], ['MwA, r = ' num2str(mwaR)], ['MwoA, r = ' num2str(mwoaR)], 'Location', 'NorthWest');
    
    
    
end
%set(gcf, 'Position', [91 403 1149 575]);

%% plot VDS for discomfort, all groups together
plotFig = figure;
sgtitle('VDS')

for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    
    plot(controlDiscomfort.(stimuli{stimulus}).Contrast400, controlVDS, 'o', 'Color', 'k');
    x = controlDiscomfort.(stimuli{stimulus}).Contrast400;
    y = controlVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
    
    plot(mwaDiscomfort.(stimuli{stimulus}).Contrast400, mwaVDS, 'o', 'Color', 'b');
    x = mwaDiscomfort.(stimuli{stimulus}).Contrast400;
    y = mwaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax2 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b');
    
    plot(mwoaDiscomfort.(stimuli{stimulus}).Contrast400, mwoaVDS, 'o', 'Color', 'r');
    x = mwoaDiscomfort.(stimuli{stimulus}).Contrast400;
    y = mwoaVDS;
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    ax.ax3 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r');
    
    xlabel('Discomfort Rating');
    ylabel('VDS');
    xlim([0 10]);
    ylim([0 40]);
    
    if stimulus == 1
        legend([ax.ax1, ax.ax2, ax.ax3], 'Controls', 'MwA', 'MwoA', 'Location', 'NorthWest');
    end
    
    
end
set(gcf, 'Position', [91 403 1149 575]);

%% Plot VDS vs. discomfort, separate plots for each group
groups = {'Controls', 'MwA', 'MwoA'};
for group = 1:length(groups)
    plotFig = figure;
    sgtitle(['VDS, ' groups{group}])
    
    for stimulus = 1:length(stimuli)
        subplot(1,3,stimulus); hold on;
        title(stimuli{stimulus});
        
        if strcmp(groups{group}, 'Controls')
            plot(controlDiscomfort.(stimuli{stimulus}).Contrast400, controlVDS, 'o', 'Color', 'k');
            x = controlDiscomfort.(stimuli{stimulus}).Contrast400;
            y = controlVDS;
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            ax.ax1 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k');
        end
        
        if strcmp(groups{group}, 'MwA')
            plot(mwaDiscomfort.(stimuli{stimulus}).Contrast400, mwaVDS, 'o', 'Color', 'b');
            x = mwaDiscomfort.(stimuli{stimulus}).Contrast400;
            y = mwaVDS;
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            ax.ax2 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b');
        end
        
        if strcmp(groups{group}, 'MwoA')
            plot(mwoaDiscomfort.(stimuli{stimulus}).Contrast400, mwoaVDS, 'o', 'Color', 'r');
            x = mwoaDiscomfort.(stimuli{stimulus}).Contrast400;
            y = mwoaVDS;
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            ax.ax3 = plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r');
        end
        
        r = corr2(x, y);
        string = (sprintf(['r = ', num2str(r)]));
        text(0.5, 39, string, 'fontsize',12)
        
        xlabel('Discomfort Rating');
        ylabel('VDS');
        xlim([0 10]);
        ylim([0 40]);
        
        
    end
    set(gcf, 'Position', [91 403 1149 575]);
    export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'compareResponses', ['VDSvsDiscomfort_', groups{group}, '.pdf']));
    
end

%% Check whether sex differences can account for our group results
sexColumn = find(contains(columnNames, 'Sex'));

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};



for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male = [];
        mwaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male = [];
        mwoaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male = [];
        
        controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female = [];
        mwaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female = [];
        mwoaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female = [];
    end
end

for ss = 1:length(subjectIDs)
    subjectRow = find(contains(surveyTable{:,1}, subjectIDs{ss}));
    sex = (cell2mat(surveyTable{subjectRow,sexColumn}));
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    load(fullfile(analysisBasePath, fileName));
    
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).(sex)(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            elseif strcmp(group, 'mwa')
                mwaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).(sex)(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                
            elseif strcmp(group, 'mwoa')
                mwoaDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).(sex)(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
end

plotFig = figure;
for stimulus = 1:length(stimuli)
    subplot(1,3,stimulus);
    data = nan(6,20);
    
    for contrast = 1:length(contrasts)
        data(contrast*2 - 1,1:length(controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male)) = controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male;
        data(contrast*2,1:length(controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female)) = controlDiscomfortBySex.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female;
        
    end
    
    categoryIdx = [ones(1,20); 2*ones(1,20); ones(1,20); 2*ones(1,20); ones(1,20); 2*ones(1,20)]';
    
    xValues = [0.8 1.2 1.8 2.2 2.8 3.2];
    categoryColors = {'b', [1 0.4 0.6]};
    
    plotSpread(data', 'categoryIdx', categoryIdx(:), 'categoryMarkers', {'o', 'o'}, 'xValues', xValues, 'categoryColors', categoryColors, 'showMM', 3)
    
    xticks([1:3])
    xticklabels({'100%', '200%', '400%'})
    xlabel('Contrast')
    ylabel('Discomfort Rating')
    title(stimuli{stimulus})
    
end
set(plotFig, 'Position', [-1811 170 1025 767], 'Units', 'pixels');

export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'compareResponses', ['discomfortBySex.pdf']));


%
% Want to get towards some kind of significance test, but label permutation
% as I currently have written it requires equal size samples in both
% groups...

%  stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
% contrasts = {100, 200, 400};
%
% fprintf('<strong>For comparison of Males vs. Females</strong>\n', stimuli{stimulus});
%
% for stimulus = 1:length(stimuli)
%     fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
%
%     for contrast = 1:length(contrasts)
%         fprintf('\tContrast: %s%%\n', num2str(contrasts{contrast}));
%
%         [ significance ] = evaluateSignificanceOfMedianDifference([controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Male, NaN, NaN, NaN, NaN, NaN, NaN], controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).Female, '~/Desktop', 'sidedness', 2);
%
%         fprintf('\t\tP-value: %4.4f\n', significance);
%
%
%
%     end
% end
%

