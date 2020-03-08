%% fitTwoStageModel
%
% Implements a two-stage, non-linear, log-linear fit to across-subject
% discomfort and pupil data from the melaSquint project.


%% Define script behavior

% Which modality to analyze: {'pupil','discomfort'}
modality = 'pupil';

% For the pupil data, we have two ways to estimate the data amplitude, the
% options being: {'AUC','TPUP'}
areaMeasure = 'AUC';

% The norms to use for model fitting. Following our pre-registered
% protocol, we adopt the L1 norm for aggregating the measurements across
% subjects within a stimulus. We fit the model to the median response
% measures across stimuli, and perform a non-parametric search across model
% parameters to optimize the L2 norm. This model fitting is performed
% across bootstraps. We observe that the parameters yielded across
% bootstraps are not normally distributed, so we take the L1 norm to get
% the central tendency of the params across bootstraps.
subNorm = 1;
stimNorm = 2;
bootNorm = 1;

% How many boot-straps to peform for the fitting
nBoots = 10;


%% Hard-coded variables

% Hard-coded values regarding the model
nParams = 4;

% Hard-coded values regarding the dataset
nStimuli = 3;
nGroups = 3;
nSubjectsPerGroup = 20;

% Data and parameters that vary by modality
if strcmp(modality, 'discomfort')
    
    % Load the data
    [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus] = loadDiscomfortRatings();
    
    % Bounds for the parameters
    x0 = [1 2 1 1];
    lb = [0.1 0.1 0 -10];
    ub = [2 3 Inf 10];
    
    % Define plotting behavior
    yLimFig1 = [0 10];
    yLimFig2 = {[0 1],[0 4],[0 6],[0 6]};
    
elseif strcmp(modality, 'pupil')
    
    % Load the data
    [resultsStruct, ~, MelContrastByStimulus, LMSContrastByStimulus] = loadPupilResponses();
    resultsStruct = resultsStruct.(areaMeasure);
    
    % Bounds for the parameters
    x0 = [1 1 200 200];
    lb = [0.1 0.1 0 -800];
    ub = [2 3 Inf 800];
    
    % Define plotting behavior
    yLimFig1 = [0 400];
    yLimFig2 = {[0 1],[0 4],[0 400],[0 400]};
end

% Define some properties for the plots
groupLabels = {'controls','mwa','mwoa'};
groupColors = {'k','b','r'};
stimSymbols = {'^','s','o'};
yLabels = {'alpha','beta','slope','offset'};

% Open a figure to plot the data
figHandle1 = figure();

% Define the fmincon search options
options = optimset('fmincon');
options.Display = 'off';

% Loop over the studied groups
pB = []; % All of the param values across bootstraps
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
    
    %% Bootstrap
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
    
    % Obtain the central tendency of the param values and plot these
    subplot(1,3,gg);  hold on
    
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
    for ss = 1:3
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
    xlim([1 3]);
    xticks([log10(50) log10(100) log10(200) log10(400) log10(800)])
    xticklabels({'0.5','1','2','4','8'})
    title(groupLabels{gg});
    
end

% Convert the intercept into the response at log(200%) ipRGC contrast
pB(:,:,4) = pB(:,:,4)+pB(:,:,3).*log10(200);

% Plot the central tendency and 95% CI of the parameters
figHandle2 = figure();
for pp=1:length(yLabels)
    subplot(1,4,pp);
    outline = [yLabels{pp} ' [95 CI] --- '];
    for gg = 1:3
        vals = sort(squeeze(pB(gg,:,pp)));
        p = median(vals);
        p95low = vals(max([round(nBoots*0.025) 1]));
        p95hi = vals(round(nBoots*0.925));
        plot(gg,p,['o',groupColors{gg}]);
        hold on
        plot([gg gg],[p95low p95hi],['-',groupColors{gg}]);
        outline = sprintf([outline groupLabels{gg} ': %2.2f [%2.2f - %2.2f]; '],p,p95low,p95hi);
        if gg>1
            df=20;
            controlVals = sort(squeeze(pB(1,:,pp)));
            switch bootNorm
                case 1
                    medC = median(controlVals);
                    medV = median(vals);
                case 2
                    medC = mean(controlVals);
                    medV = mean(vals);
            end
            sdC = sqrt(std(controlVals));
            sdV = sqrt(std(vals));
            sdPooled = sqrt( ((df-1)*sdC^2 + (df-1)*sdV^2)/(df*2-2) );
            se = sdPooled * sqrt( 1/df + 1/df);
            t = (medV - medC)/se;
            prob = 2*tpdf(t,df*2-2);
            outline = sprintf([outline groupLabels{gg} '-control, p=%.2d; '],prob);
        end
    end
    xlim([0 4]);
    ylim(yLimFig2{pp});
    ylabel(yLabels{pp});
    fprintf([outline '\n']);
end

