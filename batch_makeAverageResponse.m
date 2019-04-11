subjectListDirs = dir(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', 'MELA*'));

subjectIDs = [];
badSubjects = {'MELA_0127', 'MELA_0168'};

for ss = 1:length(subjectListDirs)
    
   subjectIDs{ss} = subjectListDirs(ss).name;
   
end

subjectIDs = setdiff(subjectIDs, badSubjects);

for ss = 30:length(subjectIDs)
   subjectID = subjectIDs{ss};
   
   [ averageResponseStruct.(subjectID), trialStruct ] = makeSubjectAverageResponses(subjectID, 'debugNumberOfNaNValuesPerTrial', true, 'blinkBufferFrames', [0 0], 'trialNaNThreshold', 2);
    
end

%% Do some summary plotting
contrasts = {'100', '200', '400'};
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

for cc = 1:length(contrasts)
    for stimulus = 1:length(stimuli)
        averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}]) = [];
    end
end

for cc = 1:length(contrasts)
    for stimulus = 1:length(stimuli)
        for ss = 1:length(subjectIDs)
            clear trialStruct
               subjectID = subjectIDs{ss};

            load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', subjectID, 'trialStruct.mat'));
            for tt = 1:length(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(1,:))
                averageResponse(tt) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{cc})])(:,tt));
            end

            
            averageResponseMatrix.(stimuli{stimulus}).(['Contrast', contrasts{cc}])(ss,:) = averageResponse;
        end
    end
end