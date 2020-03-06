function [ discomfortRatingsStruct, subjectIDsStruct ] = loadDiscomfortRatings(varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('protocol', 'SquintToPulse' ,@isstr);
p.addParameter('experimentNumber', [] ,@isstr);

p.parse(varargin{:})



if strcmp(p.Results.protocol, 'SquintToPulse')
    % load subjectIDs
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
    
    % pre-allocate variables
    controlDiscomfort = [];
    mwaDiscomfort = [];
    mwoaDiscomfort = [];
    
    controlSubjects = [];
    mwaSubjects = [];
    mwoaSubjects = [];
    
    stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
    contrasts = {100, 200, 400};
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        end
    end
    
    % gather results
    for ss = 1:length(subjectIDs)
        
        group = linkMELAIDToGroup(subjectIDs{ss});
        
        analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss});
        fileName = 'audioTrialStruct_final.mat';
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                if strcmp(group, 'c')
                    load(fullfile(analysisBasePath, fileName));
                    controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                    controlSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwa')
                    load(fullfile(analysisBasePath, fileName));
                    mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                    mwaSubjects{end+1} = subjectIDs{ss};
                elseif strcmp(group, 'mwoa')
                    load(fullfile(analysisBasePath, fileName));
                    mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                    mwoaSubjects{end+1} = subjectIDs{ss};
                else
                    fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
                end
            end
        end
        
    end
    
    % stash results
    discomfortRatingsStruct.controls = controlDiscomfort;
    discomfortRatingsStruct.mwa = mwaDiscomfort;
    discomfortRatingsStruct.mwoa = mwoaDiscomfort;
    
    subjectIDsStruct.controlSubjects = controlSubjects;
    subjectIDsStruct.mwaSubjects = mwaSubjects;
    subjectIDsStruct.mwoaSubjects = mwoaSubjects;
elseif strcmp(p.Results.protocol, 'Deuteranopes')
    
    subjectStruct = getDeuteranopeSubjectStruct;
    stimuli = {'LightFlux', 'Melanopsin', 'LS'};
    
    fileName = 'audioTrialStruct_final.mat';
    discomfortRatingStructs = [];
    
    % pre-allocate results variable
    for experiment = 1:2
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
        end
        
        for stimulus = 1:length(stimuli)
            for contrast = 1:length(contrasts)
                
                discomfortRatingsStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            end
            
        end
    end
    
    % pool results
    for experiment = 1:2
        experimentName = ['experiment_', num2str(experiment)];
        subjectIDs = fieldnames(subjectStruct.(['experiment', num2str(experiment)]));
        
        if experiment == 1
            contrasts = {100, 200, 400};
        elseif experiment == 2
            contrasts = {400, 800, 1200};
            
        end
        
        for ss = 1:5
            analysisBasePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'Experiments/OLApproach_Squint/Deuteranopes/DataFiles/', subjectIDs{ss}, ['experiment_', num2str(experiment)]);
            load(fullfile(analysisBasePath, fileName));
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    discomfortRatingsStruct.(['experiment_', num2str(experiment)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmedian(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                end
            end
            
        end
    end
end

end