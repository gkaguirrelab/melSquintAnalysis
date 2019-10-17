%% Find our subjects
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);
saveStem = '_normalized';

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};

for stimulus = 1:length(stimuli)
    
    mwaBaselineRMSAccumulator.(stimuli{stimulus}) = [];
    mwoaBaselineRMSAccumulator.(stimuli{stimulus}) = [];
    combinedMigraineBaselineRMSAccumulator.(stimuli{stimulus}) = [];
    controlBaselineRMSAccumulator.(stimuli{stimulus}) = [];

      
end

%%
resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'EMG');

for ss = 1:45%length(subjectIDs)
    
    load(fullfile(resultsDir, 'medianStructs', [subjectIDs{ss}, '_EMGMedianRMS', saveStem, '.mat']));
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    sessionNames = fieldnames(baselineRMSAccumulator);
    for session = 1:length(sessionNames)
        for stimulus = 1:length(stimuli)
            
            if strcmp(group, 'mwa')
                mwaBaselineRMSAccumulator.(stimuli{stimulus}) = [ mwaBaselineRMSAccumulator.(stimuli{stimulus}), baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).left, baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).right];
                combinedMigraineBaselineRMSAccumulator.(stimuli{stimulus}) = [combinedMigraineBaselineRMSAccumulator.(stimuli{stimulus}), baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).left, baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).right];
                
            elseif strcmp(group, 'mwoa')
                mwoaBaselineRMSAccumulator.(stimuli{stimulus}) = [ mwoaBaselineRMSAccumulator.(stimuli{stimulus}), baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).left, baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).right];
                combinedMigraineBaselineRMSAccumulator.(stimuli{stimulus}) = [combinedMigraineBaselineRMSAccumulator.(stimuli{stimulus}), baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).left, baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).right];
            elseif strcmp(group, 'c')
                controlBaselineRMSAccumulator.(stimuli{stimulus}) = [controlBaselineRMSAccumulator.(stimuli{stimulus}), baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).left, baselineRMSAccumulator.(sessionNames{session}).(stimuli{stimulus}).right];
            end
            
        end
        
    end
    
end

%% display results
baselineEMG = [];
for stimulus = 1:length(stimuli)
    
        baselineEMG.MwoA.(stimuli{stimulus}).Contrast400 = mwoaBaselineRMSAccumulator.(stimuli{stimulus});
        
        baselineEMG.MwA.(stimuli{stimulus}).Contrast400 = mwaBaselineRMSAccumulator.(stimuli{stimulus});
        baselineEMG.Controls.(stimuli{stimulus}).Contrast400 = controlBaselineRMSAccumulator.(stimuli{stimulus});
   
end

[ha, plotFig] = plotSpreadResults(baselineEMG, 'contrasts', {400}, 'yLims', [0 0.3], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['baselineRMS_groupAverage', saveStem, '.pdf']), 'markerSize', 20)
for axis = 1:3
   axes(ha(axis));
   xticklabels('');
   xlabel('');
end
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['baselineRMS_groupAverage', saveStem, '.pdf']));

baselineEMG = [];
for stimulus = 1:length(stimuli)
   
        baselineEMG.CombinedMigraineurs.(stimuli{stimulus}).Contrast400 = [mwoaBaselineRMSAccumulator.(stimuli{stimulus}), mwaBaselineRMSAccumulator.(stimuli{stimulus})];
        baselineEMG.Controls.(stimuli{stimulus}).Contrast400 = controlBaselineRMSAccumulator.(stimuli{stimulus});
 
end

[ha, plotFig] = plotSpreadResults(baselineEMG, 'contrasts', {400}, 'yLims', [0 0.3], 'yLabel', 'EMG RMS', 'saveName', fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['baselineRMS_groupAverage_combinedMigraineurs', saveStem, '.pdf']), 'markerSize', 20)
for axis = 1:3
   axes(ha(axis));
   xticklabels('');
   xlabel('');
end
export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'EMG', ['baselineRMS_groupAverage_combinedMigraineurs', saveStem, '.pdf']));
