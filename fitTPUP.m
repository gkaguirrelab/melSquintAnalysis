thePacket.response.values = nanmean(averageResponseMatrix.Melanopsin.Contrast400);
thePacket.response.timebase = 0:1/60*1000:18.5*1000;

stimulusStruct = makeStimulusStruct;
thePacket.stimulus = stimulusStruct;

thePacket.kernel = [];
thePacket.metaData = [];

defaultParamsInfo.nInstances = 1;

% Construct the model object
temporalFit = tfeTPUP('verbosity','full');

vlb=[-500, 150, 1, -1000, -1000, -1000]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
vub=[0, 400, 20, -0, -0, -0];
initialValues = [-200, 350, 5, -100, -100, -100];

[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket, ...
    'defaultParamsInfo', defaultParamsInfo, ...
    'vlb', vlb, 'vub',vub, ...
    'initialValues',initialValues);

figure; plot(thePacket.response.timebase, thePacket.response.values); hold on; plot(modelResponseStruct.timebase, modelResponseStruct.values)