function [ sessionList ] = getSessionsList()

projectName = 'melSquintAnalysis';
directionObjectsBase = fullfile(getpref(projectName, 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects');

% determine the session for this subject
sessions = dir(fullfile(directionObjectsBase, 'MELA*'));

sessionList.ID = [];
sessionList.date = [];
counter = 1;
for subjectIndex = 1:size(sessions,1)
    potentialSessionDates = dir(fullfile(directionObjectsBase, sessions(subjectIndex).name));
    for potentialDateIndex = 1:size(potentialSessionDates,1)
        if strcmp(potentialSessionDates(potentialDateIndex).name(1), '2')
            % it's a real date
            sessionList.ID{counter} = sessions(subjectIndex).name;
            sessionList.date{counter} = potentialSessionDates(potentialDateIndex).name;
            counter = counter + 1;
        end
    end
end

end