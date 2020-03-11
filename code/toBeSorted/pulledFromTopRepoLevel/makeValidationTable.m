function makeValidationTable()

dataBasePath = getpref('melSquintAnalysis','melaDataPath');
load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

validationTable = {};
sessionCounter = 1;
for ss = 1:length(subjectIDs)
    sessions = subjectListStruct.(subjectIDs{ss});
    for session = 1:length(sessions)
        
        % first column: subjectID
        validationTable{sessionCounter, 1} = subjectIDs{ss};
        
        % second colum: session ID
        validationTable{sessionCounter, 2} = sessions{session};
        
        % Melanopsin summary:
        load(fullfile(getpref('melSquintAnalysis', 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects', subjectIDs{ss}, sessions{session}, 'MaxMelDirection.mat'));
        MelValidation = summarizeValidation(MaxMelDirection, 'validationIndices', 6:15, 'plot', 'off');        
        % third column: Melanopsin contrast
        validationTable{sessionCounter, 3} = sprintf('%4.2f%%', mean(MelValidation.MelanopsinContrast)*100);
        % fourth column: S cone contrast
        validationTable{sessionCounter, 4} = sprintf('%4.2f%%', mean(MelValidation.SMinusLMContrast)*100);
        % fifth column: L-M contrast
        validationTable{sessionCounter, 5} = sprintf('%4.2f%%', mean(MelValidation.LMinusMContrast)*100);
        % sixth column: LMS contrast
        validationTable{sessionCounter, 6} = sprintf('%4.2f%%', mean(MelValidation.LMSContrast)*100);
        % seventh column: background luminance
        validationTable{sessionCounter, 7} = sprintf('%4.2f', mean(MelValidation.backgroundLuminance));
        % eighth column: background chromaticity
        chromaticity = calculateChromaticity(MaxMelDirection, 'whichValidation', {'postcorrection', 'postexperiment'});
        validationTable{sessionCounter, 8} = sprintf('%4.2f, %4.2f', chromaticity(1), chromaticity(2));
        
        % LMS summary:
        load(fullfile(getpref('melSquintAnalysis', 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects', subjectIDs{ss}, sessions{session}, 'MaxLMSDirection.mat'));
        LMSValidation = summarizeValidation(MaxLMSDirection, 'validationIndices', 6:15, 'plot', 'off');
        % nineth column: LMS contrast
        validationTable{sessionCounter, 9} = sprintf('%4.2f%%', mean(LMSValidation.LMSContrast)*100);
        % tenth column: S cone contrast
        validationTable{sessionCounter, 10} = sprintf('%4.2f%%', mean(LMSValidation.SMinusLMContrast)*100);
        % eleventh column: L-M contrast
        validationTable{sessionCounter, 11} = sprintf('%4.2f%%', mean(LMSValidation.LMinusMContrast)*100);
        % twelfth column: melanopsin contrast
        validationTable{sessionCounter, 12} = sprintf('%4.2f%%', mean(LMSValidation.MelanopsinContrast)*100);
        % thirteenth column: background luminance
        validationTable{sessionCounter, 13} = sprintf('%4.2f', mean(LMSValidation.backgroundLuminance));
        % fourteenth column: background chromaticity
        chromaticity = calculateChromaticity(MaxLMSDirection, 'whichValidation', {'postcorrection', 'postexperiment'});
        validationTable{sessionCounter, 14} = sprintf('%4.2f, %4.2f', chromaticity(1), chromaticity(2));
        
        % Light flux summary:
        load(fullfile(getpref('melSquintAnalysis', 'melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DirectionObjects', subjectIDs{ss}, sessions{session}, 'LightFluxDirection.mat'));
        LightFluxValidation = summarizeValidation(LightFluxDirection, 'validationIndices', 6:15, 'plot', 'off');        
        % fifteenth column: melanopsin contrast
        validationTable{sessionCounter, 15} = sprintf('%4.2f%%', mean(LightFluxValidation.MelanopsinContrast)*100);
        % sixteenth column: LMS contrast
        validationTable{sessionCounter, 16} = sprintf('%4.2f%%', mean(LightFluxValidation.LMSContrast)*100);
        % seventeenth column: S cone contrast
        validationTable{sessionCounter, 17} = sprintf('%4.2f%%', mean(LightFluxValidation.SMinusLMContrast)*100);
        % eigteenth column: L - M cone contrast
        validationTable{sessionCounter, 18} = sprintf('%4.2f%%', mean(LightFluxValidation.LMinusMContrast)*100);
        % nineteenth column: background luminance
        validationTable{sessionCounter, 19} = sprintf('%4.2f', mean(LightFluxValidation.backgroundLuminance));
        % twentieth column: background chromaticity
        chromaticity = calculateChromaticity(LightFluxDirection, 'whichValidation', {'postcorrection', 'postexperiment'});
        validationTable{sessionCounter, 20} = sprintf('%4.2f, %4.2f', chromaticity(1), chromaticity(2));

        sessionCounter = sessionCounter + 1;
        
    end
    
end

validationTable = array2table(validationTable);
validationTable.Properties.VariableNames = {'SubjectID', 'SessionID', 'MelanopsinContrast_Melanopsin', 'SConeContrast_Melanopsin', 'LMinusMContrast_Melanopsin', 'LMSContrast_Melanopsin', 'BackgroundLuminance_Melanopsin', 'Chromaticityv', 'LMSContrast_LMS', 'SConeContrast_LMS', 'LMinusMContrast_LMS', 'MelanopsinContrast_LMS', 'BackgroundLuminance_LMS', 'Chromaticity_LMS', 'LMSContrast_LightFlux', 'MelanopsinContrast_LightFlux', 'SConeContrast_LightFlux', 'LMinusMContrast_LightFlux', 'BackgroundLuminance_LightFlux', 'Chromaticity_LightFlux'};

writetable(validationTable, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'stimuli', 'validationsBySession.csv'));
end