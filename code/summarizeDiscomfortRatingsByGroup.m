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
% First by individual migraine group
discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage.pdf'))

% Next by combine migraineurs
discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(discomfortRatings, 'yLims', [-0.5, 10], 'yLabel', 'Discomfort Ratings', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage_combinedMigraineurs.pdf'))

%% summarize discomfort on the basis of median, +/- interquartile range

plotFig = figure; hold on;
[ha, pos] = tight_subplot(1,length(stimuli), 0.08);

% log space x-values, which will represent contrast
x = [1, 2, 3];
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
for group = 1:3
    
    if group == 1
        
        response = controlDiscomfort;
        color = 'k';
        xOffset = -0.3;
        
    elseif group == 2
        
        response = mwaDiscomfort;
        color = 'b';
        xOffset = 0;
        
    elseif group == 3
        
        response = mwoaDiscomfort;
        color = 'r';
        xOffset = 0.3;
    end
    
    for stimulus = 1:length(stimuli)
        
        axes(ha(stimulus)); hold on;
        
        y = [median(response.(stimuli{stimulus}).Contrast100), median(response.(stimuli{stimulus}).Contrast200), median(response.(stimuli{stimulus}).Contrast400)];
        
        yErrorNeg = [(median(response.(stimuli{stimulus}).Contrast100) - prctile(response.(stimuli{stimulus}).Contrast100, 25)), (median(response.(stimuli{stimulus}).Contrast200) - prctile(response.(stimuli{stimulus}).Contrast200, 25)), (median(response.(stimuli{stimulus}).Contrast400) - prctile(response.(stimuli{stimulus}).Contrast400, 25))];
        yErrorPos = [(prctile(response.(stimuli{stimulus}).Contrast100, 75) - median(response.(stimuli{stimulus}).Contrast100)), (prctile(response.(stimuli{stimulus}).Contrast200, 75) - median(response.(stimuli{stimulus}).Contrast200)), (prctile(response.(stimuli{stimulus}).Contrast400, 75) - median(response.(stimuli{stimulus}).Contrast400))];

        errorbar(x+xOffset, y, yErrorNeg, yErrorPos, 'Color', color, 'CapSize', 0);
        plot(x+xOffset,y, '*', 'MarkerSize', 20, 'Color', color);
        
        ylim([-0.5 10.5])
        ylabel('Discomfort Ratings')
        xlim([0.5 3.5])
        xlabel('Contrast')
        xticks([1, 2, 3])
        xticklabels({'100%', '200%', '400%'})
        title(stimuli{stimulus});
        yticks([0 5 10])
        yticklabels({0 5 10})
    end
end

export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'mediansWithIQR.pdf'));



