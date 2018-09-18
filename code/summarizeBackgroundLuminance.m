function [ backgroundLuminanceAccumulator ] = summarizeBackgroundLuminance(sessionList)

projectName = 'melSquintAnalysis';
directionObjectsBase = fullfile(getpref(projectName, 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects');


for ss = 1:length(sessionList.ID)
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'MaxMelDirection.mat'))
    validation = summarizeValidation(MaxMelDirection, 'plot', 'off');
    if length(validation.backgroundLuminance) == 15
        backgroundLuminanceAccumulator.Mel(ss) = median(validation.backgroundLuminance(6:15));
    else
        backgroundLuminanceAccumulator.Mel(ss) = NaN;
    end
    
    
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'MaxLMSDirection.mat'))
    validation = summarizeValidation(MaxLMSDirection, 'plot', 'off');
    if length(validation.backgroundLuminance) == 15
        
        backgroundLuminanceAccumulator.LMS(ss) = median(validation.backgroundLuminance(6:15));
    else
        backgroundLuminanceAccumulator.LMS(ss) = NaN;
    end
    
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'LightFluxDirection.mat'))
    validation = summarizeValidation(LightFluxDirection, 'plot', 'off');
    if length(validation.backgroundLuminance) == 15
        
        backgroundLuminanceAccumulator.LightFlux(ss) = median(validation.backgroundLuminance(6:15));
    else
        backgroundLuminanceAccumulator.LightFlux(ss) = NaN;
    end
end

figure;
subplot(1,3,1)
histogram(backgroundLuminanceAccumulator.LMS, 'FaceColor', 'black')
title('LMS')
xlabel('Luminance (cd/m2)')
ylabel('Frequency')

subplot(1,3,2)
histogram(backgroundLuminanceAccumulator.Mel, 'FaceColor', 'blue')
title('Melanopsin')
xlabel('Luminance (cd/m2)')

subplot(1,3,3)
histogram(backgroundLuminanceAccumulator.LightFlux, 'FaceColor', 'yellow')
title('Light Flux')
xlabel('Luminance (cd/m2)')
end
