%% Get the data
loadStatus= true;
pooledSessionStruct = planTestRetest('load', loadStatus);

%% Downshift pooledSessionStruct
downshiftedPooledSessionStruct = pooledSessionStruct; 
shiftStart = 1000;

% loop through subjects
for subject = 1:50
    % contrast 100
    downshift = nanmean(pooledSessionStruct.day1.Melanopsin.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.Melanopsin.Contrast100(subject,i) ...
            = pooledSessionStruct.day1.Melanopsin.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.Melanopsin.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.Melanopsin.Contrast100(subject,i) ...
            = pooledSessionStruct.day2.Melanopsin.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.Melanopsin.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.Melanopsin.Contrast100(subject,i) ...
            = pooledSessionStruct.combinedMean.Melanopsin.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LightFlux.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LightFlux.Contrast100(subject,i) ...
            = pooledSessionStruct.day1.LightFlux.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LightFlux.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LightFlux.Contrast100(subject,i) ...
            = pooledSessionStruct.day2.LightFlux.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LightFlux.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LightFlux.Contrast100(subject,i) ...
            = pooledSessionStruct.combinedMean.LightFlux.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LMS.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LMS.Contrast100(subject,i) ...
            = pooledSessionStruct.day1.LMS.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LMS.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LMS.Contrast100(subject,i) ...
            = pooledSessionStruct.day2.LMS.Contrast100(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LMS.Contrast100(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LMS.Contrast100(subject,i) ...
            = pooledSessionStruct.combinedMean.LMS.Contrast100(subject,i) - downshift;
    end
    % contrast 200
    downshift = nanmean(pooledSessionStruct.day1.Melanopsin.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.Melanopsin.Contrast200(subject,i) ...
            = pooledSessionStruct.day1.Melanopsin.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.Melanopsin.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.Melanopsin.Contrast200(subject,i) ...
            = pooledSessionStruct.day2.Melanopsin.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.Melanopsin.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.Melanopsin.Contrast200(subject,i) ...
            = pooledSessionStruct.combinedMean.Melanopsin.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LightFlux.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LightFlux.Contrast200(subject,i) ...
            = pooledSessionStruct.day1.LightFlux.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LightFlux.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LightFlux.Contrast200(subject,i) ...
            = pooledSessionStruct.day2.LightFlux.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LightFlux.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LightFlux.Contrast200(subject,i) ...
            = pooledSessionStruct.combinedMean.LightFlux.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LMS.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LMS.Contrast200(subject,i) ...
            = pooledSessionStruct.day1.LMS.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LMS.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LMS.Contrast200(subject,i) ...
            = pooledSessionStruct.day2.LMS.Contrast200(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LMS.Contrast200(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LMS.Contrast200(subject,i) ...
            = pooledSessionStruct.combinedMean.LMS.Contrast200(subject,i) - downshift;
    end
    % contrast 400
    downshift = nanmean(pooledSessionStruct.day1.Melanopsin.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.Melanopsin.Contrast400(subject,i) ...
            = pooledSessionStruct.day1.Melanopsin.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.Melanopsin.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.Melanopsin.Contrast400(subject,i) ...
            = pooledSessionStruct.day2.Melanopsin.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.Melanopsin.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.Melanopsin.Contrast400(subject,i) ...
            = pooledSessionStruct.combinedMean.Melanopsin.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LightFlux.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LightFlux.Contrast400(subject,i) ...
            = pooledSessionStruct.day1.LightFlux.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LightFlux.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LightFlux.Contrast400(subject,i) ...
            = pooledSessionStruct.day2.LightFlux.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LightFlux.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LightFlux.Contras400(subject,i) ...
            = pooledSessionStruct.combinedMean.LightFlux.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day1.LMS.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day1.LMS.Contrast400(subject,i) ...
            = pooledSessionStruct.day1.LMS.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.day2.LMS.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.day2.LMS.Contrast400(subject,i) ...
            = pooledSessionStruct.day2.LMS.Contrast400(subject,i) - downshift;
    end
    downshift = nanmean(pooledSessionStruct.combinedMean.LMS.Contrast400(subject,shiftStart:1111));
    for i = 1:1111
        downshiftedPooledSessionStruct.combinedMean.LMS.Contrast400(subject,i) ...
            = pooledSessionStruct.combinedMean.LMS.Contrast400(subject,i) - downshift;
    end
end

%% Fit the TPUP
summarizeTPUP_individualDifferences(downshiftedPooledSessionStruct);

%% Get the TPUP params
percentPersistent = [];
totalResponseAmplitude = [];
persistentAmplitude = [];
exponentialTau = [];

% Get total response amplitude
TPUPComponentNames = {'transient', 'sustained', 'persistent'};
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
for stimulus = 1:length(stimuli)
    for dd = 1:2
        
        totalResponseAmplitude.(['day', num2str(dd)]).(stimuli{stimulus}) = zeros(size(downshiftedPooledSessionStruct.day1.LMS.Contrast400,1),1);
        
        for tt = 1:length(TPUPComponentNames)
            
            
            % pre-allocate totalResponseAmplitude vector that we'll add to each loop
            % iteration around stimuli
            contrastLevel = 400;
            TPUPVector = getTPUPVector(dd, stimuli{stimulus}, contrastLevel, [TPUPComponentNames{tt}, 'amplitude']);
            totalResponseAmplitude.(['day', num2str(dd)]).(stimuli{stimulus})  = totalResponseAmplitude.(['day', num2str(dd)]).(stimuli{stimulus}) + TPUPVector;
            
        end
    end
end
for stimulus = 1:length(stimuli)
    totalResponseAmplitude.combinedMean.(stimuli{stimulus}) = zeros(size(downshiftedPooledSessionStruct.day1.LMS.Contrast400,1),1);
    
    for tt = 1:length(TPUPComponentNames)
        TPUPVector = getTPUPVector('combinedMean', stimuli{stimulus}, contrastLevel, [TPUPComponentNames{tt}, 'amplitude']);
        totalResponseAmplitude.combinedMean.(stimuli{stimulus})  = totalResponseAmplitude.combinedMean.(stimuli{stimulus}) + TPUPVector;
        
        
    end
end

% Get percentPersistent
for stimulus = 1:length(stimuli)
    for dd = 1:2
        persistentAmplitude.(['day', num2str(dd)]).(stimuli{stimulus})  = getTPUPVector(dd, stimuli{stimulus}, contrastLevel, ['persistentAmplitude']);
    end
end
for stimulus = 1:length(stimuli)
    persistentAmplitude.combinedMean.(stimuli{stimulus})  = getTPUPVector('combinedMean', stimuli{stimulus}, contrastLevel, ['persistentAmplitude']);
end
for stimulus = 1:length(stimuli)
    for dd = 1:2
        
        percentPersistent.(['day', num2str(dd)]).(stimuli{stimulus})  = persistentAmplitude.(['day', num2str(dd)]).(stimuli{stimulus})./totalResponseAmplitude.(['day', num2str(dd)]).(stimuli{stimulus});
        
    end
end
for stimulus = 1:length(stimuli)
    
    percentPersistent.combinedMean.(stimuli{stimulus})  = persistentAmplitude.combinedMean.(stimuli{stimulus})./totalResponseAmplitude.combinedMean.(stimuli{stimulus});
    
end

% Get exponential tau
for stimulus = 1:length(stimuli)
    for dd = 1:2
        exponentialTau.(['day', num2str(dd)]).(stimuli{stimulus})  = getTPUPVector(dd, stimuli{stimulus}, contrastLevel, ['exponentialTau']);
    end
end
for stimulus = 1:length(stimuli)
    
    exponentialTau.combinedMean.(stimuli{stimulus})  = getTPUPVector('combinedMean', stimuli{stimulus}, contrastLevel, ['exponentialTau']);
    
end

%% Make overall responsiveness vector
% As a means of quantifying the how much the pupil constricts to all
% stimuli, we'll look at thee combined constriction amplitude to all
% non-400% stimuli

non400Contrasts = {100, 200};

for dd = 1:2
    overallResponsiveness.(['day', num2str(dd)]) = zeros(size(downshiftedPooledSessionStruct.day1.LMS.Contrast400,1),1);
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(non400Contrasts)
            
            
            for tt = 1:length(TPUPComponentNames)
                
                
                % pre-allocate totalResponseAmplitude vector that we'll add to each loop
                % iteration around stimuli
                TPUPVector = getTPUPVector(dd, stimuli{stimulus}, non400Contrasts{contrast}, [TPUPComponentNames{tt}, 'amplitude']);
                overallResponsiveness.(['day', num2str(dd)])  = overallResponsiveness.(['day', num2str(dd)]) + TPUPVector;
            end
            
        end
    end
end

% Validate overallResponsiveness vector correlates with magnitude of
% response to indivdual stimuli at 400% contrast
savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'shiftedIndividualDifferences', 'overallResponsiveness');

% day 1 x day 2
xLims = [0 40];
yLims = xLims;
xTicks = [0 10 20 30 40];
yTicks = xTicks;
saveName = 'day1_x_day2';
xLabel = 'Day 1';
yLabel = 'Day 2';

plotIndividualDifferences(abs(overallResponsiveness.day1), abs(overallResponsiveness.day2), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% Now for each stimulus direction, for each day, the extent to which
% overall responsiveness predicts magnitude of response to 400% stimuli
xLims = [0 40];
yLims = [0 10];
xTicks = [0 10 20 30 40];
yTicks = [0 5 10];
for stimulus = 1:length(stimuli)
    for day = 1:2
        xLabel = (['Day ', num2str(day), ' Overall Responsiveness']);
        yLabel = (['Day ', num2str(day), ' ', stimuli{stimulus}]);
        saveName = ['day', num2str(day), '_overallResponsiveness_x_', stimuli{stimulus}];
        plotIndividualDifferences(abs(overallResponsiveness.(['day', num2str(day)])), abs(totalResponseAmplitude.(['day', num2str(day)]).(stimuli{stimulus})), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel, 'plotUnityLine', false);
        
    end
end

% Plot reproducibility of melanopsin-specific response
% Here, we'll quantify melanospin-specific as the difference in mel and LMS
% amplitudes, normalized by overall responsiveness
xLims = [-.5 0.5];
xTicks = [-0.5 0 0.5];
yLims = xLims;
yTicks = xTicks;
xLabel = 'Day 1';
yLabel = 'Day 2';
saveName = 'melMinusLMSDividedByOverallResponsiveness';
plotIndividualDifferences(((totalResponseAmplitude.day1.Melanopsin - totalResponseAmplitude.day1.LMS)./overallResponsiveness.day1), ((totalResponseAmplitude.day2.Melanopsin - totalResponseAmplitude.day2.LMS)./overallResponsiveness.day2), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel, 'plotUnityLine', true);


%% Make some across stimulus comparisons, first at the combined level
savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'shiftedIndividualDifferences', 'acrossStimulusComparisons');

xLims = [0 10];
yLims = xLims;
xTicks = [0 5 10];
yTicks = xTicks;

% Mel x LMS
saveName = 'melanopsin_x_LMS';
xLabel = 'Melanopsin Amplitude';
yLabel = 'LMS Amplitude';

plotIndividualDifferences(abs(totalResponseAmplitude.combinedMean.Melanopsin), abs(totalResponseAmplitude.combinedMean.LMS), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% Mel x LightFlux
saveName = 'melanopsin_x_LightFlux';
xLabel = 'Melanopsin Amplitude';
yLabel = 'LightFlux Amplitude';

plotIndividualDifferences(abs(totalResponseAmplitude.combinedMean.Melanopsin), abs(totalResponseAmplitude.combinedMean.LightFlux), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% LMS x LightFlux
saveName = 'LMS_x_LightFlux';
xLabel = 'LMS Amplitude';
yLabel = 'LightFlux Amplitude';

plotIndividualDifferences(abs(totalResponseAmplitude.combinedMean.LMS), abs(totalResponseAmplitude.combinedMean.LightFlux), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


%% Plot test-retest reliability
savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'shiftedIndividualDifferences', 'testRetest');

% melanospin response amplitude
xLims = [0 10];
yLims = xLims;
xTicks = [0 5 10];
yTicks = xTicks;
xLabel = 'Mel Amplitude Day 1';
yLabel = 'Mel Amplitude Day 2';
saveName = 'melAmplitude';
plotIndividualDifferences(abs(totalResponseAmplitude.day1.Melanopsin), abs(totalResponseAmplitude.day2.Melanopsin), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% LMS response amplitude
xLims = [0 10];
yLims = xLims;
xTicks = [0 5 10];
yTicks = xTicks;
xLabel = 'LMS Amplitude Day 1';
yLabel = 'LMS Amplitude Day 2';
saveName = 'LMSAmplitude';
plotIndividualDifferences(abs(totalResponseAmplitude.day1.LMS), abs(totalResponseAmplitude.day2.LMS), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% LightFlux response amplitude
xLims = [0 10];
yLims = xLims;
xTicks = [0 5 10];
yTicks = xTicks;
xLabel = 'LightFlux Amplitude Day 1';
yLabel = 'LightFlux Amplitude Day 2';
saveName = 'LightFluxAmplitude';
plotIndividualDifferences(abs(totalResponseAmplitude.day1.LightFlux), abs(totalResponseAmplitude.day2.LightFlux), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% Mel/LMS ratio
xLims = [0 4];
yLims = xLims;
xTicks = [0 1 2 3 4];
yTicks = xTicks;
xLabel = 'Mel/LMS Day 1';
yLabel = 'Mel/LMS Day 2';
saveName = 'melToLMS';
plotIndividualDifferences(totalResponseAmplitude.day1.Melanopsin./totalResponseAmplitude.day1.LMS, totalResponseAmplitude.day2.Melanopsin./totalResponseAmplitude.day2.LMS, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% melanopsin percentPersistent
xLims = [0 1];
yLims = xLims;
xTicks = [0 0.5 1];
yTicks = xTicks;
xLabel = 'Mel PercentPersistent Day 1';
yLabel = 'Mel PercentPersistent Day 2';
saveName = 'melanopsinPercentPersistent';
plotIndividualDifferences(percentPersistent.day1.Melanopsin, percentPersistent.day2.Melanopsin, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

xLims = [0 2.5];
yLims = xLims;
xTicks = [0 2];
yTicks = xTicks;
xLabel = 'Mel/LightFlux Day 1';
yLabel = 'Mel/LightFlux Day 2';
saveName = 'melToLightFlux';
plotIndividualDifferences((totalResponseAmplitude.day1.Melanopsin)./totalResponseAmplitude.day1.LightFlux, (totalResponseAmplitude.day2.Melanopsin)./totalResponseAmplitude.day2.LightFlux, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

xLims = [-2 2];
yLims = xLims;
xTicks = [-2 0 2];
yTicks = xTicks;
xLabel = '(Mel - LMS)/LightFlux Day 1';
xLabel = '(Mel - LMS)/LightFlux Day 2';
saveName = 'melMinusLMSOverLightFlux';
plotIndividualDifferences((totalResponseAmplitude.day1.Melanopsin-totalResponseAmplitude.day1.LMS)./totalResponseAmplitude.day1.LightFlux, (totalResponseAmplitude.day2.Melanopsin-totalResponseAmplitude.day2.LMS)./totalResponseAmplitude.day2.LightFlux, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);





% melanopsin exponentialTau
xLims = [0 20];
yLims = xLims;
xTicks = [0 10 20];
yTicks = xTicks;
xLabel = 'Mel exponentialTau Day 1';
yLabel = 'Mel exponentialTau Day 2';
saveName = 'melanopsinExponentialTau';
plotIndividualDifferences(exponentialTau.day1.Melanopsin, exponentialTau.day2.Melanopsin, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

%% Get area under the curve
beginningNumberOfIndicesToExclude = 40;
endingNumberOfIndicesToExclude = 45;
nIndices = 1036;

contrasts = {100 200 400};

for dd = 1:2
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            AUC.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end
end

    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            AUC.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end


for dd = 1:2
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            for ss = 1:size(downshiftedPooledSessionStruct.day1.LMS.Contrast100,1)
                
                AUC.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(trapz(downshiftedPooledSessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,beginningNumberOfIndicesToExclude:end-endingNumberOfIndicesToExclude)))/nIndices;

                
            end
        end
    end
end

    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            for ss = 1:size(downshiftedPooledSessionStruct.day1.LMS.Contrast100,1)
                
                AUC.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(trapz(downshiftedPooledSessionStruct.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,beginningNumberOfIndicesToExclude:end-endingNumberOfIndicesToExclude)))/nIndices;

                
            end
        end
    end
    
    non400Contrasts = {100, 200};

for dd = 1:2
    overallResponsivenessAUC.(['day', num2str(dd)]) = zeros(size(downshiftedPooledSessionStruct.day1.LMS.Contrast400,1),1);
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(non400Contrasts)
            
            
            for tt = 1:length(TPUPComponentNames)
                
                
                % pre-allocate totalResponseAmplitude vector that we'll add to each loop
                % iteration around stimuli
                overallResponsivenessAUC.(['day', num2str(dd)])  = overallResponsivenessAUC.(['day', num2str(dd)]) + AUC.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])';
            end
            
        end
    end
end

%% Make some across stimulus comparisons, first at the combined level
savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'shiftedIndividualDifferences', 'acrossStimulusComparisons');

xLims = [0 0.4];
yLims = xLims;
xTicks = [0 0.1 0.2 0.3 0.4];
yTicks = xTicks;

% Mel x LMS
saveName = 'AUC_melanopsin_x_LMS';
xLabel = 'Melanopsin Amplitude';
yLabel = 'LMS Amplitude';

plotIndividualDifferences(abs(AUC.combinedMean.Melanopsin.Contrast400), abs(AUC.combinedMean.LMS.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% Mel x LightFlux
saveName = 'AUC_melanopsin_x_LightFlux';
xLabel = 'Melanopsin Amplitude';
yLabel = 'LightFlux Amplitude';

plotIndividualDifferences(abs(AUC.combinedMean.Melanopsin.Contrast400), abs(AUC.combinedMean.LightFlux.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% LMS x LightFlux
saveName = 'AUC_LMS_x_LightFlux';
xLabel = 'LMS Amplitude';
yLabel = 'LightFlux Amplitude';

plotIndividualDifferences(abs(AUC.combinedMean.LMS.Contrast400), abs(AUC.combinedMean.LightFlux.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


%% Plot test-retest reliability
savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'shiftedIndividualDifferences', 'testRetest');

% melanospin response amplitude
xLims = [0 0.4];
yLims = xLims;
xTicks = [0 0.1 0.2 0.3 0.4];
yTicks = xTicks;
xLabel = 'Mel Amplitude Day 1';
yLabel = 'Mel Amplitude Day 2';
saveName = 'AUC_melAmplitude';
plotIndividualDifferences(abs(AUC.day1.Melanopsin.Contrast400), abs(AUC.day2.Melanopsin.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% LMS response amplitude
xLims = [0 0.4];
yLims = xLims;
xTicks = [0 0.1 0.2 0.3 0.4];
yTicks = xTicks;
xLabel = 'LMS Amplitude Day 1';
yLabel = 'LMS Amplitude Day 2';
saveName = 'AUC_LMSAmplitude';
plotIndividualDifferences(abs(AUC.day1.LMS.Contrast400), abs(AUC.day2.LMS.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% LightFlux response amplitude
xLims = [0 0.4];
yLims = xLims;
xTicks = [0 0.1 0.2 0.3 0.4];
yTicks = xTicks;
xLabel = 'LightFlux Amplitude Day 1';
yLabel = 'LightFlux Amplitude Day 2';
saveName = 'AUC_LightFluxAmplitude';
plotIndividualDifferences(abs(AUC.day1.LightFlux.Contrast400), abs(AUC.day2.LightFlux.Contrast400), 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


% Mel/LMS ratio
xLims = [0 40];
yLims = xLims;
xTicks = [0 10 20 30 40];
yTicks = xTicks;
xLabel = 'Mel/LMS Day 1';
yLabel = 'Mel/LMS Day 2';
saveName = 'AUC_melToLMS';
plotIndividualDifferences(AUC.day1.Melanopsin.Contrast400./AUC.day1.LMS.Contrast400, AUC.day2.Melanopsin.Contrast400./AUC.day2.LMS.Contrast400, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

% Mel/LMS ratio
xLims = [0 5];
yLims = xLims;
xTicks = [0 2.5 5];
yTicks = xTicks;
xLabel = 'Mel/LMS Day 1';
yLabel = 'Mel/LMS Day 2';
saveName = 'AUC_melToLMS_restrictedView';
plotIndividualDifferences(AUC.day1.Melanopsin.Contrast400./AUC.day1.LMS.Contrast400, AUC.day2.Melanopsin.Contrast400./AUC.day2.LMS.Contrast400, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


xLims = [0 10];
yLims = xLims;
xTicks = [0 10];
yTicks = xTicks;
xLabel = 'Mel/LightFlux Day 1';
yLabel = 'Mel/LightFlux Day 2';
saveName = 'AUC_melToLightFlux';
plotIndividualDifferences((AUC.day1.Melanopsin.Contrast400)./AUC.day1.LightFlux.Contrast400, (AUC.day2.Melanopsin.Contrast400)./AUC.day2.LightFlux.Contrast400, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);

xLims = [-2 2];
yLims = xLims;
xTicks = [-2 0 2];
yTicks = xTicks;
xLabel = '(Mel - LMS)/LightFlux Day 1';
yLabel = '(Mel - LMS)/LightFlux Day 2';
saveName = 'AUC_melMinusLMSOverLightFlux';
plotIndividualDifferences((AUC.day1.Melanopsin.Contrast400-AUC.day1.LMS.Contrast400)./AUC.day1.LightFlux.Contrast400, (AUC.day2.Melanopsin.Contrast400-AUC.day2.LMS.Contrast400)./AUC.day2.LightFlux.Contrast400, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);


x = (AUC.day1.Melanopsin.Contrast400 - AUC.day1.LMS.Contrast400)'./ ...
    (overallResponsivenessAUC.day1);
y = (AUC.day2.Melanopsin.Contrast400 - AUC.day2.LMS.Contrast400)'./ ...
    (overallResponsivenessAUC.day2);


xLims = [-0.2 0.2];
yLims = xLims;
xTicks = [-0.2 0 0.2];
yTicks = xTicks;
xLabel = '(Mel - LMS)/Overall Responsiveness Day 1';
yLabel = '(Mel - LMS)/Overall Responsiveness Day 2';
saveName = 'AUC_melMinusLMSDividedByOverallResponsiveness';
plotIndividualDifferences(x, y, 'xLims', xLims, 'yLims', yLims, 'xTicks', xTicks, 'yTicks', yTicks, 'savePath', savePath, 'saveName', saveName, 'xLabel', xLabel, 'yLabel', yLabel);
