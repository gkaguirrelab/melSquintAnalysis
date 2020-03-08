function [ passStatus, failReason ] = evaluateValidationsPerSession(subjectID, sessionID)

% get sessionID, if only the number was provided
if isnumeric(sessionID)
    
    sessionID = getSessionID(subjectID, sessionID);
    
end

% load the direction objects, which contain the validations
pathToDirectionObjects = fullfile(getpref('melSquintAnalysis', 'melaDataPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DirectionObjects', subjectID, sessionID);
load(fullfile(pathToDirectionObjects, 'MaxLMSDirection.mat'));
load(fullfile(pathToDirectionObjects, 'MaxMelDirection.mat'));
load(fullfile(pathToDirectionObjects, 'LightFluxDirection.mat'));

% create failStatus variable, which is 0 unless a reason for failure comes
% up
failStatus = 0;
failReason = [];

% extract the validations from the direction object
whichValidations = {'postcorrection', 'postexperiment'};

for ii = 1:length(whichValidations)
    LMSValidation = summarizeValidation(MaxLMSDirection, 'whichValidationPrefix', whichValidations{ii}, 'plot', 'off');
    
    [ LMSPassStatus.(whichValidations{ii})] =  applyValidationExclusionCriteria(LMSValidation, MaxLMSDirection);
    
    if LMSPassStatus.(whichValidations{ii}) == 0
        failStatus = 1;
        failReason{end+1} = ['LMS validation failed ', whichValidations{ii}];
    end
    
    
     MelValidation = summarizeValidation(MaxMelDirection, 'whichValidationPrefix', whichValidations{ii}, 'plot', 'off');
    
    [ MelPassStatus.(whichValidations{ii})] =  applyValidationExclusionCriteria(MelValidation, MaxMelDirection);
    
    if MelPassStatus.(whichValidations{ii}) == 0
        failStatus = 1;
        failReason{end+1} = ['Mel validation failed ', whichValidations{ii}];
    end
    
     LightFluxValidation = summarizeValidation(LightFluxDirection, 'whichValidationPrefix', whichValidations{ii}, 'plot', 'off');
    
    [ LightFluxPassStatus.(whichValidations{ii})] =  applyValidationExclusionCriteria(LightFluxValidation, LightFluxDirection);
    
    if LightFluxPassStatus.(whichValidations{ii}) == 0
        failStatus = 1;
        failReason{end+1} = ['LightFlux validation failed ', whichValidations{ii}];
    end
    
    if median(LightFluxValidation.backgroundLuminance) > 254.6685 || median(LightFluxValidation.backgroundLuminance) < 160.685
        failStatus = 1;
        failReason{end+1} = ['Light flux outside of background luminance range ', whichValidations{ii}];
    end
    
end

% see if anything failed
if failStatus ~= 0
    passStatus = 0;
else
    passStatus = 1;
end

end

