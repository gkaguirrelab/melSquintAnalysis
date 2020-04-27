function makeDeuteranopeSparklines
%% Basic parameters

% first and last indices are noisy, so let's not plot them
firstIndexToPlot = 40;
lastIndexToPlot = 1111-40;

% how much to horizontally shift responses of different stimulus types
xoffset = 200;
% how much to vertically shift responses from different subjects
yoffset = 0.8;

stimuli = {'LightFlux', 'Melanopsin', 'LS'};

pupilStruct = loadPupilResponses('protocol', 'Deuteranopes');
nSubjects = length(fieldnames(pupilStruct.subjects.experiment1));


%% All responses plotted together
plotlabOBJ = plotlab();

plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', 10, ...
    'figureHeightInches', 6);

hFig = figure(1); clf; hold on;

for ss = 1:(nSubjects)
    for stimulus = 1:length(stimuli)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast100(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [0.6 0.6 0.6])
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', [0 0 0])
        
        combined400Response = (pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) + pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot))./2;
        plot(x, combined400Response - yoffset*(ss-1), '-', 'Color', 'k')
        plot(x, combined400Response - yoffset*(ss-1), '--', 'Color', 'r')

        
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast800(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', [1 0.6 0.6])
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast1200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', [1 0 0])
        
    end
end
set(gca, 'XGrid', 'off')
set(gca, 'YGrid', 'off')
axis off

for stimulus = 1:length(stimuli)
    x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
    xEnd = x1+(lastIndexToPlot - firstIndexToPlot);
    xMid = (x1+xEnd)/2;
    
    text(xMid, 0.3, stimuli{stimulus}, 'FontSize', 20, 'FontName', 'Helvetica', 'HorizontalAlignment', 'Center');
    
    
end
plotlabOBJ.exportFig(hFig, 'pdf', 'sparklines', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes'));

%% All responses plotted together
plotlabOBJ = plotlab();

plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', 10, ...
    'figureHeightInches', 6);

hFig = figure(1); clf; hold on;

for ss = 1:(nSubjects)
    for stimulus = 1:length(stimuli)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  'k')
        
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', 'r')
        
    end
end
set(gca, 'XGrid', 'off')
set(gca, 'YGrid', 'off')
axis off

for stimulus = 1:length(stimuli)
    x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
    xEnd = x1+(lastIndexToPlot - firstIndexToPlot);
    xMid = (x1+xEnd)/2;
    
    text(xMid, 0.3, stimuli{stimulus}, 'FontSize', 20, 'FontName', 'Helvetica', 'HorizontalAlignment', 'Center');
    
    
end
plotlabOBJ.exportFig(hFig, 'pdf', 'sparklines_400Only', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes'));

%% Just Experiment 1
plotlabOBJ = plotlab();

plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', 10, ...
    'figureHeightInches', 6);

hFig = figure(1); clf; hold on;

for ss = 1:(nSubjects)
    for stimulus = 1:length(stimuli)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast100(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [0.8 0.8 0.8])
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [0.4 0.4 0.4])
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [0 0 0])
        
        
    end
end
set(gca, 'XGrid', 'off')
set(gca, 'YGrid', 'off')
axis off

for stimulus = 1:length(stimuli)
    x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
    xEnd = x1+(lastIndexToPlot - firstIndexToPlot);
    xMid = (x1+xEnd)/2;
    
    text(xMid, 0.3, stimuli{stimulus}, 'FontSize', 20, 'FontName', 'Helvetica', 'HorizontalAlignment', 'Center');
    
    
end
plotlabOBJ.exportFig(hFig, 'pdf', 'sparklines_experiment1', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes'));


%% Just Experiment 2
plotlabOBJ = plotlab();

plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', 10, ...
    'figureHeightInches', 6);

hFig = figure(1); clf; hold on;

for ss = 1:(nSubjects)
    for stimulus = 1:length(stimuli)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [1 0.8 0.8])
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast800(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [1 0.4 0.4])
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast1200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  [1 0 0])
        
        
    end
end
set(gca, 'XGrid', 'off')
set(gca, 'YGrid', 'off')
axis off

for stimulus = 1:length(stimuli)
    x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
    xEnd = x1+(lastIndexToPlot - firstIndexToPlot);
    xMid = (x1+xEnd)/2;
    
    text(xMid, 0.3, stimuli{stimulus}, 'FontSize', 20, 'FontName', 'Helvetica', 'HorizontalAlignment', 'Center');
    
    
end
plotlabOBJ.exportFig(hFig, 'pdf', 'sparklines_experiment2', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes'));

%% Deuteranope trichromat comparison
%[ trichromatResponses ] = loadPupilResponses('protocol', 'SquintToPulse');

contrasts = {100, 200, 400};

plotlabOBJ = plotlab();

plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', 10, ...
    'figureHeightInches', 6);

hFig = figure(1); clf; hold on;

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        
        if strcmp(stimuli{stimulus}, 'LS')
            trichromatResponse = nanmean(trichromatResponses.responseOverTime.controls.LMS.(['Contrast', num2str(contrasts{contrast})]));
        else
            trichromatResponse = nanmean(trichromatResponses.responseOverTime.controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
        end
        deuteranopeResponse = nanmean(pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
        
        plot(x, trichromatResponse(1,firstIndexToPlot:lastIndexToPlot) - yoffset*(contrast-1), 'Color',  'b')
        plot(x, deuteranopeResponse(1,firstIndexToPlot:lastIndexToPlot) - yoffset*(contrast-1), 'Color',  'k')
        
        
    end
end

for contrast = 1:length(contrasts)
    text(-200, -0.2-yoffset*(contrast-1), [num2str(contrasts{contrast}), '%'], 'HorizontalAlignment', 'Right', 'FontSize', 20, 'FontName', 'Helvetica');
    
end

set(gca, 'XGrid', 'off')
set(gca, 'YGrid', 'off')
axis off

for stimulus = 1:length(stimuli)
    x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
    xEnd = x1+(lastIndexToPlot - firstIndexToPlot);
    xMid = (x1+xEnd)/2;
    
    text(xMid, 0.3, [stimuli{stimulus}], 'FontSize', 20, 'FontName', 'Helvetica', 'HorizontalAlignment', 'Center');
    
    
end

plotlabOBJ.exportFig(hFig, 'pdf', 'sparklines_experiment1_trichomats', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes'));




end
