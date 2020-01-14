function runMixedEffectsANOVA(responseModality, responseMetric)

%% get model fit params

[slope, intercept, meanRating] = fitLineToResponseModality(responseModality, 'makePlots', false, 'makeCSV', false);

%% Create the design matrix
%     - first column  (i.e., X(:,1)) : all dependent variable values
%     - second column (i.e., X(:,2)) : between-subjects factor (e.g., subject group) level codes (ranging from 1:L where
%         L is the # of levels for the between-subjects factor)
%     - third column  (i.e., X(:,3)) : within-subjects factor (e.g., condition/task) level codes (ranging from 1:L where
%         L is the # of levels for the within-subjects factor)
%     - fourth column (i.e., X(:,4)) : subject codes (ranging from 1:N where N is the total number of subjects)

% grab the result of choice
if strcmp(responseMetric, 'slope')
    result = slope;
elseif strcmp(responseMetric, 'intercept')
    result = intercept;
elseif strcmp(responseMetric, 'meanRating')
    result = meanRating;
end
% First column: all dependent variables:
stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
groups = {'controls', 'mwa', 'mwoa'};
for group = 1:length(groups)
    for ss = 1:20
        for stimulus = 1:length(stimuli)
            
            if strcmp(groups{group}, 'controls')
                rowAdjuster = 1;
            elseif strcmp(groups{group}, 'mwa')
                rowAdjuster = 2;
            elseif strcmp(groups{group}, 'mwoa')
                rowAdjuster = 3;
            end
            
            dependentVariable = result.(groups{group}).(stimuli{stimulus})(ss);
            
            % first column is dependent variable
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 1) = dependentVariable;
            
            % second column is between-subject factor (group diagnosis)
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 2) = group;
            
            % third column is within-subject factor (stimulus type)
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 3) = stimulus;
            
            % fourth column is subject code (related to subjectID, but not
            % the same value)
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 4) = (group * 20 - 20) + ss;
        end
        
    end
end

%% Run mixed effects ANOVA
[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(designMatrix);

%%
dataTable = [];
rowCounter = 1;
for group = 1:length(groups)
    for ss = 1:20
        
        
        dataTable(rowCounter,1) = result.(groups{group}).Melanopsin(ss);
        dataTable(rowCounter,2) = result.(groups{group}).LMS(ss);
        dataTable(rowCounter,3) = result.(groups{group}).LightFlux(ss);
        dataTable(rowCounter,4) = group;
        
        rowCounter = rowCounter + 1;
        
        
    end
end

dataTable = array2table(dataTable);
dataTable.Properties.VariableNames = {'Melanopsin', 'LMS', 'LightFlux', 'Group'};
dataTable.Group = categorical(dataTable.Group);
wsVariable = table([0 1 2]', 'VariableNames', {'Stimulus'});

rm = fitrm(dataTable, 'Melanopsin,LMS,LightFlux~Group', 'WithinDesign', wsVariable);
ranovaTable = ranova(rm);

%% make summary table:
posthocTable = multcompare(rm,'Stimulus', 'By', 'Group');
% for effect of stimulus by group:
% key:
%   - group: 1 = controls; 2 = mwa; 3 = mwoa
groups = {'Controls', 'MwA', 'MwoA'};
groupNameInStruct = {'controls', 'mwa', 'mwoa'};
%   - stimulus: 0 = melanopsin; 1 = LMS; 2 = light flux
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};


comparisons = {'LightFlux - Melanopsin', 'LightFlux - LMS', 'LMS - Melanopsin'};

stimulusByGroupTable = {};
rowCounter = 1;
for group = 1:length(groups)
    for comparison = 1:length(comparisons)
        stimulusByGroupTable{rowCounter,1} = groups{group};
        stimulusByGroupTable{rowCounter,2} = comparisons{comparison};
        
        groupRows = find(posthocTable.Group == categorical(group));
        
        stimuliInComparison = strsplit(comparisons{comparison},' - ');
        firstStimulus = stimuliInComparison{1};
        firstStimulusCode = find(strcmp(stimuli, firstStimulus)) - 1;
        firstStimulusRows = find(posthocTable.Stimulus_1 == firstStimulusCode);
        
        secondStimulus = stimuliInComparison{2};
        secondStimulusCode = find(strcmp(stimuli, secondStimulus)) - 1;
        secondStimulusRows = find(posthocTable.Stimulus_2 == secondStimulusCode);
        
        firstIntersection = intersect(groupRows, firstStimulusRows);
        
        row = intersect(firstIntersection, secondStimulusRows);
        
        stimulusByGroupTable{rowCounter,3} = sprintf('%4.3f - %4.3f = %4.3f', mean(result.(groupNameInStruct{group}).(firstStimulus)), mean(result.(groupNameInStruct{group}).(secondStimulus)), [mean(result.(groupNameInStruct{group}).(firstStimulus)) - mean(result.(groupNameInStruct{group}).(secondStimulus))]);
        
        stimulusByGroupTable{rowCounter,4} = sprintf('%4.3f', table2array(posthocTable(row,4))/table2array(posthocTable(row,5)));
        
        if table2array(posthocTable(row,6)) < 0.05
            stimulusByGroupTable{rowCounter,5} = sprintf('*%0.3e', table2array(posthocTable(row,6)));
        else
            stimulusByGroupTable{rowCounter,5} = sprintf('%0.3e', table2array(posthocTable(row,6)));
        end
        
        
        stimulusByGroupTable{rowCounter,6} = sprintf('%4.3f - %4.3f', table2array(posthocTable(row,7)), table2array(posthocTable(row,8)));
        
        rowCounter = rowCounter + 1;
        
    end
    
    
end

stimulusByGroupTable = array2table(stimulusByGroupTable);
stimulusByGroupTable.Properties.VariableNames = {'Group', 'Comparison', 'Difference', 't_Statistic', 'p_Value', 'CI_95'};
writetable(stimulusByGroupTable, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, ['stimulusByGroup_', responseMetric, '_postHoc.csv']))


% group by stimulus
posthocTable = multcompare(rm,'Group', 'By', 'Stimulus');

% key:
%   - group: 1 = controls; 2 = mwa; 3 = mwoa
groups = {'Controls', 'MwA', 'MwoA'};
groupNameInStruct = {'controls', 'mwa', 'mwoa'};
%   - stimulus: 0 = melanopsin; 1 = LMS; 2 = light flux
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};


comparisons = {'MwA - Controls', 'MwoA - Controls', 'MwoA - MwA'};

groupByStimulusTable = {};
rowCounter = 1;
for stimulus = 1:length(stimuli)
    for comparison = 1:length(comparisons)
        
        
        groupByStimulusTable{rowCounter,1} = stimuli{stimulus};
        groupByStimulusTable{rowCounter,2} = comparisons{comparison};
        
        stimulusRows = find(posthocTable.Stimulus == (stimulus - 1));
        
        groupsInComparison = strsplit(comparisons{comparison},' - ');
        firstGroup = groupsInComparison{1};
        firstGroupCode = find(strcmp(groups, firstGroup));
        firstGroupRows = find(posthocTable.Group_1 == categorical(firstGroupCode));
        
        secondGroup = groupsInComparison{2};
        secondGroupCode = find(strcmp(groups, secondGroup));
        secondGroupRows = find(posthocTable.Group_2 == categorical(secondGroupCode));
        
        firstIntersection = intersect(stimulusRows, firstGroupRows);
        
        row = intersect(firstIntersection, secondGroupRows);
        
        groupByStimulusTable{rowCounter,3} = sprintf('%4.3f - %4.3f = %4.3f', mean(result.(groupNameInStruct{firstGroupCode}).(stimuli{stimulus})), mean(result.(groupNameInStruct{secondGroupCode}).(stimuli{stimulus})), [mean(result.(groupNameInStruct{firstGroupCode}).(stimuli{stimulus})) - mean(result.(groupNameInStruct{secondGroupCode}).(stimuli{stimulus}))]);
        
        groupByStimulusTable{rowCounter,4} = sprintf('%4.3f', table2array(posthocTable(row,4))/table2array(posthocTable(row,5)));
        
        if table2array(posthocTable(row,6)) < 0.05
            groupByStimulusTable{rowCounter,5} = sprintf('*%0.3e', table2array(posthocTable(row,6)));
        else
            groupByStimulusTable{rowCounter,5} = sprintf('%0.3e', table2array(posthocTable(row,6)));
        end
        
        
        groupByStimulusTable{rowCounter,6} = sprintf('%4.3f - %4.3f', table2array(posthocTable(row,7)), table2array(posthocTable(row,8)));
        
        rowCounter = rowCounter + 1;
        
    end
end

groupByStimulusTable = array2table(groupByStimulusTable);
groupByStimulusTable.Properties.VariableNames = {'Stimulus', 'Comparison', 'Difference', 't_Statistic', 'p_Value', 'CI_95'};
writetable(groupByStimulusTable, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', responseModality, ['groupBystimulus_', responseMetric, '_postHoc.csv']))

end
