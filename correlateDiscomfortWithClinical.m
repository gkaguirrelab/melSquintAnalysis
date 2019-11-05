%% Set up some paths

dataBasePath = getpref('melSquintAnalysis','melaDataPath');
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

pathToSurveyData = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'surveyMelanopsinAnalysis', 'MELA_ScoresSurveyData_Squint.xlsx');
surveyTable = readtable(pathToSurveyData);

%% Correlate VDS with discomfort rating
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
contrasts = {400};


controlVDS = [];
mwaVDS = [];
mwoaVDS = [];


columnNames = surveyTable.Properties.VariableNames;
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
    
end

%% Check whether sex differences can account for our group results