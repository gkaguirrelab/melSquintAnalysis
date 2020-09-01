subjectID = 'group';
if strcmp(subjectID, 'group')
    load('/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat');
else
    load(['/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, '/trialStruct_postSpotcheck.mat']);
end
offComponent = true;

% TPUP params
stimulusStruct = makeStimulusStruct;
thePacket.stimulus = stimulusStruct;

thePacket.kernel = [];
thePacket.metaData = [];

defaultParamsInfo.nInstances = 1;
responseIndicesToExclude = 40;


% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

melanopsinResponse = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
melanopsinResponse(1:responseIndicesToExclude) = NaN;
melanopsinResponse(end-responseIndicesToExclude:end) = NaN;

LMSResponse = nanmean(averageResponseMatrix.LMS.Contrast400);
LMSResponse(1:responseIndicesToExclude) = NaN;
LMSResponse(end-responseIndicesToExclude:end) = NaN;

LightFluxResponse = nanmean(averageResponseMatrix.LightFlux.Contrast400);
LightFluxResponse(1:responseIndicesToExclude) = NaN;
LightFluxResponse(end-responseIndicesToExclude:end) = NaN;

thePacket.response.values = [LMSResponse, melanopsinResponse, LightFluxResponse];
thePacket.response.timebase = 0:1/60*1000:length(thePacket.response.values)*1/60 * 1000 - 1/60 * 1000;

% resample the stimulus profile so it's at the same sampling as the
% response
resampledTimebase = 0:1/60*1000:1/60*length(nanmean(averageResponseMatrix.Melanopsin.Contrast400))*1000-1/60*1000;
resampledStimulusProfile = interp1(thePacket.stimulus.timebase, thePacket.stimulus.values, resampledTimebase);

thePacket.stimulus = [];
thePacket.stimulus.timebase = thePacket.response.timebase;
thePacket.stimulus.values = resampledStimulusProfile;
thePacket.stimulus.values(length(resampledStimulusProfile)+1:length(thePacket.stimulus.timebase)) = 0;


[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket, ...
    'defaultParamsInfo', defaultParamsInfo, ...
    'fminconAlgorithm','sqp');


% vlb=[-500, 1, 1, -10, -10, -10, 1]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
% vub=[0, 1000, 20, -0, -0, -0, 900];
% initialValues = [-200, 600, 5, -1, -1,0, 100];


%% to figure out gammaTau
plotFig = figure;
if strcmp(subjectID, 'group')
    thePacket.response.values = nanmean([averageResponseMatrix.Melanopsin.Contrast400; averageResponseMatrix.LMS.Contrast400; averageResponseMatrix.LightFlux.Contrast400]);
else
    thePacket.response.values = nanmean([trialStruct.Melanopsin.Contrast400; trialStruct.LMS.Contrast400; trialStruct.LightFlux.Contrast400]);
end

thePacket.response.values = thePacket.response.values(responseIndicesToExclude:end-responseIndicesToExclude);
thePacket.response.timebase = 0:1/60*1000:18.5*1000;
thePacket.response.timebase = thePacket.response.timebase(responseIndicesToExclude:end-responseIndicesToExclude);

[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket, ...
    'defaultParamsInfo', defaultParamsInfo, ...
    'vlb', vlb, 'vub',vub, ...
    'initialValues',initialValues, ...
    'fminconAlgorithm','sqp');

%close all
plotPointsToSkip = 0;
%axes1 = axes('Parent', subplotHandle);


plot(thePacket.response.timebase(1:end-plotPointsToSkip) - 1000, thePacket.response.values(1:end-plotPointsToSkip), 'Color', 'k', 'DisplayName', 'Average Response'); hold on;
plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'Color', 'r', 'DisplayName', 'Model Fit')
ylim([-0.8 0.1])
xlim([0 17*1000])
xlabel('Time (s)')
ylabel('Pupil Area (% Change)')
fprintf(' <strong>Fitting combined response </strong>\n');
temporalFit.paramPrint(paramsFit);
fprintf('\n')

transientParams = paramsFit;
transientParams.paramMainMatrix(5) = 0;
transientParams.paramMainMatrix(6) = 0;

[ modelResponseStruct ] = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Transient Component');

sustainedParams = paramsFit;
sustainedParams.paramMainMatrix(4) = 0;
sustainedParams.paramMainMatrix(6) = 0;

[ modelResponseStruct ] = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Sustained Component');


persistentParams = paramsFit;
persistentParams.paramMainMatrix(5) = 0;
persistentParams.paramMainMatrix(4) = 0;


[ modelResponseStruct ] = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Persistent Component');


title('Combined Response');
legend('show', 'Location', 'SouthEast');

%% for each stimulus
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

% use comibned response to determine both gamma parameters
vlb=[-500, paramsFit.paramMainMatrix(2), 1, -10, -10, -10, paramsFit.paramMainMatrix(7)]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, paramsFit.paramMainMatrix(2), 20, -0, -0, -0, paramsFit.paramMainMatrix(7)];
initialValues = [-200, paramsFit.paramMainMatrix(2), 5, -1, -1,0, paramsFit.paramMainMatrix(7)];

% use combined response to determine motor plant gamma, and use persistent
% gamma gleaned from group average response
vlb=[-500, paramsFit.paramMainMatrix(2), 1, -10, -10, -10, 194.478]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, paramsFit.paramMainMatrix(2), 20, -0, -0, -0, 194.478];
initialValues = [-200, paramsFit.paramMainMatrix(2), 5, -1, -1,0, 194.478];

% use combined response to determine motor plant gamma, and use persistent
% gamma gleaned from average parameter across stimulus conditions for the
% group average
vlb=[-500, paramsFit.paramMainMatrix(2), 1, -10, -10, -10, 313.7846]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, paramsFit.paramMainMatrix(2), 20, -0, -0, -0, 313.7846];
initialValues = [-200, paramsFit.paramMainMatrix(2), 5, -1, -1,0, 313.7846];

% after fixing the persistent gamma, search across all values. we'll
% average these values together in a second fit
vlb=[-500, 1, 1, -10, -10, -10, 313.7846]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, 1000, 20, -0, -0, -0, 313.7846];
initialValues = [-200, 500, 5, -1, -1,0, 313.7846];

% just search for both gammas
% vlb=[-500, 1, 1, -10, -10, -10, 1]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
% vub=[0, 1000, 20, -0, -0, -0, 1000];
% initialValues = [-200, 500, 5, -1, -1,0, 500];

plotFig = figure;
for ii = 1:length(stimuli)
    subplotHandle = subplot(1,3,ii); hold on;
    offComponent = false;
    
    if strcmp(subjectID, 'group')
        thePacket.response.values = nanmean(averageResponseMatrix.(stimuli{ii}).Contrast400);
    else
        thePacket.response.values = nanmean(trialStruct.(stimuli{ii}).Contrast400);
    end
    thePacket.response.values = thePacket.response.values(responseIndicesToExclude:end-responseIndicesToExclude);
    thePacket.response.timebase = 0:1/60*1000:18.5*1000;
    thePacket.response.timebase = thePacket.response.timebase(responseIndicesToExclude:end-responseIndicesToExclude);
    
    
    
    [paramsFit.(stimuli{ii}),fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'vlb', vlb, 'vub',vub, ...
        'initialValues',initialValues, ...
        'fminconAlgorithm','sqp');
    
    %close all
    plotPointsToSkip = 0;
    %axes1 = axes('Parent', subplotHandle);
    
    
    plot(thePacket.response.timebase(1:end-plotPointsToSkip) - 1000, thePacket.response.values(1:end-plotPointsToSkip), 'Color', 'k', 'DisplayName', 'Average Response'); hold on;
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'Color', 'r', 'DisplayName', 'Model Fit')
    ylim([-0.8 0.1])
    xlim([0 17*1000])
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change)')
    
    fprintf(' <strong>Fitting %s response </strong>\n', stimuli{ii});
    temporalFit.paramPrint(paramsFit.(stimuli{ii}));
    fprintf('\n');
    transientParams = paramsFit.(stimuli{ii});
    transientParams.paramMainMatrix(5) = 0;
    transientParams.paramMainMatrix(6) = 0;
    
    [ modelResponseStruct ] = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Transient Component');
    
    sustainedParams = paramsFit.(stimuli{ii});
    sustainedParams.paramMainMatrix(4) = 0;
    sustainedParams.paramMainMatrix(6) = 0;
    
    [ modelResponseStruct ] = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Sustained Component');
    
    
    persistentParams = paramsFit.(stimuli{ii});
    persistentParams.paramMainMatrix(5) = 0;
    persistentParams.paramMainMatrix(4) = 0;
    
    
    [ modelResponseStruct ] = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Persistent Component');
    
    
    title(stimuli{ii});
    legend('show', 'Location', 'SouthEast');
end

set(gcf, 'Position', [144 558 1621 420])

%% for each stimulus
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

% use comibned response to determine both gamma parameters
vlb=[-500, paramsFit.paramMainMatrix(2), 1, -10, -10, -10, paramsFit.paramMainMatrix(7)]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, paramsFit.paramMainMatrix(2), 20, -0, -0, -0, paramsFit.paramMainMatrix(7)];
initialValues = [-200, paramsFit.paramMainMatrix(2), 5, -1, -1,0, paramsFit.paramMainMatrix(7)];

% use combined response to determine motor plant gamma, and use persistent
% gamma gleaned from group average response
vlb=[-500, paramsFit.paramMainMatrix(2), 1, -10, -10, -10, 194.478]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, paramsFit.paramMainMatrix(2), 20, -0, -0, -0, 194.478];
initialValues = [-200, paramsFit.paramMainMatrix(2), 5, -1, -1,0, 194.478];

% use combined response to determine motor plant gamma, and use persistent
% gamma gleaned from average parameter across stimulus conditions for the
% group average
vlb=[-500, mean([paramsFit.Melanopsin.paramMainMatrix(2), paramsFit.LMS.paramMainMatrix(2), paramsFit.LightFlux.paramMainMatrix(2)]), 1, -10, -10, -10, 313.7846]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, mean([paramsFit.Melanopsin.paramMainMatrix(2), paramsFit.LMS.paramMainMatrix(2), paramsFit.LightFlux.paramMainMatrix(2)]), 20, -0, -0, -0, 313.7846];
initialValues = [-200, mean([paramsFit.Melanopsin.paramMainMatrix(2), paramsFit.LMS.paramMainMatrix(2), paramsFit.LightFlux.paramMainMatrix(2)]), 5, -1, -1,0, 313.7846];

% just search for both gammas
% vlb=[-500, 1, 1, -10, -10, -10, 1]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
% vub=[0, 1000, 20, -0, -0, -0, 1000];
% initialValues = [-200, 500, 5, -1, -1,0, 500];

plotFig = figure;
for ii = 1:length(stimuli)
    subplotHandle = subplot(1,3,ii); hold on;
    offComponent = false;
    
    if strcmp(subjectID, 'group')
        thePacket.response.values = nanmean(averageResponseMatrix.(stimuli{ii}).Contrast400);
    else
        thePacket.response.values = nanmean(trialStruct.(stimuli{ii}).Contrast400);
    end
    thePacket.response.values = thePacket.response.values(responseIndicesToExclude:end-responseIndicesToExclude);
    thePacket.response.timebase = 0:1/60*1000:18.5*1000;
    thePacket.response.timebase = thePacket.response.timebase(responseIndicesToExclude:end-responseIndicesToExclude);
    
    
    
    [paramsFit.(stimuli{ii}),fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'vlb', vlb, 'vub',vub, ...
        'initialValues',initialValues, ...
        'fminconAlgorithm','sqp');
    
    %close all
    plotPointsToSkip = 0;
    %axes1 = axes('Parent', subplotHandle);
    
    
    plot(thePacket.response.timebase(1:end-plotPointsToSkip) - 1000, thePacket.response.values(1:end-plotPointsToSkip), 'Color', 'k', 'DisplayName', 'Average Response'); hold on;
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'Color', 'r', 'DisplayName', 'Model Fit')
    ylim([-0.8 0.1])
    xlim([0 17*1000])
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change)')
    
    fprintf(' <strong>Fitting %s response </strong>\n', stimuli{ii});
    temporalFit.paramPrint(paramsFit.(stimuli{ii}));
    fprintf('\n');
    transientParams = paramsFit.(stimuli{ii});
    transientParams.paramMainMatrix(5) = 0;
    transientParams.paramMainMatrix(6) = 0;
    
    [ modelResponseStruct ] = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Transient Component');
    
    sustainedParams = paramsFit.(stimuli{ii});
    sustainedParams.paramMainMatrix(4) = 0;
    sustainedParams.paramMainMatrix(6) = 0;
    
    [ modelResponseStruct ] = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Sustained Component');
    
    
    persistentParams = paramsFit.(stimuli{ii});
    persistentParams.paramMainMatrix(5) = 0;
    persistentParams.paramMainMatrix(4) = 0;
    
    
    [ modelResponseStruct ] = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Persistent Component');
    
    
    title(stimuli{ii});
    legend('show', 'Location', 'SouthEast');
end

set(gcf, 'Position', [144 558 1621 420])