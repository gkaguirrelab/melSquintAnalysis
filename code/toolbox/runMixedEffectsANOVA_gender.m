function runMixedEffectsANOVA_gender(responseModality, responseMetric)
% This function looks at the effect of gender on discomfort ratings using
% an ANOVA.

% Syntax: 
%   runMixedEffectsANOVA_gender('discomfortRatings', 'meanRating')
%
% Description:
%   Both migraine groups show increased discomfort ratings relative to
%   headache free controls. However, both migraine groups have an increased
%   ratio of female subjects which raises the alternate hypothesis that
%   increased discomfort is not a consequence of migraine status but rather
%   gender imbalance. To assess this claim, this routine runs a two way
%   mixed effects ANOVA with between subject factors of sex and wihtin
%   subject factors of stimulus type. The routine outputs text that
%   summarizes the ANOVA.
%
% Inputs:
%   - responseModality                  a string which defines which type
%                                       of response we're looking at.
%                                       Options include
%                                       'discomfortRatings', 'pupil', and
%                                       'emg', but the routine was designed
%                                       to look at 'discomfortRatings'
%   - responseMetric                    a string which defines which aspect
%                                       of the repsonseOverContrast
%                                       function we care to examine. To
%                                       collapse across contrast levels, we
%                                       fit a line to the median discomfort
%                                       ratings across trials for each
%                                       individual subject. From this fits,
%                                       we can extract 'meanRating', which
%                                       would be predicted response at 200%
%                                       contrast, slope, and intercept.

%% get model fit params

if strcmp(responseModality, 'pupil')
    [slope, intercept, meanRating] = fitLineToResponseModality(responseModality, 'makePlots', false, 'makeCSV', false, 'responseMetric', 'AUC');
elseif strcmp(responseModality, 'emg')
    [slope, intercept, meanRating] = fitLineToResponseModality(responseModality, 'makePlots', false, 'makeCSV', false, 'responseMetric', 'normalizedPulseAUC');
else
    [slope, intercept, meanRating] = fitLineToResponseModality(responseModality, 'makePlots', false, 'makeCSV', false);
end
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

[ ~, subjectIDsStruct] = loadDiscomfortRatings;

pathToSurveyData = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'surveyMelanopsinAnalysis', 'MELA_ScoresSurveyData_Squint.xlsx');
surveyTable = readtable(pathToSurveyData);
columnNames = surveyTable.Properties.VariableNames;
sexColumn = find(contains(columnNames, 'Sex'));


% First column: all dependent variables:
stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
groups = {'controls', 'mwa', 'mwoa'};
maleResponses = [];
femaleResponses = [];

for group = 1:length(groups)
    male.(groups{group}) = [];
    female.(groups{group}) = [];
end

subjectStructFieldNames = {'controlSubjects', 'mwaSubjects', 'mwoaSubjects'};
for group = 1:length(groups)
    for ss = 1:20
        subjectID = subjectIDsStruct.(subjectStructFieldNames{group}){(ss-1)*9+1};
        for stimulus = 1:length(stimuli)
            
             dependentVariable = result.(groups{group}).(stimuli{stimulus})(ss);

            
            if strcmp(groups{group}, 'controls')
                rowAdjuster = 1;
            elseif strcmp(groups{group}, 'mwa')
                rowAdjuster = 2;
            elseif strcmp(groups{group}, 'mwoa')
                rowAdjuster = 3;
            end
            
            
            % first column is dependent variable
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 1) = dependentVariable;
            
            % second column is between-subject factor (group diagnosis)
            subjectRow = find(contains(surveyTable{:,1}, subjectID));
            sex = (cell2mat(surveyTable{subjectRow,sexColumn}));
            if strcmp(sex, 'Male')
                sex = 1;
                maleResponses = [maleResponses, dependentVariable];
                male.(groups{group}) = [male.(groups{group}), dependentVariable];
            elseif strcmp(sex, 'Female')
                sex = 2;
                femaleResponses = [femaleResponses, dependentVariable];
                female.(groups{group}) = [female.(groups{group}), dependentVariable];

            end
            
            designMatrix(((ss-1)*3+rowAdjuster+(stimulus-1)*60), 2) = sex;
            
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
        
        subjectID = subjectIDsStruct.(subjectStructFieldNames{group}){(ss-1)*9+1};
        
        subjectRow = find(contains(surveyTable{:,1}, subjectID));
        sex = (cell2mat(surveyTable{subjectRow,sexColumn}));
        if strcmp(sex, 'Male')
            sex = 1;
        elseif strcmp(sex, 'Female')
            sex = 2;
        end
        
        
        dataTable(rowCounter,1) = result.(groups{group}).Melanopsin(ss);
        dataTable(rowCounter,2) = result.(groups{group}).LMS(ss);
        dataTable(rowCounter,3) = result.(groups{group}).LightFlux(ss);
        dataTable(rowCounter,4) = sex;
        
        rowCounter = rowCounter + 1;
        
        
    end
end

dataTable = array2table(dataTable);
dataTable.Properties.VariableNames = {'Melanopsin', 'LMS', 'LightFlux', 'Sex'};
dataTable.Sex = categorical(dataTable.Sex);
wsVariable = table([0 1 2]', 'VariableNames', {'Stimulus'});

rm = fitrm(dataTable, 'Melanopsin,LMS,LightFlux~Sex', 'WithinDesign', wsVariable);

% spit out some text about these ANOVA results
% to find the within-subject effects:
ranovatbl = ranova(rm);
withinSubjectsFValue = table2array(ranovatbl(1,4));
withinSubjectspValue = table2array(ranovatbl(1,5));
interactionFValue = table2array(ranovatbl(2,4));
interactionpValue = table2array(ranovatbl(2,5));
fprintf('\n<strong>From Matlab functions: </strong>\n');
fprintf('The effect of stimulus: F-value of %4.3f, p-value of %4.5f\n', withinSubjectsFValue, withinSubjectspValue);
fprintf('The effect of interaction: F-value of %4.3f, p-value of %4.5f\n', interactionFValue, interactionpValue);


% to find the between subject effects:
anovatbl = anova(rm);
betweenSubjectsFValue = table2array(anovatbl(2,6));
betweenSubjectspValue = table2array(anovatbl(2,7));
fprintf('The effect of sex: F-value of %4.3f, p-value of %4.5f\n', betweenSubjectsFValue, betweenSubjectspValue);
end
