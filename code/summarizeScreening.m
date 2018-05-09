function [table] = summarizeScreening()

analysisBasePath = getpref('melSquintAnalysis','melaAnalysisPath');

potentialSubjects = dir(fullfile(analysisBasePath, 'Experiments/OLApproach_Squint/Screening/DataFiles/MELA*'));

summary{1,1} = 'SubjectID';
summary{1,2} = 'Pass';
for tt = 1:12
    
    summary{1,tt+2} = sprintf('Trial%d', tt);
end
summary{1,15} = 'MeanGoodFrames';

for ss = 1:length(potentialSubjects)
    screenedSubjects{ss} = potentialSubjects(ss).name;
    summary{ss+1,1} = screenedSubjects{ss};
    try
        [passStatus, percentageGoodFramesPerTrial] = analyzeScreening(screenedSubjects{ss});
        summary{ss+1,2} = passStatus;
        for tt = 1:12
            summary{ss+1,tt+2} = round(percentageGoodFramesPerTrial(tt),3);
        end
        summary{ss+1,15} = round(mean(percentageGoodFramesPerTrial),3);
    catch
        summary{ss+1,2} = 0;
        for ii =  3:15
            summary{ss+1,ii} = NaN;
        end
    end
end

table = array2table(summary(2:end,:), 'VariableNames', summary(1,:));
write(table, fullfile(analysisBasePath, 'Experiments/OLApproach_Squint/Screening/summary.txt'), 'Delimiter', '\t');

end


