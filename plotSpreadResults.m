function [ha, plotFig] = plotSpreadResults(resultsStruct, varargin)

%% Parse the input

p = inputParser; p.KeepUnmatched = true;

p.addParameter('contrasts',{100, 200, 400});
p.addParameter('stimuli',{'LightFlux', 'Melanopsin', 'LMS'});
p.addParameter('yLabel', 'Discomfort Ratings', @ischar);
p.addParameter('yLims', [-0.5 10], @isnumeric);
p.addParameter('extremeValueMultiplier', 1.07, @isnumeric);
p.addParameter('saveName', [], @ischar);
p.addParameter('markerSize', 12, @isnumeric);
p.addParameter('nDecimals', 2, @isnumeric);


p.parse(varargin{:});

nGroups = length(fieldnames(resultsStruct));
if nGroups == 3
    groupNames = {'Controls', 'MwoA', 'MwA'};
elseif nGroups == 2
    groupNames = {'Controls', 'CombinedMigraineurs'};
elseif nGroups == 1
    groupNames = fieldnames(resultsStruct);
end
stimuli = p.Results.stimuli;
contrasts = p.Results.contrasts;


plotFig = figure; hold on;
[ha, pos] = tight_subplot(1,length(stimuli), 0.08);

for stimulus = 1:length(stimuli)
    nObservationsPerGroup = [];
    
    for ii = 1:(nGroups)
        nObservationsPerGroup(end+1) = length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{end})]));
    end
    data = nan(nGroups*length(contrasts), max(nObservationsPerGroup));
    extremeData = data;
    
    
    for contrast = 1:length(contrasts)
        
        axes(ha(stimulus)); hold on;
        
        %subplot(1,length(stimuli), stimulus); hold on;
        
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for ii = 1:nGroups
            data((contrast*nGroups)-(nGroups-ii),1:length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))) = resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        end
        fprintf('\tContrast: %s%%\n', num2str(contrasts{contrast}));
        for ii = 1:nGroups
            if p.Results.nDecimals == 2
                fprintf('\t\tMedian value for %s: %4.2f\n', groupNames{ii}, median(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])));
            elseif p.Results.nDecimals == 3
                fprintf('\t\tMedian value for %s: %4.3f\n', groupNames{ii}, median(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])));
            elseif p.Results.nDecimals == 4
                fprintf('\t\tMedian value for %s: %4.4f\n', groupNames{ii}, median(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])));
            end
        end
        
    end
    
    % find values that are outside of the inputted yLims
    originalData = data;
    [i,j]=find(data > p.Results.yLims(2));
    for ii = 1:length(i)
        data(i(ii), j(ii)) = NaN;
        extremeData(i(ii), j(ii)) = p.Results.yLims(2)*p.Results.extremeValueMultiplier;
    end
    
    
    
    categoryIdx = repmat([0:nGroups-1], max(nObservationsPerGroup), size(data,1)/nGroups);
    
    if nGroups == 3
        categoryColors = {'k', 'r', 'b'};
    elseif nGroups == 2
        categoryColors = {'k', 'r'};
    elseif nGroups == 1
        categoryColors = {'k'};
    end
    
    if length(contrasts) == 3
        if nGroups == 3
            xValues = [0.8 1 1.2 1.8 2 2.2 2.8 3 3.2];
        elseif nGroups == 2
            xValues = [0.8 1.2 1.8 2.2 2.8 3.2];
        elseif nGroups == 1
            xValues = [1:3];
        end
    elseif length(contrasts) == 1
        if nGroups == 3
            xValues = [0.8 1 1.2];
        elseif nGroups == 2
            xValues = [0.8 1.2];
        end
    end
    
    if stimulus == 1
        for ii = 1:nGroups
            categoryMarkers{ii} = '.';
        end
        
    elseif stimulus == 2
        for ii = 1:nGroups
            categoryMarkers{ii} = '.';
        end
        
    elseif stimulus == 3
        for ii = 1:nGroups
            categoryMarkers{ii} = '.';
        end
        
    end
    
    plotSpread(data', 'categoryIdx', categoryIdx(:), 'categoryMarkers', categoryMarkers, 'xValues', xValues, 'categoryColors', categoryColors, 'showMM', 0, 'categoryLabels', groupNames)
    plotSpread(extremeData', 'categoryIdx', categoryIdx(:), 'categoryMarkers', categoryMarkers, 'xValues', xValues, 'categoryColors', categoryColors, 'showMM', 0, 'categoryLabels', groupNames)

    axesCellArray = [];
    legendText = [];
    for ii = 1:nGroups
        if length(contrasts) == 3
            plot([1:length(contrasts)], [nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast100), ...
                nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast200), ...
                nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400)], ...
                '*', 'Color', categoryColors{ii}, 'MarkerSize', p.Results.markerSize);
            ax.(['ax', num2str(ii)]) = plot([1:length(contrasts)], [nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast100), ...
                nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast200), ...
                nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400)], ...
                'Color', categoryColors{ii});
            axesCellArray{end+1} = ax.(['ax', num2str(ii)]);
            legendText{end+1} = [groupNames{ii}, ', N = ', num2str(length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400))];
        elseif length(contrasts) == 1
            ax.(['ax', num2str(ii)]) = plot(xValues(ii), nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400), '*', 'Color', categoryColors{ii}, 'MarkerSize', p.Results.markerSize);
            legendText{end+1} = [groupNames{ii}, ', N = ', num2str(length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400))];
            
        end
    end
    
    if length(contrasts) == 3
        xticks([1:3])
        xticklabels({'100%', '200%', '400%'})
    elseif length(contrasts) == 1
        xticks([1])
        xticklabels({'400%'})
    end
    xlabel('Contrast')
    ylabel(p.Results.yLabel)
    title(stimuli{stimulus})
    
    % adjust yLims if there are extreme data
    if sum(sum(isnan(extremeData))) == size(extremeData,1) * size(extremeData,2)
    
        ylim(p.Results.yLims)
        yticklabels(yticks);
        
    else
                yTicksNotToDisplay = find(yticks > p.Results.yLims(2));
        yTicksToDisplay = yticks;
        yTicksToDisplay(yTicksNotToDisplay) = NaN;
        yticklabels(yticks);
        ylim([p.Results.yLims(1), (p.Results.yLims(2)*p.Results.extremeValueMultiplier - p.Results.yLims(2)*1.05 + p.Results.yLims(2)*p.Results.extremeValueMultiplier)])
    end
    if length(contrasts) == 3
        xlim([0.5 3.5])
    elseif length(contrasts) == 1
        xlim([0.5 1.5])
    end
    line([0.5 3.5], [p.Results.yLims(2)*1.05, p.Results.yLims(2)*1.05], 'LineStyle', '--', 'Color', 'k');
    
    if stimulus == length(stimuli)
        if nGroups == 2
            legend([ax.ax1, ax.ax2], legendText{1}, legendText{2}, 'Location', 'NorthWest')
        elseif nGroups == 3
            legend([ax.ax1, ax.ax2, ax.ax3], legendText{1}, legendText{2}, legendText{3}, 'Location', 'NorthWest')
            
        end
        legend('boxoff')
    end
    
    savePath = fileparts(p.Results.saveName);
    if ~exist(savePath, 'dir')
        mkdir(savePath)
    end
    set(plotFig, 'Position', [-1811 170 1025 767], 'Units', 'pixels');
    export_fig(plotFig, fullfile(p.Results.saveName));
    
end

end