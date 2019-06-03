load('/Users/harrisonmcadams/Dropbox (Aguirre-Brainard Lab)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/averageResponsePlots/groupAverageMatrix.mat');
plotFig = figure;

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
responseIndicesToExclude = 40;
for ii = 1:length(stimuli)
    subplotHandle = subplot(1,3,ii); hold on;
    offComponent = false;
    
    thePacket.response.values = nanmean(averageResponseMatrix.(stimuli{ii}).Contrast400);
    thePacket.response.values = thePacket.response.values(responseIndicesToExclude:end-responseIndicesToExclude);
    thePacket.response.timebase = 0:1/60*1000:18.5*1000;
    thePacket.response.timebase = thePacket.response.timebase(responseIndicesToExclude:end-responseIndicesToExclude);
    
    stimulusStruct = makeStimulusStruct;
    thePacket.stimulus = stimulusStruct;
    
    thePacket.kernel = [];
    thePacket.metaData = [];
    
    defaultParamsInfo.nInstances = 1;
    
    % Construct the model object
    temporalFit = tfeTPUP('verbosity','full');
    
    vlb=[-500, 600, 1, -10, -10, -10]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
    if offComponent
        vlb=[-500, 150, 1, -10, -10, -10, -10]; % these boundaries are necessary to specify until we change how the delay parameter is implemented in the forward model (negative delay currently means push curve to the right). also the range of the amplitude parameters is probably much larger than we need
    end
    
    
    vub=[0, 700, 20, -0, -0, -0];
    
    if offComponent
        vub=[0, 600, 20, -0, -0, -0, -0];
    end
    
    initialValues = [-200, 700, 5, 0, -1, 0];
    if offComponent
        initialValues = [-200, 350, 5, -1, -1, -1, -1];
    end
    
    [paramsFit,fVal,modelResponseStruct] = ...
        temporalFit.fitResponse(thePacket, ...
        'defaultParamsInfo', defaultParamsInfo, ...
        'vlb', vlb, 'vub',vub, ...
        'initialValues',initialValues, ...
        'fminconAlgorithm','sqp');
    
    %close all
    plotPointsToSkip = 40;
    %axes1 = axes('Parent', subplotHandle);
    
    
    plot(thePacket.response.timebase(1:end-plotPointsToSkip) - 1000, thePacket.response.values(1:end-plotPointsToSkip), 'Color', 'k', 'DisplayName', 'Average Response'); hold on;
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'Color', 'r', 'DisplayName', 'Model Fit')
    ylim([-0.8 0.1])
    xlim([0 17*1000])
    xlabel('Time (s)')
    ylabel('Pupil Area (% Change)')
    
    temporalFit.paramPrint(paramsFit);
    
    transientParams = paramsFit;
    transientParams.paramMainMatrix(5) = 0;
    transientParams.paramMainMatrix(6) = 0;
    if offComponent
        transientParams.paramMainMatrix(7) = 0;
    end
    [ modelResponseStruct ] = temporalFit.computeResponse(transientParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Transient Component');
    
    sustainedParams = paramsFit;
    sustainedParams.paramMainMatrix(4) = 0;
    sustainedParams.paramMainMatrix(6) = 0;
    if offComponent
        sustainedParams.paramMainMatrix(7) = 0;
    end
    [ modelResponseStruct ] = temporalFit.computeResponse(sustainedParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Sustained Component');
    
    
    persistentParams = paramsFit;
    persistentParams.paramMainMatrix(5) = 0;
    persistentParams.paramMainMatrix(4) = 0;
    if offComponent
        persistentParams.paramMainMatrix(7) = 0;
    end
    
    [ modelResponseStruct ] = temporalFit.computeResponse(persistentParams, thePacket.stimulus, thePacket.kernel);
    plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Persistent Component');
    
    if offComponent
        offParams = paramsFit;
        offParams.paramMainMatrix(5) = 0;
        offParams.paramMainMatrix(4) = 0;
        offParams.paramMainMatrix(6) = 0;
        
        [ modelResponseStruct ] = temporalFit.computeResponse(offParams, thePacket.stimulus, thePacket.kernel);
        plot(modelResponseStruct.timebase(1:end-plotPointsToSkip) -1000, modelResponseStruct.values(1:end-plotPointsToSkip), 'DisplayName', 'Off Component');
    end
    title(stimuli{ii});
    legend('show', 'Location', 'SouthEast');
end

set(gcf, 'Position', [144 558 1621 420])