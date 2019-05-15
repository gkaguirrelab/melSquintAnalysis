function [ sessionList ] = getSessionsList(varargin)

p = inputParser; p.KeepUnmatched = true;
p.addParameter('whichDirectory','DataFiles',@ischar);
p.addParameter('makePlots',false,@islogical);
% Parse and check the parameters
p.parse(varargin{:});

projectName = 'melSquintAnalysis';
directionObjectsBase = fullfile(getpref(projectName, 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/', p.Results.whichDirectory);

% determine the session for this subject
sessions = dir(fullfile(directionObjectsBase, 'MELA*'));

sessionList.ID = [];
sessionList.date = [];
counter = 1;
for subjectIndex = 1:size(sessions,1)
    potentialSessionDates = dir(fullfile(directionObjectsBase, sessions(subjectIndex).name));
    for potentialDateIndex = 1:size(potentialSessionDates,1)
        if strcmp(potentialSessionDates(potentialDateIndex).name(1), '2') || strcmp(potentialSessionDates(potentialDateIndex).name(1), 'x')
            % it's a real date
            sessionList.ID{counter} = sessions(subjectIndex).name;
            sessionList.date{counter} = potentialSessionDates(potentialDateIndex).name;
            counter = counter + 1;
        end
    end
end

if p.Results.makePlots
    for dd = 1:length(sessionList.date)
        date = strsplit(sessionList.date{dd}, '_');
        date = date{1};
        if strcmp(date(1), 'x')
            date = date(2:end);
        end
        dates(dd) = datenum(date, 'yyyy-mm-dd');
        sortedDates = sort(dates);
    end
    plotFig = figure;
    plot(sortedDates, 1:length(sortedDates))
    axesInfo = gca;
    x1OG = axesInfo.XLim(1);
    x2OG =  axesInfo.XLim(2);
    datetick('x', 29)
    xlabel('Date')
    ylabel('Total Number of Sessions')
    
    plotFig = figure;
    hold on
    
    
    plot(sortedDates, 1:length(sortedDates))
    axesInfo = gca;
    x1 = axesInfo.XLim(1);
    x2 = axesInfo.XLim(2);
    line([x1OG, x2OG], [480 480], 'Color', 'r', 'LineStyle', '--')
    datetick('x', 29)
    xlabel('Date')
    ylabel('Total Number of Sessions')
    ylim([0 500])
    xlim([x1, x2])
    
    plotFig = figure;
    hold on
    plot(sortedDates, 1:length(sortedDates))
    beginningIndex = 55;
    endingIndex = 77;
    x = sortedDates(beginningIndex:endingIndex);
    y = beginningIndex:endingIndex;
    c = polyfit(x,y,1);
    y_est = polyval(c,737331:(datenum('2020-01-01', 'yyyy-mm-dd')));
    x_new = 737331:(datenum('2020-01-01', 'yyyy-mm-dd'));
    plot(x_new, y_est, 'Color', 'b', 'LineStyle', '--')
    axesInfo = gca;
    x1 = axesInfo.XLim(1);
    x2 = axesInfo.XLim(2);
    line([x1, x2], [480 480], 'Color', 'r', 'LineStyle', '--')
    xlabel('Date')
    ylabel('Total Number of Sessions')
    ylim([0 500]);
    xlim([x1OG, x_new(410)]);
    datetick('x', 29, 'keeplimits')

end


end