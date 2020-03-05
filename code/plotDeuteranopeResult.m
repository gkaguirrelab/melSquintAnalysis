function plotDeuteranopeResult(experiment1ResultsStruct, experiment2ResultsStruct, trichromatStruct, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('savePath', [] ,@isstr);
p.addParameter('saveName', [] ,@isstr);
p.addParameter('yLims', [] ,@isnumeric);
p.addParameter('yLabel', [] ,@ischar);
p.addParameter('whichPlot', 'experimentComparison' ,@ischar);


p.parse(varargin{:})

%% Do the plotting


if strcmp(p.Results.whichPlot, 'experimentComparison')
    
    if ~isempty(experiment1ResultsStruct)
        stimuli = fieldnames(experiment1ResultsStruct);
    else
        stimuli = fieldnames(experiment2ResultsStruct);
    end
    
    plotFig = figure;
    for stimulus = 1:length(stimuli)
        subplot(1,3,stimulus); hold on;
        title(stimuli{stimulus});
        
        if ~isempty(experiment1ResultsStruct)
            data = [experiment1ResultsStruct.(stimuli{stimulus}).Contrast100; experiment1ResultsStruct.(stimuli{stimulus}).Contrast200; experiment1ResultsStruct.(stimuli{stimulus}).Contrast400];
            plotSpread(data', 'xValues', [log10(100), log10(200), log10(400)], 'distributionColors', 'k')
            plot([log10(100), log10(200), log10(400)], [median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast100), median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast200), median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast400)], '*', 'Color', 'k')
            experiment1Plot = plot([log10(100), log10(200), log10(400)], [median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast100), median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast200), median(experiment1ResultsStruct.(stimuli{stimulus}).Contrast400)], 'Color', 'k');
        end
        
        if ~isempty(experiment2ResultsStruct)
            data = [experiment2ResultsStruct.(stimuli{stimulus}).Contrast400; experiment2ResultsStruct.(stimuli{stimulus}).Contrast800; experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200];
            plotSpread(data', 'xValues', [log10(400), log10(800), log10(1200)], 'distributionColors', 'r')
            plot([log10(400), log10(800), log10(1200)], [median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast400), median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast800), median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200)], '*', 'Color', 'r')
            experiment2Plot = plot([log10(400), log10(800), log10(1200)], [median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast400), median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast800), median(experiment2ResultsStruct.(stimuli{stimulus}).Contrast1200)], 'Color', 'r');
        end
        
        if ~isempty(trichromatStruct)
            trichromatStimulusName = stimuli{stimulus};
            if strcmp(trichromatStimulusName, 'LS')
                trichromatStimulusName = 'LMS';
            end
            lineProps.col{1} = 'b';
            errorLower = [[abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))] - [abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 25)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 25)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 25))]];
            errorUpper = abs([abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 75)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 75)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 75))] - [abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))]);
            
            errorToPlot(1,1:3, 1) = errorUpper;
            errorToPlot(1,1:3, 2) = errorLower;
            trichromatPlot = plot([log10(100), log10(200), log10(400)], [abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))], 'Color', 'b');
            mseb([log10(100), log10(200), log10(400)], [abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))], ...
                errorToPlot, lineProps, 1);
            
            
        end
        
        if isempty(experiment2ResultsStruct)
            xticks([log10(100), log10(200), log10(400)]);
            xticklabels({'100%', '200%', '400%'});
            
        elseif isempty(experiment1ResultsStruct) && isempty(trichromatStruct)
            xticks([log10(400), log10(800), log10(1200)]);
            xticklabels({'400%', '800%', '1200%'});
            
        else
            xticks([log10(100), log10(200), log10(400), log10(800), log10(1200)]);
            xticklabels({'100%', '200%', '400%', '800%', '1200%'});
        end
        xtickangle(45);
        xlabel('Contrast')
        
        ylim(p.Results.yLims);
        ylabel(p.Results.yLabel)
        
        
        
        if stimulus == 3
            if isempty(experiment2ResultsStruct) || isempty(experiment1ResultsStruct)
                if isempty(experiment2ResultsStruct) && ~isempty(experiment1ResultsStruct) && ~isempty(trichromatStruct)
                    legend([experiment1Plot, trichromatPlot], 'Experiment 1', 'Trichromats');
                    legend('boxoff')
                end
            elseif isempty(trichromatStruct)
                legend([experiment1Plot, experiment2Plot], 'Experiment 1', 'Experiment 2');
                legend('boxoff')
                
            else
                legend([experiment1Plot, experiment2Plot, trichromatPlot], 'Experiment 1', 'Experiment 2', 'Trichromats');
                legend('boxoff')
            end
        end
    end
    
    
    
    
    
elseif strcmp(p.Results.whichPlot, '400Comparison')
    stimuli = fieldnames(experiment1ResultsStruct);

    plotFig = figure;
    for stimulus = 1:length(stimuli)
        ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
        title(stimuli{stimulus})
        for ss = 1:5
            plot([1, 2], [experiment1ResultsStruct.(stimuli{stimulus}).Contrast400(ss), experiment2ResultsStruct.(stimuli{stimulus}).Contrast400(ss)], 'Color', 'k')
        end
        
        xlim([0.75 2.25])
        xticks([1 2])
        xticklabels({'Low Contrast', 'High Contrast'});
        xtickangle(30)
        ylabel(p.Results.yLabel)
        
        
        if ~isempty(trichromatStruct)
            trichromatStimulusName = stimuli{stimulus};
            if strcmp(trichromatStimulusName, 'LS')
                trichromatStimulusName = 'LMS';
            end
            lineProps.col{1} = 'b';
            errorLower = [[abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))] - [abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 25)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 25)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 25))]];
            errorUpper = abs([abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast100, 75)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast200, 75)), abs(prctile(trichromatStruct.(trichromatStimulusName).Contrast400, 75))] - [abs(median(trichromatStruct.(trichromatStimulusName).Contrast100)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast200)), abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))]);
            
            errorToPlot(1,1:2, 1) = [errorUpper(3) errorUpper(3)];
            errorToPlot(1,1:2, 2) = [errorLower(3) errorLower(3)];
            trichromatPlot = plot([0.75 2.25], [abs(median(trichromatStruct.(trichromatStimulusName).Contrast400)) abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))], 'Color', 'b');
            mseb([0.75 2.25], [abs(median(trichromatStruct.(trichromatStimulusName).Contrast400)) abs(median(trichromatStruct.(trichromatStimulusName).Contrast400))], ...
                errorToPlot, lineProps, 1);
        end
        
        
    end
    
    linkaxes([ax.ax1, ax.ax2, ax.ax3]);

end




set(plotFig, 'Position', [680 460 968 518]);
export_fig(plotFig, fullfile(p.Results.savePath, p.Results.saveName));


end