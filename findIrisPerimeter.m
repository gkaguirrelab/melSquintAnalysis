function [ center, radius ] = findIrisPerimeter(grayImageFile, pupilFile)
%{
Example

subjectID = 'MELA_0206';

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

load(pupilFile)

irisCenterX = nanmean(pupilData.initial.ellipses.values(:,1));
irisCenterY = nanmean(pupilData.initial.ellipses.values(:,2));

meanRadius = nanmean(sqrt((pupilData.initial.ellipses.values(:,3)/pi)));


grayImage = imread(grayImageFile);

I = grayImage;

% look for edges
bw1 = edge(grayImage, 'sobel');

bw1_double = double(bw1);

bw1 = imgaussfilt(bw1_double, 5);


angleRange = -20:1:20;
sides = {'left', 'right'};

ellipseX = [];
ellipseY = [];

for aa = angleRange
    for side = 1:length(sides)
        
        
        if strcmp(sides{side}, 'left')
            x(2) = 1;
        else
            x(2) = size(grayImage,2);
        end
        x(1) = irisCenterX;
        y(1) = irisCenterY;
        
        plotFig = figure; hold on;
        
        subplot(1,3,1); hold on;
        imshow(grayImage, 'Border', 'tight'); hold on;
        plot(irisCenterX, irisCenterY, 'X', 'Color', 'r')
        y(2) = tand(aa)*(abs(x(1) - x(2)))+y(1);
        subplot(1,3,1); hold on;
        plot(x,y);
        
        values = improfile(grayImage, x, y);
        
        
        pupilRangeToCutOff = ceil(meanRadius*1.1);
        
        ax2 = subplot(1,3,2); hold on;
        plot(values);
        line([pupilRangeToCutOff, pupilRangeToCutOff], [ax2.YLim(1), ax2.YLim(2)], 'Color', 'r');
        
        ax3 = subplot(1,3,3); hold on;
        smoothedDiffValues = smoothdata(diff(values),'gaussian', 20);
        plot(smoothedDiffValues)
        line([pupilRangeToCutOff, pupilRangeToCutOff], [ax3.YLim(1), ax3.YLim(2)], 'Color', 'r');
        
        
        
        % beginning of the iris
        [~, minLocations] = findpeaks(-smoothedDiffValues);
        beginningOfIris = find(minLocations > pupilRangeToCutOff);
        beginningOfIris = minLocations(beginningOfIris(1));
        
        
        % find the end of the iris
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
        
        [~, minLocations] = findpeaks(-smoothedDiffValues);
        minPeakIndex = find(minLocations > maxPeakIndex);
        minPeakIndex = minLocations(minPeakIndex(1));
        endOfIris = mean([maxPeakIndex, minPeakIndex]);
       
        
        
        
        
        
        % add to the plot
        subplot(1,3,2);
        plot(endOfIris, values(round(endOfIris)), 'X', 'Color', 'r');
        
        subplot(1,3,3);
        plot(endOfIris, smoothedDiffValues(round(endOfIris)), 'X', 'Color', 'r');
        
        
        %[~, location] = findpeaks(smoothedValues(pupilRangeToCutOff:end));
        
        if ~isempty(endOfIris)
            distanceAlongVector = endOfIris;
            
            xDistance = cosd(aa) * distanceAlongVector;
            yDistance = sind(aa) * distanceAlongVector;
            
            if strcmp(sides{side}, 'left')
                xIntersection = x(1) - xDistance;
            else
                xIntersection = x(1) + xDistance;
            end
            yIntersection = y(1) + yDistance;
            %
            %             plotFig1;
            %             plot(xIntersection, yIntersection, 'X', 'Color', 'R', 'MarkerSize', 14);
            %
            subplot(1,3,1);
            plot(xIntersection, yIntersection, 'X', 'Color', 'R', 'MarkerSize', 14);
            ellipseX(end+1) = xIntersection;
            ellipseY(end+1) = yIntersection;
        end
        set(gcf, 'Position', [-1975 126 1445 859]);
        close all
    end
    
    
end

figure; imshow(squeeze(grayImage)); hold on; plot(ellipseX, ellipseY, 'X', 'Color', 'G', 'MarkerSize', 14)

doEllipseFit = false;

if doEllipseFit
    % fit an ellipse to the inputted points
    ellipseTransparentUB = [irisCenterX+50, irisCenterY+50, 90000, 0.6, pi];
    ellipseTransparentLB = [irisCenterX-50, irisCenterY-50, meanRadius^2*pi, 0, 0];
    [ellipseFitParams] = constrainedEllipseFit(ellipseX,ellipseY, ellipseTransparentLB, ellipseTransparentUB, []);
    
    % convert the ellipse params from transparent params to explicit params
    explicitEllipseFitParams = ellipse_transparent2ex(ellipseFitParams);
    
    % convert the explicit ellipse params to implicit
    pFitImplicit = ellipse_ex2im(explicitEllipseFitParams);
    % write the implicit function on teh basis of these params
    fh=@(x,y) pFitImplicit(1).*x.^2 +pFitImplicit(2).*x.*y +pFitImplicit(3).*y.^2 +pFitImplicit(4).*x +pFitImplicit(5).*y +pFitImplicit(6);
    % superimpose the ellipse using fimplicit
    hold on
    fHandle = fimplicit(fh,[1, size(grayImage,1), 1, size(grayImage,2)],'Color', 'green','LineWidth',1);
    set(gca,'position',[0 0 1 1],'units','normalized')
end

drawMeanCircle = true;
if drawMeanCircle
    
    for ii = 1:length(ellipseX)
        distance(ii) = sqrt((ellipseX(ii) - irisCenterX)^2 + (ellipseY(ii) - irisCenterY)^2);
    end
    
    goodDistances = [];
    badDistanceIndices = [];
    
    limit = 0.1;
    for ii = 1:length(distance)
        if distance(ii) < median(distance)* (1+limit) && distance(ii) > median(distance) * (1 - limit)
            goodDistances(end+1) = distance(ii);
        else
            badDistanceIndices(end+1) = ii;
        end
    end
    
    plot(ellipseX(badDistanceIndices), ellipseY(badDistanceIndices), 'X', 'Color', 'r', 'MarkerSize', 14);
    
    
    
    
    meanIrisRadius = mean(goodDistances);
    viscircles([irisCenterX, irisCenterY], meanIrisRadius, 'Color', 'b');
    
    
end

end