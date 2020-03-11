dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

calculateRMS = false;

controlRMS = [];
mwaRMS = [];
mwoaRMS = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
        controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        combinedMigraineResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];

useNormalized = true;

if useNormalized
   saveStem = '_normalized';
else
    saveStem = '';
end

for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
    
    if calculateRMS
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true);
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', false);
        
    end
    close all;
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwoaSubjects{end+1} = subjectIDs{ss};
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
end


slopeWithZeroInterceptCellArray = [];
interceptCellArray = [];
slopeCellArray = [];
meanRatingCellArray = [];

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
                y = [controlRMS.(stimuli{stimulus}).Contrast100(ss), controlRMS.(stimuli{stimulus}).Contrast200(ss), controlRMS.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 1;
                color = 'k';
                subjectID = controlSubjects{ss};
            elseif strcmp(groups{group}, 'mwa')
                y = [mwaRMS.(stimuli{stimulus}).Contrast100(ss), mwaRMS.(stimuli{stimulus}).Contrast200(ss), mwaRMS.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 2;
                color = 'b';
                subjectID = mwaSubjects{ss};
            elseif strcmp(groups{group}, 'mwoa')
                y = [mwoaRMS.(stimuli{stimulus}).Contrast100(ss), mwoaRMS.(stimuli{stimulus}).Contrast200(ss), mwoaRMS.(stimuli{stimulus}).Contrast400(ss)];
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
            ylim([-0.4 1.4]);
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
        subjectPlotSavePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'subjectFits');
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
    ylim([-0.4 1.4]);
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

cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'EMG_slopesWithZeroIntercept.csv'), slopeWithZeroInterceptCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'EMG_slopes.csv'), slopeCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'EMG_intercepts.csv'), interceptCellArray);
cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'EMG_meanRating.csv'), meanRatingCellArray);


% example ANOVA command:
cellArrayToTest = slopeCellArray;
anovan(cell2mat(cellArrayToTest(2:end,4)), { cellArrayToTest(2:end, 2), cellArrayToTest(2:end, 3)}, 'varnames', {'Stimulus', 'Group'}, 'model', 'interaction')
