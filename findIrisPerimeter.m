function [ center, radius ] = findIrisPerimeter(grayImageFile, pupilFile)
%{
Example

subjectID = 'MELA_0122';

sessionID = 1;
acquisitionNumber = 1;
trialNumber = 1;

[ defaultFitParams, cameraParams, pathParams, sceneParams ] = getDefaultParams('approach', 'Squint','protocol', 'SquintToPulse');

pathParams.subject = subjectID;
if isnumeric(sessionID)
    sessionDir = dir(fullfile(pathParams.dataSourceDirFull, pathParams.subject, ['2*session_', num2str(sessionID)]));
    sessionID = sessionDir(end).name;
end

if acquisitionNumber ~= 7 && ~strcmp(acquisitionNumber, 'pupilCalibration')
    acquisitionFolderName = sprintf('videoFiles_acquisition_%02d', acquisitionNumber);
else
    acquisitionFolderName = 'pupilCalibration';
end

if ~isnumeric(trialNumber)
    runName = trialNumber;
elseif acquisitionNumber == 7 || strcmp(acquisitionNumber, 'pupilCalibration')
    runName = pathParams.runNames{end};
else
    runName = sprintf('trial_%03d', trialNumber);
end

videoFileName = fullfile(pathParams.dataSourceDirFull, subjectID, sessionID, acquisitionFolderName, [runName, '.mp4']);
saveName = strrep(strrep(videoFileName, 'MELA_data', 'MELA_processing'), '.mp4', 'mean.jpg');

createMeanFrameFromVideo(videoFileName, 'saveName', saveName);
pupilFile = fullfile(pathParams.dataOutputDirBase, subjectID, sessionID, acquisitionFolderName, [runName, '_pupil.mat']);

findIrisPerimeter(saveName, pupilFile);

%}

%% Magic values
showDebugPlots = false;

%% Use the pupil file to start to learn about some of the aspects of the scene
load(pupilFile)

% use the center of the found ellipses to say where the center of the
% pupil, and therefore the iris is
irisCenterX = nanmean(pupilData.initial.ellipses.values(:,1));
irisCenterY = nanmean(pupilData.initial.ellipses.values(:,2));

% calculate the mean pupil radius. this is useful because the iris has to
% be at least a bit bigger than this.
meanRadius = nanmean(sqrt((pupilData.initial.ellipses.values(:,3)/pi)));

%% Begin the iris finding
% Load up our image
grayImage = imread(grayImageFile);

% State where we're going to be looking for iris edges
angleRange = -20:1:20;
sides = {'left', 'right'};

% pre-allocate results
ellipseX = [];
ellipseY = [];

for aa = angleRange
    for side = 1:length(sides)
        
        % The basic loop will be to 1) define a vector along the specified
        % angle, 2) extract all pixel values along that vector in our
        % averaged image, 3) and analyze how the pixel values change as a
        % function of distance.
        
        % More specifically, the change in pixel value as a function of
        % distance highlights where boundaries occur. There's a first
        % massive spike for the pupil boundary, but then there's  clear
        % spike for where the iris occurs. The rest of the loop is some
        % logic to grab the location of that iris peak.
        
        % First create the vector starting from the center of the pupil
        % extending in the specified angle and direction.
        if strcmp(sides{side}, 'left')
            x(2) = 1;
        else
            x(2) = size(grayImage,2);
        end
        x(1) = irisCenterX;
        y(1) = irisCenterY;
        y(2) = tand(aa)*(abs(x(1) - x(2)))+y(1);

        
        if showDebugPlots
            plotFig = figure; hold on;
            subplot(1,3,1); hold on;
            imshow(grayImage, 'Border', 'tight'); hold on;
            plot(irisCenterX, irisCenterY, 'X', 'Color', 'r')
            subplot(1,3,1); hold on;
            plot(x,y);
        end
        
        % extract pixel values along that vector
        values = improfile(grayImage, x, y);
        
        % we know the pupil to be about a certain radius, so define a
        % cutoff a bit after for which to begin to look for the iris. This
        % helps to avoid the big peak corresponding to the pupil boundary.
        pupilRadiusExtender = 1.1;
        pupilRangeToCutOff = ceil(meanRadius*pupilRadiusExtender);
        
        if showDebugPlots
            ax2 = subplot(1,3,2); hold on;
            plot(values);
            line([pupilRangeToCutOff, pupilRangeToCutOff], [ax2.YLim(1), ax2.YLim(2)], 'Color', 'r');
            
            ax3 = subplot(1,3,3); hold on;
            plot(smoothedDiffValues)
            line([pupilRangeToCutOff, pupilRangeToCutOff], [ax3.YLim(1), ax3.YLim(2)], 'Color', 'r');
        end
        
        
        % Find the beginning of the iris region. This corresponds to when
        % the pupil boundary has ended (the valley after the pupil peak).
        % beginning of the iris
        smoothedDiffValues = smoothdata(diff(values),'gaussian', 20);

        [~, minLocations] = findpeaks(-smoothedDiffValues);
        beginningOfIris = find(minLocations > pupilRangeToCutOff);
        beginningOfIris = minLocations(beginningOfIris(1));
        
        
        % Find the end of the iris. This corresponds to the largest peak in
        % pixel differential that occurs relatively closely to the pupil
        % boundary.
        % Note this part is the trickiest to get right: it's not
        % necessarily the largest peak after the pupil boundary (as
        % sometimes values closer to the edge of the frame take these
        % values). It doesn't also seem to be a particularly well defined
        % number of peaks away. What I've done here is to define a general
        % number of peaks to consider, and then identify the largest of
        % these and assume that's the iris boundary.
        
        numberOfPeaksToConsider = 15;
        [~, maxLocations] = findpeaks(smoothedDiffValues);        
        possibleRelevantPeakLocationsBeyondPupil = find(maxLocations > beginningOfIris);        
        if numberOfPeaksToConsider > length(possibleRelevantPeakLocationsBeyondPupil)
            possibleRelevantPeakLocationsBeyondPupil = maxLocations(possibleRelevantPeakLocationsBeyondPupil(1:end));
            
        else
            possibleRelevantPeakLocationsBeyondPupil = maxLocations(possibleRelevantPeakLocationsBeyondPupil(1:numberOfPeaksToConsider));
        end
        [~, maxPeakNumber ] = max(smoothedDiffValues(possibleRelevantPeakLocationsBeyondPupil));
        maxPeakIndex = possibleRelevantPeakLocationsBeyondPupil(maxPeakNumber);        
        
        % ultimately the iris boundary seems to be best characterized as
        % the midway point between the peak and its neighboring valley.
        [~, minLocations] = findpeaks(-smoothedDiffValues);
        if maxPeakIndex > max(minLocations)
            endOfIris = [];
        else
        minPeakIndex = find(minLocations > maxPeakIndex);
        minPeakIndex = minLocations(minPeakIndex(1));
        endOfIris = mean([maxPeakIndex, minPeakIndex]);
        end
       
        
        
        
        
        
        % add to the plot
        if showDebugPlots
            subplot(1,3,2);
            plot(endOfIris, values(round(endOfIris)), 'X', 'Color', 'r');
            
            subplot(1,3,3);
            plot(endOfIris, smoothedDiffValues(round(endOfIris)), 'X', 'Color', 'r');
        end
        
        % Now if we've found something, stash it away        
        if ~isempty(endOfIris)
            distanceAlongVector = endOfIris;
            
            % compute x and y distance away from the center of the iris
            xDistance = cosd(aa) * distanceAlongVector;
            yDistance = sind(aa) * distanceAlongVector;
            
            % convert to x and y position
            if strcmp(sides{side}, 'left')
                xIntersection = x(1) - xDistance;
            else
                xIntersection = x(1) + xDistance;
            end
            yIntersection = y(1) + yDistance;

            if showDebugPlots
                subplot(1,3,1);
                plot(xIntersection, yIntersection, 'X', 'Color', 'R', 'MarkerSize', 14);
            end
            
            % stash result
            ellipseX(end+1) = xIntersection;
            ellipseY(end+1) = yIntersection;
        end
        
        if showDebugPlots
            set(gcf, 'Position', [-1975 126 1445 859]);
            close all
        end
    end
    
    
end

%% Now we have a list of iris boundary locations. Let's use them to define the iris
% Show the found iris boundary locations;
figure; imshow(squeeze(grayImage)); hold on; plot(ellipseX, ellipseY, 'X', 'Color', 'G', 'MarkerSize', 14)

% However, there's a good chance that a number of the identified points
% will be crappy. I'm using a tight range around the median distance from
% center to boundary position to define a good iris candidate boundary
% point.

% compute distances for each potential iris boundary position to the center
% of the iris
for ii = 1:length(ellipseX)
    distance(ii) = sqrt((ellipseX(ii) - irisCenterX)^2 + (ellipseY(ii) - irisCenterY)^2);
end

% discard iris boundary points that are too 
goodDistances = [];
badDistanceIndices = [];
goodEllipseX = [];
goodEllipseY = [];

limit = 0.1;
for ii = 1:length(distance)
    if distance(ii) < median(distance)* (1+limit) && distance(ii) > median(distance) * (1 - limit)
        goodDistances(end+1) = distance(ii);
        goodEllipseX(end+1) = ellipseX(ii);
        goodEllipseY(end+1) = ellipseY(ii);
    else
        badDistanceIndices(end+1) = ii;
    end
end

% show the bad points
plot(ellipseX(badDistanceIndices), ellipseY(badDistanceIndices), 'X', 'Color', 'r', 'MarkerSize', 14);


% I have here two potential methods to define the iris boundary on the
% basis of these points. First is to try to fit an ellipse to the iris
% boundaries. This was problematic in early versions (perhaps I didn't find
% enough points?).
doEllipseFit = false;
if doEllipseFit
    % fit an ellipse to the inputted points
    ellipseTransparentUB = [irisCenterX+50, irisCenterY+50, 1000000, 0.6, pi];
    ellipseTransparentLB = [irisCenterX-50, irisCenterY-50, meanRadius^2*pi, 0, 0];
    [ellipseFitParams] = constrainedEllipseFit(goodEllipseX,goodEllipseY, ellipseTransparentLB, ellipseTransparentUB, []);
    
    % convert the ellipse params from transparent params to explicit params
    explicitEllipseFitParams = ellipse_transparent2ex(ellipseFitParams);
    
    % convert the explicit ellipse params to implicit
    pFitImplicit = ellipse_ex2im(explicitEllipseFitParams);
    % write the implicit function on teh basis of these params
    fh=@(xFunc,yFunc) pFitImplicit(1).*xFunc.^2 +pFitImplicit(2).*xFunc.*yFunc +pFitImplicit(3).*yFunc.^2 +pFitImplicit(4).*xFunc +pFitImplicit(5).*yFunc +pFitImplicit(6);
    % superimpose the ellipse using fimplicit
    hold on
    fHandle = fimplicit(fh,[1, size(grayImage,1), 1, size(grayImage,2)],'Color', 'green','LineWidth',1);
    set(gca,'position',[0 0 1 1],'units','normalized')
end

% The second version is just to assume the iris is a circle, and calculate
% the average radius.
drawMeanCircle = true;
if drawMeanCircle
    
    
    
    
    
    
    meanIrisRadius = mean(goodDistances);
    viscircles([irisCenterX, irisCenterY], meanIrisRadius, 'Color', 'b');
    
    
end

end