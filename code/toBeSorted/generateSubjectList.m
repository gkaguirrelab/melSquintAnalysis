function [ subjectList, subjectStructWithSessions ] = generateSubjectList(varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('method', 'hardCode', @ischar);



p.parse(varargin{:});

if strcmp(p.Results.method, 'hardCode')
    
    subjectList = { ...
        'MELA_0187', ...
        'MELA_0177', ...
        'MELA_0181', ...
        'MELA_0175', ...
        'MELA_0179', ...
        'MELA_0194', ...
        'MELA_0191', ...
        'MELA_0192', ...
        'MELA_0174', ...
        'MELA_0173', ...
        'MELA_0171', ...
        'MELA_0170', ...
        'MELA_0169', ...
        'MELA_0168', ...
        'MELA_0167', ...
        'MELA_0166', ...
        'MELA_0164', ...
        'MELA_0163', ...
        'MELA_0160', ...
        'MELA_0158', ...
        'MELA_0157', ...
        'MELA_0155', ...
        'MELA_0153', ...
        'MELA_0152', ...
        'MELA_0150', ...
        'MELA_0143', ...
        'MELA_0147', ...
        'MELA_0140', ...
        'MELA_0139', ...
        'MELA_0138', ...
        'MELA_0137', ...
        'MELA_0131', ...
        'MELA_0130', ...
        'MELA_0129', ...
        'MELA_0128', ...
        'MELA_0126', ...
        'MELA_0124', ...
        'MELA_0201', ...
        'MELA_0122', ...
        'MELA_0121', ...
        'MELA_0119', ...
        'MELA_0120', ...
        'MELA_0198'};
    
elseif strcmp(p.Results.method, 'sufficientSubjects')
    
    % get list of all candidate subjects by looking in the data directory
    subjectIDs = [];
    potentialSubjects =  dir(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/MELA*'));
    for ss = 1:length(potentialSubjects)
        subjectIDs{end+1} = potentialSubjects(ss).name;
    end
    
    
    % exclude subjects with poor pupillometry
    badSubjects = {'MELA_0195', 'MELA_0144', 'MELA_0162', 'MELA_0127'};
    mTBISubjects = {'MELA_0212', 'MELA_0173'};
    badSubjects = {badSubjects{:}, mTBISubjects{:}};
    subjectIDs = setdiff(subjectIDs, badSubjects);
    
    % for each potential subject, determine if they've completed at least
    % two sessions
    
    sufficientSubjects = [];
    subjectStructWithSessions = [];
    for ss = 1:length(subjectIDs)
        completedSessionIDs = [];
        potentialSessions = dir(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, '2*_session*'));
        completedSessions = 0;
        for ii = 1:length(potentialSessions)
            
            % determine if a session is good depending on if all of the
            % data has been saved
            if exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_01')) && ...
                    exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_02')) && ...
                    exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_03')) && ...
                    exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_04')) && ...
                    exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_05')) && ...
                    exist(fullfile(getpref('melSquintAnalysis','melaDataPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, potentialSessions(ii).name, 'videoFiles_acquisition_06'))
                
                dataAllPresent = 1;
            else
                dataAllPresent = 0;
                
                
            end
            
            % also determine if a session is good if both pre- and
            % post-experimental validations are good
            [passStatus, ~] = evaluateValidationsPerSession(subjectIDs{ss}, potentialSessions(ii).name);
            if passStatus == 1
                goodValidations = 1;
            else
                goodValidations = 0;
            end
            
            % if we have both all the data, and good validations, then this
            % is a complete session
            if goodValidations == 1 && dataAllPresent == 1
                completedSessions = completedSessions + 1;
                completedSessionIDs{end+1} = potentialSessions(ii).name;
            end
            
        end
        
        if completedSessions >= 2
            
            sufficientSubjects{end+1} = subjectIDs{ss};
            subjectStructWithSessions.(subjectIDs{ss}) = completedSessionIDs;
        end
        subjectList = sufficientSubjects;
        
    end
    
    % need at least two sessions complete to be considered sufficient
    

end


end
