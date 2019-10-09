%% Determine list of studied subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

calculateRMS = true;

%% Pool results
controlRMS = [];
mwaRMS = [];
mwoaRMS = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');
    
    if calculateRMS
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true);
        calculateRMSforEMG(subjectIDs{ss}, 'sessions', subjectListStruct.(subjectIDs{ss}), 'makePlots', true, 'normalize', true);
        
    end
    close all;
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                load(fullfile(resultsDir,  'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS.mat']));
                mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1) = nanmean([medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).left, medianRMS.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast}), '_median']).right]);
                mwoaSubjects{end+1} = subjectIDs{ss};
            else
                fprintf('Subject %s has group %s\n', subjectIDs{ss}, group);
            end
        end
    end
    
end

mwaSubjects = unique(mwaSubjects);
mwoaSubjects = unique(mwoaSubjects);
controlSubjects = unique(controlSubjects);
%% Analyze EMG responses over time
windowLength = 500;
stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
    end
end
for ss = 1:length(subjectIDs)
    load(fullfile(fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs'], 'trialStructs', [subjectIDs{ss}, '.mat'])));
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]).combined);
        end
    end
    
end

plotFig = figure;
resampledTimebase = 0:1/5000*windowLength:1/5000*windowLength*length(pooledSubjectMeanResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(ss,:)) - 1/5000*windowLength;

nStimuli = length(stimuli);
nContrasts = length(contrasts);

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

for ss = 1:nStimuli
    
    % pick the right subplot for the right stimuli
    ax.(['ax', num2str(ss)]) = subplot(nStimuli,1,ss);
    title(stimuli{ss})
    hold on
    
    for cc = 1:nContrasts
        
        % make thicker plot lines
        lineProps.width = 1;
        
        % adjust color
        lineProps.col{1} = colorPalette.(stimuli{ss}){cc};
        
        % plot
        axis.(['ax', num2str(cc)]) = mseb(resampledTimebase, nanmean(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})])), std(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]))/(sqrt(size(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]),1))), lineProps);
        
        legendText{cc} = ([num2str(contrasts{cc}), '% Contrast, N = ', num2str(size(pooledSubjectMeanResponses.(stimuli{ss}).(['Contrast', num2str(contrasts{cc})]), 1))]);
        
    end
    
    legend(legendText, 'Location', 'NorthEast')
    legend('boxoff')
    
    % add line for pulse onset
    line([1.5,  5.5], [-0.5, -0.5], 'Color', 'k', 'LineWidth', 5, 'HandleVisibility','off');
    
    % spruce up axes
    
    
    xlabel('Time (s)')
    ylabel('EMG Activity (STD)')
    
end

linkaxes([ax.ax1, ax.ax2, ax.ax3]);

fullSavePath = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'responseOverTime', ['windowLength_', num2str(windowLength), 'MSecs']);

if ~exist(fullSavePath)
    mkdir(fullSavePath);
end

print(plotFig, fullfile(fullSavePath, 'combinedGroupAverage'), '-dpdf', '-fillpage')


%% Display results

EMG = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        EMG.MwoA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        
        EMG.MwA.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
        EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(EMG, 'yLims', [0 6], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'groupAverage.pdf'))



EMG = [];
for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        EMG.CombinedMigraineurs.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])];
        EMG.Controls.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]);
    end
end

plotSpreadResults(EMG, 'yLims', [0 6], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', 'groupAverage_combinedMigraineurs.pdf'))

