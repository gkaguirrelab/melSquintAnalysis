function [ initialParameters ] = transparentTrackGUI(grayVideoName)

videoInObj = VideoReader(grayVideoName);
thisFrame = readFrame(videoInObj);
thisFrame = squeeze(thisFrame);

videoSizeX = videoInObj.Width;
videoSizeY = videoInObj.Height;
figure;
imshow(thisFrame, 'Border', 'tight')
hold on

[x,y] = ginput;

ellipseTransparentUB = [1280, 720, 90000, 0.6, pi];
ellipseTransparentLB = [0, 0, 1000, 0, 0];
[ellipseFitParams] = constrainedEllipseFit(x,y, ellipseTransparentLB, ellipseTransparentUB, []);

explicitEllipseFitParams = ellipse_transparent2ex(ellipseFitParams);

pFitImplicit = ellipse_ex2im(explicitEllipseFitParams);
fh=@(x,y) pFitImplicit(1).*x.^2 +pFitImplicit(2).*x.*y +pFitImplicit(3).*y.^2 +pFitImplicit(4).*x +pFitImplicit(5).*y +pFitImplicit(6);
% superimpose the ellipse using fimplicit or ezplot (ezplot
% is the fallback option for older Matlab versions)
hold on
fimplicit(fh,[1, videoSizeX, 1, videoSizeY],'Color', 'green','LineWidth',1);
set(gca,'position',[0 0 1 1],'units','normalized')
axis off;


% make pupilMask
% figure out smaller ellipse axis
if explicitEllipseFitParams(3) > explicitEllipseFitParams(4)
    circleRadius = explicitEllipseFitParams(4);
else
    circleRadius = explicitEllipseFitParams(3);
end

shrinkFactor = 0.9;
pupilMask = zeros(size(thisFrame));
pupilMask = insertShape(pupilMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*shrinkFactor],'Color','white');
pupilMask = im2bw(pupilMask);
thisFrameRGB = rgb2gray(thisFrame);
maskedPupil = immultiply(thisFrameRGB,pupilMask);
maskedPupilNaN=double(maskedPupil);
maskedPupilNaN(maskedPupil == 0) = NaN;
pupilMaskDilationFactor = 1.5;
initialParams.pupilFrameMask = [round(explicitEllipseFitParams(2)-explicitEllipseFitParams(4)*pupilMaskDilationFactor) ...
    round(videoSizeX - (explicitEllipseFitParams(1)+explicitEllipseFitParams(3)*pupilMaskDilationFactor)) ...
    round(videoSizeY - (explicitEllipseFitParams(2)+explicitEllipseFitParams(4)*pupilMaskDilationFactor)) ...
    round(explicitEllipseFitParams(1)-explicitEllipseFitParams(3)*pupilMaskDilationFactor)];

% figure out initial pupil range
pupilRangeDilator = 1.1;
pupilRangeContractor = 0.9;
initialParams.pupilRange = [round(circleRadius*pupilRangeContractor) round(circleRadius*pupilRangeDilator)];


% find the glint
[x,y] = ginput(2);
glintMaskPaddingFactor = 50;
glintXPosition = mean(x);
glintYPositionLower = max(y);
glintYPositionUpper = min(y);
initialParams.glintFrameMask = [round(glintYPositionUpper - glintMaskPaddingFactor) ...
    round(videoSizeX - (glintXPosition + glintMaskPaddingFactor)) ...
    round(videoSizeY - (glintYPositionLower + glintMaskPaddingFactor)) ...
    round(glintXPosition - glintMaskPaddingFactor)];

% make irisMask
innerDilationFactor = 1.1;
outerDilationFactor = 1.3;
irisMask = zeros(size(thisFrame));
innerIrisMask = insertShape(irisMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*innerDilationFactor],'Color','white');
outerIrisMask = insertShape(irisMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*outerDilationFactor],'Color','white');

innerIrisMask = im2bw(innerIrisMask);
outerIrisMask = im2bw(outerIrisMask);
differentialIrisMask = outerIrisMask - innerIrisMask;
differentialIrisMask = im2bw(differentialIrisMask);

maskedIris = immultiply(thisFrameRGB, differentialIrisMask);
maskedIrisNaN = double(maskedIris);
maskedIrisNaN(maskedIris == 0) = NaN;

% find pupilCircleThresh
pupilGammaCorrection = 0.75;
frameMaskValue = 220;
thisFrameMasked = imadjust(thisFrame,[],[],pupilGammaCorrection);
thisFrameMasked = rgb2gray(thisFrameMasked);
thisFrameMasked((1:initialParams.pupilFrameMask(1)),:) = frameMaskValue; %top
thisFrameMasked(:, (end - initialParams.pupilFrameMask(2):end)) = frameMaskValue; %left
thisFrameMasked((end - initialParams.pupilFrameMask(3):end),:) = frameMaskValue; %bottom
thisFrameMasked(:, (1:initialParams.pupilFrameMask(4))) = frameMaskValue; %right

I = thisFrameMasked;
filtSize = round([0.01*min(size(I)) 0.01*min(size(I)) 0.01*min(size(I))]);
padP = padarray(I,[size(I,1)/2 size(I,2)/2], 128);
h = fspecial('gaussian',[filtSize(1) filtSize(2)],filtSize(3));
pI = imfilter(padP,h);
pI = pI(size(I,1)/2+1:size(I,1)/2+size(I,1),size(I,2)/2+1:size(I,2)/2+size(I,2));

%intensityDivider = nanmean([maskedPupilNaN(:); maskedIrisNaN(:)]);
intensityDivider = min(maskedIrisNaN(:));
minThreshValue = 0.001;
maxThreshValue = 0.2;
threshStep = 0.001;
potentialThreshValues = [minThreshValue:threshStep:maxThreshValue];
counter = 1; for xx = potentialThreshValues; y(counter) = quantile(double(pI(:)),xx); counter = counter+1; end
potentialIndices = find(abs(y-intensityDivider) <= 1);

pupilCircleThresh = potentialThreshValues(min(potentialIndices));
initialParams.pupilCircleThresh = pupilCircleThresh;




end