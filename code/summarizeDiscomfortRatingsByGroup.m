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
    fileName = 'audioTrialStruct.mat';
    
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

contrastsOfInterest = {400};

if combineMigraineurs
    for stimulus = 1:length(stimuli)
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMigraineDiscomfort = nanmedian([mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]);
            medianControlDiscomfort = nanmedian(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            fprintf('\t\tMedian discomfort rating for all migraineurs: %4.2f\n', medianMigraineDiscomfort);
            fprintf('\t\tMedian discomfort rating for controls: %4.2f\n', medianControlDiscomfort);

        end
    end
end
    
    


