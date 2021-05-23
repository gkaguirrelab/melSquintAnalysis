function combineResponsesAcrossStimuli(responseStruct, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('yLabel',[], @ischar);
p.addParameter('saveName',[], @ischar);


p.parse(varargin{:});

groups = {'mwa', 'mwoa', 'controls'};
groupColors = {'b', 'r', 'k'};
contrasts = {100, 200, 400};

plotFig = figure; hold on;

SEMPooler = [];
meanPooler = [];

% Do the analysis
for group = 1:length(groups)
    for contrast = 1:length(contrasts)
        
        pooledResponses = [responseStruct.(groups{group}).LightFlux.(['Contrast', num2str(contrasts{contrast})]), responseStruct.(groups{group}).LMS.(['Contrast', num2str(contrasts{contrast})]), responseStruct.(groups{group}).Melanopsin.(['Contrast', num2str(contrasts{contrast})])];
        
        meanResponse = nanmean(pooledResponses);
        SEM = nanstd(pooledResponses)/(sqrt(length(pooledResponses)));
        
        meanPooler.(groups{group})(contrast) = meanResponse;
        SEMPooler.(groups{group})(contrast) = SEM;
        
        %plot(contrast, meanResponse, 'o', 'Color', groupColors{group})
        
    end
end

% Do the plotting
for group = 1:length(groups)
    plot([1:3], meanPooler.(groups{group}), 'o', 'Color', groupColors{group}, 'MarkerFaceColor',  groupColors{group}, 'MarkerSize', 8);
    
    % Plot line of best fit
    x = 1:3;
    coeffs = polyfit(x,meanPooler.(groups{group}),1);
    plot(x,x*coeffs(1)+coeffs(2), 'Color', groupColors{group}, 'MarkerFaceColor',  groupColors{group}, 'LineWidth', 3)
    
    % add SEM plot
    for contrast = 1:length(contrasts)
        lh = line([contrast, contrast], [meanPooler.(groups{group})(contrast)-SEMPooler.(groups{group})(contrast), meanPooler.(groups{group})(contrast)+SEMPooler.(groups{group})(contrast)], 'Color', groupColors{group}, 'LineWidth', 3);
        lh.Color(4) = 0.2;
        
    end
end

% Tidy up the plot
xlim([0.5 3.5]);
xticks(1:3);
xticklabels({'100%', '200%', '400%'});
xlabel('Contrast');
ylabel(p.Results.yLabel);

if ~isempty(p.Results.saveName)
    export_fig(plotFig, p.Results.saveName);
end




end