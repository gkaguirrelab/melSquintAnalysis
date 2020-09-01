function summarizeTPUP(persistentGammaTau, varargin)
%% Parse Input
p = inputParser; p.KeepUnmatched = true;

p.addParameter('savePath', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'TPUP'), @ischar);
p.addParameter('saveName', 'TPUPParams.csv', @ischar);
p.addParameter('experimentName',[]);
p.addParameter('protocol','SquintToPulse', @ischar);
p.addParameter('contrast',400, @isnumeric);


p.parse(varargin{:});

%% Set up CSV File
if strcmp(p.Results.protocol, 'SquintToPulse')
    csvFile = fullfile(p.Results.savePath, p.Results.saveName);
else
    csvFile = fullfile(p.Results.savePath, p.Results.protocol, p.Results.experimentName, p.Results.saveName);

end
cellArray = {'SubjectID', 'LMS Delay', 'LMS Pupil Gamma', 'LMS Persistent Gamma', 'LMS Exponential Tau', 'LMS Transient Amplitude', 'LMS Sustained Amplitude', 'LMS Persistent Amplitude','Melanopsin Delay', 'Melanopsin Pupil Gamma', 'Melanopsin Persistent Gamma', 'Melanopsin Exponential Tau', 'Melanopsin Transient Amplitude', 'Melanopsin Sustained Amplitude', 'Melanopsin Persistent Amplitude', 'Light Flux Delay', 'Light Flux Pupil Gamma', 'Light Flux Persistent Gamma', 'Light Flux Exponential Tau', 'Light Flux Transient Amplitude', 'Light Flux Sustained Amplitude', 'Light Flux Persistent Amplitude'};


rowNumber = 2;
%% Get the subject list
if strcmp(p.Results.protocol, 'SquintToPulse')
    dataBasePath = getpref('melSquintAnalysis','melaDataPath');
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));    
    subjectIDs = fieldnames(subjectListStruct);
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    subjectListStruct = getDeuteranopeSubjectStruct;
    subjectIDs = fieldnames(subjectListStruct.experiment1);
end

trialStructPath = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/', p.Results.protocol, 'DataFiles');


%% Loop over subjects, fitting TPUP
for ss = 1:length(subjectIDs)
    % load up trialStruct for the given subject
    load(fullfile(trialStructPath, subjectIDs{ss}, p.Results.experimentName, 'trialStruct_radiusSmoothed.mat'));
    if strcmp(p.Results.protocol, 'SquintToPulse')
        LMSResponse = nanmean(trialStruct.LMS.(['Contrast', num2str(p.Results.contrast)]));
    elseif strcmp(p.Results.protocol, 'Deuteranopes')
        LMSResponse = nanmean(trialStruct.LS.(['Contrast', num2str(p.Results.contrast)]));
        
    end
    MelanopsinResponse = nanmean(trialStruct.Melanopsin.(['Contrast', num2str(p.Results.contrast)]));
    LightFluxResponse = nanmean(trialStruct.LightFlux.(['Contrast', num2str(p.Results.contrast)]));
    
    
    modeledResponses = fitTPUP('', 'methodForDeterminingPersistentGammaTau', persistentGammaTau, 'LMSResponse', LMSResponse, 'LightFluxResponse', LightFluxResponse, 'MelanopsinResponse', MelanopsinResponse, 'saveName', [subjectIDs{ss}, 'Contrast', num2str(p.Results.contrast)], 'protocol', p.Results.protocol, 'experimentName', p.Results.experimentName);
    close all
    cellArray{rowNumber, 1} = subjectIDs{ss};
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