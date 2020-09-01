function parseGenotype()

%% Figure out where the genotype data lives
% define paths to relevant spreadsheets
pathToGenotypeFolder = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), '..', 'MELA_subject', 'GeneticResults');

% error when trying to concatenate more than 3 spreadsheets??
specificSpreadsheets = {% 'MELA_Batch_1/5291_OPN4_rs1079610_Results.xlsx', ...
    % 'MELA_Batch_2/5319_OPN4_rs1079610_Results.xlsx', ...
    'MELA_Batch_3_PIPRMaxPulse/5415_OPN4_rs1079610.xlsx', ...
    'MELA_Batch_4_Squint/5723_OPN4_rs107910_2018-08-21 081448_QuantStudio 12K Flex_export.xlsx', ...
    'MELA_Batch_5_Squint/MPF_HT_301_OPN4_2020-01-14 094429_QuantStudio 12K Flex_export.xlsx', ...
    };

genotypeResultsCellArray = [];
%% Load up each spreadsheet
for ii = 1:length(specificSpreadsheets)
    % load one spreadsheet
    table = readtable(fullfile(pathToGenotypeFolder, specificSpreadsheets{ii}), 'Sheet', 'Results');
    
    % loop over MELA_IDs, unformatted
    partialListOfMELA_IDs = table(:,4);
    
    %% loop over mela_IDs
    for subject = 1:height(partialListOfMELA_IDs)
        
        % for each MELA_ID, figure out what row we're in
        MELA_ID = table{subject, 4};
        TF = contains(MELA_ID, 'MELA');
        if TF == 1        
            % for each MELA_ID, grab the genotype result for that row
            genotypeResult = table{subject, 23};
            % make cell array to save out results
            genotypeResultsCellArray{end+1, 1} = MELA_ID;
            genotypeResultsCellArray{end, 2} = genotypeResult;
        end
     end
    
end

%% Save out results
savePathForTable = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), '..', 'MELA_subject', 'GeneticResults', 'GenotypesTable.csv');
genotypeResultsTable = array2table(genotypeResultsCellArray);
genotypeResultsTable.Properties.VariableNames = {'MELA_ID', 'GenotypeResult'};
writetable(genotypeResultsTable, savePathForTable);

end