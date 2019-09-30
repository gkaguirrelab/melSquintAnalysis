%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

calculateRMS = true;

%% Pool results
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
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
    
    if calculateRMS
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true);
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', true);

    end
    close all;
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
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

%% Display results

EMG = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        EMG.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        
        EMG.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(EMG, 'yLims', [0 6], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'groupAverage.pdf'))



EMG = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        EMG.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(EMG, 'yLims', [0 6], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'groupAverage_combinedMigraineurs.pdf'))

