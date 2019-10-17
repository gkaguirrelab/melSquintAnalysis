%%
% use the summaryScripts to generate the relevant resultStructs
% (mwaDiscomfort, mwaRMS, and mwaTotalResponseAmplitude, for example)
close all

stimuli = {'Melanopsin', 'LightFlux', 'LMS'};
contrasts = {100, 200, 400};

%%
plotFig = figure; 
subplot(1,3,1); hold on;
for stimulus = 1:length(stimuli)
    
    if stimulus == 1
        plotSymbol = 'o';
    elseif stimulus == 2
        plotSymbol = '*';
    elseif stimulus == 3
        plotSymbol = '+';
    end
    
    for contrast = 1:length(contrasts)
        if contrast == 1
           markerSize = 6; 
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(median(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'b', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'r', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'k', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        
        
    end
end

ylabel('RMS % Change from Baseline')
xlabel('Discomfort Rating')

%%
subplot(1,3,2); hold on;
for stimulus = 1:length(stimuli)
    
    if stimulus == 1
        plotSymbol = 'o';
    elseif stimulus == 2
        plotSymbol = '*';
    elseif stimulus == 3
        plotSymbol = '+';
    end
    
    for contrast = 1:length(contrasts)
                if contrast == 1
           markerSize = 6; 
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(median(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'b', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'r', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'k', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        
        
    end
end

ylabel('Pupil Constriction')
xlabel('Discomfort Rating')

%%
subplot(1,3,3); hold on;
for stimulus = 1:length(stimuli)
    
    if stimulus == 1
        plotSymbol = 'o';
    elseif stimulus == 2
        plotSymbol = '*';
    elseif stimulus == 3
        plotSymbol = '+';
    end
    
    for contrast = 1:length(contrasts)
                if contrast == 1
           markerSize = 6; 
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(median(mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'b', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'r', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        plot(median(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), 'Color', 'k', 'Marker', plotSymbol, 'MarkerSize', markerSize)
        
        
    end
end

ylabel('Pupil Constriction')
xlabel('RMS % Change from Baseline')

%%

plotFig = figure; hold on;
for stimulus = 1:length(stimuli)
    
    if stimulus == 1
        plotSymbol = 'o';
    elseif stimulus == 2
        plotSymbol = '*';
    elseif stimulus == 3
        plotSymbol = '+';
    end
    for contrast = 1:length(contrasts)
                if contrast == 1
           markerSize = 10; 
        elseif contrast == 2
            markerSize = 20;
        elseif contrast == 3
            markerSize = 40;
        end
        scatter3(median(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), markerSize, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Marker', plotSymbol)
        scatter3(median(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(mwoaTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), markerSize, 'MarkerFaceColor', 'r',  'MarkerEdgeColor', 'r','Marker', plotSymbol)
        scatter3(median(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), median(controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), -median(controlTotalResponseAmplitude.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])), markerSize, 'MarkerFaceColor', 'k',  'MarkerEdgeColor', 'k','Marker', plotSymbol)
    end
end
xlabel('Discomfort Rating')
ylabel('RMS % Change from Baseline')
zlabel('Pupil Constriction')
view(-30, 10)
