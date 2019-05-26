function makeSparklines(varargin)

load('/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat')
subjectList = generateSubjectList;
%% make the sparkline plot
% we are going to skip plotting the first and last seconds (they're
% particularly noisy and uninformative)
firstIndexToPlot = 61;
lastIndexToPlot = 1061;

% how much to horizontally shift responses of different stimulus types
xoffset = 200;
% how much to vertically shift responses from different subjects
yoffset = 0.6;

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
colors.Melanopsin{1} = [220/255, 237/255, 200/255];
colors.Melanopsin{2} = [66/255, 179/255, 213/255];
colors.Melanopsin{3} = [26/255, 35/255, 126/255];

grayColormap = colormap(gray);
colors.LMS{1} = grayColormap(50,:);
colors.LMS{2} = grayColormap(25,:);
colors.LMS{3} = grayColormap(1,:);

colors.LightFlux{1} = [254/255, 235/255, 101/255];
colors.LightFlux{2} = [228/255, 82/255, 27/255];
colors.LightFlux{3} = [77/255, 52/255, 47/255];



%%
nColumns = 3;
nRows = ceil(length(subjectList)/nColumns);
for stimulus = 1:length(stimuli)
    plotFig = figure; hold on;
    for ss = 1:length(subjectList)
        [rowNumber, columnNumber] = ind2sub([nRows, nColumns], ss);
        x1 = (lastIndexToPlot - firstIndexToPlot)*(columnNumber - 1) + xoffset*(columnNumber - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        
        response100 = averageResponseMatrix.(stimuli{stimulus}).Contrast100(ss, firstIndexToPlot:lastIndexToPlot) - yoffset*(rowNumber-1);
        response200 = averageResponseMatrix.(stimuli{stimulus}).Contrast200(ss, firstIndexToPlot:lastIndexToPlot) - yoffset*(rowNumber-1);
        response400 = averageResponseMatrix.(stimuli{stimulus}).Contrast400(ss, firstIndexToPlot:lastIndexToPlot) - yoffset*(rowNumber-1);
        
        
        plot(x, response100, 'Color', colors.(stimuli{stimulus}){1}, 'LineWidth', 2);
        plot(x, response200, 'Color', colors.(stimuli{stimulus}){2}, 'LineWidth', 2);
        plot(x, response400, 'Color', colors.(stimuli{stimulus}){3}, 'LineWidth', 2);
        
    end
    
    
    axis off
    set(gcf, 'Renderer', 'painters')
    print(plotFig, fullfile('~/Desktop',['sparkline_', stimuli{stimulus}]), '-dpdf')
end



end