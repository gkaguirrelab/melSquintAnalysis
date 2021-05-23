function makeStimulusByGroupPlot(responseModality, responseMetric)

%% summary figrue proposed by geoff:
stimuli = {'LightFlux', 'Melanopsin', 'LMS'};
groups = {'controls', 'mwa', 'mwoa'};

if strcmp(responseModality, 'discomfortRatings')
    [ resultsStruct ] = loadDiscomfortRatings;
    yLims = [0 10.5];
    yTicks = [0 5 10];
    yTickLabels = [0 5 10];
    yLabel = 'Discomfort Ratings';
elseif strcmp(responseModality, 'emg')
    [ resultsStruct ] = loadEMG;
     resultsStruct = resultsStruct.(responseMetric);
     
     yLims = [-.3 3];
     yTicks = [0, 1 2 3];
     yTickLabels = {'0' '100%' '200%', '300%'};
     yLabel = 'Squint';

elseif strcmp(responseModality, 'pupil')
    [ resultsStruct ] = loadPupilResponses;
    resultsStruct = resultsStruct.(responseMetric);
    
    yLims = [0 0.5];
    yTicks = [0, 0.25, 0.5];
    yTickLabels = {'0' '25%' '50%'};
    yLabel = 'Pupil Constriction';
elseif strcmp(responseModality, 'droppedFrames')
    %[ resultsStruct ] = loadBlinks;
    [ resultsStruct ] = loadBlinks('runAnalyzeDroppedFrames', true, 'range', [1.8 5.2])
    yLims = [0 80];
    yTicks = [0 40 80];
    yTickLabels = yTicks;
    yLabel = '# Blink Frames';
    
end
[ slope, intercept, meanRating ] = fitLineToResponseModality(responseModality, 'responseMetric', responseMetric, 'makePlots', false, 'makeCSV', false);

x = [log10(100), log10(200), log10(400)];

counter = 1;
[ha, pos] = tight_subplot(3,3, 0.04);

for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
        end
        
        
        axes(ha(counter)); hold on;
        result = resultsStruct.([groups{group}]);
        data = [result.(stimuli{stimulus}).Contrast100; result.(stimuli{stimulus}).Contrast200; result.(stimuli{stimulus}).Contrast400];
        
        plotSpread(data', 'xValues', x, 'xNames', {'100%', '200%', '400%'}, 'distributionColors', color)
        set(findall(gcf,'type','line'),'markerSize',13)
        yticks(yTicks)
        
        if group  == 1
            if stimulus == 1
                ylabel({'{\bf\fontsize{15} Light Flux}'; yLabel})
            elseif stimulus == 2
                ylabel({'{\bf\fontsize{15} Melanopsin}'; yLabel})
                
            elseif stimulus == 3
                ylabel({'{\bf\fontsize{15} LMS}'; yLabel})
                
            end
            
           
            yticks(yTicks);
            yticklabels(yTickLabels);
        end
         ylim(yLims);
        
        counter = counter + 1;
        
        
        
    end
end

% add titles to the columns
axes(ha(1));
title({'\fontsize{15} Controls'});
axes(ha(2));
title({'\fontsize{15} MwA'});
axes(ha(3));
title({'\fontsize{15} MwoA'});


% add means
counter = 1;
for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
        end
        
        axes(ha(counter)); hold on;
        result = resultsStruct.([groups{group}]);
        
        plot(x, [mean(result.(stimuli{stimulus}).Contrast100), mean(result.(stimuli{stimulus}).Contrast200), mean(result.(stimuli{stimulus}).Contrast400)], '.', 'Color', color, 'MarkerSize', 25)
        counter = counter + 1;
    end
end

% add line fits
counter = 1;
for stimulus = 1:length(stimuli)
    
    for group = 1:length(groups)
        
        
        if strcmp(groups{group}, 'controls')
            color = 'k';
            groupName = 'controls';
        elseif strcmp(groups{group}, 'mwa')
            color = 'b';
            groupName = 'mwa';
        elseif strcmp(groups{group}, 'mwoa')
            color = 'r';
            groupName = 'mwoa';
        end
        y = x*mean(slope.(groupName).(stimuli{stimulus})) + mean(intercept.(groupName).(stimuli{stimulus}));
        axes(ha(counter)); hold on;
        plot(x,y, 'Color', color)
        counter = counter + 1;
        
        
    end
end



% to make the markers transparent. for whatever reason, the effect doesn't
% stick so you have to run it manually?
drawnow()
test = findall(gcf,'type','line');
for ii = 1:length(test)
    if strcmp(test(ii).DisplayName, '100%') ||  strcmp(test(ii).DisplayName, '200%') ||  strcmp(test(ii).DisplayName, '400%')
        hMarkers = [];
        hMarkers = test(ii).MarkerHandle;
        hMarkers.EdgeColorData(4) = 75;
    end
end
set(gcf, 'Position', [600 558 1060 620]);
set(gcf, 'Renderer', 'painters');

drawnow()
test = findall(gcf,'type','line');
for ii = 1:length(test)
    if strcmp(test(ii).DisplayName, '100%') ||  strcmp(test(ii).DisplayName, '200%') ||  strcmp(test(ii).DisplayName, '400%')
        hMarkers = [];
        hMarkers = test(ii).MarkerHandle;
        hMarkers.EdgeColorData(4) = 75;
    end
end
set(gcf, 'Position', [600 558 1060 620]);
set(gcf, 'Renderer', 'painters');

%export_fig(gcf, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'discomfortRatings', 'summary_groupxstimulus.pdf'))
