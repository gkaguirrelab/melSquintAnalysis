function summarizeTPUP_individualDifferences(pooledSessionStruct)
% Routine to fit the TPUP model to average pupil responses for each subject
% across both dates of testing.

% This routine loops over each subject and each date of testing to fit the
% TPUP model to average pupil response for each stimulus type. Prior to
% fitting each individual subject, the routine fits the group average
% response for at each contrast level to fit the 'persistentGammaTau'
% parameter, which is then locked for all individual subject fits for that
% contrast level. The results are stored in the form of plots of fits as
% well as a CSV file of all individual fit parameters.

contrasts = {100, 200, 400};
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};

cellArray = {'SubjectID', 'TestingDay', 'Contrast', 'LMS Delay', 'LMS Pupil Gamma', 'LMS Persistent Gamma', 'LMS Exponential Tau', 'LMS Transient Amplitude', 'LMS Sustained Amplitude', 'LMS Persistent Amplitude','Melanopsin Delay', 'Melanopsin Pupil Gamma', 'Melanopsin Persistent Gamma', 'Melanopsin Exponential Tau', 'Melanopsin Transient Amplitude', 'Melanopsin Sustained Amplitude', 'Melanopsin Persistent Amplitude', 'Light Flux Delay', 'Light Flux Pupil Gamma', 'Light Flux Persistent Gamma', 'Light Flux Exponential Tau', 'Light Flux Transient Amplitude', 'Light Flux Sustained Amplitude', 'Light Flux Persistent Amplitude'};


savePath = fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'TPUP');

%% Get persistent gamma tau for the group
% make group average

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        groupMeanResponse.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = nanmean(pooledSessionStruct.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
    end
end

for contrast = 1:length(contrasts)
    groupModeledResponses.(['Contrast', num2str(contrasts{contrast})]) = fitTPUP('', 'methodForDeterminingPersistentGammaTau', 'fitToIndividualSubject', 'savePath', savePath, 'saveName', ['combinedGroup_contrast', num2str(contrasts{contrast})], ...
        'LMSResponse', groupMeanResponse.LMS.(['Contrast', num2str(contrasts{contrast})]), ...
        'MelanopsinResponse', groupMeanResponse.Melanopsin.(['Contrast', num2str(contrasts{contrast})]), ...
        'LightFluxResponse', groupMeanResponse.LightFlux.(['Contrast', num2str(contrasts{contrast})]));
    
end

%% Fit each subject, across each testing day
subjectIDs = pooledSessionStruct.subjectIDs;
rowNumber = 2;
for ss = 1:length(subjectIDs)
        for contrast = 1:length(contrasts)
            modeledResponses = fitTPUP('', 'methodForDeterminingPersistentGammaTau', groupModeledResponses.(['Contrast', num2str(contrasts{contrast})]).Melanopsin.params.paramMainMatrix(3), 'savePath', savePath, 'saveName', [subjectIDs{ss}, '_combinedMean_Contrast', num2str(contrasts{contrast})], ...
                'LMSResponse', pooledSessionStruct.combinedMean.LMS.(['Contrast', num2str(contrasts{contrast})])(ss,:), ...
                'MelanopsinResponse', pooledSessionStruct.combinedMean.Melanopsin.(['Contrast', num2str(contrasts{contrast})])(ss,:), ...
                'LightFluxResponse', pooledSessionStruct.combinedMean.LightFlux.(['Contrast', num2str(contrasts{contrast})])(ss,:))
                
            close all
            cellArray{rowNumber, 1} = subjectIDs{ss};
            cellArray{rowNumber, 2} = 'combinedMean';
            cellArray{rowNumber, 3} = contrasts{contrast};

            cellArray{rowNumber, 4} = modeledResponses.LMS.params.paramMainMatrix(1);
            cellArray{rowNumber, 5} = modeledResponses.LMS.params.paramMainMatrix(2);
            cellArray{rowNumber, 6} = modeledResponses.LMS.params.paramMainMatrix(3);
            cellArray{rowNumber, 7} = modeledResponses.LMS.params.paramMainMatrix(4);
            cellArray{rowNumber, 8} = modeledResponses.LMS.params.paramMainMatrix(5);
            cellArray{rowNumber, 9} = modeledResponses.LMS.params.paramMainMatrix(6);
            cellArray{rowNumber, 10} = modeledResponses.LMS.params.paramMainMatrix(7);
            
            cellArray{rowNumber, 11} = modeledResponses.Melanopsin.params.paramMainMatrix(1);
            cellArray{rowNumber, 12} = modeledResponses.Melanopsin.params.paramMainMatrix(2);
            cellArray{rowNumber, 13} = modeledResponses.Melanopsin.params.paramMainMatrix(3);
            cellArray{rowNumber, 14} = modeledResponses.Melanopsin.params.paramMainMatrix(4);
            cellArray{rowNumber, 15} = modeledResponses.Melanopsin.params.paramMainMatrix(5);
            cellArray{rowNumber, 16} = modeledResponses.Melanopsin.params.paramMainMatrix(6);
            cellArray{rowNumber, 17} = modeledResponses.Melanopsin.params.paramMainMatrix(7);
            
            cellArray{rowNumber, 18} = modeledResponses.LightFlux.params.paramMainMatrix(1);
            cellArray{rowNumber, 19} = modeledResponses.LightFlux.params.paramMainMatrix(2);
            cellArray{rowNumber, 20} = modeledResponses.LightFlux.params.paramMainMatrix(3);
            cellArray{rowNumber, 21} = modeledResponses.LightFlux.params.paramMainMatrix(4);
            cellArray{rowNumber, 22} = modeledResponses.LightFlux.params.paramMainMatrix(5);
            cellArray{rowNumber, 23} = modeledResponses.LightFlux.params.paramMainMatrix(6);
            cellArray{rowNumber, 24} = modeledResponses.LightFlux.params.paramMainMatrix(7);
            
            rowNumber = rowNumber + 1;
            
            for dd = 1:2
            
            modeledResponses = fitTPUP('', 'methodForDeterminingPersistentGammaTau', groupModeledResponses.(['Contrast', num2str(contrasts{contrast})]).Melanopsin.params.paramMainMatrix(3), 'savePath', savePath, 'saveName', [subjectIDs{ss}, '_day', num2str(dd), '_Contrast', num2str(contrasts{contrast})], ...
                'LMSResponse', pooledSessionStruct.(['day', num2str(dd)]).LMS.(['Contrast', num2str(contrasts{contrast})])(ss,:), ...
                'MelanopsinResponse', pooledSessionStruct.(['day', num2str(dd)]).Melanopsin.(['Contrast', num2str(contrasts{contrast})])(ss,:), ...
                'LightFluxResponse', pooledSessionStruct.(['day', num2str(dd)]).LightFlux.(['Contrast', num2str(contrasts{contrast})])(ss,:))
                
            close all
            cellArray{rowNumber, 1} = subjectIDs{ss};
            cellArray{rowNumber, 2} = dd;
            cellArray{rowNumber, 3} = contrasts{contrast};

            cellArray{rowNumber, 4} = modeledResponses.LMS.params.paramMainMatrix(1);
            cellArray{rowNumber, 5} = modeledResponses.LMS.params.paramMainMatrix(2);
            cellArray{rowNumber, 6} = modeledResponses.LMS.params.paramMainMatrix(3);
            cellArray{rowNumber, 7} = modeledResponses.LMS.params.paramMainMatrix(4);
            cellArray{rowNumber, 8} = modeledResponses.LMS.params.paramMainMatrix(5);
            cellArray{rowNumber, 9} = modeledResponses.LMS.params.paramMainMatrix(6);
            cellArray{rowNumber, 10} = modeledResponses.LMS.params.paramMainMatrix(7);
            
            cellArray{rowNumber, 11} = modeledResponses.Melanopsin.params.paramMainMatrix(1);
            cellArray{rowNumber, 12} = modeledResponses.Melanopsin.params.paramMainMatrix(2);
            cellArray{rowNumber, 13} = modeledResponses.Melanopsin.params.paramMainMatrix(3);
            cellArray{rowNumber, 14} = modeledResponses.Melanopsin.params.paramMainMatrix(4);
            cellArray{rowNumber, 15} = modeledResponses.Melanopsin.params.paramMainMatrix(5);
            cellArray{rowNumber, 16} = modeledResponses.Melanopsin.params.paramMainMatrix(6);
            cellArray{rowNumber, 17} = modeledResponses.Melanopsin.params.paramMainMatrix(7);
            
            cellArray{rowNumber, 18} = modeledResponses.LightFlux.params.paramMainMatrix(1);
            cellArray{rowNumber, 19} = modeledResponses.LightFlux.params.paramMainMatrix(2);
            cellArray{rowNumber, 20} = modeledResponses.LightFlux.params.paramMainMatrix(3);
            cellArray{rowNumber, 21} = modeledResponses.LightFlux.params.paramMainMatrix(4);
            cellArray{rowNumber, 22} = modeledResponses.LightFlux.params.paramMainMatrix(5);
            cellArray{rowNumber, 23} = modeledResponses.LightFlux.params.paramMainMatrix(6);
            cellArray{rowNumber, 24} = modeledResponses.LightFlux.params.paramMainMatrix(7);
            
            rowNumber = rowNumber + 1;
            
            
            
        end
        
    end
end

cell2csv(fullfile(savePath, 'TPUPParams.csv'), cellArray);

end