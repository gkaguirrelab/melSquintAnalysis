%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% Pool results
controlDiscomfort = [];
mwaDiscomfort = [];
mwoaDiscomfort = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};



for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(analysisBasePath, fileName));
                controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            elseif strcmp(group, 'mwa')
                load(fullfile(analysisBasePath, fileName));
                mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                
            elseif strcmp(group, 'mwoa')
                load(fullfile(analysisBasePath, fileName));
                mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end


%% Display results
combineMigraineurs = true;

contrastsOfInterest = {100, 200, 400};

if combineMigraineurs
    plotFig = figure;
    
    for stimulus = 1:length(stimuli)
        subplot(1,length(stimuli), stimulus); hold on;
        data = nan(2*length(contrastsOfInterest), max(length([mwoaDiscomfort.Melanopsin.Contrast400, mwaDiscomfort.Melanopsin.Contrast400]), length(controlDiscomfort.Melanopsin.Contrast400)));
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            data(contrast*2,1:length([mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]')) = [mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]';
            data(contrast*2-1,1:length(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])';
            
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMigraineDiscomfort = nanmedian([mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]);
            medianControlDiscomfort = nanmedian(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            
            fprintf('\t\tMedian discomfort rating for all migraineurs: %4.2f\n', medianMigraineDiscomfort);
            fprintf('\t\tMedian discomfort rating for controls: %4.2f\n', medianControlDiscomfort);
            
        end
        categoryIdx = repmat([0,1], max(length([mwoaDiscomfort.Melanopsin.Contrast400, mwaDiscomfort.Melanopsin.Contrast400]), length(controlDiscomfort.Melanopsin.Contrast400)), size(data,1)/2);
        
        plotSpread(data', 'categoryIdx', categoryIdx(:), 'xValues', [0.8 1.2 1.8 2.2 2.8 3.2], 'categoryColors', {'k', 'r'}, 'showMM', 0, 'categoryLabels', {'Controls', 'Migraineurs'})
        
        plot([1, 2, 3], ...
            [nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast100, mwaDiscomfort.(stimuli{stimulus}).Contrast100]) ...
            nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast200, mwaDiscomfort.(stimuli{stimulus}).Contrast200]) ...
            nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast400, mwaDiscomfort.(stimuli{stimulus}).Contrast400])], ...
            '*', 'Color', 'r', 'MarkerSize', 12);
        
        ax1 = plot([1, 2, 3], ...
            [nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast100, mwaDiscomfort.(stimuli{stimulus}).Contrast100]) ...
            nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast200, mwaDiscomfort.(stimuli{stimulus}).Contrast200]) ...
            nanmedian([mwoaDiscomfort.(stimuli{stimulus}).Contrast400, mwaDiscomfort.(stimuli{stimulus}).Contrast400])], ...
            'Color', 'r');
        
        plot([1, 2, 3], ...
            [nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            '*', 'Color', 'k', 'MarkerSize', 12);
        
        ax2 = plot([1, 2, 3], ...
            [nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            'Color', 'k');
        
        
        xticks([1:3])
        xticklabels({'100%', '200%', '400%'})
        xlabel('Contrast')
        ylabel('Discomfort Rating')
        title(stimuli{stimulus})
        ylim([-0.5 10])
        
        if stimulus == length(stimuli)
            legend([ax1, ax2], ['Combined Migraineurs, N = ', num2str(length([mwoaDiscomfort.Melanopsin.Contrast400, mwaDiscomfort.Melanopsin.Contrast400]))], ['Controls, N = ', num2str(length(controlDiscomfort.Melanopsin.Contrast400))], 'Location', 'NorthWest')
            legend('boxoff')
        end
        
    end
    
    savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings');
    
    if ~exist(savePath, 'dir')
        mkdir(savePath)
    end
    set(plotFig, 'Position', [85 230 1633 748], 'Units', 'pixels');
    export_fig(plotFig, fullfile(savePath, 'groupAverage_combinedMigraineurs.pdf'));
    
    
else
    plotFig = figure;
    
    for stimulus = 1:length(stimuli)
        subplot(1,length(stimuli), stimulus); hold on;
        data = nan(3*length(contrastsOfInterest), max([length(mwoaDiscomfort.Melanopsin.Contrast400), length(mwaDiscomfort.Melanopsin.Contrast400), length(controlDiscomfort.Melanopsin.Contrast400)]));
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            data(contrast*3,1:length(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]';
            data(contrast*3-1,1:length(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = [mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]';
            data(contrast*3-2,1:length(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])';
            
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMWADiscomfort = nanmedian(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            medianMWOADiscomfort = nanmedian(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            medianControlDiscomfort = nanmedian(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            
            fprintf('\t\tMedian discomfort rating for all MwA: %4.2f\n', medianMWADiscomfort);
            fprintf('\t\tMedian discomfort rating for all MwoA: %4.2f\n', medianMWOADiscomfort);
            fprintf('\t\tMedian discomfort rating for controls: %4.2f\n', medianControlDiscomfort);
            
        end
        categoryIdx = repmat([0,1,2], max([length(mwoaDiscomfort.Melanopsin.Contrast400), length(mwaDiscomfort.Melanopsin.Contrast400), length(controlDiscomfort.Melanopsin.Contrast400)]), size(data,1)/3);
        
        plotSpread(data', 'categoryIdx', categoryIdx(:), 'xValues', [0.8 1 1.2 1.8 2 2.2 2.8 3 3.2], 'categoryColors', {'k', 'r', 'b'}, 'showMM', 0, 'categoryLabels', {'Controls', 'MwoA', 'MwA'})
        
        plot([1, 2, 3], ...
            [nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            '*', 'Color', 'r', 'MarkerSize', 12);
        
        ax1 = plot([1, 2, 3], ...
            [nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(mwoaDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            'Color', 'r');
        
        plot([1, 2, 3], ...
            [nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            '*', 'Color', 'b', 'MarkerSize', 12);
        
        ax2 = plot([1, 2, 3], ...
            [nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(mwaDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            'Color', 'b');
        
        plot([1, 2, 3], ...
            [nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            '*', 'Color', 'k', 'MarkerSize', 12);
        
        ax3 = plot([1, 2, 3], ...
            [nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast100) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast200) ...
            nanmedian(controlDiscomfort.(stimuli{stimulus}).Contrast400)], ...
            'Color', 'k');
        
        
        xticks([1:3])
        xticklabels({'100%', '200%', '400%'})
        xlabel('Contrast')
        ylabel('Discomfort Rating')
        title(stimuli{stimulus})
        ylim([-0.5 10])
        
        if stimulus == length(stimuli)
            legend([ax1, ax2, ax3], ['MwoA, N = ', num2str(length(mwoaDiscomfort.Melanopsin.Contrast400))], ['MwA, N = ', num2str(length(mwaDiscomfort.Melanopsin.Contrast400))], ['Controls, N = ', num2str(length(controlDiscomfort.Melanopsin.Contrast400))], 'Location', 'NorthWest')
            legend('boxoff')
        end
        
        savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings');
        
        if ~exist(savePath, 'dir')
            mkdir(savePath)
        end
        set(plotFig, 'Position', [85 230 1633 748], 'Units', 'pixels');
        export_fig(plotFig, fullfile(savePath, 'groupAverage.pdf'));
        
    end
end










