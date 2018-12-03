function makeSparklines(varargin)

%% load in list of sessions to run
analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/');

[~, ~, sessionTable] = xlsread(fullfile(analysisBasePath, 'whichSessions.xlsx'));

%% loop over subjects
averageResponseStructAccumulator = [];
for ss = 2:size(sessionTable, 1)
    subjectID = sessionTable{ss,1};
    
    numberOfGoodSessions = 1;
    sessionID = [];
    if ~isnan(sessionTable{ss,2})
        sessionID{numberOfGoodSessions} = sessionTable{ss,2};
        numberOfGoodSessions = numberOfGoodSessions + 1 ;
    end
    if ~isnan(sessionTable{ss,3})
        sessionID{numberOfGoodSessions} = sessionTable{ss,3};
        numberOfGoodSessions = numberOfGoodSessions + 1 ;
    end
    if ~isnan(sessionTable{ss,4})
        sessionID{numberOfGoodSessions} = sessionTable{ss,4};
        numberOfGoodSessions = numberOfGoodSessions + 1 ;
    end
    if ~isnan(sessionTable{ss,5})
        sessionID{numberOfGoodSessions} = sessionTable{ss,5};
        numberOfGoodSessions = numberOfGoodSessions + 1 ;
    end
    
    if ~isempty(sessionID)
        [averageResponseStruct, trialStruct] = makeSubjectAverageResponses_interpolateLast(subjectID, 'sessions', sessionID);
        averageResponseStructAccumulator{end + 1} = averageResponseStruct;
    end
    
    
end

%% make the sparkline plot
% we are going to skip plotting the first and last seconds (they're
% particularly noisy and uninformative)
firstIndexToPlot = 61;
lastIndexToPlot = 1081;

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

plotFig = figure;
hold on
%for ss = 1:length(averageResponseStructAccumulator)
counter = 1;
for ss = [5,3,4,6,7,8,10, 12, 19, 1, 2, 9, 11, 13:18]
    for stimulus = 1:length(stimuli)
        
        x1 = (lastIndexToPlot - firstIndexToPlot)*(stimulus - 1) + xoffset*(stimulus - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        
        response100 = averageResponseStructAccumulator{ss}.(stimuli{stimulus}).Contrast100(firstIndexToPlot:lastIndexToPlot) - yoffset*(counter-1);
        response200 = averageResponseStructAccumulator{ss}.(stimuli{stimulus}).Contrast200(firstIndexToPlot:lastIndexToPlot) - yoffset*(counter-1);
        response400 = averageResponseStructAccumulator{ss}.(stimuli{stimulus}).Contrast400(firstIndexToPlot:lastIndexToPlot) - yoffset*(counter-1);
        
        
        plot(x, response100, 'Color', colors.(stimuli{stimulus}){1}, 'LineWidth', 2);
        plot(x, response200, 'Color', colors.(stimuli{stimulus}){2}, 'LineWidth', 2);
        plot(x, response400, 'Color', colors.(stimuli{stimulus}){3}, 'LineWidth', 2);
        
        
    end
            counter = counter + 1;

end

axis off
set(gcf, 'Renderer', 'painters')
print(plotFig, fullfile('~/Desktop','sparkline'), '-dpdf')



end