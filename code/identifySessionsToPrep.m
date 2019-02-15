sessionList = [];

% identify all sessions
dataBasePath = getpref('melSquintAnalysis','melaDataPath');
subjectDirs = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));

commandList = [];
for ss = 1:length(subjectDirs)
    sessions = dir(fullfile(dataBasePath, 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectDirs(ss).name, '2*session*'));
    if ~strcmp(subjectDirs(ss).name, 'MELA_0127')
        for session = 1:length(sessions)
            
            if ~exist(fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectDirs(ss).name, sessions(session).name, 'pupilCalibration/fitParams.mat'));
                commandList{end+1} = ['trackSubject(''', subjectDirs(ss).name, ''', ''', sessions(session).name, ''', ''skipProcessing'', true)'];
            end
        end
    end
    
    
end

for cc = 1:length(commandList)
    eval(commandList{cc})
    splitCommand = strsplit(commandList{cc}, '''skipProcessing''');
    newCommand = [splitCommand{1}, '''resume'', true)'];
    system(['echo "', newCommand, '" >> ', '~/Documents/MATLAB/projects/melSquintAnalysis/code/newlyProcessed.m']);
end