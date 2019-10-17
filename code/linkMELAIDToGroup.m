function [ group ] = linkMELAIDToGroup(subjectID)

keyName = 'MELA_Squint_Subject_Info.xlsx';
pathToKey = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis/subjectInfo', keyName);

[num, txt, raw] = xlsread(pathToKey);

index = strfind(txt, subjectID);

rowNumber = find(~cellfun(@isempty,index));

group = txt{rowNumber, 6};

end