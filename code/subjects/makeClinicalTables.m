function [headacheTable, ipRGCTable] = makeClinicalTables(varargin)

centralTendencyMetric = 'mean';
errorMetric = 'std';




%% Make headache characteritics table
headacheColumns = {'NumberFemales', 'Age_years','HeadacheDaysPer3Months',  'MIDAS', 'HIT6'}; % need to add meds when available
spreadsheetLabels = {'Sex', 'Age', 'HAdaysPer3Months', 'MIDAS', 'HIT6' };
countVariable = {true, false, false, false, false};

%headacheCellArray{1,1} = 'Group';
headacheCellArray{1,1} = 'Controls';
headacheCellArray{2,1} = 'MwA';
headacheCellArray{3,1} = 'MwoA';
for ii = 1:length(headacheColumns)
    %headacheCellrray{1,ii} = headacheColumns{ii};
    
    [ resultsStruct ] = runANOVAOnDemographics(spreadsheetLabels{ii});
    close all;
    %headacheCellArray{1,ii} = headacheColumns{ii};
    
    if countVariable{ii}
        
        controlsCentralTendency = sum(resultsStruct.controls);
        mwaCentralTendency = sum(resultsStruct.mwa);
        mwoaCentralTendency = sum(resultsStruct.mwoa);
        
        headacheCellArray{1,ii+1} = sprintf('%4.2f', controlsCentralTendency);
        headacheCellArray{2,ii+1} = sprintf('%4.2f', mwaCentralTendency);
        headacheCellArray{3,ii+1} = sprintf('%4.2f', mwoaCentralTendency);
        
    else
        if strcmp(centralTendencyMetric, 'mean')
            controlsCentralTendency = mean(resultsStruct.controls);
            mwaCentralTendency = mean(resultsStruct.mwa);
            mwoaCentralTendency = mean(resultsStruct.mwoa);
        elseif strcmp(centralTendencyMetric, 'median')
            controlsCentralTendency = median(resultsStruct.controls);
            mwaCentralTendency = median(resultsStruct.mwa);
            mwoaCentralTendency = median(resultsStruct.mwoa);
        end
        
        if strcmp(errorMetric, 'std')
            controlsError = nanstd(resultsStruct.controls);
            mwaError = nanstd(resultsStruct.mwa);
            mwoaError = nanstd(resultsStruct.mwoa);
            
            headacheCellArray{1,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            headacheCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            headacheCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        elseif strcmp(errorMetric, 'iqr')
            controlsError = [num2str(prctile(resultsStruct.controls, 25)), ' - ', num2str(prctile(resultsStruct.controls, 75))];
            mwaError = [num2str(prctile(resultsStruct.mwa, 25)), ' - ', num2str(prctile(resultsStruct.mwa, 75))];
            mwoaError = [num2str(prctile(resultsStruct.mwoa, 25)), ' - ', num2str(prctile(resultsStruct.mwoa, 75))];
            
            headacheCellArray{1,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            headacheCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            headacheCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        end
        
        
    end
    
    
    
end
headacheTable = array2table(headacheCellArray);
headacheTable.Properties.VariableNames = ['Group', headacheColumns];
writetable(headacheTable, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'subjectInfo', ['headacheTable.csv']))

%% Make ipRGC function table
ipRGCColumns = {'VDS', 'PAQPhotophobia', 'PAQPhotophilia', 'SeasonalSensitivity', 'MorningnessEveningness', 'PhoticSneezeReflex'}; % need to add meds when available
spreadsheetLabels = {'Conlon_1999_VDS', 'PAQ_phobia', 'PAQ_philia', 'Rosenthal_1984_SPAQ_GSS', 'Horne_1976_MEQ', 'Photic_sneeze'};
countVariable = {false, false, false, false, false, true};

%ipRGCCellArray{1,1} = 'Group';
ipRGCCellArray{1,1} = 'Controls';
ipRGCCellArray{2,1} = 'MwA';
ipRGCCellArray{3,1} = 'MwoA';
for ii = 1:length(ipRGCColumns)
    %headacheCellrray{1,ii} = ipRGCColumns{ii};
    
    [ resultsStruct ] = runANOVAOnDemographics(spreadsheetLabels{ii});
    close all;
    %ipRGCCellArray{1,ii} = ipRGCColumns{ii};
    
    if countVariable{ii}
        
        controlsCentralTendency = nansum(resultsStruct.controls);
        mwaCentralTendency = nansum(resultsStruct.mwa);
        mwoaCentralTendency = nansum(resultsStruct.mwoa);
        
        ipRGCCellArray{1,ii+1} = sprintf('%4.2f', controlsCentralTendency);
        ipRGCCellArray{2,ii+1} = sprintf('%4.2f', mwaCentralTendency);
        ipRGCCellArray{3,ii+1} = sprintf('%4.2f', mwoaCentralTendency);
        
    else
        if strcmp(centralTendencyMetric, 'mean')
            controlsCentralTendency = mean(resultsStruct.controls);
            mwaCentralTendency = mean(resultsStruct.mwa);
            mwoaCentralTendency = mean(resultsStruct.mwoa);
        elseif strcmp(centralTendencyMetric, 'median')
            controlsCentralTendency = median(resultsStruct.controls);
            mwaCentralTendency = median(resultsStruct.mwa);
            mwoaCentralTendency = median(resultsStruct.mwoa);
        end
        
        if strcmp(errorMetric, 'std')
            controlsError = nanstd(resultsStruct.controls);
            mwaError = nanstd(resultsStruct.mwa);
            mwoaError = nanstd(resultsStruct.mwoa);
            
            ipRGCCellArray{1,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            ipRGCCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            ipRGCCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        elseif strcmp(errorMetric, 'iqr')
            controlsError = [num2str(prctile(resultsStruct.controls, 25)), ' - ', num2str(prctile(resultsStruct.controls, 75))];
            mwaError = [num2str(prctile(resultsStruct.mwa, 25)), ' - ', num2str(prctile(resultsStruct.mwa, 75))];
            mwoaError = [num2str(prctile(resultsStruct.mwoa, 25)), ' - ', num2str(prctile(resultsStruct.mwoa, 75))];
            
            ipRGCCellArray{1,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            ipRGCCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            ipRGCCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        end
        
        
    end
    
    
    
end
ipRGCTable = array2table(ipRGCCellArray);
ipRGCTable.Properties.VariableNames = ['Group', ipRGCColumns];
writetable(ipRGCTable, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'subjectInfo', ['ipRGCTable.csv']))


end