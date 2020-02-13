function subjectStruct = getDeuteranopeSubjectStruct()

dataFilesPath = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles');
subjectIDs = {'MELA_3032', 'MELA_3009', 'MELA_3035', 'MELA_3036', 'MELA_3038'};
for ss = 1:length(subjectIDs)
    
    for experiment = 1:2
        sessionDirs = dir(fullfile(dataFilesPath, subjectIDs{ss}, ['experiment_', num2str(experiment)], '2*session*'));
        for session = 1:length(sessionDirs)
            subjectStruct.(['experiment', num2str(experiment)]).(subjectIDs{ss}){session} = sessionDirs(session).name;
        end
    end
end



end