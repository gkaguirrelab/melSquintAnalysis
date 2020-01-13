function [slope, intercept, meanRating] = fitLineToResponseModality(responseModality, varargin)

%% collect some inputs
p = inputParser; p.KeepUnmatched = true;
p.addParameter('fitType','withIntercept',@ischar);
p.addParameter('makePlots',true,@islogical);
p.addParameter('makeCSV',true,@islogical);

% Parse and check the parameters
p.parse(varargin{:});

%% Load in the discomfort ratings

if strcmp(responseModality, 'discomfortRating')
    responseModality = 'discomfortRatings';
end

if strcmp(responseModality, 'discomfortRatings') || strcmp(responseModality, 'discomfortRating')
    [ discomfortRatingsStruct, subjectIDsStruct ] = loadDiscomfortRatings;

    mwaResult = discomfortRatingsStruct.mwaDiscomfort;
    mwoaResult = discomfortRatingsStruct.mwoaDiscomfort;
    controlResult = discomfortRatingsStruct.controlDiscomfort;
elseif strcmp(responseModality, 'emg')
    [ emgRMSStruct, subjectIDsStruct ] = loadEMG;
    
    mwaResult = emgRMSStruct.mwaRMS;
    mwoaResult= emgRMSStruct.mwoaRMS;
    controlResult = emgRMSStruct.controlRMS;
    
end

%% Make linear model fits across contrast levels for each stimulus type and each subject
% pre-allocate some variables
stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
for stimulus = 1:length(stimuli)
    
    slope.controls.(stimuli{stimulus}) = [];
    slope.mwa.(stimuli{stimulus}) = [];
    slope.mwoa.(stimuli{stimulus}) = [];
    
    intercept.controls.(stimuli{stimulus}) = [];
    intercept.mwa.(stimuli{stimulus}) = [];
    intercept.mwoa.(stimuli{stimulus}) = [];
    
    meanRating.controls.(stimuli{stimulus}) = [];
    meanRating.mwa.(stimuli{stimulus}) = [];
    meanRating.mwoa.(stimuli{stimulus}) = [];
    
end
controlSubjects = subjectIDsStruct.controlSubjects;
mwaSubjects = subjectIDsStruct.mwaSubjects;
mwoaSubjects = subjectIDsStruct.mwoaSubjects;

slopeCellArrayHeader = {'Stimulus', 'Group', 'Slope'};
interceptCellArrayHeader = {'Stimulus', 'Group', 'Intercept'};

% define x as log-spaced contrast
x = [log10(100), log10(200), log10(400)];

% loop around group, subject number, and stimulus type
groups = {'controls', 'mwa', 'mwoa'};
if p.Results.makePlots
    plotFig = figure(1); hold on;
end
for group = 1:length(groups)
    
    for ss = 1:20
        
        if p.Results.makePlots
            subjectPlotFig = figure(2);
        end
        
        for stimulus = 1:length(stimuli)
            
            
            
            % for specific stimulus type, for specific subject, concatenate
            % discomfort ratings across contrast levels
            if strcmp(groups{group}, 'controls')
                y = [controlResult.(stimuli{stimulus}).Contrast100(ss), controlResult.(stimuli{stimulus}).Contrast200(ss), controlResult.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 1;
                color = 'k';
                subjectID = controlSubjects{ss};
            elseif strcmp(groups{group}, 'mwa')
                y = [mwaResult.(stimuli{stimulus}).Contrast100(ss), mwaResult.(stimuli{stimulus}).Contrast200(ss), mwaResult.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 2;
                color = 'b';
                subjectID = mwaSubjects{ss};
            elseif strcmp(groups{group}, 'mwoa')
                y = [mwoaResult.(stimuli{stimulus}).Contrast100(ss), mwoaResult.(stimuli{stimulus}).Contrast200(ss), mwoaResult.(stimuli{stimulus}).Contrast400(ss)];
                rowAdjuster = 3;
                color = 'r';
                subjectID = mwoaSubjects{ss};
            end
            
            % fit linear model
            coeffs = polyfit(x, y, 1);
            fittedX = linspace(min(x), max(x), 200);
            fittedY = polyval(coeffs, fittedX);
            
            if p.Results.makePlots
                % individual subject plot
                figure(2);
                subplot(1,3,stimulus); hold on;
                plot(x, y, 'o', 'Color', 'k');
                withInterceptLine = plot(fittedX, fittedY, '--', 'Color', 'k');
                xticks(x);
                xticklabels({'100%', '200%', '400%'});
                xlabel('Contrast')
                ylabel(responseModality)
                xlim([x(1) - 0.1, x(3) + 0.1]);
                ylim([-0.5 10.5]);
                yticks([0:1:10])
                title(stimuli{stimulus});
                legend([withInterceptLine], ['y = ', num2str(coeffs(1), '%4.2f'), 'x + ', num2str(coeffs(2), '%4.2f')]);
            end
            
            % extract model summary params
            slope.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(1);
            intercept.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(2);
            meanRating.(groups{group}).(stimuli{stimulus})(end+1) = coeffs(1)*x(2) + coeffs(2);
            
            % stash results for CSV file
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            slopeCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(1);
            
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            interceptCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(2);
            
            
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 1} = subjectID;
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 2} = stimuli{stimulus};
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 3} = groups{group};
            meanRatingCellArray{(ss-1)*3+rowAdjuster+(stimulus-1)*60, 4} = coeffs(1)*x(2) + coeffs(2);
            
            
            if p.Results.makePlots
                figure(1);
                subplot(1,3,stimulus); hold on;
                
                plot(fittedX, fittedY, 'LineWidth', 1, 'Color', color);
            end
        end
        
        if p.Results.makePlots
            subjectPlotSavePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'subjectFits');
            if ~exist(subjectPlotSavePath, 'dir')
                mkdir(subjectPlotSavePath);
            end
            export_fig(subjectPlotFig, fullfile(subjectPlotSavePath, [groups{group}, num2str(ss), '_linearModelFits.png']));
            close(figure(2));
        end
    end
end

%% Create across-subject summary plots
if p.Results.makePlots
    % summarize model fits
    for stimulus = 1:length(stimuli)
        
        subplot(1,3,stimulus); hold on;
        
        controlSlopeMean = median(slope.controls.(stimuli{stimulus}));
        mwaSlopeMean = median(slope.mwa.(stimuli{stimulus}));
        mwoaSlopeMean = median(slope.mwoa.(stimuli{stimulus}));
        
        controlInterceptMean = median(intercept.controls.(stimuli{stimulus}));
        mwaInterceptMean = median(intercept.mwa.(stimuli{stimulus}));
        mwoaInterceptMean = median(intercept.mwoa.(stimuli{stimulus}));
        
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
        xlim([x(1) - 0.1, x(3) + 0.1]);
        ylim([-0.5 10.5]);
        yticks([0:1:10])
        
        title(stimuli{stimulus})
        xticks(x);
        xticklabels({'100%', '200%', '400%'});
        xlabel('Contrast')
        ylabel('Discomfort')
        xlim([x(1) - 0.1, x(3) + 0.1]);
        ylim([-0.5 10.5]);
        yticks([0:1:10])
        
        
    end
    export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'discomfortFitLines.png'));
    
    % summarize model params across subjects
    slopes = [];
    contrasts = {400};
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            slopes.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = slope.mwa.(stimuli{stimulus});
            slopes.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = slope.mwoa.(stimuli{stimulus});
            slopes.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = slope.controls.(stimuli{stimulus});
        end
    end
    if strcmp(responseModality, 'discomfortRatings')
        yLims = [-1 12];
    elseif strcmp(responseModality, 'emg')
        yLims = [-0.5 3];
    end
    plotSpreadResults(slopes, 'contrasts', {400}, 'yLims', yLims, 'yLabel', [responseModality,' Slopes'], 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'groupAverage_slopes.pdf'))
    
    
    intercepts = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            intercepts.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = intercept.mwa.(stimuli{stimulus});
            intercepts.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = intercept.mwoa.(stimuli{stimulus});
            intercepts.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = intercept.controls.(stimuli{stimulus});
        end
    end
    
    if strcmp(responseModality, 'discomfortRatings')
        yLims = [-20 5];
    elseif strcmp(responseModality, 'emg')
        yLims = [-3 3];
    end
    
    plotSpreadResults(intercepts, 'contrasts', {400}, 'yLims', yLims, 'yLabel', [responseModality, ' Intercepts'], 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'groupAverage_intercepts.pdf'))
    
    meanRatings = [];
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            meanRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = meanRating.mwa.(stimuli{stimulus});
            meanRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = meanRating.mwoa.(stimuli{stimulus});
            meanRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = meanRating.controls.(stimuli{stimulus});
        end
    end
    
    if strcmp(responseModality, 'discomfortRatings')
        yLims = [-0.5 10];
    elseif strcmp(responseModality, 'emg')
        yLims = [-0.25 1.5];
    end
    
    plotSpreadResults(meanRatings, 'contrasts', {400}, 'yLims', yLims, 'yLabel', ['Mean ', responseModality], 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'groupAverage_meanRating.pdf'))
    
    
end

%% Save out results to CSV file
if p.Results.makeCSV
    slopeCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'Slope'}, slopeCellArray);
    interceptCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'Intercept'}, interceptCellArray);
    meanRatingCellArray = vertcat({'SubjectID', 'Stimulus', 'Group', 'MeanRating'}, meanRatingCellArray);
    
    cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'slopes.csv'), slopeCellArray);
    cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'intercepts.csv'), interceptCellArray);
    cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, 'meanRating.csv'), meanRatingCellArray);
    
end

end
