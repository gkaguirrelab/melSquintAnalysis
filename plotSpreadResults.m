function plotSpreadResults(resultsStruct, varargin)

%% Parse the input

p = inputParser; p.KeepUnmatched = true;

p.addParameter('contrasts',{100, 200, 400});
p.addParameter('stimuli',{'Melanopsin', 'LMS', 'LightFlux'});
p.addParameter('yLabel', 'Discomfort Ratings', @ischar);
p.addParameter('yLims', [-0.5 10], @isnumeric);
p.addParameter('saveName', [], @ischar);


p.parse(varargin{:});

nGroups = length(fieldnames(resultsStruct));
if nGroups == 3
    groupNames = {'Controls', 'MwoA', 'MwA'};
elseif nGroups == 2
    groupNames = {'Controls', 'CombinedMigraineurs'};
end
stimuli = p.Results.stimuli;
contrasts = p.Results.contrasts;


plotFig = figure;
for stimulus = 1:length(stimuli)
    nObservationsPerGroup = [];
    
    for ii = 1:(nGroups)
        nObservationsPerGroup(end+1) = length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{end})]));
    end
    data = nan(nGroups*length(contrasts), max(nObservationsPerGroup));
    
    
    for contrast = 1:length(contrasts)
        
        
        subplot(1,length(stimuli), stimulus); hold on;
        
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for ii = 1:nGroups
            data((contrast*nGroups)-(nGroups-ii),1:length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))) = resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        end
        fprintf('\tContrast: %s%%\n', num2str(contrasts{contrast}));
        for ii = 1:nGroups
            fprintf('\t\tMedian value for %s: %4.2f\n', groupNames{ii}, median(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])));
            
        end
        
    end
    
    categoryIdx = repmat([0:nGroups-1], max(nObservationsPerGroup), size(data,1)/nGroups);
    
    if nGroups == 3
        xValues = [0.8 1 1.2 1.8 2 2.2 2.8 3 3.2];
        categoryColors = {'k', 'r', 'b'};
    elseif nGroups == 2
        xValues = [0.8 1.2 1.8 2.2 2.8 3.2];
        categoryColors = {'k', 'r'};
    end
    
    plotSpread(data', 'categoryIdx', categoryIdx(:), 'xValues', xValues, 'categoryColors', categoryColors, 'showMM', 0, 'categoryLabels', groupNames)
    
    axesCellArray = [];
    legendText = [];
    for ii = 1:nGroups
        plot([1:length(contrasts)], [nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast100), ...
            nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast200), ...
            nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400)], ...
            '*', 'Color', categoryColors{ii}, 'MarkerSize', 12);
        ax.(['ax', num2str(ii)]) = plot([1:length(contrasts)], [nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast100), ...
            nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast200), ...
            nanmedian(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400)], ...
            'Color', categoryColors{ii});
        axesCellArray{end+1} = ax.(['ax', num2str(ii)]);
        legendText{end+1} = [groupNames{ii}, ', N = ', num2str(length(resultsStruct.(groupNames{ii}).(stimuli{stimulus}).Contrast400))];
    end
    
    xticks([1:3])
    xticklabels({'100%', '200%', '400%'})
    xlabel('Contrast')
    ylabel(p.Results.yLabel)
    title(stimuli{stimulus})
    ylim(p.Results.yLims)
    
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
    set(plotFig, 'Position', [85 230 1633 748], 'Units', 'pixels');
    export_fig(plotFig, fullfile(p.Results.saveName));
    
end

end