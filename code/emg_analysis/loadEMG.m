function [ emgRMSStruct, subjectIDsStruct ] = loadEMG(varargin)
p = inputParser; p.KeepUnmatched = true;

p.addParameter('calculateRMS',false, @islogical);
p.addParameter('protocol','SquintToPulse', @ischar);

p.parse(varargin{:});

calculateRMS = p.Results.calculateRMS;

%% SquintToPulse

if strcmp(p.Results.protocol, 'SquintToPulse');
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
    
    for ss = 1:length(subjectIDs)
        
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
        
        if calculateRMS
            calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true);
            calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', false);
            
        end
        close all;
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                if strcmp(group, 'c')
                    load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                    controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                    controlSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwa')
                    load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                    mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                    mwaSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwoa')
                    load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
                    mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
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
    
    emgRMSStruct.mwaRMS = mwaRMS;
    emgRMSStruct.mwoaRMS = mwoaRMS;
    emgRMSStruct.controlRMS = controlRMS;
    
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



end