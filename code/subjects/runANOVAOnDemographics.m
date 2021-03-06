function [resultsStruct] = runANOVAOnDemographics(resultType)

dataBasePath = getpref('melSquintAnalysis','melaDataPath');
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);


pathToSurveyData = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'surveyMelanopsinAnalysis', 'MELA_ScoresSurveyData_Squint.xlsx');
surveyTable = readtable(pathToSurveyData);
columnNames = surveyTable.Properties.VariableNames;

% if you're not sure what the name of the result is, display all options
if strcmp(resultType, '')
    fprintf('Possible result types include:\n')
    
    columnNames
    
    return
end



controlResults = [];
mwaResults = [];
mwoaResults = [];


resultColumn = find(contains(columnNames, resultType));

for ss = 1:length(subjectIDs)
    subjectRow = find(contains(surveyTable{:,1}, subjectIDs{ss}));
    result = surveyTable{subjectRow,resultColumn};
    %result = (cell2mat(surveyTable{subjectRow,resultColumn}));
    
    if strcmp(result, 'Male')
        result = 0;
    elseif strcmp(result, 'Female')
        result = 1;
    elseif isstr(result)
        result = str2num(result);
    end
    
    if isempty(result)
        result = NaN;
    end
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    
    if strcmp(group, 'c')
        controlResults(end+1) = result;
    elseif strcmp(group, 'mwa')
        mwaResults(end+1) = result;
        
    elseif strcmp(group, 'mwoa')
        mwoaResults(end+1) = result;
    else
        fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
    end
end

% concatenate together into a matrix, in which different columns represent
% results from different groups
table = vertcat(controlResults, mwaResults, mwoaResults);

% run one-way anova
[p,tbl,stats] = anova1(table')

fprintf('<strong>Post-hoc testing results:</strong>\n')
[COMPARISON,MEANS,H,GNAMES] = multcompare(stats)

% multcompare will not give a direct t-statistic as output, but it seems
% relatively simple to derive it from what they do output. specifically,
% one can get the standard error of the specific comparison from the second
% column of the MEANS output and the estimate of the difference from the
% fourth column of the comparisons column.

resultsStruct.mwa = mwaResults;
resultsStruct.mwoa = mwoaResults;
resultsStruct.controls = controlResults;


end