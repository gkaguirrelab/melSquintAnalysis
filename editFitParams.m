function editFitParams(subjectID, sessionID, acquisitionNumber, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('trialNumber',[],@isnumeric);
p.addParameter('paramName', []);
p.addParameter('paramValue', []);

% Parse and check the parameters
p.parse(varargin{:});

%% Get some params
[ defaultFitParams, cameraParams, pathParams, sceneParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

pathParams.subject = subjectID;
if isnumeric(sessionID)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(sessionID)]));
    sessionID = sessionDir(end).name;
end
pathParams.session = sessionID;
pathParams.protocol = 'SquintToPulse';

[pathParams.runNames, ~] = getTrialList(pathParams);

%%  Load the fitParams we have to work with

if acquisitionNumber ~= 7 && ~strcmp(acquisitionNumber, 'pupilCalibration')
    acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
else
    acquisitionFolderName = 'pupilCalibration';
end

if isempty(p.Results.trialNumber)
    fitParamsSaveName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams.mat']);
    if ~exist(fitParamsSaveName)   
        warning('FitParams not saved for acquisition. Loading fitParams for the session.')
        fitParamsSaveName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, ['fitParams.mat']);
    end
else
    if acquisitionNumber ~= 7 && ~strcmp(acquisitionNumber, 'pupilCalibration')
        runName = sprintf('trial_%03d', trialNumber);
    else
        runName = pathParams.runNames{end};
    end
    fitParamsSaveName = fullfile(pathParams.dataOutputDirBase, pathParams.subject, pathParams.session, acquisitionFolderName, ['fitParams_', runName, '.mat']);
end
load(fitParamsSaveName);

%% Allow user to adjust params
if isempty(p.Results.paramName)
params = fieldnames(fitParams);
fprintf('Select the parameter you would like to adjust:\n')
counter = 1;
for ii = 1:length(params)
    %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
    fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
    fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
    counter = counter + 1;
end
fprintf('\t%d. Add additional parameter\n', counter);


choice = input('\nYour choice: ', 's');
if ~isempty(choice)
    if str2num(choice) ~= counter
        paramOfInterest = params{str2num(choice)};
        string = sprintf('Enter new %s:      \n', paramOfInterest);
        answer = input(string, 's');
        if strcmp(answer, 'true') || strcmp(answer, 'false')
            if strcmp(answer, 'true')
                fitParams.(paramOfInterest) = true;
            elseif strcmp(answer, 'false')
                fitParams(paramOfInterest) = false;
            end
        else
            fitParams.(paramOfInterest) = str2num(answer);
        end
        
    else
        paramName = input('Enter new param name:       ', 's');
        answer = input(sprintf('Enter %s:       ', paramName), 's');
        if strcmp(answer, 'true') || strcmp(answer, 'false')
            if strcmp(answer, 'true')
                fitParams.(paramName) = true;
            elseif strcmp(answer, 'false')
                fitParams.(paramName) = false;
            end
        else
            fitParams.(paramName) = str2num(answer);
        end
        
    end
    
    params = fieldnames(fitParams);
    fprintf('Current params:\n')
    counter = 1;
    for ii = 1:length(params)
        %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
        fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
        fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
        counter = counter + 1;
    end
    adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
    if ~strcmp(adjustParamsChoice, 'y')
        params = fieldnames(fitParams);
        
        adjustParamsFlag = false;
        while ~adjustParamsFlag
            fprintf('Select the parameter you would like to adjust:\n')
            counter = 1;
            for ii = 1:length(params)
                %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
                fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
                fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
                counter = counter + 1;
            end
            fprintf('\t%d. Add additional parameter\n', counter);
            
            
            choice = input('\nYour choice: ', 's');
            if ~isempty(choice)
                if str2num(choice) ~= counter
                    paramOfInterest = params{str2num(choice)};
                    string = sprintf('Enter new %s:      \n', paramOfInterest);
                    answer = input(string, 's');
                    if strcmp(answer, 'true') || strcmp(answer, 'false')
                        if strcmp(answer, 'true')
                            fitParams.(paramOfInterest) = true;
                        elseif strcmp(answer, 'false')
                            fitParams(paramOfInterest) = false;
                        end
                    else
                        fitParams.(paramOfInterest) = str2num(answer);
                    end
                    
                else
                    paramName = input('Enter new param name:       ', 's');
                    answer = input(sprintf('Enter %s:       ', paramName), 's');
                    if strcmp(answer, 'true') || strcmp(answer, 'false')
                        if strcmp(answer, 'true')
                            fitParams.(paramName) = true;
                        elseif strcmp(answer, 'false')
                            fitParams(paramName) = false;
                        end
                    else
                        fitParams.(paramName) = str2num(answer);
                    end
                    
                end
                
                params = fieldnames(fitParams);
                fprintf('Current params:\n')
                counter = 1;
                for ii = 1:length(params)
                    %[fprintf('\t%d. ellipseTransparentUB: ', counter) fitParams.(params{ii})(:), '\n'];
                    fmt = ['\t%d. %s: ', repmat('%g ', 1, numel(fitParams.(params{ii}))-1), '%g\n'];
                    fprintf(fmt, counter, params{ii}, fitParams.(params{ii})(:));
                    counter = counter + 1;
                end
            end
            adjustParamsChoice = GetWithDefault('>> Satisfied with these parameters? Enter ''y'' to proceed and exit, or ''n'' to manually adjust the parameters. [y/n]', 'y');
            switch adjustParamsChoice
                case 'y'
                    adjustParamsFlag = true;
                case 'n'
                    adjustParamsFlag = false;
                    close all
            end
        end
    end
end
else
   fitParams.(p.Results.paramName) = p.Results.paramValue; 
end


%% Save out adjust params
save(fitParamsSaveName, 'fitParams');

end

