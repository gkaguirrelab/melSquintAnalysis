sessionList = [];

% identify all sessions
dataBasePath = getpref('melSquintAnalysis','melaDataPath');
subjectDirs = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));

commandList = [];
for ss = 1:length(subjectDirs)
    sessions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectDirs(ss).name, '2*session*'));
    if ~strcmp(subjectDirs(ss).name, 'MELA_0127')
        for session = 1:length(sessions)
            
            if ~exist(fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectDirs(ss).name, sessions(session).name, 'pupilCalibration/fitParams.mat'));
                commandList{end+1} = ['trackSubject(''', subjectDirs(ss).name, ''', ''', sessions(session).name, ''', ''skipProcessing'', true)'];
            end
        end
    end
    
    
end
commandList = fliplr(commandList);
for cc = 1:length(commandList)
    subjectID = strsplit(commandList{cc}, 'MELA_');
    subjectID = ['MELA_', subjectID{2}(1:4)];
    sessionID = strsplit(commandList{cc}, ' ');
    sessionID = sessionID{2};
    sessionID = sessionID(2:end-2);
    fprintf('\tProcessing %s, %s\n', subjectID, sessionID);
    eval(commandList{cc})
    splitCommand = strsplit(commandList{cc}, '''skipProcessing''');
    newCommand = [splitCommand{1}, '''resume'', true)'];
    system(['echo "', newCommand, '" >> ', '~/Documents/MATLAB/projects/melSquintAnalysis/code/newlyProcessed.m']);
end