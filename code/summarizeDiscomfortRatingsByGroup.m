%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

subjectIDs = [];
potentialSubjects =  dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));
for ss = 1:length(potentialSubjects)
    subjectIDs{end+1} = potentialSubjects(ss).name;
end
% rationale for exlcuded subjects:
% MELA_0127: only completed 1 session
% MELA_0215: TEMPORARY -- the subject completed screening, at which time I
% accidentally saved the initial pupil calibration as RunPulseSquintTrials
% rather than ScreenPulseSquintTrials
% MELA_0195, MELA_0144, MELA_0162: poor pupillometry
badSubjects = {'MELA_0127', 'MELA_0215', 'MELA_0195', 'MELA_0144', 'MELA_0162'};
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

contrastsOfInterest = {100, 200, 400};

if combineMigraineurs
    plotFig = figure;
    
    for stimulus = 1:length(stimuli)
        subplot(1,length(stimuli), stimulus);
        data = nan(2*length(contrastsOfInterest), max(length([mwoaDiscomfort.Melanopsin.Contrast400, mwaDiscomfort.Melanopsin.Contrast400]), length(controlDiscomfort.Melanopsin.Contrast400)));
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            data(contrast*2,1:length([mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]')) = [mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]';
            data(contrast*2-1,1:length(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])';
            
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMigraineDiscomfort = nanmedian([mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]);
            medianControlDiscomfort = nanmedian(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            
            fprintf('\t\tMedian discomfort rating for all migraineurs: %4.2f\n', medianMigraineDiscomfort);
            fprintf('\t\tMedian discomfort rating for controls: %4.2f\n', medianControlDiscomfort);
            
        end
        categoryIdx = repmat([0,1], max(length([mwoaDiscomfort.Melanopsin.Contrast400, mwaDiscomfort.Melanopsin.Contrast400]), length(controlDiscomfort.Melanopsin.Contrast400)), size(data,1)/2);
        plotSpread(data', 'categoryIdx', categoryIdx(:), 'xValues', [0.8 1.2 1.8 2.2 2.8 3.2], 'categoryColors', {'k', 'r'}, 'showMM', 3, 'categoryLabels', {'Controls', 'Migraineurs'})
        xticks([1:3])
        xticklabels({'100%', '200%', '400%'})
        xlabel('Contrast')
        ylabel('Discomfort Rating')
        title(stimuli{stimulus})
        ylim([0 10])
    end
    
end




