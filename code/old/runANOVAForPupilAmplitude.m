%% get all discomfort ratings responses
generateMatrix = false;

if generateMatrix
    
    stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
    contrasts = {100, 200, 400};
    
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
            percentPersistent.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
            percentPersistent.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
            
            totalResponseAmplitude.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])].*-1;
            totalResponseAmplitude.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).*-1;
            
            
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
                    pooledMatrix(instanceCounter,1) = totalResponseAmplitude.(groups{group}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ii);
                    
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
    
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'pooledObservationsForANOVA.mat'), 'pooledMatrix');
else
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil/TPUP', 'pooledObservationsForANOVA.mat'))
    
end

%% Run the ANOVA

p = anovan(pooledMatrix(:,1), pooledMatrix(:,2:4), 'varnames', {'Stimulus', 'Contrast', 'Group'})
