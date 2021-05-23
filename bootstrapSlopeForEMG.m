% set up some basic variables
groups = {'mwa', 'mwoa', 'controls'};
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
nBootstraps = 10000;
x = [log10(100), log10(200), log10(400)];

%resultType = 'emg';
resultType = 'blinks';
%resultType = 'discomfortRatings';

if strcmp(resultType, 'emg')
    % load EMG results with window from 1.8 to 5.2
    resultStruct = loadEMG('windowOnset', 1.8, 'windowOffset', 5.2);
    resultStruct = resultStruct.normalizedPulseAUC;
elseif strcmp(resultType, 'blinks')
    resultStruct = loadBlinks('runAnalyzeDroppedFrames', true, 'range', [1.8 5.2]);
elseif strcmp(resultType, 'discomfortRatings')
    resultStruct = loadDiscomfortRatings;
end


% pre-allocate results variable
for group = 1:length(groups)
    for stimulus = 1:length(stimuli)
        slopes.(groups{group}).(stimuli{stimulus}) = [];
    end
end




% Do the bootstrapping
for group = 1:length(groups)
    for stimulus = 1:length(stimuli)
        for bb = 1:nBootstraps
            
            bootstrapIndices = datasample(1:length(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast100), 20);
            
            contrast100Mean = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast100([bootstrapIndices]));
            contrast200Mean = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast200([bootstrapIndices]));
            contrast400Mean = nanmean(resultStruct.(groups{group}).(stimuli{stimulus}).Contrast400([bootstrapIndices]));
            x = [log10(100), log10(200), log10(400)];
            y = [contrast100Mean, contrast200Mean, contrast400Mean];
            
            
            coeffs = polyfit(x,y,1);
            slope = coeffs(1);
            
            slopes.(groups{group}).(stimuli{stimulus}) = [slopes.(groups{group}).(stimuli{stimulus}), slope];
            
            
        end
    end
end

%% Display the results
fprintf('\n<strong>RESULTS TYPE:</strong> %s\n', resultType);
for group = 1:length(groups)
    fprintf('\n<strong>For group %s: </strong> mean slope, (95CI)\n', groups{group});
    for stimulus = 1:length(stimuli)
        if strcmp(stimuli{stimulus}, 'Melanopsin')
            fprintf('   - %s:\t%.3f, (%.3f - %.3f)\n', stimuli{stimulus}, mean(slopes.(groups{group}).(stimuli{stimulus})), prctile(slopes.(groups{group}).(stimuli{stimulus}), 5), prctile(slopes.(groups{group}).(stimuli{stimulus}), 95));           
        else
            fprintf('   - %s:\t\t%.3f, (%.3f - %.3f)\n', stimuli{stimulus}, mean(slopes.(groups{group}).(stimuli{stimulus})), prctile(slopes.(groups{group}).(stimuli{stimulus}), 5), prctile(slopes.(groups{group}).(stimuli{stimulus}), 95));
        end
    end
    
end

