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
badSubjects = {'MELA_0127', 'MELA_0195', 'MELA_0144', 'MELA_0162'};
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

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', subjectIDs{ss});
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                load(fullfile(resultsDir, 'EMGMedianResponseStruct.mat'));
                mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianResponseStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
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
combineMigraineurs = true;

contrastsOfInterest = {100, 200, 400};

if combineMigraineurs
    plotFig = figure;
    
    for stimulus = 1:length(stimuli)
        ax.(['ax', num2str(stimulus)]) = subplot(1,length(stimuli), stimulus);
        data = nan(2*length(contrastsOfInterest), max(length([mwoaRMS.Melanopsin.Contrast400, mwaRMS.Melanopsin.Contrast400]), length(controlRMS.Melanopsin.Contrast400)));
        
        fprintf('<strong>Stimulus type: %s</strong>\n', stimuli{stimulus});
        for contrast = 1:length(contrastsOfInterest)
            data(contrast*2,1:length([mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]')) = [mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]';
            data(contrast*2-1,1:length(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])')) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])';
            
            fprintf('\tContrast: %s%%\n', num2str(contrastsOfInterest{contrast}));
            medianMigraineDiscomfort = nanmedian([mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]),mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})])]);
            mediancontrolRMS = nanmedian(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrastsOfInterest{contrast})]));
            
            
            fprintf('\t\tMedian discomfort rating for all migraineurs: %4.2f\n', medianMigraineDiscomfort);
            fprintf('\t\tMedian discomfort rating for controls: %4.2f\n', mediancontrolRMS);
            
        end
        categoryIdx = repmat([0,1], max(length([mwoaRMS.Melanopsin.Contrast400, mwaRMS.Melanopsin.Contrast400]), length(controlRMS.Melanopsin.Contrast400)), size(data,1)/2);
        plotSpread(data', 'categoryIdx', categoryIdx(:), 'xValues', [0.8 1.2 1.8 2.2 2.8 3.2], 'categoryColors', {'k', 'r'}, 'showMM', 3, 'categoryLabels', {'Controls', 'Migraineurs'})
        xticks([1:3])
        xticklabels({'100%', '200%', '400%'})
        xlabel('Contrast')
        ylabel('Discomfort Rating')
        title(stimuli{stimulus})
    end
    linkaxes([ax.ax1, ax.ax2, ax.ax3]);
    
end






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
    
    


