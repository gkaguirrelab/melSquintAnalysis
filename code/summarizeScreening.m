function summarizeScreening()

analysisBasePath = getpref(projectName,'melaAnalysisPath');

potentialSubjects = dir(fullfile(analysisBasePath, 'Experiments/OLApproach_Squint/Screening/DataFiles/MELA*'));

summary{1,1} = 'Subject ID';
summary{1,2} = 'Pass Status';
for tt = 1:12
    
    summary{1,tt+2} = sprintf('Trial %d', tt);
end
summary{1,15} = 'Mean Good Frames';

for ss = 1:length(potentialSubjects)
    screenedSubjects{ss} = potentialSubjects(ss).name;
    summary{ss+1,1} = screenedSubjects{ss};
    try
        [passStatus, percentageGoodFramesPerTrial] = analyzeScreening(screenedSubjects{ss});
        summary{ss+1,2} = passStatus;
        for tt = 1:12
            summary{ss+1,tt+2} = percentageGoodFramesPerTrial(tt);
        end
        summary{ss+1,15} = mean(percentageGoodFramesPerTrial);
    catch
        summary{ss+1,2} = 0;
        summary{ss+1,3:15} = NaN;
    end
end

