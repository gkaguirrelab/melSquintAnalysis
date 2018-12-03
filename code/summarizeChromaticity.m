function [ chromaticityAccumulator ] = summarizeChromaticity(sessionList)

projectName = 'melSquintAnalysis';
directionObjectsBase = fullfile(getpref(projectName, 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects');


for ss = 1:length(sessionList.ID)
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'MaxMelDirection.mat'))
    [ XYChromaticity ] = calculateChromaticity(MaxMelDirection, 'whichValidation', 'postcorrection');
    chromaticityAccumulator.Mel(ss,1) = XYChromaticity(1);
    chromaticityAccumulator.Mel(ss,2) = XYChromaticity(2);
    
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'MaxLMSDirection.mat'))
    [ XYChromaticity ] = calculateChromaticity(MaxLMSDirection, 'whichValidation', 'postcorrection');
    chromaticityAccumulator.LMS(ss,1) = XYChromaticity(1);
    chromaticityAccumulator.LMS(ss,2) = XYChromaticity(2);
    
    load(fullfile(directionObjectsBase, sessionList.ID{ss}, sessionList.date{ss}, 'LightFluxDirection.mat'))
    [ XYChromaticity ] = calculateChromaticity(LightFluxDirection, 'whichValidation', 'postcorrection');
    chromaticityAccumulator.LightFlux(ss,1) = XYChromaticity(1);
    chromaticityAccumulator.LightFlux(ss,2) = XYChromaticity(2);
end

figure;
hold on
plot(chromaticityAccumulator.LightFlux(:,1), chromaticityAccumulator.LightFlux(:,2), 'o', 'Color', 'y')
plot(chromaticityAccumulator.Mel(:,1), chromaticityAccumulator.Mel(:,2), 'o', 'Color', 'c')
plot(chromaticityAccumulator.LMS(:,1), chromaticityAccumulator.LMS(:,2), 'o', 'Color', 'k')


end
