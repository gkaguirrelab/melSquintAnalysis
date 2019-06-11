temporalFit = tfeDynamicNormalization('verbosity','none'); % Construct the model object

load('/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat');
plotFig = figure;
responseIndicesToExclude = 40;
offComponent = true;

% TPUP params
stimulusStruct = makeStimulusStruct;
thePacket.stimulus = stimulusStruct;
thePacket.stimulus = stimulusStruct;
thePacket.response = modelResponseStruct;
thePacket.kernel = []; thePacket.metaData = [];

thePacket.response.values = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
thePacket.response.values = thePacket.response.values(responseIndicesToExclude:end-responseIndicesToExclude);
thePacket.response.values = (thePacket.response.values - nanmean(thePacket.response.values));
thePacket.response.timebase = 0:1/60*1000:18.5*1000;
thePacket.response.timebase = thePacket.response.timebase(responseIndicesToExclude:end-responseIndicesToExclude);

[~,vlbParams,vubParams] = temporalFit.defaultParams;
vlbParams.paramMainMatrix = [-1, 1, 0, 1, 0.01, 0.1, -1000];
vubParams.paramMainMatrix = [0, 2000, 10, 1, 1, 0.1, 0];
initialParams.paramMainMatrix = [-.05, 600, 0, 2, 0.05, 0.1, -200];
%% Fit the simulated data
[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket,...
    'vlbParams', vlbParams, 'vubParams',vubParams, ...
    'fminconAlgorithm','sqp', ...
    'defaultParamsInfo', defaultParamsInfo);

plot(thePacket.response.timebase, thePacket.response.values);
hold on;
plot(modelResponseStruct.timebase, modelResponseStruct.values);

temporalFit.paramPrint(paramsFit);
