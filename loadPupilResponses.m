function [resultsStruct] = loadPupilResponses(varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('experimentNumber', [] ,@isstr);

p.parse(varargin{:})


%% Load subjectListStruct
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

if strcmp(p.Results.protocol, 'SquintToPulse')
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    subjectListStruct = getDeuteranopeSubjectStruct;
    subjectIDs = fieldnames(subjectListStruct.experiment1);
end

% For AUC, how many noisy indices to exclude from beginning and end:
numberOfIndicesToExclude = 40;




%% Pool pupil traces

if strcmp(p.Results.protocol, 'SquintToPulse')
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
            
            controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
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
                
                        subjectAverageResponse = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
        AUC = abs(trapz(subjectAverageResponse(numberOfIndicesToExclude:end-numberOfIndicesToExclude)));
                
                if strcmp(group, 'c')
                    controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    controlSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwa')
                    mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwaSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwoa')
                    mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwoaSubjects{end+1} = subjectIDs{ss};
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
        
    end
    
    responseOverTimeStruct.mwa = mwaPupilResponses;
    responseOverTimeStruct.mwoa = mwoaPupilResponses;
    responseOverTimeStruct.controls = controlPupilResponses;
    
    AUCStruct.mwa = mwaAUC;
    AUCStruct.mwoa = mwoaAUC;
    AUCStruct.controls = controlAUC;
    
    mwaSubjects = unique(mwaSubjects);
    mwoaSubjects = unique(mwoaSubjects);
    controlSubjects = unique(controlSubjects);
    
    subjectListStruct = [];
    subjectListStruct.mwaSubjects = mwaSubjects;
    subjectListStruct.mwoaSubjects = mwoaSubjects;
    subjectListStruct.controlSubjects = controlSubjects;
    
    
    
    stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
    contrasts = {100, 200, 400};
    amplitudes = {'Transient', 'Sustained', 'Persistent'};
    
    
    
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
                
                amplitude = (transientAmplitude + sustainedAmplitude + persistentAmplitude);
                
                if strcmp(group, 'c')
                    controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -amplitude;
                    
                elseif strcmp(group, 'mwa')
                    mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -amplitude;
                    
                    
                elseif strcmp(group, 'mwoa')
                    mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                    mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -amplitude;
                    
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
    end
    
    amplitudeStruct.mwa = mwaTotalResponseAmplitude;
    amplitudeStruct.mwoa = mwoaTotalResponseAmplitude;
    amplitudeStruct.controls = controlTotalResponseAmplitude;
    
    percentPersistentStruct.mwa = mwaPercentPersistent;
    percentPersistentStruct.mwoa = mwoaPercentPersistent;
    percentPersistentStruct.controls = controlPercentPersistent;
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    % pupil responses
    fitType = 'radiusSmoothed';
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};
    saveNameSuffix = '';
    
    experiments = 1:2;
    subjectIndices = 1:5;
    
    runMakeSubjectAverageResponses = false;
    
    for experiment = experiments
        experimentName = ['experiment_', num2str(experiment)];
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
            
        end
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                AUCStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                
            end
        end
    end
    
    
    for experiment = experiments
        experimentName = ['experiment_', num2str(experiment)];
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
            
        end
        
        for ss = subjectIndices
            subjectID = subjectIDs{ss};
            if runMakeSubjectAverageResponses
                
                makeSubjectAverageResponses(subjectID, 'experimentName', experimentName, 'stimuli', stimuli, 'contrasts', contrasts, 'Protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes','blinkBufferFrames', [3 6], 'saveNameSuffix', saveNameSuffix, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectID), 'fitLabel', fitType)
                load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));
                
            else
                load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));
            end
            
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    subjectAverageResponse = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                    AUC = abs(trapz(subjectAverageResponse(numberOfIndicesToExclude:end-numberOfIndicesToExclude)));
                    
                    responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    AUCStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = AUC;
                    
                end
            end
            
        end
    end
    
    % amplitude and percent persistent
    for experiment = 1:2
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
        end
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                amplitudeStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                percentPersistentStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                
            end
            
        end
    end
    
    % pool results
    for experiment = 1:2
        experimentName = ['experiment_', num2str(experiment)];
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
            
        end
        
        for ss = 1:5
            
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/TPUP/Deuteranopes', ['experiment_', num2str(experiment)], ['TPUPParams_', num2str(contrasts{contrast}),  'Contrast.csv']);
                    
                    TPUPParamsTable = readtable(csvFileName);
                    columnsNames = TPUPParamsTable.Properties.VariableNames;
                    subjectRow = find(contains(TPUPParamsTable{:,1}, subjectIDs{ss}));
                    
                    if strcmp(stimuli{stimulus}, 'LS')
                        transientAmplitudeColumn = find(contains(columnsNames, ['LMSTransientAmplitude']));
                        sustainedAmplitudeColumn = find(contains(columnsNames, ['LMSSustainedAmplitude']));
                        persistentAmplitudeColumn = find(contains(columnsNames, ['LMSPersistentAmplitude']));
                    else
                        transientAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'TransientAmplitude']));
                        sustainedAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'SustainedAmplitude']));
                        persistentAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'PersistentAmplitude']));
                    end
                    
                    transientAmplitude = TPUPParamsTable{subjectRow, transientAmplitudeColumn};
                    sustainedAmplitude = TPUPParamsTable{subjectRow, sustainedAmplitudeColumn};
                    persistentAmplitude = TPUPParamsTable{subjectRow, persistentAmplitudeColumn};
                    
                    
                    
                    amplitudeStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = abs(transientAmplitude + sustainedAmplitude + persistentAmplitude);
                    percentPersistentStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = persistentAmplitude/(persistentAmplitude + transientAmplitude + sustainedAmplitude);
                    
                end
            end
            
            
            
            
            
        end
    end
    
    % percentPersistent
    
end

resultsStruct.responseOverTime = responseOverTimeStruct;
resultsStruct.AUC = AUCStruct;
resultsStruct.amplitude = amplitudeStruct;
resultsStruct.percentPersistent = percentPersistentStruct;
resultsStruct.subjects = subjectListStruct;


end
