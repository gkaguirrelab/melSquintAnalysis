function makeSparklines(varargin)
dataBasePath = getpref('melSquintAnalysis','melaDataPath');


load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', 'subjectListStruct.mat'));

subjectIDs = fieldnames(subjectListStruct);

%% Pool pupil traces
controlPupilResponses = [];
mwaPupilResponses = [];
mwoaPupilResponses = [];

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
contrasts = {100, 200, 400};

for stimulus = 1:length(stimuli)
    for contrast = 1:length(contrasts)
        controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        combinedPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})]) = [];
        
    end
end

controlSubjects = [];
mwaSubjects = [];
mwoaSubjects = [];


for ss = 1:length(subjectIDs)
    
    
    group = linkMELAIDToGroup(subjectIDs{ss});
    
    resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
    load(fullfile(resultsDir, [subjectIDs{ss}, '_trialStruct_radiusSmoothed.mat']));
    
    
    for stimulus = 1:length(stimuli)
        for contrast = 1:length(contrasts)
            if strcmp(group, 'c')
                controlPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                controlSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwa')
                mwaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
                mwaSubjects{end+1} = subjectIDs{ss};
            elseif strcmp(group, 'mwoa')
                mwoaPupilResponses.(stimuli{stimulus}).(['Contrast', num2str(contrasts{contrast})])(end+1,:) = nanmean(trialStruct.(stimuli{stimulus}).(['Contrast',num2str(contrasts{contrast})]));
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

subjectList = [controlSubjects, mwaSubjects, mwoaSubjects];
%% make the sparkline plot
% we are going to skip plotting the first and last seconds (they're
% particularly noisy and uninformative)
firstIndexToPlot = 61;
lastIndexToPlot = 1061;

% how much to horizontally shift responses of different stimulus types
xoffset = 200;
% how much to vertically shift responses from different subjects
yoffset = 0.8;

stimuli = {'Melanopsin', 'LMS', 'LightFlux'};
colors.Melanopsin{1} = [220/255, 237/255, 200/255];
colors.Melanopsin{2} = [66/255, 179/255, 213/255];
colors.Melanopsin{3} = [26/255, 35/255, 126/255];

grayColormap = colormap(gray);
colors.LMS{1} = grayColormap(50,:);
colors.LMS{2} = grayColormap(25,:);
colors.LMS{3} = grayColormap(1,:);

colors.LightFlux{1} = [254/255, 235/255, 101/255];
colors.LightFlux{2} = [228/255, 82/255, 27/255];
colors.LightFlux{3} = [77/255, 52/255, 47/255];



%%
nColumns = 3;
nRows = ceil(length(subjectList)/nColumns);
for stimulus = 1:length(stimuli)
    plotFig = figure; hold on;
    for ss = 1:length(subjectList)
        [rowNumber, columnNumber] = ind2sub([nRows, nColumns], ss);
        x1 = (lastIndexToPlot - firstIndexToPlot)*(columnNumber - 1) + xoffset*(columnNumber - 1);
        x = x1:x1+(lastIndexToPlot - firstIndexToPlot);
        
        resultsDir = fullfile(getpref('melSquintAnalysis','melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'trialStructs');
        load(fullfile(resultsDir, [subjectList{ss}, '_trialStruct_radiusSmoothed.mat']));
        
        response100 = nanmean(trialStruct.(stimuli{stimulus}).Contrast100(:, firstIndexToPlot:lastIndexToPlot)) - yoffset*(rowNumber-1);
        response200 = nanmean(trialStruct.(stimuli{stimulus}).Contrast200(:, firstIndexToPlot:lastIndexToPlot)) - yoffset*(rowNumber-1);
        response400 = nanmean(trialStruct.(stimuli{stimulus}).Contrast400(:, firstIndexToPlot:lastIndexToPlot)) - yoffset*(rowNumber-1);
        
        
        plot(x, response100, 'Color', colors.(stimuli{stimulus}){1}, 'LineWidth', 2);
        plot(x, response200, 'Color', colors.(stimuli{stimulus}){2}, 'LineWidth', 2);
        plot(x, response400, 'Color', colors.(stimuli{stimulus}){3}, 'LineWidth', 2);
        
    end
    
    
    axis off
    set(gcf, 'Renderer', 'painters')
    print(plotFig, fullfile('~/Desktop',['sparkline_', stimuli{stimulus}]), '-dpdf')
    
    
    text(500, 1, 'Controls', 'FontSize', 20, 'FontName', 'Helvetica Neue', 'HorizontalAlignment', 'Center');
    text(1700, 1, 'MwA', 'FontSize', 20, 'FontName', 'Helvetica Neue', 'HorizontalAlignment', 'Center');
    text(2900, 1, 'MwoA', 'FontSize', 20, 'FontName', 'Helvetica Neue', 'HorizontalAlignment', 'Center');
end



end