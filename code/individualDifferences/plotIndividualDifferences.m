function plotIndividualDifferences(x, y, varargin)

p = inputParser; p.KeepUnmatched = true;
p.addParameter('plotLineOfBestFit',true,@islogical);
p.addParameter('plotUnityLine',true,@islogical);
p.addParameter('color','r',@ischar);
p.addParameter('significance','rho',@ischar);
p.addParameter('figureWidthInches', 5, @isnumeric);
p.addParameter('figureHeightInches', 5, @isnumeric);
p.addParameter('xLims', [], @isnumeric);
p.addParameter('yLims', [], @isnumeric);
p.addParameter('xTicks', [], @isnumeric);
p.addParameter('yTicks', [], @isnumeric);
p.addParameter('xLabel', [], @ischar);
p.addParameter('yLabel', [], @ischar);
p.addParameter('saveName',[],@ischar);
p.addParameter('savePath',[],@ischar);


p.parse(varargin{:});

plotlabOBJ = plotlab();





plotlabOBJ.applyRecipe(...
    'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
    'lightTheme', 'light', ...
    'lineMarkerSize', 12, ...
    'figureWidthInches', p.Results.figureWidthInches, ...
    'figureHeightInches', p.Results.figureHeightInches)
hFig = figure(1); clf; hold on;

if p.Results.plotUnityLine
   plot(-1000:1000, -1000:1000, '-.', 'Color', 'k', 'LineWidth', 1) 
end

% make sure vectors are row vectors
if size(x,1) == 1
    x = x';
    y = y';
end

s = scatter(x,y, 'w')
s.MarkerFaceAlpha = 1;


scatter(x,y, p.Results.color)

if p.Results.plotLineOfBestFit
    xnan = isnan(x);
    
    xnanlist = [];
    hits = 0;
    for xx = 1:length(x)
        if xnan(xx) == 1
            hits = hits+1;
            x(xx-(hits-1)) = [];
            y(xx-(hits-1)) = [];
            
        end
    end
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 2, 'Color', p.Results.color)
    
end

if strcmp(p.Results.significance, 'rho') || strcmp(p.Results.significance, 'spearman')
    
    rho = corr(x, y, 'type', 'Spearman');
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    title(sprintf(['rho = ', sprintf('%.2f', rho)]));
    
elseif strcmp(p.Results.significance, 'r') || strcmp(p.Results.significance, 'pearson')

    r = corr2(x, y);
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    title(sprintf(['r = ', num2str(r)]));
    
end




ylim([p.Results.yLims]);
xlim([p.Results.xLims]);
xticks(p.Results.xTicks);
yticks(p.Results.yTicks);
xlabel(p.Results.xLabel);
ylabel(p.Results.yLabel);
pbaspect([1 1 1])
axis square

plotlabOBJ.exportFig(hFig, 'pdf', p.Results.saveName, p.Results.savePath)

end