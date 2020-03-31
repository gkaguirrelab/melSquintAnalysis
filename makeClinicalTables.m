function [headacheTable, ipRGCTable] = makeClinicalTables(varargin)

centralTendencyMetric = 'mean';
errorMetric = 'std';




%% Make headache characteritics table
headacheColumns = {'# Females', 'MIDAS', 'HIT6', 'Headache Days per 3 Months'}; % need to add meds when available
spreadsheetLabels = {'Sex', 'MIDAS', 'HIT6', 'HAdaysPer3Months'};
countVariable = {true, false, false, false};

headacheCellArray{1,1} = 'Group';
headacheCellArray{2,1} = 'Controls';
headacheCellArray{3,1} = 'MwA';
headacheCellArray{4,1} = 'MwoA';
for ii = 1:length(headacheColumns)
    headacheCellrray{1,ii+1} = headacheColumns{ii};
    
    [ resultsStruct ] = runANOVAOnDemographics(spreadsheetLabels{ii});
    headacheCellArray{1,ii+1} = headacheColumns{ii};
    
    if countVariable{ii}
        
        controlsCentralTendency = sum(resultsStruct.controls);
        mwaCentralTendency = sum(resultsStruct.mwa);
        mwoaCentralTendency = sum(resultsStruct.mwoa);
        
        headacheCellArray{2,ii+1} = sprintf('%4.2f', controlsCentralTendency);
        headacheCellArray{3,ii+1} = sprintf('%4.2f', mwaCentralTendency);
        headacheCellArray{4,ii+1} = sprintf('%4.2f', mwoaCentralTendency);
        
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
            
            headacheCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            headacheCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            headacheCellArray{4,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        elseif strcmp(errorMetric, 'iqr')
            controlsError = [num2str(prctile(resultsStruct.controls, 25)), ' - ', num2str(prctile(resultsStruct.controls, 75))];
            mwaError = [num2str(prctile(resultsStruct.mwa, 25)), ' - ', num2str(prctile(resultsStruct.mwa, 75))];
            mwoaError = [num2str(prctile(resultsStruct.mwoa, 25)), ' - ', num2str(prctile(resultsStruct.mwoa, 75))];
            
            headacheCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            headacheCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            headacheCellArray{4,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        end
        
        
    end
    
    
    
end

ipRGCColumns = {'VDS', 'PAQ-Photophobia', 'PAQ-Photophilia', 'Seasonal Sensitivity', 'Morningness-Eveningness', 'Photic Sneeze Reflex'}; % need to add meds when available
spreadsheetLabels = {'Conlon_1999_VDS', 'PAQ_phobia', 'PAQ_philia', 'Rosenthal_1984_SPAQ_GSS', 'Horne_1976_MEQ', 'Photic_sneeze'};
countVariable = {false, false, false, false, false, true};

%% Make ipRGC function table
ipRGCCellArray{1,1} = 'Group';
ipRGCCellArray{2,1} = 'Controls';
ipRGCCellArray{3,1} = 'MwA';
ipRGCCellArray{4,1} = 'MwoA';
for ii = 1:length(ipRGCColumns)
    headacheCellrray{1,ii+1} = ipRGCColumns{ii};
    
    [ resultsStruct ] = runANOVAOnDemographics(spreadsheetLabels{ii});
    ipRGCCellArray{1,ii+1} = ipRGCColumns{ii};
    
    if countVariable{ii}
        
        controlsCentralTendency = nansum(resultsStruct.controls);
        mwaCentralTendency = nansum(resultsStruct.mwa);
        mwoaCentralTendency = nansum(resultsStruct.mwoa);
        
        ipRGCCellArray{2,ii+1} = sprintf('%4.2f', controlsCentralTendency);
        ipRGCCellArray{3,ii+1} = sprintf('%4.2f', mwaCentralTendency);
        ipRGCCellArray{4,ii+1} = sprintf('%4.2f', mwoaCentralTendency);
        
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
            
            ipRGCCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            ipRGCCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            ipRGCCellArray{4,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        elseif strcmp(errorMetric, 'iqr')
            controlsError = [num2str(prctile(resultsStruct.controls, 25)), ' - ', num2str(prctile(resultsStruct.controls, 75))];
            mwaError = [num2str(prctile(resultsStruct.mwa, 25)), ' - ', num2str(prctile(resultsStruct.mwa, 75))];
            mwoaError = [num2str(prctile(resultsStruct.mwoa, 25)), ' - ', num2str(prctile(resultsStruct.mwoa, 75))];
            
            ipRGCCellArray{2,ii+1} = sprintf('%4.2f (%4.2f)', controlsCentralTendency, controlsError);
            ipRGCCellArray{3,ii+1} = sprintf('%4.2f (%4.2f)', mwaCentralTendency, mwaError);
            ipRGCCellArray{4,ii+1} = sprintf('%4.2f (%4.2f)', mwoaCentralTendency, mwoaError);
        end
        
        
    end
    
    
    
end



end