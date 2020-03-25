function [resultsStruct, subjectIDsStruct, MelContrastByStimulus, LMSContrastByStimulus] = loadPupilResponses(varargin)
% This function loads in pupil results for Squint and Deuteranope
% experiments.

% Syntax: 
%   [resultsStruct, subjectIDsStruct, MelContrastByStimulus, LMSContrastByStimulus] = loadPupilResponses('protocol', 'SquintToPulse')

% Description:
%   Depending on the specific experiment of interest, this function loads
%   up the pupil results of various types. The function loads for each 
%   individual subject for each stimulus condition: 1) the raw pupil time 
%   series for each individual subject, the area under the curve,
%   normalized area under the curve (AUC divided by the number of indicies
%   over which this was calculated), TPUP total response amplitude (sum of
%   amplitude of each component), and TPUP percent persistent.

% Outputs:
%   - resultsStruct         - a struct, where the first level contains the
%                             different result types (responseOverTime,
%                             AUC, normalized AUC, percentPersistent, TPUP
%                             amplitude). Second level contains either
%                             migraine group for the Squint study, or
%                             experimentNumber for Deuteranopes. Third
%                             level is stimulus type, fourth level is
%                             contrast level. At the final level we have
%                             the result in question for each individual
%                             subject.
%   - subjectIDsStruct      - a struct which gives the subjectIDs for the
%                             given experiment. The ordering of subjects
%                             corresponds to the ordering of results within
%                             the resultsStruct.
%   - mel/LMSContrastByStimulus - Each is a 1x9 vector which reflects the
%                             amount of either melanopsin or LMS contrast
%                             for each stimulus type for each contrast
%                             level. Stimuli range from Melanopsin -> LMS
%                             -> LightFlux, ascending from 100-200-400%
%                             contrast for each stimulus type.

% Key-value pairs:
%   - protocol              - a string specifying which protocol the video
%                             to be processed belongs to. The default is
%                             SquintToPulse for the migraine squint study,
%                             but Deuteranopes is another workable
%                             protocol.
%   - experimentNumber      - a string specifying the experiment number
%                             to which the video to be processed belongs.
%                             The default is an empty variable, which is
%                             appropriate because some protocols
%                             (SquintToPulse) do not have an
%                             experimentNumber. For deuteranopes, the
%                             workable options include 'experiment_1' and
%                             'experiment_2'
%   - runFitTPUP            - a logical used to control fitting behavior.
%                             If set to true, this routine will fit average
%                             responses with the TPUP model and extract
%                             parameters from this fit. If false, the
%                             routine will load up a recently fitted
%                             results.



%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('experimentNumber', [] ,@isstr);
p.addParameter('runFitTPUP', false ,@islogical);


p.parse(varargin{:})


%% Silence anticipated warnings
warningState = warning;
warning('off','MATLAB:table:ModifiedAndSavedVarnames');


%% Load subjectListStruct
% Which will vary depending on which experiment
dataBasePath = getpref('melSquintAnalysis','melaDataPath');
if strcmp(p.Results.protocol, 'SquintToPulse')
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    subjectListStruct = getDeuteranopeSubjectStruct;
    subjectIDs = fieldnames(subjectListStruct.experiment1);
end

% For AUC, how many noisy indices to exclude from beginning and end:
% Essentially, the first and last indices are unstable and would lead to
% funny answers. This step will exclude the noisy indices.
beginningNumberOfIndicesToExclude = 40;
endingNumberOfIndicesToExclude = 40;



%% SquintToPulse Experiment
if strcmp(p.Results.protocol, 'SquintToPulse')
    
    % define stimulus parameters
    stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
    contrasts = {100, 200, 400};

    % pre-allocate variables
    controlPupilResponses = [];
    mwaPupilResponses = [];
    mwoaPupilResponses = [];
   
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM']) = [];
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
    
    % Loop over subjects, ultimately extracting average response over time
    % for each stimulus condition
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
        load(fullfile(resultsDir, [subjectIDs{ss}, '_trialStruct_radiusSmoothed.mat']));
        

        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                % define average response over time
                subjectAverageResponse = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                
                % define SEM over time
                SEM = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1));
                
                % calculate AUC from response over time
                AUC = abs(trapz(subjectAverageResponse(beginningNumberOfIndicesToExclude:end-endingNumberOfIndicesToExclude)));
                
                % stash result, depending on group
                if strcmp(group, 'c')
                    controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
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
    
    % save out result
    responseOverTimeStruct.mwa = mwaPupilResponses;
    responseOverTimeStruct.mwoa = mwoaPupilResponses;
    responseOverTimeStruct.controls = controlPupilResponses;
    
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
    % define amplitude components
    amplitudes = {'Transient', 'Sustained', 'Persistent'};

    % only fitTPUP if specified
    runFitTPUP = p.Results.runFitTPUP;
    if runFitTPUP
        [modeledResponses] = fitTPUP('group');
        persistentGammaTau = modeledResponses.LightFlux.params.paramMainMatrix(3);
        for contrast = 1:length(contrasts)
            summarizeTPUP(persistentGammaTau, 'contrast', contrasts{contrast}, 'saveName', ['TPUPParams_', num2str(contrasts{contrast}), 'Contrast.csv']);
        end

    end
    
    
    % Otherwise, just load in recent analysis
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
                
                % load up CSV file, which contains TPUP results for all
                % subjects for a given contrast level
                csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/pupil/TPUP/', ['TPUPParams_Contrast', num2str(contrasts{contrast}),  '.csv']);
                
                % load CSV contents as table
                TPUPParamsTable = readtable(csvFileName);

                % Figure out column labels of the table
                columnsNames = TPUPParamsTable.Properties.VariableNames;

                % Find row for the given subject
                subjectRow = find(contains(TPUPParamsTable{:,1}, subjectIDs{ss}));
                
                % Identify which columns correspond to amplitude of each
                % component
                transientAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'TransientAmplitude']));
                sustainedAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'SustainedAmplitude']));
                persistentAmplitudeColumn = find(contains(columnsNames, [stimuli{stimulus}, 'PersistentAmplitude']));
                
                % Extract these amplitudes
                transientAmplitude = TPUPParamsTable{subjectRow, transientAmplitudeColumn};
                sustainedAmplitude = TPUPParamsTable{subjectRow, sustainedAmplitudeColumn};
                persistentAmplitude = TPUPParamsTable{subjectRow, persistentAmplitudeColumn};
                
                % Calculate percent persistnet:
                percentPersistent = (persistentAmplitude)/(transientAmplitude + sustainedAmplitude + persistentAmplitude)*100;
                
                % Calculate total response amplitude
                amplitude = (transientAmplitude + sustainedAmplitude + persistentAmplitude);
                
                % Stash result by group
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
    
    % Save out result
    amplitudeStruct.mwa = mwaTotalResponseAmplitude;
    amplitudeStruct.mwoa = mwoaTotalResponseAmplitude;
    amplitudeStruct.controls = controlTotalResponseAmplitude;
    
    percentPersistentStruct.mwa = mwaPercentPersistent;
    percentPersistentStruct.mwoa = mwoaPercentPersistent;
    percentPersistentStruct.controls = controlPercentPersistent;
    
    resultsStruct.responseOverTime = responseOverTimeStruct;
    resultsStruct.AUC = AUCStruct;
    resultsStruct.normalizedAUC = normalizedAUCStruct;
    resultsStruct.amplitude = amplitudeStruct;
    resultsStruct.percentPersistent = percentPersistentStruct;
    resultsStruct.subjects = subjectListStruct;
    resultsStruct.peakAmplitude = peakAmplitudeStruct;

%% Now Deuteranope experiment
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    % First load up average pupil responses

    % define some specific pupil parameters (which fits to load)
    fitType = 'radiusSmoothed';
    saveNameSuffix = '';

    % Define experimental conditions
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};
    
    experiments = 1:2;
    % we're dealing with 5 subjects for the deuteranope experiment
    subjectIndices = 1:5;
    
    % We don't need to actually run makeSubjectAverageResponse, so we'll
    % just load output from previous iterations
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
        
        % loop over subjects
        for ss = subjectIndices
            subjectID = subjectIDs{ss};

            % load trial struct
            if runMakeSubjectAverageResponses
                
                makeSubjectAverageResponses(subjectID, 'experimentName', experimentName, 'stimuli', stimuli, 'contrasts', contrasts, 'Protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes','blinkBufferFrames', [3 6], 'saveNameSuffix', saveNameSuffix, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectID), 'fitLabel', fitType)
                load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));
                
            else
                load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles', subjectID, experimentName, ['trialStruct_', fitType, '.mat']));
            end
            
            % Get the pupil data of interest
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    
                    % calculate average response timeseries
                    subjectAverageResponse = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                    
                    % calculate SEM over time
                    SEM = nanstd(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]))/sqrt(size(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1));
                    
                    % calculate AUC
                    AUC = abs(trapz(subjectAverageResponse(beginningNumberOfIndicesToExclude:end-endingNumberOfIndicesToExclude)));
                    
                    % stash result
                    responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = subjectAverageResponse;
                    responseOverTimeStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_SEM'])(end+1,:) = SEM;
                    AUCStruct.(experimentName).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss) = AUC;
                    
                end
            end
            
        end
    end
    
    % TPUP stuff
    runFitTPUP = p.Results.runFitTPUP;

    % fit TPUP, if specified
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

    % Load TPUP results
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
    
    resultsStruct.responseOverTime = responseOverTimeStruct;
resultsStruct.AUC = AUCStruct;
%resultsStruct.normalizedAUC = normalizedAUCStruct;
resultsStruct.amplitude = amplitudeStruct;
resultsStruct.percentPersistent = percentPersistentStruct;
resultsStruct.subjects = subjectListStruct;
%resultsStruct.peakAmplitude = peakAmplitudeStruct;
    
end




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
