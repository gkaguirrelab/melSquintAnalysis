%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

subjectIDs = [];
potentialSubjects =  dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));
for ss = 1:length(potentialSubjects)
    subjectIDs{end+1} = potentialSubjects(ss).name;
end
badSubjects = {'MELA_0127', 'MELA_0215'};
subjectIDs = setdiff(subjectIDs, badSubjects);

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


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', subjectIDs{ss});
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
            elseif strcmp(group, 'mwa')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                
            elseif strcmp(group, 'mwoa')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end


%% Display results
combineMigraineurs = true;

contrastsOfInterest = {400};

if combineMigraineurs
    for stimulus = 1:length(stimuli)
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMigraineRMS = median([mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]);
            medianControlRMS = median(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            fprintf('\t\tMedian RMS for all migraineurs: %4.2f\n', medianMigraineRMS);
            fprintf('\t\tMedian RMS for controls: %4.2f\n', medianControlRMS);

        end
    end
end
    
    


