function [resultsStruct, subjectIDsStruct, MelContrastByStimulus, LMSContrastByStimulus] = loadPupilResponses(varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('experimentNumber', [] ,@isstr);
p.addParameter('runFitTPUP', false ,@islogical);
p.addParameter('AUCBeginningIndicesToExclude', 40 ,@isnumeric);
p.addParameter('AUCEndingIndicesToExclude', 40 ,@isnumeric);

p.parse(varargin{:})


%% Silence anticipated warnings
warningState = warning;
warning('off','MATLAB:table:ModifiedAndSavedVarnames');


%% Set up some basic preferences that will differ depending on the protocol
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

% Get subjectList
if strcmp(p.Results.protocol, 'SquintToPulse')
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    subjectListStruct = getDeuteranopeSubjectStruct;
    subjectIDs = fieldnames(subjectListStruct.experiment1);
end

% Set-up loop structure.
if strcmp(p.Results.protocol, 'SquintToPulse')
    % looping over groups for squint to pulse
    fieldNamesToLoopOver = {'controls', 'mwa', 'mwoa'};
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    % looping over experimentNumber for Deuteranopes
    fieldNamesToLoopOver = {'experiment_1', 'experiment_2'};
end

% Define stimulus names. LMS is for SquintToPulse, LS for Deuteranopes
if strcmp(p.Results.protocol, 'SquintToPulse')
    stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};

end

%% Loop to build resultsStruct
for ii = 1:length(fieldNamesToLoopOver)
    
    % Define contrast levels, which will vary depending on the specific
    % protocol and experiment
    if strcmp(p.Results.protocol, 'SquintToPulse')
        contrasts = {100, 200, 400};
    elseif strcmp(p.Results.protocol, 'Deuteranopes')
        if strcmp(fieldNamesToLoopOver, 'experiment_1')
            contrasts = {100, 200, 400};
        elseif strcmp(fieldNamesToLoopOver, 'experiment_2')
            contrasts = {400, 800, 1200};
        end
    end

    %% First we'll do some operations that require the pupil response over
    % time. Besides the response over time vector itself, we'll calculate
    % area under the curve (AUC) and peak amplitude.
    
    % Pre-allocate the variable
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)

            % response over time
            resultsStruct.responseOverTime.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            % SEM of response over time
            resultsStruct.responseOverTime.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
            
            % AUC
            resultsStruct.AUC.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            % Normalized AUC
            resultsStruct.normalizedAUC.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            % Peak amplitude. Basically minimium value
            resultsStruct.peakAmplitude.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
        end
    end

    % Loop over subjects
    for ss = 1:length(subjectIDs)

        subjectID = subjectIDs{ss};
        
        % Load the trialStruct which contains pupil responses over time for
        % each acceptable trial.
        % Where to load that trialStruct depends on which protocol
        if strcmp(p.Results.protocol, 'SquintToPulse')
            resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
            load(fullfile(resultsDir, [subjectID, '_trialStruct_radiusSmoothed.mat']));
        else
            load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, fieldNamesToLoopOver{ii}, ['trialStruct_radiusSmoothed.mat']));
        end

        % Loop over stimulus conditions
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                subjectAverageResponse = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                SEM = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1));
                
                AUC = abs(trapz(subjectAverageResponse(p.Results.AUCBeginningIndicesToExclude:end-p.Results.AUCEndingIndicesToExclude)));
                
                % response over time
                resultsStruct.responseOverTime.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                
                % SEM of response over time
                resultsStruct.responseOverTime.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                
                % AUC
                resultsStruct.AUC.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                
                % Normalized AUC
                resultsStruct.normalizedAUC.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC/(length(subjectAverageResponse-p.Results.AUCBeginningIndicesToExclude - p.Results.AUCEndingIndicesToExclude));
                
                % Peak amplitude. Basically minimium value
                resultsStruct.peakAmplitude.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(min(subjectAverageResponse));
            end
        end

    end

    %% Now we'll do some modeling with TPUP and extract some summary measures

    % Only run fitTPUP if necessary, otherwise just load the results from
    % previous analysis
    if p.Results.runFitTPUP
        
        % Get the persistentGammaTau from the group average
        if strcmp(p.Results.protocol, 'SquintToPulse')
            [modeledResponses] = fitTPUP('group', 'protocol', p.Results.protocol);
        elseif strcmp(p.Results.protocol, 'Deuteranopes')
            [modeledResponses] = fitTPUP('group', 'protocol', p.Results.protocol, 'experimentName', fieldNamesToLoopOver{ii});
        end
        persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);

        % Run fitTPUP, looping over contrast levels
        for contrast = 1:length(contrasts)
            if strcmp(p.Results.protocol, 'SquintToPulse')
                summarizeTPUP(persistentGammaTau, 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
            elseif strcmp(p.Results.protocol, 'Deuteranopes')
                summarizeTPUP(persistentGammaTau, 'protocol', 'Deuteranopes', 'experimentName', ['experiment_', num2str(experiment)], 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
            end

        end

    end

    % Load TPUP params
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            % percent persistent
            resultsStruct.percentPersistent.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            % total responsee amplitude (modeled area under the curve)
            resultsStruct.amplitude.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end

    
    
end



%% Pool pupil traces

if strcmp(p.Results.protocol, 'SquintToPulse')
    resultsStruct.(fieldNamesToLoopOver{ii}) = [];
    mwaPupilResponses = [];
    mwoaPupilResponses = [];
    
    stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
    contrasts = {100, 200, 400};
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            resultsStruct.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            resultsStruct.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
            mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
            mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
            combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
            
            
            controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
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
                SEM = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1));
                
                AUC = abs(trapz(subjectAverageResponse(p.Results.AUCBeginningIndicesToExclude:end-p.Results.AUCEndingIndicesToExclude)));
                
                if strcmp(group, 'c')
                    resultsStruct.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    resultsStruct.(fieldNamesToLoopOver{ii}).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                    controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    controlNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC/1031;
                    controlPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(min(subjectAverageResponse));
                    controlSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwa')
                    mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                    mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC/1031;
                    mwaPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(min(subjectAverageResponse));
                    mwaSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwoa')
                    mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                    mwoaPeakAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = abs(min(subjectAverageResponse));
                    mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwoaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC/1031;
                    mwoaSubjects{end+1} = subjectIDs{ss};
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
        
    end
    
    responseOverTimeStruct.mwa = mwaPupilResponses;
    responseOverTimeStruct.mwoa = mwoaPupilResponses;
    responseOverTimeStruct.controls = resultsStruct.(fieldNamesToLoopOver{ii});
    
    AUCStruct.mwa = mwaAUC;
    AUCStruct.mwoa = mwoaAUC;
    AUCStruct.controls = controlAUC;
    
    normalizedAUCStruct.mwa = mwaNormalizedAUC;
    normalizedAUCStruct.mwoa = mwoaNormalizedAUC;
    normalizedAUCStruct.controls = controlNormalizedAUC;
    
    peakAmplitudeStruct.mwa = mwaPeakAmplitude;
    peakAmplitudeStruct.mwoa = mwoaPeakAmplitude;
    peakAmplitudeStruct.controls = controlPeakAmplitude;

    
    mwaSubjects = unique(mwaSubjects);
    mwoaSubjects = unique(mwoaSubjects);
    controlSubjects = unique(controlSubjects);
    
    subjectListStruct = [];
    subjectListStruct.mwaSubjects = mwaSubjects;
    subjectListStruct.mwoaSubjects = mwoaSubjects;
    subjectListStruct.controlSubjects = controlSubjects;
    
    
    % Now TPUP stuff
    stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
    contrasts = {100, 200, 400};
    amplitudes = {'Transient', 'Sustained', 'Persistent'};

    runFitTPUP = p.Results.runFitTPUP;
    if runFitTPUP
        [modeledResponses] = fitTPUP('group');
        persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
        for contrast = 1:length(contrasts)
            summarizeTPUP(persistentGammaTau, 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
        end

    end
    
    
    
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
                responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
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
                    SEM = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1));
                    AUC = abs(trapz(subjectAverageResponse(numberOfIndicesToExclude:end-numberOfIndicesToExclude)));
                    
                    responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                    AUCStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = AUC;
                    
                end
            end
            
        end
    end
    
    % TPUP stuff
    runFitTPUP = p.Results.runFitTPUP;
    if runFitTPUP
        for experiment = experiments
            experimentName = ['experiment_', num2str(experiment)];
            
            if experiment == 1
                contrasts = {100, 200, 400};
                [modeledResponses] = fitTPUP('group', 'protocol', 'Deuteranopes', 'experimentName', 'experiment_1');
                persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
            elseif experiment == 2
                contrasts = {400, 800, 1200};
                [modeledResponses] = fitTPUP('group', 'protocol', 'Deuteranopes', 'experimentName', 'experiment_2');
                persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
            end
            
            for contrast = 1:length(contrasts)
                summarizeTPUP(persistentGammaTau, 'protocol', 'Deuteranopes', 'experimentName', ['experiment_', num2str(experiment)], 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
            end
            
        end
    end

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
resultsStruct.normalizedAUC = normalizedAUCStruct;
resultsStruct.amplitude = amplitudeStruct;
resultsStruct.percentPersistent = percentPersistentStruct;
resultsStruct.subjects = subjectListStruct;
resultsStruct.peakAmplitude = peakAmplitudeStruct;


% Restore the warning state
warning(warningState);


% Defining this empty variable to maintain parallel structure with
% loadDiscomfortRatings.m
subjectIDsStruct = [];



% Assemble the melanopsin and cone contrasts for each stimulus type. We
% treat light flux stimuli as having equal contrast on the mel and LMS
% photoreceptor pools.
MelContrastByStimulus = [100 200 400 0 0 0 100 200 400];
LMSContrastByStimulus = [0 0 0 100 200 400 100 200 400];



end
