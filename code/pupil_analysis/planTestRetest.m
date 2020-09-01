function pooledSessionStruct = planTestRetest(varargin)
% Routine to create pupil responses per subject by testing date.

% This routine loops through all subjects studied as part of the Squint
% study (regardless of diagnosis), and pools pupil responses according to
% the date in which they were studied. The goal is to create for each
% subject average pupil responses collected on individual days of
% experimentation, in order to examine the reproducibility of these pupil
% responses. The routine also imposes inclusion criteria, where subjects
% need to have at least 5 pupil responses in all stimulus types on two days
% of testing. In addition, this routine collapses days for subjects tested
% across more than 2 days of study. The logic is as follows: if the first
% testing day does not allow a subject to reach 5 trials in all stimuli,
% add individual days until this threshold of 5 trials is reached. Then,
% pool the remainder of testing days together to represent the "second"
% date. Finally, this routine plots average pupil constriction for each
% individual subject for each stimulus type across day 1 and day 2 of
% study.

% Inputs: none

% Outputs: 
%   - pooledSessionStruct           A struct with the first subfield that
%                                   describes whether results come from the
%                                   first or second day of study. The next
%                                   subfield is stimulus direction, and
%                                   final subfield is contrast level. At
%                                   this deepest level, the data is
%                                   represented by a s x t matrix, where
%                                   each of s rows is the average pupil
%                                   response for an individual subject
%                                   sampled a t timepoints.
%
% Optional key-value pairs:
%   - load                          A logical to control whether to
%                                   actually loop through the subjects and
%                                   process the data, or to just load a
%                                   previously created iteration. The
%                                   default is set to false, to process the
%                                   data.

p = inputParser; p.KeepUnmatched = true;

p.addParameter('load',false, @islogical);

p.parse(varargin{:});

if ~p.Results.load
    %% Define some experiment basics
    stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
    contrasts = {100, 200, 400};
    
    
    
    %% load subjects and sessions
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));
    subjectIDs = fieldnames(subjectListStruct);
    
    %% Prep the table
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            pooledSessionStruct.day1.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pooledSessionStruct.day2.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            pooledSessionStruct.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
            
        end
    end
    pooledSessionStruct.subjectIDs = [];
    
    %% Loop over subjects
    %subjectIDs = []; subjectIDs{1} = 'MELA_0147';
    for ss = 1:length(subjectIDs)
        
        % determine number of different dates in which the subject came in and
        % was studied
        dates = {};
        for session = 1:length(subjectListStruct.(subjectIDs{ss}))
            sessionString = subjectListStruct.(subjectIDs{ss}){session};
            sessionStringSplit = strsplit(sessionString, '_');
            dates{end+1} = sessionStringSplit{1};
        end
        
        % grab only the unique dates:
        dates = unique(dates);
        
        % load pupil data
        load(fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles', subjectIDs{ss}, 'trialStruct_radiusSmoothed_droppedFramesAnalysis.mat'));
        
        for dd = 1:length(dates)
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                    
                    
                end
            end
        end
        
        subjectFailStatus = 0;
        for dd = 1:length(dates)
            
            if length(dates) == 2
                for stimulus = 1:length(stimuli)
                    for contrast = 1:length(contrasts)
                        
                        
                        nTrials = length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                        
                        
                        % loop over trials
                        trialCounter = 0;
                        for tt = 1:nTrials
                            
                            % if the trial occured in the date in question, stash
                            % it
                            if contains(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.session, dates{dd})
                                sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,:);
                                trialCounter = trialCounter + 1;
                                
                            end
                            
                        end
                        
                        id = sub2ind([length(contrasts),length(stimuli),length(dates)],contrast,stimulus,dd);
                        sessionSubjectCount{ss,id+1} = trialCounter;
                        sessionSubjectCount{ss,1} = subjectIDs{ss};
                        
                        if size(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1) < 5
                            subjectFailStatus = 1;
                        end
                        
                    end
                    
                    
                end
                
                
                
            elseif length(dates) < 2
                % for subjects studied on only one date, these results will be
                % discarded
                subjectFailStatus = 1;
                
                
            elseif length(dates) > 2
                
                for stimulus = 1:length(stimuli)
                    for contrast = 1:length(contrasts)
                        
                        nTrials = length(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]));
                        
                        
                        % loop over trials
                        trialCounter = 0;
                        for tt = 1:nTrials
                            
                            % if the trial occured in the date in question, stash
                            % it
                            if contains(trialInfoStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]){tt}.session, dates{dd})
                                sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(tt,:);
                                trialCounter = trialCounter + 1;
                                
                            end
                            
                        end
                        
                        id = sub2ind([length(contrasts),length(stimuli),length(dates)],contrast,stimulus,dd);
                        sessionSubjectCount{ss,id+1} = trialCounter;
                        sessionSubjectCount{ss,1} = subjectIDs{ss};
                        
                        
                    end
                    
                    
                end
                
                
                
            end
            
        end
        
        % if subject was studied on more than three dates, pool them together
        % so we only have two
        
        
        if length(dates) > 2
            % determine number of trials in each stimulus condition in each
            % date
            for dd = 1:length(dates)
                columnCounter = 1;
                for stimulus = 1:length(stimuli)
                    for contrast = 1:length(contrasts)
                        trialCounter(dd,columnCounter) = size(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1);
                        columnCounter = columnCounter + 1;
                    end
                end
                
            end
            
            % parse this trial counter
            % if the first date has at least 6 trials across all conditions,
            % let that be the first date and pool all other dates into the
            % second date
            pooledTrialCounter = zeros(1,length(trialCounter));
            for dd = 1:length(dates)
                pooledTrialCounter = [ pooledTrialCounter + trialCounter(dd,:)];
                if min(pooledTrialCounter(1,:)) >= 5
                    numberOfDatesNeededForFirstSession = dd;
                    break
                else
                    numberOfDatesNeededForFirstSession = dd;
                    
                end
            end
            
            % if we need to use all dates to get to 5, then there's nothing
            % left for session two and this subject won't work
            if numberOfDatesNeededForFirstSession == length(dates)
                subjectFailStatus = 1;
            else
                for stimulus = 1:length(stimuli)
                    for contrast = 1:length(contrasts)
                        newSessionStruct.day1.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                        newSessionStruct.day2.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
                    end
                end
                for stimulus = 1:length(stimuli)
                    for contrast = 1:length(contrasts)
                        for dd = 1:numberOfDatesNeededForFirstSession
                            newSessionStruct.day1.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [newSessionStruct.day1.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
                        end
                        
                        for dd = numberOfDatesNeededForFirstSession+1:length(dates)
                            newSessionStruct.day2.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [newSessionStruct.day2.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]); sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
                            
                        end
                    end
                end
                
                sessionStruct = newSessionStruct;
                
                
                
            end
        end
        
        
        
        % if we have good data, stash away the group result
        if subjectFailStatus == 0
            pooledSessionStruct.subjectIDs{end+1} = subjectIDs{ss};
            for stimulus = 1:length(stimuli)
                for contrast = 1:length(contrasts)
                    pooledSessionStruct.combinedMean.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1);
                    for dd = 1:2
                        
                        
                        % pooled subject struct
                        pooledSessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]),1);
                        
                    end
                end
            end
        end
        
        
        % make some plots
        plotFig = figure;
        nStimuli = length(stimuli);
        nContrasts = length(contrasts);
        nTimePointsToSkipPlotting = 40;
        plotShift = 1;
        xLims = [0 17];
        yLims = [-0.8 0.1];
        pulseOnset = 1.5;
        pulseOffset = 5.5;
        resampledTimebase = 0:1/60:18.5;
        
        
        % set up color palette
        colorPalette.Melanopsin{1} = [220/255, 237/255, 200/255];
        colorPalette.Melanopsin{2} = [66/255, 179/255, 213/255];
        colorPalette.Melanopsin{3} = [26/255, 35/255, 126/255];
        
        grayColorMap = colormap(gray);
        colorPalette.LMS{1} = grayColorMap(50,:);
        colorPalette.LMS{2} = grayColorMap(25,:);
        colorPalette.LMS{3} = grayColorMap(1,:);
        colorPalette.LS = colorPalette.LMS;
        
        colorPalette.LightFlux{1} = [254/255, 235/255, 101/255];
        colorPalette.LightFlux{2} = [228/255, 82/255, 27/255];
        colorPalette.LightFlux{3} = [77/255, 52/255, 47/255];
        
        
        for stimulus = 1:nStimuli
            for dd = 1:2
                
                % pick the right subplot for the right stimuli
                id = sub2ind([2,nStimuli], dd,stimulus);
                subplot(nStimuli,2,id)
                title(stimuli{stimulus})
                hold on
                
                for cc = 1:nContrasts
                    
                    % make thicker plot lines
                    lineProps.width = 1;
                    
                    % adjust color
                    lineProps.col{1} = colorPalette.(stimuli{stimulus}){cc};
                    
                    % plot
                    meanTrace = nanmean(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{cc})]),1);
                    nTrials = size(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{cc})]),1);
                    if nTrials > 1
                        SEM = nanstd(sessionStruct.(['day', num2str(dd)]).(stimuli{stimulus}).(['Contrast', num2str(contrasts{cc})]),1)./sqrt(nTrials);
                    else
                        SEM = meanTrace*0;
                    end
                    
                    if nTrials > 0
                        axis.(['ax', num2str(cc)]) = mseb(resampledTimebase(1:end-nTimePointsToSkipPlotting)-plotShift, meanTrace(1:end-nTimePointsToSkipPlotting), SEM(1:end-nTimePointsToSkipPlotting), lineProps);
                    end
                    
                    legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(nTrials)]);
                    
                    
                end
                
                legend(legendText, 'Location', 'SouthEast')
                legend('boxoff')
                
                % add line for pulse onset
                line([pulseOnset-plotShift,  pulseOffset-plotShift], [0.05, 0.05], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
                
                % spruce up axes
                ylim(yLims)
                xlim(xLims)
                xlabel('Time (s)')
                ylabel('Pupil Area (% Change)')
                
                
            end
        end
        
        % save out plots
        print(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'subjectPlotsByDate', subjectIDs{ss}), '-dpdf', '-fillpage')
        
        
        
        close(plotFig)
    end
    
    % save out table
    cell2csv(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'subjectPlotsByDate', 'summaryTable.csv'), sessionSubjectCount);
    
    save(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'groupStruct.mat'), 'pooledSessionStruct');
else
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'individualDifferences', 'groupStruct.mat'));
    
end

end % end function