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