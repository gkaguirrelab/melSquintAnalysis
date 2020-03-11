%% ANOVA on slopes and intercepts
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

controlDiscomfort = [];
mwaDiscomfort = [];
mwoaDiscomfort = [];

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];



stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

slopeWithZeroInterceptCellArray = [];
interceptCellArray = [];
slopeCellArray = [];
meanRatingCellArray = [];


for stimulus = 1:length(stimuli)
    slope.controls.(stimuli{stimulus}) = [];
    slope.mwa.(stimuli{stimulus}) = [];
    slope.mwoa.(stimuli{stimulus}) = [];
    
    intercept.controls.(stimuli{stimulus}) = [];
    intercept.mwa.(stimuli{stimulus}) = [];
    intercept.mwoa.(stimuli{stimulus}) = [];
    
    slopeWithZeroIntercept.controls.(stimuli{stimulus}) = [];
    slopeWithZeroIntercept.mwa.(stimuli{stimulus}) = [];
    slopeWithZeroIntercept.mwoa.(stimuli{stimulus}) = [];
    
    for contrast = 1:length(contrasts)
        controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end


close all;
for ss = 1:length(subjectIDs)
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
    fileName = 'audioTrialStruct_final.mat';
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(analysisBasePath, fileName));
                controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                load(fullfile(analysisBasePath, fileName));
                mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                load(fullfile(analysisBasePath, fileName));
                mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                mwoaSubjects{end+1} = subjectIDs{ss};
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end


slopeCellArrayHeader = {'Stimulus', 'Group', 'Slope'};
interceptCellArrayHeader = {'Stimulus', 'Group', 'Intercept'};

x = [log10(100), log10(200), log10(400)];
%x = [1 2 4];
%x = [sqrt(1), sqrt(2), sqrt(4)];
groups = {'controls', 'mwa', 'mwoa'};
plotFig = figure(1); hold on;
for group = 1:length(groups)
    
    for ss = 1:20
        subjectPlotFig = figure(2);
        
        for stimulus = 1:length(stimuli)
            
            
            
            
            if strcmp(groups{group}, 'controls')
                y = [controlDiscomfort.(stimuli{stimulus}).Contrast100(ss), controlDiscomfort.(stimuli{stimulus}).Contrast200(ss), controlDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 1;
                color = 'k';
                subjectID = controlSubjects{ss};
            elseif strcmp(groups{group}, 'mwa')
                y = [mwaDiscomfort.(stimuli{stimulus}).Contrast100(ss), mwaDiscomfort.(stimuli{stimulus}).Contrast200(ss), mwaDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 2;
                color = 'b';
                subjectID = mwaSubjects{ss};
            elseif strcmp(groups{group}, 'mwoa')
                y = [mwoaDiscomfort.(stimuli{stimulus}).Contrast100(ss), mwoaDiscomfort.(stimuli{stimulus}).Contrast200(ss), mwoaDiscomfort.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 3;
                color = 'r';
                subjectID = mwoaSubjects{ss};
            end
            
            
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            
            fitWithZeroIntercept = fitlm(x,y,'Intercept',false);
            
            % individual subject plot
            figure(2);
            subplot(1,3,stimulus); hold on;
            plot(x, y, 'o', 'Color', 'k');
            withInterceptLine = plot(fittedX, fittedY, '--', 'Color', 'k');
            %withoutInterceptLine = plot([(x(1) - .0*x(1)):0.001:(x(end) + .0*x(1))], [(x(1) - .0*x(1)):0.001:(x(end) + .0*x(1))]*fitWithZeroIntercept.Coefficients.Estimate, 'Color', 'k');
            xticks(x);
            xticklabels({'100%', '200%', '400%'});
            xlabel('Contrast')
            ylabel('Discomfort')
            xlim([x(1) - 0.1, x(3) + 0.1]);
            ylim([-0.5 10.5]);
            yticks([0:1:10])
            title(stimuli{stimulus});
            legend([withInterceptLine], ['y = ', num2str(coeffs(1), '%4.2f'), 'x + ', num2str(coeffs(2), '%4.2f')]);
            
            
            slope.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(1);
            intercept.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(2);
            slopeWithZeroIntercept.(groups{group}).(stimuli{stimulus})(end+1) = fitWithZeroIntercept.Coefficients.Estimate;
            
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(1);
            
            slopeWithZeroInterceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            slopeWithZeroInterceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            slopeWithZeroInterceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            slopeWithZeroInterceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = fitWithZeroIntercept.Coefficients.Estimate;
            
            
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(2);
            
            
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(1)*x(2) + coeffs(2);
            
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 1) = ss+(group-1)*20;
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 2) = stimulus;
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 3) = group;
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 4) = coeffs(1);
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 5) = coeffs(2);
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 6) = fitWithZeroIntercept.Coefficients.Estimate;
            anovaTable((ss-1)*3+rowAdjuster+(stimulus-1)*60, 7) = coeffs(1)*x(2) + coeffs(2);

            
            figure(1);
            subplot(1,3,stimulus); hold on;
            
            plot(fittedX, fittedY, 'LineWidth', 1, 'Color', color);
        end
        subjectPlotSavePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'subjectFits');
        if ~exist(subjectPlotSavePath, 'dir')
            mkdir(subjectPlotSavePath);
        end
        export_fig(subjectPlotFig, fullfile(subjectPlotSavePath, [groups{group}, num2str(ss), '_linearModelFits.png']));
        close(figure(2));
    end
    
    
end

useZeroIntercept = false;
for stimulus = 1:length(stimuli)
    
    subplot(1,3,stimulus); hold on;
    
    if ~useZeroIntercept
        controlSlopeMean = median(anovaTable((1:3:60)+(stimulus-1)*60, 4));
        mwaSlopeMean = median(anovaTable((2:3:60)+(stimulus-1)*60, 4));
        mwoaSlopeMean = median(anovaTable((3:3:60)+(stimulus-1)*60, 4));
        
        controlInterceptMean = median(anovaTable((1:3:60)+(stimulus-1)*60, 5));
        mwaInterceptMean = median(anovaTable((2:3:60)+(stimulus-1)*60, 5));
        mwoaInterceptMean = median(anovaTable((3:3:60)+(stimulus-1)*60, 5));
        
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval([controlSlopeMean, controlInterceptMean], fittedX);
        plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'k');
        
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval([mwaSlopeMean, mwaInterceptMean], fittedX);
        plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'b');
        
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval([mwoaSlopeMean, mwoaInterceptMean], fittedX);
        plot(fittedX, fittedY, 'LineWidth', 5, 'Color', 'r');
        
    else
        medianSlopeControls = median(slopeWithZeroIntercept.controls.(stimuli{stimulus}));
        medianSlopeMwa = median(slopeWithZeroIntercept.mwa.(stimuli{stimulus}));
        medianSlopeMwoa = median(slopeWithZeroIntercept.mwoa.(stimuli{stimulus}));
        
        xNew = 0:100;
        
        plot(xNew, xNew*medianSlopeControls, 'LineWidth', 5, 'Color', 'k');
        plot(xNew, xNew*medianSlopeMwa, 'LineWidth', 5, 'Color', 'b');
        plot(xNew, xNew*medianSlopeMwoa, 'LineWidth', 5, 'Color', 'r');
        
    end
    
    title(stimuli{stimulus})
    xticks(x);
    xticklabels({'100%', '200%', '400%'});
    xlabel('Contrast')
    ylabel('Discomfort')
    xlim([x(1) - 0.1, x(3) + 0.1]);
    ylim([-0.5 10.5]);
    yticks([0:1:10])
    
    
end

if ~useZeroIntercept
    export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfortFitLines.png'));
else
    export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfortFitLines_zeroIntercept.png'));
end

% save out csv files
slopeCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'Slope'}, slopeCellArray);
slopeWithZeroInterceptCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'SlopeWithZeroIntercept'}, slopeWithZeroInterceptCellArray);
interceptCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'Intercept'}, interceptCellArray);
meanRatingCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'MeanRating'}, meanRatingCellArray);

cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfort_slopesWithZeroIntercept.csv'), slopeWithZeroInterceptCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfort_slopes.csv'), slopeCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfort_intercepts.csv'), interceptCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'discomfort_meanRating.csv'), meanRatingCellArray);


% example ANOVA command:
cellArrayToTest = meanRatingCellArray;
anovan(cell2mat(cellArrayToTest(2:end,4)), { cellArrayToTest(2:end, 2), cellArrayToTest(2:end, 3)}, 'varnames', {'Stimulus', 'Group'}, 'model', 'interaction')


slopes = [];
contrasts = {400};
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        slopes.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((2:3:60)+(stimulus-1)*60, 4);
        slopes.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((3:3:60)+(stimulus-1)*60, 4);
        slopes.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((1:3:60)+(stimulus-1)*60, 4);
    end
end

plotSpreadResults(slopes, 'contrasts', {400}, 'yLims', [-1, 12], 'yLabel', 'Discomfort Rating Slopes', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage_slopes.pdf'))


intercepts = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        intercepts.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((2:3:60)+(stimulus-1)*60, 5);
        intercepts.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((3:3:60)+(stimulus-1)*60, 5);
        intercepts.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((1:3:60)+(stimulus-1)*60, 5);
    end
end

plotSpreadResults(intercepts, 'contrasts', {400}, 'yLims', [-20, 5], 'yLabel', 'Discomfort Rating Slopes', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage_intercepts.pdf'))

meanRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        meanRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((2:3:60)+(stimulus-1)*60, 7);
        meanRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((3:3:60)+(stimulus-1)*60, 7);
        meanRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = anovaTable((1:3:60)+(stimulus-1)*60, 7);
    end
end

plotSpreadResults(meanRatings, 'contrasts', {400}, 'yLims', [-0.5, 10], 'yLabel', 'Mean Discomfort Rating', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'groupAverage_meanRating.pdf'))


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
