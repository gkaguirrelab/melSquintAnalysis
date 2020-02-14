function [responseOverTimeStruct, amplitudeStruct, percentPersistentStruct, subjectListStruct] = loadPupilResponses

dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% Pool pupil traces
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
            if strcmp(group, 'c')
                controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
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
            
            totalResponseAmplitude = (transientAmplitude + sustainedAmplitude + persistentAmplitude);
            
            if strcmp(group, 'c')
                controlPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -totalResponseAmplitude;
                
            elseif strcmp(group, 'mwa')
                mwaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -totalResponseAmplitude;
                
                
            elseif strcmp(group, 'mwoa')
                mwoaPercentPersistent.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = percentPersistent;
                mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = -totalResponseAmplitude;
                
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

end
