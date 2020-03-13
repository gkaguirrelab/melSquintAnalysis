% generate sessionStruct on the basis of processing directory

melaProcessingDirectory = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles');

potentialSubjects = dir(fullfile(melaProcessingDirectory, 'MELA*'));

badSubjects = {'MELA_0195', 'MELA_0144', 'MELA_0162'};
incompleteSubjects = {'MELA_0127'};
mTBISubjects = {'MELA_0212', 'MELA_0173'};
badSubjects = {badSubjects{:}, mTBISubjects{:}, incompleteSubjects{:}};

for ss = 1:length(potentialSubjects)
    if ~strcmp(potentialSubjects(ss).name, badSubjects)
        potentialSessions = dir(fullfile(melaProcessingDirectory, potentialSubjects(ss).name, '2*_session_*'));
        
        sessionsFromProcessing = {potentialSessions(:).name};
        
        if ~isequal(sessionsFromProcessing, subjectListStruct.(potentialSubjects(ss).name))
            fprintf('Check out %s\n', potentialSubjects(ss).name)
        end
    end
    
end