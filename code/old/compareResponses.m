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
%% Discomfort vs. EMG, at the individual subject level
% median vs. all values
% one plot for each stimulus type or all plots

% per subject first, median values
plotFig = figure; hold on;
sgtitle('MwA')
for stimulus = 1:length(stimuli)
    ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    for contrast = 1:length(contrasts)
        if contrast == 1
            markerSize = 6;
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'b', 'markerSize', markerSize);
        
        
       
        
    end
    
     x = [mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), mwaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
        y = [mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), mwaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
        
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1)
        
        r = corr2(x, y);
        
        xlims=get(gca,'xlim');
        ylims=get(gca,'ylim');
        xrange = xlims(2)-xlims(1);
        yrange = ylims(2) - ylims(1);
        xpos = xlims(1)+0.20*xrange;
        ypos = ylims(1)+0.80*yrange;
        string = (sprintf(['r = ', num2str(r)]));
        text(xpos, ypos, string, 'fontsize',12)
        
        xlabel('Discomfort Rating'); ylabel('EMG RMS');
end
linkaxes([ax.ax1, ax.ax2, ax.ax3])
export_fig(

plotFig = figure; hold on;
sgtitle('MwoA')
for stimulus = 1:length(stimuli)
    ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    for contrast = 1:length(contrasts)
        if contrast == 1
            markerSize = 6;
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'r', 'markerSize', markerSize);
        
               xlabel('Discomfort Rating'); ylabel('EMG RMS');

        
    end
    
     x = [mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), mwoaDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
        y = [mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), mwoaRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
        
        coeffs = polyfit(x, y, 1);
        fittedX = linspace(min(x), max(x), 200);
        fittedY = polyval(coeffs, fittedX);
        plot(fittedX, fittedY, 'LineWidth', 1)
        
        r = corr2(x, y);
        
        xlims=get(gca,'xlim');
        ylims=get(gca,'ylim');
        xrange = xlims(2)-xlims(1);
        yrange = ylims(2) - ylims(1);
        xpos = xlims(1)+0.20*xrange;
        ypos = ylims(1)+0.80*yrange;
        string = (sprintf(['r = ', num2str(r)]));
        text(xpos, ypos, string, 'fontsize',12)
        
end
linkaxes([ax.ax1, ax.ax2, ax.ax3])

plotFig = figure; hold on;
sgtitle('Controls')
for stimulus = 1:length(stimuli)
    ax.(['ax', num2str(stimulus)]) = subplot(1,3,stimulus); hold on;
    title(stimuli{stimulus});
    for contrast = 1:length(contrasts)
        if contrast == 1
            markerSize = 6;
        elseif contrast == 2
            markerSize = 10;
        elseif contrast == 3
            markerSize = 14;
        end
        plot(controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]), 'o', 'Color', 'k', 'markerSize', markerSize);
        xlabel('Discomfort Rating'); ylabel('EMG RMS');
    end
    
    x = [controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), controlDiscomfort.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
    y = [controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{1})]), controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{2})]), controlRMS.(stimuli{stimulus}).(['Contrast', num2str(contrasts{3})])];
    
    coeffs = polyfit(x, y, 1);
    fittedX = linspace(min(x), max(x), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'LineWidth', 1)
    
    r = corr2(x, y);
    
    xlims=get(gca,'xlim');
    ylims=get(gca,'ylim');
    xrange = xlims(2)-xlims(1);
    yrange = ylims(2) - ylims(1);
    xpos = xlims(1)+0.20*xrange;
    ypos = ylims(1)+0.80*yrange;
    string = (sprintf(['r = ', num2str(r)]));
    text(xpos, ypos, string, 'fontsize',12)
    
    
    
    xlabel('Discomfort Rating'); ylabel('EMG RMS');
end
linkaxes([ax.ax1, ax.ax2, ax.ax3])


