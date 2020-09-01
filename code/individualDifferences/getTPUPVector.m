function TPUPVector = getTPUPVector(dateNumber, stimulusDirection, contrastLevel, TPUPParam)

% Where is the CSV file containing the TPUP params located.
csvFileName = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'TPUP', 'TPUPParams.csv');

% load CSV contents as table
TPUPParamsTable = readtable(csvFileName);


% Find the relevant rows that contain the TPUP params for each subject for
% the relevant dateNumber.
rowsDateNumber = find(contains(TPUPParamsTable{:,2}, num2str(dateNumber)));

% Find the relevant rows that contain the TPUP params for each subject for
% the relevant contrastLevel.
rowsContrastLevel = find(TPUPParamsTable{:,3} == (contrastLevel));

% Find the intersection of these two vectors, which represents the rows that
% contain the relevant contrastLevel for the relevant dateNumber
rows = intersect(rowsDateNumber, rowsContrastLevel);


% Find the appropriate column(s) that contain the TPUPParam of interest.
columnsNames = TPUPParamsTable.Properties.VariableNames;
columns = find(contains(columnsNames, [stimulusDirection, TPUPParam], 'IgnoreCase', true));

% Get the vector.
TPUPVector = TPUPParamsTable{rows, columns};


end