function parseSurveys()

%% Figure out where the survey data lives
% define paths to relevant spreadsheets
pathToSurveyFolder = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), '..', 'MELA_subject', 'Google_Doc_Sheets');

specificSpreadsheets = {
    'MELA Headache and Comorbid Disorders Screening Form v1.0 (Responses).xlsx'
    };

surveyResultsCellArray = [];
variableNamesArray = {'MELA_ID'};

%% Load spreadsheet
table = readtable(fullfile(pathToSurveyFolder, specificSpreadsheets{1}));
for column = 3:7
    variableNamesArray{end+1} = table.Properties.VariableNames{column};
end
for column = 18:23
    variableNamesArray{end+1} = table.Properties.VariableNames{column};
end
variableNamesArray{end+1} = 'MIDAS';
variableNamesArray{end+1} = 'HIT';
    
%% loop over MELA_IDs
partialListOfMELA_IDs = table(:,2);
    
for subject = 1:height(partialListOfMELA_IDs)
        
% for each MELA_ID, figure out what row we're in
   MELA_ID = table{subject, 2};
   TF = contains(MELA_ID, 'MELA');
   
   % reset scores
   midas = 0;
   hit = 0;
   
   if TF == 1
       surveyResultsCellArray{end+1, 1} = MELA_ID;
       count = 2;
       % for each MELA_ID, grab the survey results for that row
       for results = 3:7
           surveyResultsCellArray{end, count} = table{subject, results};
           midas = midas + results;
           count = count + 1;
       end
       for results = 18:23
           surveyResultsCellArray{end, count} = table{subject, results};
           if strcmp(results, 'Never')
               hit = hit + 6;
           elseif strcmp(results, 'Rarely')
               hit = hit + 8;
           elseif strcmp(results, 'Sometimes')
               hit = hit + 10;
           elseif strcmp(results, 'Very Often')
               hit = hit + 11;
           elseif strcmp(results, 'Always')
               hit = hit + 13;
           end
           count = count + 1;
       end
       surveyResultsCellArray{end, count} = midas;
       surveyResultsCellArray{end, count+1} = hit;
   end
end

%% Save out results
savePathForTable = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), '..', 'MELA_subject', 'HIT_MIDAS_SurveyTable.csv');
surveyResultsTable = array2table(surveyResultsCellArray);
surveyResultsTable.Properties.VariableNames = variableNamesArray;
writetable(surveyResultsTable, savePathForTable);

end