function [figHandle1, figHandle2, rngSeed] = fitTwoStageModel(varargin)
% A two-stage, non-linear, log-linear model for discomfort and pupil data
%
% Syntax:
%  fitTwoStageModel
%
% Description:
%   Implements a two-stage, non-linear, log-linear fit to across-subject
%   discomfort and pupil data from the melaSquint project. These fits are
%   the basis of panels in Figures XXX of McAdams et al, 2020.
%
% Optional key-value pairs:
%  'modality'             - Char vector. Which data set to operate upon. 
%                           Valid options are:
%                               {'pupil','discomfort','EMG'}
%  'areaMeasure'          - Char vector. For the pupil data, we have two 
%                           ways to estimate the data amplitude, the
%                           options being:
%                               {'AUC','TPUP'}
%                           and for the EMG data, the options are:
%                               {'normalizedPulseAUC'}
%  'pupilScalar'          - Scalar. The pupil response data are recorded as
%                           integrated (over time) response area. By
%                           dividing these values by this scalar, we obtain
%                           the pupil response as expressed as mean %
%                           change area over time.
%  'nBoots'               - Scalar. The number of boot-strap resamplings to
%                           perform in estimating the variation in the
%                           model parameters.
%  'rngSeed'              - Structure. Can provide an rng seed structure to
%                           place the random number generator in a known
%                           state so that reproducible bootstrap results
%                           are obtained. The default behavior of this
%                           function is to place the rng seed in the
%                           default state (i.e., as if Matlab had just been
%                           started).
%  'stimSymbols'          - 1x3 cell array. Provides the char codes for the
%                           symbols used to plot the Mel, LMS, and
%                           lightFlux stimuli, respectively.
%  'x0,lb,ub'             - 1x4 vectors. Properties for the fmincon search.
%                           If defined, it would usually be for the purpose
%                           of locking one or more parameters.
%
% Outputs:
%   figHandle1, figHandle2 - Handles to the plotted figures.
%   rngSeed               - Structure. The rngSeed state at the start of
%                           the execution of the function.
%
% Examples:
%{
    % Fit the discomfort data
    [~, figHandle2] = fitTwoStageModel('modality','discomfort','rngSeed',1000);
    % Save figure 2
    print(figHandle2, '~/Desktop/discomfort_params.pdf', '-dpdf', '-fillpage')
%}
%{
    % Re-fit the discomfort data, locking the first two parameters
    x0 = [0.6323, 1.7488, 1, 1];
    lb = [0.6323, 1.7488, 0, -10];
    ub = [0.6323, 1.7488, Inf, 10];
    figHandle1 = fitTwoStageModel('modality','discomfort','x0',x0,'lb',lb,'ub',ub,'rngSeed',1000);
    % Save figure 1
    print(figHandle1, '~/Desktop/discomfort_fit.pdf', '-dpdf', '-fillpage')
%}
%{
    % Fit the pupil data
    [~, figHandle2] = fitTwoStageModel('modality','pupil','rngSeed',1000);
    % Save figure 2
    print(figHandle2,'~/Desktop/pupil_params.pdf', '-dpdf', '-fillpage')
%}
%{
    % Re-fit the pupil data, locking all parameters
    x0 = [0.4152, 0.8292, 0.1296, -0.1512];
    lb = [0.4152, 0.8292, 0.1296, -0.1512];
    ub = [0.4152, 0.8292, 0.1296, -0.1512];
    figHandle1 = fitTwoStageModel('modality','pupil','x0',x0,'lb',lb,'ub',ub,'nBoots',2,'rngSeed',1000);
    % Save figure 1
    print(figHandle1, '~/Desktop/pupil_fit.pdf', '-dpdf', '-fillpage')
%}
%{
    % Fit the EMG data
    [figHandle1, figHandle2] = fitTwoStageModel('modality','emg','responseMetric', 'normalizedPulseAUC', 'rngSeed',1000);
    % Save figures
    print(figHandle1, '~/Desktop/emg_fit.pdf', '-dpdf', '-fillpage')
    print(figHandle2, '~/Desktop/emg_params.pdf', '-dpdf', '-fillpage')
%}


%% Parse input
p = inputParser;

% Optional params
p.addParameter('modality','discomfort',@ischar);
p.addParameter('responseMetric','AUC',@ischar);
p.addParameter('pupilScalar',1031,@isscalar);
p.addParameter('nBoots',1000,@isscalar);
p.addParameter('rngSeed',[],@(x)(isempty(x)| isnumeric(x) | isstruct(x)));
p.addParameter('meanCenteredR2',true,@islogical);
p.addParameter('stimSymbols',{'o','o','o'},@iscell);
p.addParameter('stimLabels',{'m','c','f'},@iscell);
p.addParameter('x0',[],@(x)(isempty(x) | isnumeric(x)));
p.addParameter('lb',[],@(x)(isempty(x) | isnumeric(x)));
p.addParameter('ub',[],@(x)(isempty(x) | isnumeric(x)));

% parse
p.parse(varargin{:})


%% Extract parameters
modality = p.Results.modality;
responseMetric = p.Results.responseMetric;
nBoots = p.Results.nBoots;
stimSymbols = p.Results.stimSymbols;
rngSeed = p.Results.rngSeed;


%% Set the random number generator
if isempty(rngSeed)
    rngSeed = rng('default');
end
rng(rngSeed);


%% Hard-coded variables

% The norms to use for model fitting. While we would prefer to use the L1
% norm to aggregate data across subjects within a stimulus, we find that
% this leads to unstable model fits for the discomfort data, as these data
% are discrete. We therefore adopt the L2 norm for the analysis of data of
% all modalities for consistency. We fit the model to these mean
% response measures across stimuli, and perform a non-parametric search
% across model parameters to optimize the L2 norm. This model fitting is
% performed across bootstraps. We observe that the parameters yielded
% across bootstraps are not always normally distributed, so we take the L1
% norm to get the central tendency of the params across bootstraps.
subNorm = 2;
stimNorm = 2;
bootNorm = 1;
groupNorm = 2;

% The number of model params
nParams = 4;

% Properties of the dataset
nStimuli = 3;
nContrasts = 3;
nGroups = 3;
nSubjectsPerGroup = 20;

% Data and parameters that vary by modality
switch modality
    case 'discomfort'
        
        % Load the data
        [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus, localContrastByStimulus ] = loadDiscomfortRatings();
        
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
        
        % Define the parameter names
        yLabels = {'alpha_{mel}','beta','slope','offset'};
        
        % Define plotting behavior
        xLimFig1 = [log10(25) log10(800)];
        xticksFig1 = [log10(25) log10(50) log10(100) log10(200) log10(400) log10(800)];
        xticklabelsFig1 = {'0.25','0.5','1','2','4','8'};
        yLimFig1 = [-1 10];
        yLimFig2 = {[0 1],[0 4],[0 6],[0 6]};
        
    case 'pupil'
        
        % Load the data
        [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus, localContrastByStimulus ] = loadPupilResponses();
        resultsStruct = resultsStruct.(responseMetric);
        
        % Bounds for the parameters
        if isempty(p.Results.x0)
            x0 = [1 1 0.2 -0.2];
        else
            x0 = p.Results.x0;
        end
        if isempty(p.Results.lb)
            lb = [0 0 0 -0.8];
        else
            lb = p.Results.lb;
        end
        if isempty(p.Results.ub)
            ub = [2 3 Inf 0.8];
        else
            ub = p.Results.ub;
        end

        % Define the parameter names
        yLabels = {'alpha_{mel}','beta','slope','offset'};

        % Define plotting behavior
        xLimFig1 = [log10(25) log10(800)];
        xticksFig1 = [log10(25) log10(50) log10(100) log10(200) log10(400) log10(800)];
        xticklabelsFig1 = {'0.25','0.5','1','2','4','8'};
        yLimFig1 = [-0.05 0.5];
        yLimFig2 = {[0 1],[0 4],[0 0.4],[0 0.4]};
        
    case 'emg'
        
        % Load the data
        [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus, localContrastByStimulus ] = loadEMG();
        resultsStruct = resultsStruct.(responseMetric);
        
        % Bounds for the parameters
        if isempty(p.Results.x0)
            x0 = [1 100 0.05 0.1];
        else
            x0 = p.Results.x0;
        end
        if isempty(p.Results.lb)
            lb = [0 100 0 0];
        else
            lb = p.Results.lb;
        end
        if isempty(p.Results.ub)
            ub = [10 100 Inf 1];
        else
            ub = p.Results.ub;
        end
        
        % Define the parameter names
        yLabels = {'alpha_{lms}','beta','slope','offset'};

        % Define plotting behavior
        xLimFig1 = [log10(25) log10(800)];
        xticksFig1 = [log10(25) log10(50) log10(100) log10(200) log10(400) log10(800)];
        xticklabelsFig1 = {'0.25','0.5','1','2','4','8'};
        yLimFig1 = [-0.3 3];
        yLimFig2 = {[0 1],[0 100],[0 0.2],[0 0.5]};
        
end

% Define the fmincon search options
options = optimset('fmincon');
options.Display = 'off';


%% Set up the plot figure

% Define some properties for the plots
groupLabels = {'controls','mwa','mwoa'};
groupColors = {'k','b','r'};

% Open a figure to plot the data
figHandle1 = figure();
orient(figHandle1,'landscape');



%% Bootstrap fitting

% All of the param values across bootstraps
pBoot = [];

% The R2 of the model by group across bootstraps
r2byGroupByBoot = nan(nGroups,nBoots);

% Loop over groups
for gg = 1:nGroups
    
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
    
    % If these are pupil data, convert the data values from total area
    % under the curve to the units "mean constriction over time expressed
    % in units of percentage change from baseline"
    if strcmp(modality,'pupil')
        dVeridical = dVeridical./p.Results.pupilScalar;
    end
    
    % Stage 1 of the model transforms mel and cone contrast into log10
    % "ipRGC" contrast
    switch yLabels{1}
        case 'alpha_{mel}'
            myModelStage1 = @(k) log10(( (k(1).*MelContrastByStimulus).^k(2) + (LMSContrastByStimulus).^k(2) ).^(1/k(2)));
        case 'alpha_{lms}'
            myModelStage1 = @(k) log10(( (MelContrastByStimulus).^k(2) + (k(1).*LMSContrastByStimulus).^k(2) ).^(1/k(2)));
        otherwise
            error('Not a recognized form of the alpha parameter');
    end
    
    % The stage 2 model then applies a slope and intercept parameter to log
    % ipRGC contrast
    myModelStage2 = @(k,m) m(1).*myModelStage1(k) + m(2);
        
    
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
        myObj = @(p) norm(d - myModelStage2(p(1:2),p(3:4)),stimNorm);
        
        % Fit that sucker
        pB = fmincon(myObj,x0,[],[],[],[],lb,ub,[],options);
                
        % Save the params
        pBoot(gg,bb,:) = pB;
        
    end
    
    % Prepare a sub-plot
    subplot(1,3,gg);  hold on
    
    % The central tendency of the parameter values across bootstraps.
    switch bootNorm
        case 1
            params = median(squeeze(pBoot(gg,:,:)));
        case 2
            params = mean(squeeze(pBoot(gg,:,:)));
    end
    
    % Perform a second boot-strap to find the R2 of these parameters to the
    % data. First, we get the model that is defined by the central tendency
    % of the parameters
    dFit = myModelStage2(params(1:2),params(3:4));
    if p.Results.meanCenteredR2
        dFit = dFit - mean(dFit);
    end
    mss = sum((dFit - mean(dFit)).^2);

    % Now loop over boots and obtain the R^2 of the fit to versions of the
    % resampled data.
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
        
        if p.Results.meanCenteredR2
        d = d - mean(d);
        end

        % The residual sum of squares
        rss = sum((dFit-d).^2);
        
        % The R2 is the proportion of the total variance that is explained
        % by the model
        r2byGroupByBoot(gg,bb) = mss/(mss+rss);
        
    end
    
    % The ipRGC contrast values implied by the stage 1 parameters, broken
    % down into the different stimulus types. These are the x-values for
    % the plot
    ipRGCContrastValues = myModelStage1(params(1:2));
    xSetsByStim = {[1 2 3],[4 5 6],[7 8 9]};
    
    % The subject responses by stimulus type; these are the y-values for
    % the plot.
    ySetsByStim = {[1 2 3],[4 5 6],[7 8 9]};
    
    % Plot the data for each subject in this group, using different plot
    % symbols for each stimulus type
    for ss = 1:nStimuli
        x = ipRGCContrastValues(xSetsByStim{ss});
        y = dVeridical(ySetsByStim{ss},:)';
        h = scatter(repmat(x, 1, nSubjectsPerGroup), y(:), 7, 'o');
        h.MarkerFaceColor = groupColors{gg};
        h.MarkerEdgeColor = 'none';
        h.MarkerFaceAlpha = 0.2;
        
        % Add the central tendency of the response across subjects for each
        % stimulus type.
        switch subNorm
            case 1
                y = median(y);
                plot(x, y, [stimSymbols{ss} groupColors{gg}],'MarkerSize',7);
            case 2
                y = mean(y);
                plot(x, y, [stimSymbols{ss} groupColors{gg}],'MarkerSize',7);
        end

        % Include a text label so we know which stimulus is which even if
        % we use the same plot symbols
        text(x, y, p.Results.stimLabels{ss}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');        
        
    end
    
    % Add the model fit line using the central tendency of the parameters
    % from stage 2
    reflineHandle = refline(params(3),params(4));
    reflineHandle.Color = groupColors{gg};
        
    % Add a text report of the parameters used for the fit
    str = sprintf('[%2.2f, %2.2f, %2.2f, %2.2f]',params);
    text(log10(25),yLimFig1(2)*0.9,str,'VerticalAlignment','bottom');
    
    % Clean up the plot
    xlim(xLimFig1);
    xticks(xticksFig1)
    xticklabels(xticklabelsFig1)
    ylim(yLimFig1);
    title(groupLabels{gg});
    pbaspect([1.5 1 1])
    
end

% Add a title to the figure
str = ['Model fit to the ' modality ' data'];
suptitle(str);


%% Report the central tendency of the parameters across all groups
switch bootNorm
    case 1
        m=squeeze(median(pBoot,2));
    case 2
        m=squeeze(mean(pBoot,2));
end
switch groupNorm
    case 1
        m=median(m);
    case 2
        m=mean(m);
end
str = sprintf('central tendency params across bootstraps and groups: [%2.4f, %2.4f, %2.4f, %2.4f]\n',m);
fprintf(str);


%% Report the R2 (±SEM) for each group across bootstraps
str = 'model R2 [±SEM] by group: ';
for gg = 1:nGroups
    switch bootNorm
        case 1
            r2=median(r2byGroupByBoot(gg,:));
            r2SEM=iqr(r2byGroupByBoot(gg,:))/1.35;
        case 2
            r2=mean(r2byGroupByBoot(gg,:));
            r2SEM=std(r2byGroupByBoot(gg,:));
    end
    str = [str groupLabels{gg} sprintf(': %2.3f \x00B1 %2.5f; ',r2,r2SEM)];
end
fprintf([str '\n']);


%% Plot the central tendency and SEM of the parameters
figHandle2 = figure();

% Convert the intercept into the response at log(200%) ipRGC contrast
pBoot(:,:,4) = pBoot(:,:,4)+pBoot(:,:,3).*log10(200);

% Loop over params
for pp=1:length(yLabels)
    
    % We make some small gaps between the subplots to make sure that the
    % sizes of the plot 
    subplot(1,nParams*6-1,[(pp-1)*5+pp (pp-1)*5+2+pp]);
    outline = [yLabels{pp} ' [SEM] --- '];

    % Loop over the groups
    for gg = 1:nGroups
        
        % Get the central tendency and SEM of the vals for this group. We
        % obtain these measures for the control group in every pass through
        % the data, so that they are available for calculating
        % between-group t-tests.
        vals = sort(squeeze(pBoot(gg,:,pp)));
        controlVals = sort(squeeze(pBoot(1,:,pp)));

        % Which norm are we using for the measures across boot straps? Note
        % that the SD of the param values across bootstraps gives the SEM
        % of the central tendency of the parameter.
        switch bootNorm
            case 1
                % Obtain the central tendency
                medC = median(controlVals);
                medV = median(vals);
                
                % For normally distributed data, SD = IQR / 1.35. Demo:
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
        
        % Plot the error bars (+- 2 SEM)
        plot([gg gg],[medV+2*semV medV-2*semV],['-',groupColors{gg}]);
        hold on

        % Plot the central tendency value
        h = plot(gg,medV,['o',groupColors{gg}]);
        h.MarkerFaceColor = groupColors{gg};
        h.MarkerEdgeColor = 'w';        
        h.MarkerSize = 6;        
                
        % Clean up the plot
        xlim([0 4]);
        ylim(yLimFig2{pp});
        ylabel(yLabels{pp});
        pbaspect([1 2.5 1]);

        % Report the result to the console
        outline = sprintf([outline groupLabels{gg} ': %2.2f [%2.2f]; '],medV,semV);
        if gg > 1
            
            % Calculate the two-sample t-test result given the estimates of
            % mean and standard error
            df = nSubjectsPerGroup;
            t = (medV - medC)/norm([semC semV]);
            prob = 2*tpdf(t,df*2-2);
            
            % Add this result to the plot
            yPos = yLimFig2{pp}(2) .* (0.81.^(1/(gg-1)));
            plot([1 gg],[yPos yPos],'-k');
            str = sprintf('p=%2.5f',prob);
            text(1,yPos,str,'VerticalAlignment','bottom');
            
            % Add this result to the output line
            outline = sprintf([outline groupLabels{gg} '-control, p=%2.5f; '],prob);
        end
    end
    
    % report the outline
    fprintf([outline '\n']);
    
end

% Add a title to the figure
str = ['Parameter fits [+-2SEM] for the ' modality ' data'];
suptitle(str);

end % Function