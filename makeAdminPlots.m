function makeAdminPlots

%% Make plot of total sufficient subjects as a function of time
subjectList = generateSubjectList('method', 'sufficientSubjects');
datesInWhichSubjectBecameSufficient = [];
subjectInfoArray = [];

for ss = 1:length(subjectList)
    % determine when the subject was deemed sufficient
    potentialSessions = dir(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectList{ss}, '2*_session*'));
    potentialSessions = {potentialSessions(:).name};
    
    dateInWhichSubjectBecameSufficient = potentialSessions{2};
    dateInWhichSubjectBecameSufficient = strsplit(dateInWhichSubjectBecameSufficient, '_');
    dateInWhichSubjectBecameSufficient = dateInWhichSubjectBecameSufficient{1};
    dateInWhichSubjectBecameSufficient = datenum(dateInWhichSubjectBecameSufficient);
    
    datesInWhichSubjectBecameSufficient{end+1} = dateInWhichSubjectBecameSufficient;
    
    subjectInfoArray{ss,1} = subjectList{ss};
    subjectInfoArray{ss,2} = dateInWhichSubjectBecameSufficient;
    subjectInfoArray{ss,3} = linkMELAIDToGroup(subjectList{ss});
    
    
end

groups = {'mwa', 'c', 'mwoa'};
colors = {'r', 'b', 'k'};
plotFig = figure; hold on;
for gg = 1:length(groups)
    groupIndices = find(strcmp({subjectInfoArray{:,3}},groups{gg}));
    
    sortedDates = sort([subjectInfoArray{groupIndices,2}]);
    
    %plot(sortedDates,1:length(sortedDates), 'Color', colors{gg});
    %plot(sortedDates(end):datenum(date), repmat(length(sortedDates), 1, length(sortedDates(end):datenum(date))), 'Color', colors{gg});
    plot([sortedDates(1), sortedDates(1), sortedDates, sortedDates(end):datenum(date)], [0,  1, 1:length(sortedDates), repmat(length(sortedDates), 1, length(sortedDates(end):datenum(date)))], 'Color', colors{gg}, 'LineWidth', 2);
    
end

ylim([0 20]);
datetick('x');
xlabel('Date');
ylabel('Sufficient Subjects');

% add mTBI subjects
potentialSubjects = dir(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));
mTBISubjects = [];
for ss = 1:length(potentialSubjects)
    subjectDiagnosis = linkMELAIDToGroup(potentialSubjects(ss).name);
    if strcmp(subjectDiagnosis, 'mTBI')
        mTBISubjects{end+1} = potentialSubjects(ss).name;
    end
end

mTBISubjectInfoArray = [];
for ss = 1:length(mTBISubjects)
    potentialSessions = dir(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', mTBISubjects{ss}, '2*_session*'));
    potentialSessions = {potentialSessions(:).name};
    
    dateInWhichSubjectBecameSufficient = potentialSessions{2};
    dateInWhichSubjectBecameSufficient = strsplit(dateInWhichSubjectBecameSufficient, '_');
    dateInWhichSubjectBecameSufficient = dateInWhichSubjectBecameSufficient{1};
    dateInWhichSubjectBecameSufficient = datenum(dateInWhichSubjectBecameSufficient);
    
    datesInWhichSubjectBecameSufficient{end+1} = dateInWhichSubjectBecameSufficient;
    
    mTBISubjectInfoArray{ss,1} = mTBISubjects{ss};
    mTBISubjectInfoArray{ss,2} = dateInWhichSubjectBecameSufficient;
    mTBISubjectInfoArray{ss,3} = linkMELAIDToGroup(mTBISubjects{ss});
end

sortedDates = sort([mTBISubjectInfoArray{:,2}]);
    plot([sortedDates(1), sortedDates(1), sortedDates, sortedDates(end):datenum(date)], [0,  1, 1:length(sortedDates), repmat(length(sortedDates), 1, length(sortedDates(end):datenum(date)))], 'Color', 'y', 'LineWidth', 2);


legend(['Migraine with Aura: N = ', num2str(length(find(strcmp({subjectInfoArray{:,3}},'mwa'))))], ['Controls: N = ', num2str(length(find(strcmp({subjectInfoArray{:,3}},'c'))))],['Migraine without Aura: N = ', num2str(length(find(strcmp({subjectInfoArray{:,3}},'mwoa'))))], ['mTBI: N = ', num2str(length(mTBISubjects))], 'Location', 'NorthWest') 

export_fig(plotFig, fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'Experiments/OLApproach_Squint/SquintToPulse/Admin', 'recruitment.pdf'));


end