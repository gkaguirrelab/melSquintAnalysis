%% Load migraine recency data
recencyTable = readtable(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), '../MELA_subject/MELA_SquintLastHeadacheNotes.xlsx'));
recencyCellArray = table2cell(recencyTable);

load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'experiments/olapproach_squint/squinttopulse/datafiles/', 'subjectListStruct.mat'));
subjectIDs = fieldnames(subjectListStruct);

sessionCellArray = {};

sessionCounter = 1;
for row = 2:size(recencyTable,1)
    if ~contains(recencyCellArray{row,2}, 'N/A')
        
        
        dates = {};
        
        
        
        
        if sum((contains(subjectIDs, recencyCellArray{row,1})))>0
            
            totalPotentialSessions = [];
            sessionDirs = dir(fullfile(getpref('melSquintAnalysis', 'melaDataPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', recencyCellArray{row,1}));
            for ii = 3:length(sessionDirs)
                totalPotentialSessions{ii} = sessionDirs(ii).name;
                if strcmp(totalPotentialSessions{ii}(1), 'x')
                    totalPotentialSessions{ii} = totalPotentialSessions{ii}(2:end);
                end
            end
            
            % look at total sessions
            totalDates = [];
            totalPotentialSessions = totalPotentialSessions(~cellfun('isempty',totalPotentialSessions));
            for ii = 1:length(totalPotentialSessions)
                totalPotentialSessionsString = totalPotentialSessions{ii};
                totalPotentailSessionsStringSplit = strsplit(totalPotentialSessionsString, '_');
                totalDates{end+1} = totalPotentailSessionsStringSplit{1};
            end
            totalDates = sort(unique(totalDates));
            
            % look at sessions which were actually included in analysis
            for session = 1:length(subjectListStruct.(recencyCellArray{row,1}))
                sessionString = subjectListStruct.(recencyCellArray{row,1}){session};
                sessionStringSplit = strsplit(sessionString, '_');
                dates{end+1} = sessionStringSplit{1};
            end
            dates = unique(dates);
            
            % figure out the intersection
            whichSessionsAreGood = find(contains(totalDates, dates));
            
            % grab only the unique dates:
            
            for ii = 1:length(whichSessionsAreGood)
                
                if ~isempty(recencyCellArray{row,whichSessionsAreGood(ii)+1})
                    sessionCellArray{sessionCounter,1} = recencyCellArray{row,1};
                    
                    recencyString = recencyCellArray{row,whichSessionsAreGood(ii)+1};
                    recencyStringSplit = strsplit(recencyString, ' ');
                    quantity = recencyStringSplit{1};
                    unit = recencyStringSplit{2};
                    
                    if contains(unit, 'week')
                        multiplier = 7;
                    elseif contains(unit, 'month')
                        multiplier = 30;
                    elseif contains(unit, 'day')
                        multiplier = 1;
                    end
                    
                    relevantSessionIDs = find(contains(subjectListStruct.(recencyCellArray{row,1}), dates{ii}));
                    relevantSessionIDs = {subjectListStruct.(recencyCellArray{row,1}){relevantSessionIDs}};
                    
                    sessionCellArray{sessionCounter,2} = relevantSessionIDs; % fix this so it includes sessionIDs
                    
                    sessionCellArray{sessionCounter,3} = str2double(quantity)*multiplier;
                    
                    sessionCounter = sessionCounter + 1;
                end
                
            end
        end
        
        
        
        
        
        
    end
    
    
    
end

%% Look for correlation with EMG data

EMGByMigraineRecency.mwa = [];
EMGByMigraineRecency.mwoa = [];

windowOnset = 1.8;
windowOffset = 5.2;
stimuli = {'LMS', 'LightFlux', 'Melanopsin'};
counter = 1;
for session = 1:size(sessionCellArray,1)
    
    trialStruct = calculateEMGResponseOverTime(sessionCellArray{session,1}, 'sessions', sessionCellArray{session,2}, 'makePlots', false);
    timebase = 0:0.1:17.5;
    windowOnsetIndex = find(timebase == windowOnset);
    windowOffsetIndex = find(timebase == windowOffset);
    
    for stimulus = 1:length(stimuli)
        responseOverTime = nanmean(trialStruct.(stimuli{stimulus}).Contrast400.combined);
        normalizedPulseAUC(stimulus) = sum(responseOverTime(windowOnsetIndex:windowOffsetIndex))/(windowOffsetIndex - windowOnsetIndex + 1);
    end
    groupID = linkMELAIDToGroup(sessionCellArray{session,1});
    
    if ~isnan(sessionCellArray{session,3})
        EMGByMigraineRecency.(groupID)(end+1,:) = [sessionCellArray{session,3}, mean(normalizedPulseAUC)*100];
        %EMGByMigraineRecency.(groupID)(counter,2) = mean(normalizedPulseAUC);
        counter = counter + 1;
    end
    
end

%%


%% Look for correlation with blink data

BlinkByMigraineRecency.mwa = [];
BlinkByMigraineRecency.mwoa = [];

counter = 1;
for session = 1:size(sessionCellArray,1)
    droppedFramesStruct = analyzeDroppedFrames('subjectIDs', sessionCellArray{session,1}, 'sessions', sessionCellArray{session,2}, 'saveOutput', false, 'runResponseOverTime', false);
    groupID = linkMELAIDToGroup(sessionCellArray{session,1});
    
    if strcmp(groupID, 'c')
        groupID = 'controls';
    end
    meanBlinkResponse = mean([droppedFramesStruct.(groupID).Melanopsin.Contrast400, droppedFramesStruct.(groupID).LightFlux.Contrast400, droppedFramesStruct.(groupID).LMS.Contrast400]);
    
    if ~isnan(sessionCellArray{session,3}) && ~isnan(meanBlinkResponse)
        BlinkByMigraineRecency.(groupID)(end+1,:) = [sessionCellArray{session,3}, meanBlinkResponse];
        %BlinkByMigraineRecency.(groupID)(counter,2) = meanBlinkResponse;
            counter = counter + 1;

    end
    
end

%% Do some plotting
figure; subplot(1,2,1); hold on;

% coeffs = polyfit(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 1);
% fittedX = linspace(min(EMGByMigraineRecency.mwa(:,1)), max(EMGByMigraineRecency.mwa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);

fittedX = linspace(min(EMGByMigraineRecency.mwa(:,1)), max(EMGByMigraineRecency.mwa(:,1)), 200);
[r p] = robustfit(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'b')
ax1 = plot(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 'o', 'Color', 'b');
mwaRho = corr(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 'Type', 'Spearman');

% coeffs = polyfit(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 1);
% fittedX = linspace(min(EMGByMigraineRecency.mwoa(:,1)), max(EMGByMigraineRecency.mwoa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);

fittedX = linspace(min(EMGByMigraineRecency.mwoa(:,1)), max(EMGByMigraineRecency.mwoa(:,1)), 200);
[r p] = robustfit(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'r')
ax2 = plot(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 'o', 'Color', 'r');
mwoaRho = corr(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 'Type', 'Spearman');


xlabel('Days Since Last Headache');
ylabel('OO-EMG Activity (%Delta)');
legend([ax1 ax2], ['MwA, rho = ', num2str(mwaRho)], ['MwoA, rho = ', num2str(mwoaRho)]);

subplot(1,2,2); hold on;

% coeffs = polyfit(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 1);
% fittedX = linspace(min(BlinkByMigraineRecency.mwa(:,1)), max(BlinkByMigraineRecency.mwa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);

fittedX = linspace(min(BlinkByMigraineRecency.mwa(:,1)), max(BlinkByMigraineRecency.mwa(:,1)), 200);
[r p] = robustfit(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'b')
ax1 = plot(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 'o', 'Color', 'b');
mwaRho = corr(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 'Type', 'Spearman');


% coeffs = polyfit(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 1);
% fittedX = linspace(min(BlinkByMigraineRecency.mwoa(:,1)), max(BlinkByMigraineRecency.mwoa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);
fittedX = linspace(min(BlinkByMigraineRecency.mwoa(:,1)), max(BlinkByMigraineRecency.mwoa(:,1)), 200);
[r p] = robustfit(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'r')
ax2 = plot(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 'o', 'Color', 'r');
mwoaRho = corr(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 'Type', 'Spearman');


xlabel('Days Since Last Headache');
ylabel('Blinks (%)');

legend([ax1 ax2], ['MwA, rho = ', num2str(mwaRho)], ['MwoA, rho = ', num2str(mwoaRho)]);

suptitle( sprintf('HA recency: MwA %4.2f (%4.2f), MwoA %4.2f (%4.2f)', mean(BlinkByMigraineRecency.mwa(:,1)), std(BlinkByMigraineRecency.mwa(:,1)), mean(BlinkByMigraineRecency.mwoa(:,1)), std(BlinkByMigraineRecency.mwoa(:,1))));

set(gcf, 'Position', [52 489 913 309], 'DefaultFigureRenderer', 'painters');
export_fig(gcf, fullfile('~/Desktop', 'headacheRecency.pdf'));

%% Plot just MwA
figure; subplot(1,2,1); hold on;

% coeffs = polyfit(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 1);
% fittedX = linspace(min(EMGByMigraineRecency.mwa(:,1)), max(EMGByMigraineRecency.mwa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);

fittedX = linspace(min(EMGByMigraineRecency.mwa(:,1)), max(EMGByMigraineRecency.mwa(:,1)), 200);
[r p] = robustfit(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'b')
ax1 = plot(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 'o', 'Color', 'b');
[mwaRho, mwaP] = corr(EMGByMigraineRecency.mwa(:,1), EMGByMigraineRecency.mwa(:,2), 'Type', 'Spearman');

% coeffs = polyfit(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 1);
% fittedX = linspace(min(EMGByMigraineRecency.mwoa(:,1)), max(EMGByMigraineRecency.mwoa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);
% 
% fittedX = linspace(min(EMGByMigraineRecency.mwoa(:,1)), max(EMGByMigraineRecency.mwoa(:,1)), 200);
% [r p] = robustfit(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2));
% fittedY = fittedX*r(2) + r(1);
% plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'r')
% ax2 = plot(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 'o', 'Color', 'r');
% mwoaRho = corr(EMGByMigraineRecency.mwoa(:,1), EMGByMigraineRecency.mwoa(:,2), 'Type', 'Spearman');


xlabel('Days Since Last Headache');
ylabel('OO-EMG Activity (%Delta)');
title(sprintf('rho = %4.3f, p = %4.3f', mwaRho, mwaP));

%legend([ax1 ax2], ['MwA, rho = ', num2str(mwaRho)], ['MwoA, rho = ', num2str(mwoaRho)]);


subplot(1,2,2); hold on;

% coeffs = polyfit(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 1);
% fittedX = linspace(min(BlinkByMigraineRecency.mwa(:,1)), max(BlinkByMigraineRecency.mwa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);

fittedX = linspace(min(BlinkByMigraineRecency.mwa(:,1)), max(BlinkByMigraineRecency.mwa(:,1)), 200);
[r p] = robustfit(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2));
fittedY = fittedX*r(2) + r(1);
plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'b')
ax1 = plot(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 'o', 'Color', 'b');
[mwaRho, mwaP] = corr(BlinkByMigraineRecency.mwa(:,1), BlinkByMigraineRecency.mwa(:,2), 'Type', 'Spearman');


% coeffs = polyfit(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 1);
% fittedX = linspace(min(BlinkByMigraineRecency.mwoa(:,1)), max(BlinkByMigraineRecency.mwoa(:,1)), 200);
% fittedY = polyval(coeffs, fittedX);
% fittedX = linspace(min(BlinkByMigraineRecency.mwoa(:,1)), max(BlinkByMigraineRecency.mwoa(:,1)), 200);
% [r p] = robustfit(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2));
% fittedY = fittedX*r(2) + r(1);
% plot(fittedX, fittedY, 'LineWidth', 2, 'Color', 'r')
% ax2 = plot(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 'o', 'Color', 'r');
% mwoaRho = corr(BlinkByMigraineRecency.mwoa(:,1), BlinkByMigraineRecency.mwoa(:,2), 'Type', 'Spearman');
title(sprintf('rho = %4.3f, p = %4.3f', mwaRho, mwaP));

xlabel('Days Since Last Headache');
ylabel('Blinks (%)');

%legend([ax1 ax2], ['MwA, rho = ', num2str(mwaRho)], ['MwoA, rho = ', num2str(mwoaRho)]);

suptitle( sprintf('HA recency: MwA %4.2f (%4.2f)', mean(BlinkByMigraineRecency.mwa(:,1)), std(BlinkByMigraineRecency.mwa(:,1))));

set(gcf, 'Position', [52 489 913 309], 'DefaultFigureRenderer', 'painters');
saveas(gca,'~/Desktop/headacheRecencyAnalysis_mwaOnly.png')