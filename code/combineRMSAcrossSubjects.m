%subjectIDs = {'MELA_0119','MELA_0124'};
dataBasePath = getpref('melSquintAnalysis','melaDataPath');

subjectIDs = [];
potentialSubjects =  dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));
for ss = 1:length(potentialSubjects)
        subjectIDs{end+1} = potentialSubjects(ss).name;
end
badSubjects = {'MELA_0127', 'MELA_0198'};
subjectIDs = setdiff(subjectIDs, badSubjects);

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrastLevels = {'100', '200', '400'};

pooledMedianResponseStruct = [];
for stimulus = 1:length(stimuli)
   for cc = 1:length(contrastLevels)
       pooledMedianResponseStruct.(stimuli{stimulus}).(['Contrast', contrastLevels{cc}, '_median']).left = [];
       pooledMedianResponseStruct.(stimuli{stimulus}).(['Contrast', contrastLevels{cc}, '_median']).right = [];

   end
end


for ss = 1:length(subjectIDs)
   [ medianResponseStruct, ~ ] = calculateRMSforEMG(subjectIDs{ss}, 'normalize', false);
   close all
   stimuli = fieldnames(medianResponseStruct);
   for stimulus = 1:length(stimuli)
       stats = fieldnames(medianResponseStruct.(stimuli{stimulus}));
       for stat = 1:length(stats)
           if contains(stats{stat}, 'median')
               pooledMedianResponseStruct.(stimuli{stimulus}).(stats{stat}).left(end+1) = medianResponseStruct.(stimuli{stimulus}).(stats{stat}).left;
               pooledMedianResponseStruct.(stimuli{stimulus}).(stats{stat}).right(end+1) = medianResponseStruct.(stimuli{stimulus}).(stats{stat}).right;
           end
       end
   end
end

pooledMedianResponseStruct.subjects = subjectIDs;

save(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'pooledMedianResponseStruct.mat'), 'pooledMedianResponseStruct','-v7.3');
