function plotDeuteranopeResult(experiment1ResultsStruct, experiment2ResultsStruct, trichromatStruct, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('savePath', [] ,@isstr);
p.addParameter('saveName', [] ,@isstr);
p.addParameter('yLims', [] ,@isnumeric);
p.addParameter('yTicks', [0 5 10] ,@isnumeric);
p.addParameter('yTickLabels', [0 5 10]);
p.addParameter('shiftDistance', 0.5, @isnumeric);
p.addParameter('stimulusLabelMultiplier', 1.2 ,@isnumeric);
p.addParameter('figureWidthInches', 15, @isnumeric);
p.addParameter('figureHeightInches', 5, @isnumeric);
p.addParameter('yLimsMultiplier', 1.3 ,@isnumeric);
p.addParameter('yLabel', [] ,@ischar);
p.addParameter('whichPlot', 'experimentComparison' ,@ischar);
p.addParameter('errorType', 'SEM' ,@ischar);
p.addParameter('legendLocation', 'eastoutside' ,@ischar);


p.parse(varargin{:})

plotlabOBJ = plotlab();



if strcmp(p.Results.whichPlot, 'experimentComparison')
    
    % Apply the default plotlab recipe overriding
    % the color order and the figure size
    plotlabOBJ.applyRecipe(...
        'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
        'lightTheme', 'light', ...
        'lineMarkerSize', 12, ...
        'figureWidthInches', p.Results.figureWidthInches, ...
        'figureHeightInches', p.Results.figureHeightInches);
    
    
    hFig = figure(1); clf; hold on;
    
    if ~isempty(experiment1ResultsStruct)
        stimuli = fieldnames(experiment1ResultsStruct);
    else
        stimuli = fieldnames(experiment2ResultsStruct);
    end
    
    %plotFig = figure;
    xValues = [];
    shiftDistance = p.Results.shiftDistance;
    for stimulus = 1:length(stimuli)
        %subplot(1,3,stimulus); hold on;
        %title(stimuli{stimulus});
        
        if ~isempty(experiment2ResultsStruct)
            if isempty(experiment1ResultsStruct)
                xShift =(stimulus - 1) *  shiftDistance + ((log10(1200)-log10(400))*(stimulus-1));
                xRange = [log10(400), log10(800), log10(1200)];
            else
                xShift =(stimulus - 1) *  shiftDistance + ((log10(1200)-log10(100))*(stimulus-1));
                xRange = [log10(100), log10(200), log10(400), log10(800), log10(1200)];
            end
        else
            xShift = (stimulus - 1) * shiftDistance + ((log10(400)-log10(100))*(stimulus-1));
            xRange = [log10(100), log10(200), log10(400)];
            
        end
        xValues = [xValues, xRange+xShift];
        
        
        if ~isempty(trichromatStruct)
            trichromatStimulusName = stimuli{stimulus};
            if strcmp(trichromatStimulusName, 'LS')
                trichromatStimulusName = 'LMS';
            end
            lineProps.col{1} = 'b';
            if strcmp(p.Results.errorType, 'IQR')
                errorLower = [[(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))] - [(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 25)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 25)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 25))]];
                errorUpper = ([(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 75)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 75)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 75))] - [(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))]);
            elseif strcmp(p.Results.errorType, 'SEM')
                SEM = [std(trichromatStruct.(trichromatStimulusName).Contrast100)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast100)), std(trichromatStruct.(trichromatStimulusName).Contrast200)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast200)), std(trichromatStruct.(trichromatStimulusName).Contrast400)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast400))];
                errorUpper = SEM*2;
                errorLower = SEM*2;
            end
            errorToPlot(1,1:3, 1) = errorUpper;
            errorToPlot(1,1:3, 2) = errorLower;
            trichromatPlot = plot([log10(100), log10(200), log10(400)]+xShift, [(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))], 'Color', 'b');
            mseb([log10(100), log10(200), log10(400)]+xShift, [(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))], ...
                errorToPlot, lineProps, 1);
            
            
        end
        
        if ~isempty(experiment1ResultsStruct)
            
            for ss = 1:length(experiment1ResultsStruct.LightFlux.Contrast400)
                scatter([log10(100), log10(200), log10(400)]+xShift, [experiment1ResultsStruct.(stimuli{stimulus}).Contrast100(ss), experiment1ResultsStruct.(stimuli{stimulus}).Contrast200(ss), experiment1ResultsStruct.(stimuli{stimulus}).Contrast400(ss)], 'k')
            end
            
            data = [experiment1ResultsStruct.(stimuli{stimulus}).Contrast100; experiment1ResultsStruct.(stimuli{stimulus}).Contrast200; experiment1ResultsStruct.(stimuli{stimulus}).Contrast400];
            %plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
            
        end
        
        if ~isempty(experiment2ResultsStruct)
            for ss = 1:length(experiment2ResultsStruct.LightFlux.Contrast400)
                scatter([log10(400), log10(800), log10(1200)]+xShift, [experiment2ResultsStruct.(stimuli{stimulus}).Contrast400(ss), experiment2ResultsStruct.(stimuli{stimulus}).Contrast800(ss), experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200(ss)], 'r')
            end
            
            data = [experiment2ResultsStruct.(stimuli{stimulus}).Contrast400; experiment2ResultsStruct.(stimuli{stimulus}).Contrast800; experiment2ResultsStruct.(stimuli{stimulus}).Contrast400];
            %plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
            
            experiment2Plot = plot([log10(400), log10(800), log10(1200)]+xShift, [mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast400), mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast800), mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');
            %experiment1Plot = scatter([log10(400), log10(800), log10(1200)], [mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast400), mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast800), mean(experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200)], 300, 'ro', 'MarkerFaceAlpha',1);
        end
        
        if ~isempty(experiment1ResultsStruct)
            experiment1Plot = plot([log10(100), log10(200), log10(400)]+xShift, [mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast100), mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast200), mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast400)], 'Color', 'k');
            %experiment1Plot = scatter([log10(100), log10(200), log10(400)], [mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast100), mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast200), mean(experiment1ResultsStruct.(stimuli{stimulus}).Contrast400)], 300, 'ko', 'MarkerFaceAlpha',1);
        end
        
        if stimulus == 3
            if isempty(experiment2ResultsStruct)
                xticks(xValues);
                xticklabels({'100%', '200%', '400%', '100%', '200%', '400%', '100%', '200%', '400%'});
                
            elseif isempty(experiment1ResultsStruct) && isempty(trichromatStruct)
                xticks(xValues);
                xticklabels({'400%', '800%', '1200%', '400%', '800%', '1200%', '400%', '800%', '1200%'});
                
            else
                xticks(xValues);
                xticklabels({'100%', '200%', '400%', '800%', '1200%', '100%', '200%', '400%', '800%', '1200%', '100%', '200%', '400%', '800%', '1200%'});
            end
            xtickangle(30);
            xlabel('Contrast')
        end
        
        ylim([p.Results.yLims(1), p.Results.yLims(2)]);
        yticks(p.Results.yTicks);
        yticklabels(p.Results.yTickLabels);
        xlim([xValues(1) - 0.5*shiftDistance, xValues(end) + 0.5*shiftDistance])
        
        if stimulus == 1
            ylabel(p.Results.yLabel)
        end
        
        set(gca, 'XGrid', 'off')
        %text(mean([xRange(1), xRange(end)])+xShift, p.Results.yLims(2) * p.Results.stimulusLabelMultiplier, stimuli{stimulus}, 'HorizontalAlignment','center', 'FontName', 'Helvetica', 'FontSize', 20)
        
        
        if stimulus == 3
            if isempty(experiment2ResultsStruct) || isempty(experiment1ResultsStruct)
                if isempty(experiment2ResultsStruct) && ~isempty(experiment1ResultsStruct) && ~isempty(trichromatStruct)
                    legend([experiment1Plot, trichromatPlot], 'Experiment 1', 'Trichromats', 'Location', p.Results.legendLocation);
                    legend('boxoff')
                end
            elseif isempty(trichromatStruct)
                legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2', 'Location', p.Results.legendLocation);
                legend('boxoff')
                
            else
                legend([experiment1Plot, experiment2Plot, trichromatPlot], 'Experiment 1', 'Experiment 2', 'Trichromats', 'Location', p.Results.legendLocation);
                legend('boxoff')
            end
        end
    end
    
    % add annotations to label stimulus conditions
    for stimulus = 1:length(stimuli)
        axisPosition = get(gca, 'Position');
        xLocation = (((stimulus*2)-1)/6*axisPosition(3)+axisPosition(1))/p.Results.figureWidthInches;
        annotation('textbox', [xLocation, 1, 0, 0], 'string', stimuli{stimulus}, 'FontName', 'Helvetica', 'FontSize', 20, 'HorizontalAlignment','center')
        
    end
    
elseif strcmp(p.Results.whichPlot, '400Comparison')
    
    % Apply the default plotlab recipe overriding
    % the color order and the figure size
    plotlabOBJ.applyRecipe(...
        'colorOrder', [1 0 0; 0 0 1; 0 0 0], ...
        'lightTheme', 'light', ...
        'lineMarkerSize', 12, ...
        'figureWidthInches', p.Results.figureWidthInches, ...
        'figureHeightInches', p.Results.figureHeightInches);
    
    
    hFig = figure(1); clf; hold on;
    stimuli = fieldnames(experiment1ResultsStruct);
    shiftDistance = p.Results.shiftDistance;
    xValues = [];
    for stimulus = 1:length(stimuli)
        
        %         ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
        %         title(stimuli{stimulus})
        
        
        %subplot(1,3,stimulus); hold on;
        %title(stimuli{stimulus});
        
        
        xShift = (stimulus - 1) * shiftDistance + (1*(stimulus-1));
        xRange = [1 2];
        
        
        xValues = [xValues, xRange+xShift];
        
        if ~isempty(trichromatStruct)
            trichromatStimulusName = stimuli{stimulus};
            if strcmp(trichromatStimulusName, 'LS')
                trichromatStimulusName = 'LMS';
            end
            lineProps.col{1} = 'b';
            if strcmp(p.Results.errorType, 'IQR')
                errorLower = [[(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))] - [(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 25)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 25)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 25))]];
                errorUpper = ([(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 75)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 75)), (prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 75))] - [(mean(trichromatStruct.(trichromatStimulusName).Contrast100)), (mean(trichromatStruct.(trichromatStimulusName).Contrast200)), (mean(trichromatStruct.(trichromatStimulusName).Contrast400))]);
            elseif strcmp(p.Results.errorType, 'SEM')
                SEM = [std(trichromatStruct.(trichromatStimulusName).Contrast100)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast100)), std(trichromatStruct.(trichromatStimulusName).Contrast200)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast200)), std(trichromatStruct.(trichromatStimulusName).Contrast400)./sqrt(length(trichromatStruct.(trichromatStimulusName).Contrast400))];
                errorUpper = SEM*2;
                errorLower = SEM*2;
            end
            errorToPlot(1,1:2, 1) = [errorUpper(3) errorUpper(3)];
            errorToPlot(1,1:2, 2) = [errorLower(3) errorLower(3)];
            trichromatPlot = plot([0.75 2.25]+xShift, [(mean(trichromatStruct.(trichromatStimulusName).Contrast400)) (mean(trichromatStruct.(trichromatStimulusName).Contrast400))], 'Color', 'b');
            mseb([0.75 2.25]+xShift, [(mean(trichromatStruct.(trichromatStimulusName).Contrast400)) (mean(trichromatStruct.(trichromatStimulusName).Contrast400))], ...
                errorToPlot, lineProps, 1);
        end
        
        for ss = 1:5
            scatter([1, 2]+xShift, [experiment1ResultsStruct.(stimuli{stimulus}).Contrast400(ss), experiment2ResultsStruct.(stimuli{stimulus}).Contrast400(ss)], 'k')
            plot([1, 2]+xShift, [experiment1ResultsStruct.(stimuli{stimulus}).Contrast400(ss), experiment2ResultsStruct.(stimuli{stimulus}).Contrast400(ss)], 'Color', 'k')

        end
        
        xlim([xValues(1) - 0.5*shiftDistance, xValues(end) + 0.5*shiftDistance])        
        xticks(xValues)
        xticklabels({'Low Contrast', 'High Contrast', 'Low Contrast', 'High Contrast', 'Low Contrast', 'High Contrast'});
        xtickangle(30);
        ylabel(p.Results.yLabel);
        ylim(p.Results.yLims);
        yticks(p.Results.yTicks);
        yticklabels(p.Results.yTickLabels);
        
        set(gca, 'XGrid', 'off')

        
        
        
        
        
    end
    
    for stimulus = 1:length(stimuli)
        axisPosition = get(gca, 'Position');
        xLocation = (((stimulus*2)-1)/6*axisPosition(3)+axisPosition(1))/p.Results.figureWidthInches;
        annotation('textbox', [xLocation, 1, 0, 0], 'string', stimuli{stimulus}, 'FontName', 'Helvetica', 'FontSize', 20, 'HorizontalAlignment','center')
        
    end
    
    
end



plotlabOBJ.exportFig(hFig, 'pdf', p.Results.saveName, p.Results.savePath)



end
