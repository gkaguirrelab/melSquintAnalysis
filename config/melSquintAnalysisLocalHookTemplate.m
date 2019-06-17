function melSquintAnalysisLocalHook
%  melSquintAnalysisLocalHook
%
% Configure things for working on the  melSquintAnalysis project.
%
% For use with the ToolboxToolbox.
%
% If you 'git clone' melSquintAnalysis into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('melSquintAnalysis')
% ToolboxToolbox will set up melSquintAnalysis and its dependencies on
% your machine.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/melSquintAnalysisLocalHook.m
%
% Each time you run tbUseProject('melSquintAnalysis'), ToolboxToolbox will
% execute your local copy of this file to do setup for melSquintAnalysis.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
fprintf('melSquintAnalysis local hook.\n');
projectName = 'melSquintAnalysis';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'melanopsin' 'pupillab'}
        materialsBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        MELA_dataBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
        MELA_processingBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_processing/'];
        MELA_analysisBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/'];
    case {'eyetrackingworker'}
        if exist('/Volumes/melchiorBayTwo', 'dir')
            materialsBasePath = ['/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
            MELA_dataBasePath = ['/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
            MELA_processingBasePath = ['/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)/MELA_processing/'];
            MELA_analysisBasePath = ['/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/'];
        end
        
    otherwise
        materialsBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        MELA_dataBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
        MELA_processingBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_processing/'];
        MELA_analysisBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/'];
        
end


%% Specify where output goes

if ismac
    % Code to run on Mac plaform
    setpref(projectName,'melaDataPath', MELA_dataBasePath);
    setpref(projectName,'melaAnalysisPath', MELA_analysisBasePath);
    setpref(projectName, 'melaProcessingPath', MELA_processingBasePath);
elseif isunix
    % Code to run on Linux plaform
    setpref(projectName,'melaDataPath', MELA_dataBasePath);
    setpref(projectName,'melaAnalysisPath', MELA_analysisBasePath);
    setpref(projectName, 'melaProcessingPath', MELA_processingBasePath);
elseif ispc
    % Code to run on Windows platform
    warning('No supported for PC')
else
    disp('What are you using?')
end
