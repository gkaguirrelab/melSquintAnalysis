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

discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        
    end
end

% Next by combine migraineurs
%discomfortRatings = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end


%% Pool pupil traces
controlPupilResponses = [];
mwaPupilResponses = [];
mwoaPupilResponses = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
    load(fullfile(resultsDir, [subjectIDs{ss}, '_trialStruct_radiusSmoothed.mat']));
    
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwoaSubjects{end+1} = subjectIDs{ss};
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end

mwaSubjects = unique(mwaSubjects);
mwoaSubjects = unique(mwoaSubjects);
controlSubjects = unique(controlSubjects);

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
        controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end

for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            
            csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/TPUP/', ['TPUPParams_Contrast', num2str(contrasts{contrast}),  '.csv']);
            TPUPParamsTable = readtable(csvFileName);
            columnsNames = TPUPParamsTable.Properties.VariableNames;
            subjectRow = find(contains(TPUPParamsTable{:,1}, subjectIDs{ss}));
            
            transientAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'TransientAmplitude']));
            sustainedAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'SustainedAmplitude']));
            persistentAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'PersistentAmplitude']));
            
            transientAmplitude = TPUPParamsTable{subjectRow, transientAmplitudeColumn};
            sustainedAmplitude = TPUPParamsTable{subjectRow, sustainedAmplitudeColumn};
            persistentAmplitude = TPUPParamsTable{subjectRow, persistentAmplitudeColumn};
            
            percentPersistent = (persistentAmplitude)/(transientAmplitude + sustainedAmplitude + persistentAmplitude)*100;
            
            totalResponseAmplitude = (transientAmplitude + sustainedAmplitude + persistentAmplitude);
            
            if strcmp(group, 'c')
                controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
            elseif strcmp(group, 'mwa')
                mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
                
            elseif strcmp(group, 'mwoa')
                mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = totalResponseAmplitude;
                
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
end



percentPersistent = [];
totalResponseAmplitude = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        percentPersistent.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        percentPersistent.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        percentPersistent.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        
        totalResponseAmplitude.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        totalResponseAmplitude.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        
        
    end
end

%% Do the summary plotting
plotFig = figure;
hold on;
counter = 1;
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        subplot(3,3,counter); hold on;
        plot(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'r')
        plot(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'k')
        
        coeffs = polyfit(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
        fittedX = linspace(min(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), max(discomfortRatings.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r')
        
        coeffs = polyfit(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
        fittedX = linspace(min(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), max(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k')
        
        counter = counter + 1;
        
        title([stimuli{stimulus}, 'Contrast ', num2str(contrasts{contrast}), '%']);
    end
end


plotFig = figure;
hold on;
counter = 1;
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        subplot(3,3,counter); hold on;
        plot(discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'b')
        plot(discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'r')
        
        plot(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'k')
        
        coeffs = polyfit(discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
        fittedX = linspace(min(discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), max(discomfortRatings.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'r')
        
        coeffs = polyfit(discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
        fittedX = linspace(min(discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), max(discomfortRatings.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'b')
        
        coeffs = polyfit(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 1);
        fittedX = linspace(min(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), max(discomfortRatings.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1, 'Color', 'k')
        
        counter = counter + 1;
        
        title([stimuli{stimulus}, 'Contrast ', num2str(contrasts{contrast}), '%']);
    end
end