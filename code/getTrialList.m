function [runNamesList, subfoldersList] = getTrialList(pathParams, varargin)

p = inputParser; p.KeepUnmatched = true;

p.addParameter('approach', 'Squint' ,@isstr);
p.addParameter('protocol', 'SquintToPulse' ,@isstr);

p.parse(varargin{:})




% figure out the relevant calibration video -- we want the last one created
% first see if any were made after the session. if so, that's the one we
% want


% now figure out the paths of the pulse trial videos
if strcmp(pathParams.protocol, 'Screening')
    for ii = 1:12
        runNames{ii} = sprintf('trial_%03d.mp4',ii);
        trialsSubfolders{ii} = 'videoFiles_acquisition_01';
    end
    runNamesList = [runNames];
    subfoldersList = [trialsSubfolders];
end

counter = 1;
if strcmp(pathParams.protocol, 'SquintToPulse')
    potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*post.mp4'));
    if ~isempty(potentialCalibrationVideos)
        calibrationRunName = [potentialCalibrationVideos(end).name];
        calibrationSubfolder = 'pupilCalibration';
    else
        potentialCalibrationVideos = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, pathParams.session, 'pupilCalibration', '*.mp4'));
        calibrationRunName = [potentialCalibrationVideos(end).name];
        calibrationSubfolder = 'pupilCalibration';
    end
    for aa = 1:6
        for ii = 1:10
            runNames{counter} = sprintf('trial_%03d.mp4', ii);
            trialsSubfolders{counter} = sprintf('videoFiles_acquisition_%02d', aa);
            counter = counter + 1;
        end
    end
    runNamesList = [runNames, calibrationRunName];
    subfoldersList = [trialsSubfolders, calibrationSubfolder];
end

%package all of the runNames up so now we have a list of all of the video


end