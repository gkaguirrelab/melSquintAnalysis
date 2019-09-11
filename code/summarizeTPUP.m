function summarizeTPUP(subjectList, persistentGammaTau)

csvFile = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP', 'TPUPParams.csv');
cellArray = {'SubjectID', 'LMS Delay', 'LMS Pupil Gamma', 'LMS Persistent Gamma', 'LMS Exponential Tau', 'LMS Transient Amplitude', 'LMS Sustained Amplitude', 'LMS Persistent Amplitude','Melanopsin Delay', 'Melanopsin Pupil Gamma', 'Melanopsin Persistent Gamma', 'Melanopsin Exponential Tau', 'Melanopsin Transient Amplitude', 'Melanopsin Sustained Amplitude', 'Melanopsin Persistent Amplitude', 'Light Flux Delay', 'Light Flux Pupil Gamma', 'Light Flux Persistent Gamma', 'Light Flux Exponential Tau', 'Light Flux Transient Amplitude', 'Light Flux Sustained Amplitude', 'Light Flux Persistent Amplitude'};


rowNumber = 2;
for ss = 1:length(subjectList)
    modeledResponses = fitTPUP(subjectList{ss}, 'methodForDeterminingPersistentGammaTau', persistentGammaTau);
    close all
    cellArray{rowNumber, 1} = subjectList{ss};
    cellArray{rowNumber, 2} = modeledResponses.LMS.params.paramMainMatrix(1);
    cellArray{rowNumber, 3} = modeledResponses.LMS.params.paramMainMatrix(2);
    cellArray{rowNumber, 4} = modeledResponses.LMS.params.paramMainMatrix(3);
    cellArray{rowNumber, 5} = modeledResponses.LMS.params.paramMainMatrix(4);
    cellArray{rowNumber, 6} = modeledResponses.LMS.params.paramMainMatrix(5);
    cellArray{rowNumber, 7} = modeledResponses.LMS.params.paramMainMatrix(6);
    cellArray{rowNumber, 8} = modeledResponses.LMS.params.paramMainMatrix(7);
    
    cellArray{rowNumber, 9} = modeledResponses.Melanopsin.params.paramMainMatrix(1);
    cellArray{rowNumber, 10} = modeledResponses.Melanopsin.params.paramMainMatrix(2);
    cellArray{rowNumber, 11} = modeledResponses.Melanopsin.params.paramMainMatrix(3);
    cellArray{rowNumber, 12} = modeledResponses.Melanopsin.params.paramMainMatrix(4);
    cellArray{rowNumber, 13} = modeledResponses.Melanopsin.params.paramMainMatrix(5);
    cellArray{rowNumber, 14} = modeledResponses.Melanopsin.params.paramMainMatrix(6);
    cellArray{rowNumber, 15} = modeledResponses.Melanopsin.params.paramMainMatrix(7);
    
    cellArray{rowNumber, 16} = modeledResponses.LightFlux.params.paramMainMatrix(1);
    cellArray{rowNumber, 17} = modeledResponses.LightFlux.params.paramMainMatrix(2);
    cellArray{rowNumber, 18} = modeledResponses.LightFlux.params.paramMainMatrix(3);
    cellArray{rowNumber, 19} = modeledResponses.LightFlux.params.paramMainMatrix(4);
    cellArray{rowNumber, 20} = modeledResponses.LightFlux.params.paramMainMatrix(5);
    cellArray{rowNumber, 21} = modeledResponses.LightFlux.params.paramMainMatrix(6);
    cellArray{rowNumber, 22} = modeledResponses.LightFlux.params.paramMainMatrix(7);
    
    rowNumber = rowNumber + 1;
    
end

cell2csv(csvFile, cellArray);

end