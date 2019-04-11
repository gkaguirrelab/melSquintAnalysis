subjectListDirs = dir(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', 'MELA*'));

subjectIDs = [];
badSubjects = 'MELA_0127';

for ss = 1:length(subjectListDirs)
    
   subjectIDs{ss} = subjectListDirs(ss).name;
   
end

subjectIDs = setdiff(subjectIDs, badSubjects);

for ss = 1:length(subjectIDs)
   subjectID = subjectIDs{ss};
   
   [ averageResponseStruct.(subjectID), trialStruct ] = makeSubjectAverageResponses(subjectID, 'debugNumberOfNaNValuesPerTrial', true, 'blinkBufferFrames', [0 0], 'trialNaNThreshold', 2);
    
end