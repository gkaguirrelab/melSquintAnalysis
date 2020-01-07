%% get model fit params
[slope, intercept, meanRating] = fitLineToDiscomfortRatings('makePlots', false, 'makeCSV', false);

%% Create the design matrix
%     - first column  (i.e., X(:,1)) : all dependent variable values
%     - second column (i.e., X(:,2)) : between-subjects factor (e.g., subject group) level codes (ranging from 1:L where 
%         L is the # of levels for the between-subjects factor)
%     - third column  (i.e., X(:,3)) : within-subjects factor (e.g., condition/task) level codes (ranging from 1:L where 
%         L is the # of levels for the within-subjects factor)
%     - fourth column (i.e., X(:,4)) : subject codes (ranging from 1:N where N is the total number of subjects)
result = meanRating;
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
[SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(designMatrix)