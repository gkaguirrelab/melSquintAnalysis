function [ emgRMSStruct, subjectIDsStruct, MelContrastByStimulus, LMSContrastByStimulus] = loadEMG(varargin)
p = inputParser; p.KeepUnmatched = true;

p.addParameter('calculateRMS',false, @islogical);
p.addParameter('calculateResponseOverTime',false, @islogical);
p.addParameter('protocol','SquintToPulse', @ischar);

p.parse(varargin{:});

calculateRMS = p.Results.calculateRMS;

%% SquintToPulse

if strcmp(p.Results.protocol, 'SquintToPulse')
    % load subjectIDs
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
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
            
            controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                        
            controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
            controlNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end
    
    controlSubjects = [];
    mwaSubjects = [];
    mwoaSubjects = [];
    
    useNormalized = true;
    
    if useNormalized
        saveStem = '_normalized';
    else
        saveStem = '';
    end
    
    % pool normalized data
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
        
        if calculateRMS
            calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', true);
            
        end
        close all;
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                if strcmp(group, 'c')
                    load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
                    controlRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                    controlSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwa')
                    load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
                    mwaRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                    mwaSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwoa')
                    load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
                    mwoaRMSnormalized.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                    mwoaSubjects{end+1} = subjectIDs{ss};
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
        
    end
    
    % pool un-normalized data
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
        
        if calculateRMS
            calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', false);
            
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
    
    % response over time
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', 'WindowLength_500MSecs', 'trialStructs');
        
        if p.Results.calculateResponseOverTime
            calculateEMGResponseOverTime(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', false);   
        end
        close all;
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                load(fullfile(resultsDir, [subjectIDs{ss}, '.mat']));
                responseOverTime = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).combined);
                
                responseOverTime_withoutNaNs = responseOverTime(~isnan(responseOverTime));
                AUC = (trapz(responseOverTime_withoutNaNs));
                normalizedAUC = AUC/(length(responseOverTime_withoutNaNs));
                
                % timebase, which is hard-coded for what was used for these
                % response over time calculations:
                timebase = 0:0.1:17.5;
                windowOnsetIndex = find(timebase == 2.5);
                windowOffsetIndex = find(timebase == 4.5);
                normalizedPulseAUC = sum(responseOverTime(windowOnsetIndex:windowOffsetIndex))/(windowOffsetIndex - windowOnsetIndex + 1);

                
                if strcmp(group, 'c')
                    controlResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = responseOverTime;
                    controlSubjects{end+1} = subjectIDs{ss};
                    controlAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    controlNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedAUC;
                    controlNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedPulseAUC;

                    
                elseif strcmp(group, 'mwa')
                    mwaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = responseOverTime;
                    mwaSubjects{end+1} = subjectIDs{ss};
                    mwaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedAUC;
                    mwaNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedPulseAUC;

                elseif strcmp(group, 'mwoa')
                    mwoaResponseOverTime.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = responseOverTime;
                    mwoaSubjects{end+1} = subjectIDs{ss};
                    mwoaAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = AUC;
                    mwoaNormalizedAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedAUC;
                    mwoaNormalizedPulseAUC.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = normalizedPulseAUC;

                    
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
        
    end
    
    
    mwaSubjects = unique(mwaSubjects);
    mwoaSubjects = unique(mwoaSubjects);
    controlSubjects = unique(controlSubjects);
    
        subjectListStruct = [];
    subjectListStruct.mwaSubjects = mwaSubjects;
    subjectListStruct.mwoaSubjects = mwoaSubjects;
    subjectListStruct.controlSubjects = controlSubjects;
    
    emgRMSStruct.normalizedRMS.mwa = mwaRMSnormalized;
    emgRMSStruct.normalizedRMS.mwoa = mwoaRMSnormalized;
    emgRMSStruct.normalizedRMS.controls = controlRMSnormalized;
    
    emgRMSStruct.RMS.mwa = mwaRMS;
    emgRMSStruct.RMS.mwoa = mwoaRMS;
    emgRMSStruct.RMS.controls = controlRMS;
    
    emgRMSStruct.responseOverTime.mwa = mwaResponseOverTime;
    emgRMSStruct.responseOverTime.mwoa = mwoaResponseOverTime;
    emgRMSStruct.responseOverTime.controls = controlResponseOverTime;
    
    emgRMSStruct.AUC.mwa = mwaAUC;
    emgRMSStruct.AUC.mwoa = mwoaAUC;
    emgRMSStruct.AUC.controls = controlAUC;
    
    emgRMSStruct.normalizedAUC.mwa = mwaNormalizedAUC;
    emgRMSStruct.normalizedAUC.mwoa = mwoaNormalizedAUC;
    emgRMSStruct.normalizedAUC.controls = controlNormalizedAUC;
    
    
    emgRMSStruct.normalizedPulseAUC.mwa = mwaNormalizedPulseAUC;
    emgRMSStruct.normalizedPulseAUC.mwoa = mwoaNormalizedPulseAUC;
    emgRMSStruct.normalizedPulseAUC.controls = controlNormalizedPulseAUC;
    
    subjectIDsStruct.mwaSubjects = mwaSubjects;
    subjectIDsStruct.mwoaSubjects = mwoaSubjects;
    subjectIDsStruct.controlSubjects = controlSubjects;
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    emgRMSStruct = [];
    normalize = true;
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};
    subjectStruct = getDeuteranopeSubjectStruct;
    % pre-allocate results variable
    for experiment = 1:2
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
        end
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                emgRMSStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            end
            
        end
    end
    
    % pool results
    for experiment = 1:2
        experimentName = ['experiment_', num2str(experiment)];
        subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
            
        end
        
        for ss = 1:5
            
            if calculateRMS
                savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'Deuteranopes', ['experiment_', num2str(experiment)]);
                medianRMS = calculateRMSforEMG(subjectIDs{ss}, 'experimentName', ['experiment_', num2str(experiment)], 'protocol', 'Deuteranopes', 'protocolShortName', 'Deuteranopes', 'stimuli', stimuli, 'makePlots', true, 'contrasts', contrasts, 'normalize', normalize, 'sessions', subjectStruct.(['experiment', num2str(experiment)]).(subjectIDs{ss}), 'savePath', savePath);
            else
                load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'Deuteranopes', experimentName, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS_normalized.mat']));
            end
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    emgRMSStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast}), '_median']).right]);
                end
            end
            
        end
    end
    
end


% Assemble the melanopsin and cone contrasts for each stimulus type. We
% treat light flux stimuli as having equal contrast on the mel and LMS
% photoreceptor pools.
MelContrastByStimulus = [100 200 400 0 0 0 100 200 400];
LMSContrastByStimulus = [0 0 0 100 200 400 100 200 400];

end