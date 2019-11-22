%% ANOVA on slopes and intercepts
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

controlDiscomfort = [];
mwaDiscomfort = [];
mwoaDiscomfort = [];



stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};



for stimulus = 1:length(stimuli)
    slope.controls.(stimuli{stimulus}) = [];
    slope.mwa.(stimuli{stimulus}) = [];
    slope.mwoa.(stimuli{stimulus}) = [];
    
    intercept.controls.(stimuli{stimulus}) = [];
    intercept.mwa.(stimuli{stimulus}) = [];
    intercept.mwoa.(stimuli{stimulus}) = [];

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


slopeCellArrayHeader = {'Stimulus', 'Group', 'Slope'};
interceptCellArrayHeader = {'Stimulus', 'Group', 'Intercept'};

x = [log10(100), log10(200), log10(400)];
groups = {'controls', 'mwa', 'mwoa'};
plotFig = figure; hold on;
for ss = 1:20
    for stimulus = 1:length(stimuli)
        for group = 1:length(groups)
            
            if strcmp(groups{group}, 'controls')
                y = [controlDiscomfort.(stimuli{stimulus}).Contrast100(ss), controlDiscomfort.(stimuli{stimulus}).Contrast200(ss), controlDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 1;
                color = 'k';
            elseif strcmp(groups{group}, 'mwa')
                y = [mwaDiscomfort.(stimuli{stimulus}).Contrast100(ss), mwaDiscomfort.(stimuli{stimulus}).Contrast200(ss), mwaDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 2;
                color = 'b';
            elseif strcmp(groups{group}, 'mwoa')
                y = [mwoaDiscomfort.(stimuli{stimulus}).Contrast100(ss), mwoaDiscomfort.(stimuli{stimulus}).Contrast200(ss), mwoaDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 3;
                color = 'r';
            end
            
            
          coeffs = polyfit(x, y, 1);
          
          slope.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(1);
          intercept.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(2);

          
          slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = stimuli{stimulus};
          slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = groups{group};
          slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = coeffs(1);
          
          interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = stimuli{stimulus};
          interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = groups{group};
          interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = coeffs(2);
          
          anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 1) = stimulus;
          anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 2) = group;
          anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 3) = coeffs(1);
          anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 4) = coeffs(2);
          subplot(1,3,stimulus); hold on;
          fittedX = linspace(min(x), max(x), 200);
          fittedY = polyval(coeffs, fittedX);
          plot(fittedX, fittedY, 'LineWidth', 1, 'Color', color);
        end
       
    end
   
   
end

for stimulus = 1:length(stimuli)
    
    subplot(1,3,stimulus); hold on;
    
    controlSlopeMean = median(anovaTable(1:3:60+(stimulus-1)*60, 3));
    mwaSlopeMean = median(anovaTable(2:3:60+(stimulus-1)*60, 3));
    mwoaSlopeMean = median(anovaTable(3:3:60+(stimulus-1)*60, 3));
    
    controlInterceptMean = median(anovaTable(1:3:60+(stimulus-1)*60, 4));
    mwaInterceptMean = median(anovaTable(2:3:60+(stimulus-1)*60, 4));
    mwoaInterceptMean = median(anovaTable(3:3:60+(stimulus-1)*60, 4));
    
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval([controlSlopeMean, controlInterceptMean], fittedX);
    plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'k');
    
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval([mwaSlopeMean, mwaInterceptMean], fittedX);
    plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'b');
    
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval([mwoaSlopeMean, mwoaInterceptMean], fittedX);
    plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'r');

    title(stimuli{stimulus})
    xticks(x);
    xticklabels({'100%', '200%', '400%'});
    xlabel('Contrast')
    ylabel('Discomfort')
   

end

export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfortFitLines.png'));
 
% save out csv files
slopeCellArray = vertcat({'Stimulus', 'Group', 'Slope'}, slopeCellArray);
interceptCellArray = vertcat({'Stimulus', 'Group', 'Intercept'}, interceptCellArray);

cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'slopes.csv'), slopeCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'intercepts.csv'), interceptCellArray);

% intercepts and slopes by group
%% get all discomfort ratings responses
generateMatrix = false;

if generateMatrix
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
    
    discomfortRatings = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        end
    end
    
    %% create massive matrix
    matrixForStimulusType = [];
    pooledMatrix = [];
    groups = {'CombinedMigraineurs', 'Controls'};
    instanceCounter = 1;
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            for group = 1:length(groups)
                nSubjects = length(discomfortRatings.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                for ii = 1:nSubjects
                    pooledMatrix(instanceCounter,1) = discomfortRatings.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ii);
                    
                    pooledMatrix(instanceCounter,2) = stimulus;
                    
                    pooledMatrix(instanceCounter,3) = contrast;
                    
                    pooledMatrix(instanceCounter,4) = group;
                    
                    instanceCounter = instanceCounter + 1;
                    
                end
            end
            
            %         % first column is discomfort ratings
            %         matrixForStimulusType(1:length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),1) = discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            %         matrixForStimulusType(length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+1:length(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),1) = (discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
            %
            %
            %         % second column is stimulus type
            %         matrixForStimulusType(1:length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),2) = repmat(length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 1, stimuli{stimulus};
            %         matrixForStimulusType(length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+1:length(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),2) = stimuli{stimulus};
            %
            %
            %         % third column is contrast level
            %         matrixForStimulusType(1:length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),3) = contrast;
            %         matrixForStimulusType(length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+1:length(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))+length(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])),3) = contrast;
            %
            %         pooledMatrix = vertcat(pooledMatrix, matrixForStimulusType);
        end
    end
    
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'pooledObservationsForANOVA.mat'), 'pooledMatrix');
else
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'pooledObservationsForANOVA.mat'))
    
end

%% Run the ANOVA

p = anovan(pooledMatrix(:,1), pooledMatrix(:,2:4), 'varnames', {'Stimulus', 'Contrast', 'Group'})
