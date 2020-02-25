function summarizePupillometryForDeuteranopes(subjectID, varargin)

resampledTimebase = 0:1/60:18.5;
pulseOnset = 1.5;
pulseOffset = 5.5;
plotShift = 1;
nTimePointsToSkipPlotting = 40;
yLims = [-0.8 0.3];
xLims = [0 17];

    plotFig = figure;

for experiment = 1:2
    load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, ['experiment_', num2str(experiment)], 'trialStruct_radiusSmoothed.mat'));
    
    % stimuli:
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};
    if experiment == 1
        contrasts = {100, 200, 400};
    else
        contrasts = {400, 800, 1200};
    end
    
    for ss = 1:length(stimuli)
        for cc = 1:length(contrasts)
            for tt = 1:length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,:))
                averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(1,tt) = nanmean(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt));
                averageResponseStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc}), '_SEM'])(1,tt) = nanstd(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt))/sqrt((length(trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt)) - sum(isnan((trialStruct.(stimuli{ss}).(['Contrast',num2str(contrasts{cc})])(:,tt))))));
            end
        end
    end
    
    
    
    
    nStimuli = length(stimuli);
    nContrasts = length(contrasts);
    
    % set up color palette
    colorPalette.Melanopsin{1} = [220/255, 237/255, 200/255];
    colorPalette.Melanopsin{2} = [143/255, 208/255, 207/255];
    colorPalette.Melanopsin{3} = [66/255, 179/255, 213/255];
    colorPalette.Melanopsin{4} = [46/255, 107/255, 170/255];
    colorPalette.Melanopsin{5} = [26/255, 35/255, 126/255];
    
    
    grayColorMap = colormap(gray);
    colorPalette.LMS{1} = grayColorMap(50,:);
    colorPalette.LMS{2} = grayColorMap(38,:);
    colorPalette.LMS{3} = grayColorMap(25,:);
    colorPalette.LMS{4} = grayColorMap(13,:);
    colorPalette.LMS{5} = grayColorMap(1,:);
    colorPalette.LS = colorPalette.LMS;
    
    colorPalette.LightFlux{1} = [254/255, 235/255, 101/255];
    colorPalette.LightFlux{2} = [241/255, 159/255, 64/255];
    colorPalette.LightFlux{3} = [228/255, 82/255, 27/255];
    colorPalette.LightFlux{4} = [153/255, 67/255, 37/255];
    colorPalette.LightFlux{5} = [77/255, 52/255, 47/255];
    
    for ss = 1:nStimuli
        
        % pick the right subplot for the right stimuli
        subplot(nStimuli,2,ss*2-(2-experiment))
        title(stimuli{ss})
        hold on
        
        for cc = 1:nContrasts
            
            % make thicker plot lines
            lineProps.width = 1;
            
            % adjust color
            lineProps.col{1} = colorPalette.(stimuli{ss}){cc+(experiment-1)*2};
            
            % plot
            axis.(['ax', num2str(cc)]) = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, averageResponseStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])(1:end-nTimePointsToSkipPlotting), averageResponseStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc}), '_SEM'])(1:end-nTimePointsToSkipPlotting), lineProps);
            
            legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(trialStruct.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]), 1))]);
            
        end
        
        legend(legendText, 'Location', 'SouthEast')
        legend('boxoff')
        
        % add line for pulse onset
        line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
        
        % spruce up axes
        ylim(yLims)
        xlim(xLims)
        xlabel('Time (s)')
        ylabel('Pupil Area (% Change)')
        
    end
end

saveDir = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'deuteranopes', 'summaryPlots');
if ~exist(saveDir)
    mkdir(saveDir);
end
set(gcf, 'Renderer', 'painters');
set(gcf, 'Position', [303 353 937 626]);
export_fig(plotFig, fullfile(saveDir, [subjectID, '.pdf']))

end