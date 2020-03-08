function [figHandle1, figHandle2] = fitTwoStageModel(varargin)
% A two-stage, non-linear, log-linear model for discomfort and pupil data
%
% Syntax:
%  fitTwoStageModel
%
% Description:
%   Implements a two-stage, non-linear, log-linear fit to across-subject
%   discomfort and pupil data from the melaSquint project.
%
% Optional key-value pairs:
%  'modality'             - Char vector. Which data set to operate upon. 
%                           Valid options are: {'pupil','discomfort'}
%  'areaMeasure'          - Char vector. For the pupil data, we have two 
%                           ways to estimate the data amplitude, the
%                           options being: {'AUC','TPUP'}
%  'nBoots'               - Scalar. The number of boot-strap resamplings to
%                           perform in estimating the variation in the
%                           model parameters.
%  'x0,lb,ub'             - 1x4 vectors. Properties for the fmincon search.
%                           If defined, it would usually be for the purpose
%                           of locking one or more parameters.
%
% Outputs:
%   figHandle1, figHandle2 - Handles to the plotted figures.
%
% Examples:
%{
    % Fit the discomfort data
    fitTwoStageModel('modality','discomfort');
%}
%{
    % Re-fit the discomfort data, locking the first two parameters
    x0 = [0.63 1.75 1 1];
    lb = [0.63 1.75 0 -10];
    ub = [0.63 1.75 Inf 10];
    fitTwoStageModel('modality','discomfort','x0',x0,'lb',lb,'ub',ub);
%}
%{
    % Fit the pupil data
    fitTwoStageModel('modality','pupil');
%}
%{
    % Re-fit the pupil data, locking all parameters
    x0 = [0.4179    0.8245  133.5397 -156.1173];
    lb = [0.4179    0.8245  133.5397 -156.1173];
    ub = [0.4179    0.8245  133.5397 -156.1173];
    fitTwoStageModel('modality','pupil','x0',x0,'lb',lb,'ub',ub,'nBoots',2);
%}


%% Parse input
p = inputParser;

% Optional params
p.addParameter('modality','pupil',@ischar);
p.addParameter('areaMeasure','AUC',@ischar);
p.addParameter('nBoots',1000,@isscalar);
p.addParameter('x0',[],@(x)(isempty(x) | isnumeric(x)));
p.addParameter('lb',[],@(x)(isempty(x) | isnumeric(x)));
p.addParameter('ub',[],@(x)(isempty(x) | isnumeric(x)));

% parse
p.parse(varargin{:})


%% Extract parameters
modality = p.Results.modality;
areaMeasure = p.Results.areaMeasure;
nBoots = p.Results.nBoots;

% The norms to use for model fitting. While we would prefer to use the L1
% norm to aggregate data across subjects within a stimulus, we find that
% this leads to unstable model fits for the discomfort data, as these data
% are discrete. We therefore adopt the L2 norm for the analysis of both the
% discomfort and pupil data for consistency. We fit the model to these mean
% response measures across stimuli, and perform a non-parametric search
% across model parameters to optimize the L2 norm. This model fitting is
% performed across bootstraps. We observe that the parameters yielded
% across bootstraps are not normally distributed, so we take the L1 norm to
% get the central tendency of the params across bootstraps.
subNorm = 2;
stimNorm = 2;
bootNorm = 1;



%% Hard-coded variables

% The number of model params
nParams = 4;

% Properties of the dataset
nStimuli = 3;
nGroups = 3;
nSubjectsPerGroup = 20;

% Data and parameters that vary by modality
if strcmp(modality, 'discomfort')
    
    % Load the data
    [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus] = loadDiscomfortRatings();
    
    % Bounds for the parameters
    if isempty(p.Results.x0)
        x0 = [1 2 1 1];
    else
        x0 = p.Results.x0;
    end
    if isempty(p.Results.lb)
        lb = [0 0 0 -10];
    else
        lb = p.Results.lb;
    end
    if isempty(p.Results.ub)
        ub = [2 3 Inf 10];
    else
        ub = p.Results.ub;
    end
        
    % Define plotting behavior
    yLimFig1 = [-1 10];
    yLimFig2 = {[0 1],[0 4],[0 6],[0 6]};
    
elseif strcmp(modality, 'pupil')
    
    % Load the data
    [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus] = loadPupilResponses();
    resultsStruct = resultsStruct.(areaMeasure);
    
    % Bounds for the parameters
    if isempty(p.Results.x0)
        x0 = [1 1 200 200];
    else
        x0 = p.Results.x0;
    end
    if isempty(p.Results.lb)
        lb = [0 0 0 -800];
    else
        lb = p.Results.lb;
    end
    if isempty(p.Results.ub)
        ub = [2 3 Inf 800];
    else
        ub = p.Results.ub;
    end
    
    % Define plotting behavior
    yLimFig1 = [0 400];
    yLimFig2 = {[0 1],[0 4],[0 400],[0 400]};
    
end

% Define some properties for the plots
groupLabels = {'controls','mwa','mwoa'};
groupColors = {'k','b','r'};
stimSymbols = {'^','s','o'};
yLabels = {'alpha','beta','slope','offset'};

% Define the fmincon search options
options = optimset('fmincon');
options.Display = 'off';

% Open a figure to plot the data
figHandle1 = figure();


%% Bootstrap fitting

% All of the param values across bootstraps
pB = [];

% Loop over groups
for gg = 1:length(groupLabels)
    
    % Assemble the data to be fit
    dVeridical = [ ...
        resultsStruct.(groupLabels{gg}).Melanopsin.Contrast100; ...
        resultsStruct.(groupLabels{gg}).Melanopsin.Contrast200; ...
        resultsStruct.(groupLabels{gg}).Melanopsin.Contrast400; ...
        resultsStruct.(groupLabels{gg}).LMS.Contrast100; ...
        resultsStruct.(groupLabels{gg}).LMS.Contrast200; ...
        resultsStruct.(groupLabels{gg}).LMS.Contrast400; ...
        resultsStruct.(groupLabels{gg}).LightFlux.Contrast100; ...
        resultsStruct.(groupLabels{gg}).LightFlux.Contrast200; ...
        resultsStruct.(groupLabels{gg}).LightFlux.Contrast400; ...
        ];
    
    % Stage 1 of the model transforms mel and cone contrast into log10
    % "ipRGC" contrast
    myModelStage1 = @(k) log10(((k(1).*MelContrastByStimulus).^k(2) + LMSContrastByStimulus.^k(2)).^(1/k(2)));
    
    % The full model then applies a slope and intercept parameter to log
    % ipRGC contrast
    myModel = @(k,m) m(1).*myModelStage1(k) + m(2);
    
    % Loop over bootstraps
    for bb = 1:nBoots
        
        % Resample across columns (subjects) with replacement
        d = dVeridical(:,datasample(1:nSubjectsPerGroup,nSubjectsPerGroup));
        
        % How do we aggregate the values across subjects?
        switch subNorm
            case 1
                % Fit the median value across subjects
                d = median(d,2)';
            case 2
                % Fit the mean value across subjects
                d = mean(d,2)';
        end
        
        % How do we minimize error in the search across stimuli?
        myObj = @(p) norm(d - myModel(p(1:2),p(3:4)),stimNorm);
        
        % Fit that sucker
        pB(gg,bb,:) = fmincon(myObj,x0,[],[],[],[],lb,ub,[],options);
        
    end
    
    % Prepare a sub-plot
    subplot(3,1,gg);  hold on
    
    % The central tendency of the parameter values across bootstraps.
    switch bootNorm
        case 1
            p = median(squeeze(pB(gg,:,:)));
        case 2
            p = mean(squeeze(pB(gg,:,:)));
    end
    
    % The ipRGC contrast values implied by the stage 1 parameters, brpken
    % down into the different stimulus types. These are the x-values for
    % the plot
    ipRGCContrastValues = unique(myModelStage1(p(1:2)));
    xSetsByStim = {[1 4 7],[2 5 8],[3 6 9]};
    
    % The subject responses by stimulus type; these are the y-values for
    % the plot.
    ySetsByStim = {[1 2 3],[4 5 6],[7 8 9]};
    
    % Plot the data for each subject in this group, using different plot
    % symbols for each stimulus type
    for ss = 1:nStimuli
        x = ipRGCContrastValues(xSetsByStim{ss});
        y = dVeridical(ySetsByStim{ss},:)';
        h = scatter(repmat(x, 1, nSubjectsPerGroup), y(:), stimSymbols{ss});
        h.MarkerFaceColor = groupColors{gg};
        h.MarkerEdgeColor = 'none';
        h.MarkerFaceAlpha = 0.2;
        
        % Add the central tendency of the response across subjects for each
        % stimulus type
        switch subNorm
            case 1
                plot(x, median(y), [stimSymbols{ss} groupColors{gg}],'MarkerSize',14);
            case 2
                plot(x, mean(y), [stimSymbols{ss} groupColors{gg}],'MarkerSize',14);
        end
        
    end
    
    % Add the model fit line using the central tendency of the parameters
    % from stage 2
    reflineHandle = refline(p(3),p(4));
    reflineHandle.Color = groupColors{gg};
    
    % Clean up the plot
    ylim(yLimFig1);
    xlim([log10(25) log10(1000)]);
    xticks([log10(50) log10(100) log10(200) log10(400) log10(800)])
    xticklabels({'0.5','1','2','4','8'})
    title(groupLabels{gg});
    
end


%% Plot the central tendency and SEM of the parameters
figHandle2 = figure();

% Convert the intercept into the response at log(200%) ipRGC contrast
pB(:,:,4) = pB(:,:,4)+pB(:,:,3).*log10(200);

% Loop over params
for pp=1:length(yLabels)
    
    subplot(1,nParams,pp);
    outline = [yLabels{pp} ' [SEM] --- '];

    % Loop over the groups
    for gg = 1:nGroups
        
        % Get the central tendency and SEM of the vals for this group. We
        % obtain these measures for the control group in every pass through
        % the data, so that they are available for calculating
        % between-group t-tests.
        vals = sort(squeeze(pB(gg,:,pp)));
        controlVals = sort(squeeze(pB(1,:,pp)));

        % Which norm are we using for the measures across boot straps? Note
        % that the SD of the param values across bootstraps gives the SEM
        % of the central tendency of the parameter.
        switch bootNorm
            case 1
                % Obtain the central tendency
                medC = median(controlVals);
                medV = median(vals);
                
                % For normally distrubuted data, SD = IQR / 1.35. Demo:
                %{
                    mu = 0; sd = 1;
                    iqr(normrnd(mu,sd,1000,1))
                %}
                semC = iqr(controlVals)/1.35;
                semV = iqr(vals)/1.35;
            case 2
                % Obtain the central tendency
                medC = mean(controlVals);
                medV = mean(vals);
                
                % The std of the bootstraps is the SEM of the mean
                semC = std(controlVals);
                semV = std(vals);
        end
        
        % Plot the central tendency value
        plot(gg,medV,['o',groupColors{gg}]);
        hold on
        
        % Add error bars (+- 2 SEM)
        plot([gg gg],[medV+2*semV medV-2*semV],['-',groupColors{gg}]);
        
        % Clean up the plot
        xlim([0 4]);
        ylim(yLimFig2{pp});
        ylabel(yLabels{pp});

        % Report the result to the console
        outline = sprintf([outline groupLabels{gg} ': %2.2f [%2.2f]; '],medV,semV);
        if gg > 1
            
            % Calculate the two-sample t-test result given the estimates of
            % mean and standard error
            df = nSubjectsPerGroup;
            t = (medV - medC)/norm([semC semV]);
            prob = 2*tpdf(t,df*2-2);
            
            % Add this result to the output line
            outline = sprintf([outline groupLabels{gg} '-control, p=%2.5f; '],prob);
        end
    end
    
    % Print the outline
    fprintf([outline '\n']);
    
end

