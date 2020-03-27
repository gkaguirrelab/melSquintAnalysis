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
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast100(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color',  'k')
        plot(x, pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color','k')
        
        combined400Response = (pupilStruct.responseOverTime.experiment_1.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot) + pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast400(ss,firstIndexToPlot:lastIndexToPlot))./2;
        plot(x, combined400Response - yoffset*(ss-1), '-', 'Color', 'b')
        
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast800(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', 'r')
        plot(x, pupilStruct.responseOverTime.experiment_2.(stimuli{stimulus}).Contrast1200(ss,firstIndexToPlot:lastIndexToPlot) - yoffset*(ss-1), '-', 'Color', 'r')

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




    
    
end
