function makeEMGTable

groups = {'controls', 'mwoa', 'mwa'};
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};

modality = 'emg';

modalities = {'emg', 'blinks'};

for mm = 1:2
    if strcmp(modalities{mm}, 'emg')
        resultStruct = loadEMG('windowOnset', 1.8, 'windowOffset', 5.2);
        resultStruct = resultStruct.normalizedPulseAUC;
    elseif strcmp(modalities{mm}, 'blinks')
        resultStruct = loadBlinks('runAnalyzeDroppedFrames', true, 'range', [1.8 5.2]);
        
    end
    
    for group = 1:length(groups)
        for stimulus=1:length(stimuli)
            contrast100Mean.(groups{group}).(stimuli{stimulus}) = [];
            contrast200Mean.(groups{group}).(stimuli{stimulus}) = [];
            contrast400Mean.(groups{group}).(stimuli{stimulus}) = [];
            
            contrast100SEM.(groups{group}).(stimuli{stimulus}) = [];
            contrast200SEM.(groups{group}).(stimuli{stimulus}) = [];
            contrast400SEM.(groups{group}).(stimuli{stimulus}) = [];
        end
    end
    
    
    for group = 1:length(groups)
        for stimulus=1:length(stimuli)
            contrast100Mean.(groups{group}).(stimuli{stimulus}) = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast100);
            contrast200Mean.(groups{group}).(stimuli{stimulus}) = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast200);
            contrast400Mean.(groups{group}).(stimuli{stimulus}) = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast400);
            
            contrast100SEM.(groups{group}).(stimuli{stimulus}) = nanstd(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast100)./(sqrt(length(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast100)));
            contrast200SEM.(groups{group}).(stimuli{stimulus}) = nanstd(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast200)./(sqrt(length(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast200)));
            contrast400SEM.(groups{group}).(stimuli{stimulus}) = nanstd(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast400)./(sqrt(length(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast400)));
        end
        contrast100Mean.(groups{group}).combined = nanmean([resultStruct.(groups{group}).(stimuli{1}).Contrast100, resultStruct.(groups{group}).(stimuli{2}).Contrast100, resultStruct.(groups{group}).(stimuli{3}).Contrast100]);
        contrast200Mean.(groups{group}).combined = nanmean([resultStruct.(groups{group}).(stimuli{1}).Contrast200, resultStruct.(groups{group}).(stimuli{2}).Contrast200, resultStruct.(groups{group}).(stimuli{3}).Contrast200]);
        contrast400Mean.(groups{group}).combined = nanmean([resultStruct.(groups{group}).(stimuli{1}).Contrast400, resultStruct.(groups{group}).(stimuli{2}).Contrast400, resultStruct.(groups{group}).(stimuli{3}).Contrast400]);
        
        contrast100SEM.(groups{group}).combined = nanstd([resultStruct.(groups{group}).(stimuli{1}).Contrast100, resultStruct.(groups{group}).(stimuli{2}).Contrast100, resultStruct.(groups{group}).(stimuli{3}).Contrast100])/sqrt(60);
        contrast200SEM.(groups{group}).combined = nanstd([resultStruct.(groups{group}).(stimuli{1}).Contrast200, resultStruct.(groups{group}).(stimuli{2}).Contrast200, resultStruct.(groups{group}).(stimuli{3}).Contrast200])/sqrt(60);
        contrast400SEM.(groups{group}).combined = nanstd([resultStruct.(groups{group}).(stimuli{1}).Contrast400, resultStruct.(groups{group}).(stimuli{2}).Contrast400, resultStruct.(groups{group}).(stimuli{3}).Contrast400])/sqrt(60);
    end
    
    rows = {'LightFlux', 'Melanopsin', 'LMS', 'combined'};
    % make the table
    rowCounter = 1;
    for rr = 1:length(rows)
        for group = 1:length(groups)
            tableData{rowCounter,1} = sprintf('%s', rows{rr});
            tableData{rowCounter,2} = sprintf('%s', groups{group});
            tableData{rowCounter,3} = sprintf('%4.3f (%4.3f)', contrast100Mean.(groups{group}).(rows{rr}), contrast100SEM.(groups{group}).(rows{rr}));
            tableData{rowCounter,4} = sprintf('%4.3f (%4.3f)', contrast200Mean.(groups{group}).(rows{rr}), contrast200SEM.(groups{group}).(rows{rr}));
            tableData{rowCounter,5} = sprintf('%4.3f (%4.3f)', contrast400Mean.(groups{group}).(rows{rr}), contrast400SEM.(groups{group}).(rows{rr}));
            
            
            rowCounter = rowCounter + 1;
        end
    end
    
    groupTable = array2table(tableData);
    groupTable.Properties.VariableNames = {'Stimulus', 'Group', 'Contrast100', 'Contrast200', 'Contrast400'};
    writetable(groupTable, fullfile('~/Desktop', [modalities{mm}, '_summaryTable.csv']))
end


end