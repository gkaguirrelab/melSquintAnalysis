function [ initialParams ] = transparentTrackGUI(grayVideoName, defaultParams, varargin)

%% Input parser
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('grayVideoName',@isstr);


% Optional flow control params
p.addParameter('frameNumber',1,@isnumeric);
p.addParameter('openVideo',true,@islogical);
p.addParameter('verbose',true,@islogical);



% automatic default parameters in case no default parameters are provided
p.addParameter('ellipseTransparentUB', [1280, 720, 90000, 0.6, pi], @isnumeric);
p.addParameter('ellipseTransparentLB', [0, 0, 1000, 0, 0], @isnumeric);
p.addParameter('pupilGammaCorrection', 0.75, @isnumeric);
p.addParameter('frameMaskValue', 220, @isnumeric);

% parameters to
p.addParameter('pupilMaskShrinkFactor', 0.9, @isnumeric);
p.addParameter('pupilMaskDilationFactor', 4, @isnumeric);
p.addParameter('pupilRangeDilator', 1.2, @isnumeric);
p.addParameter('pupilRangeContractor', 0.8, @isnumeric);
p.addParameter('innerDilationFactor', 1.1, @isnumeric);
p.addParameter('outerDilationFactor', 1.3, @isnumeric);
p.addParameter('potentialThreshValues', [0.001:0.001:0.2], @isnumeric);
p.addParameter('intensityDividerComputeMethod', 'irisMaskMinimum', @isstr);
p.addParameter('glintMaskPaddingFactor', 50, @isnumeric);

% parse
p.parse(grayVideoName, varargin{:})

if ~isfield(defaultParams, 'ellipseTransparentUB')
    ellipseTransparentUB = p.Results.ellipseTransparentUB;
else
    ellipseTransparentUB = defaultParams.ellipseTransparentUB;
end

if ~isfield(defaultParams, 'ellipseTransparentLB')
    ellipseTransparentLB = p.Results.ellipseTransparentLB;
else
    ellipseTransparentLB = defaultParams.ellipseTransparentLB;
end

if ~isfield(defaultParams, 'pupilGammaCorrection')
    pupilGammaCorrection = p.Results.pupilGammaCorrection;
else
    pupilGammaCorrection = defaultParams.pupilGammaCorrection;
end

if ~isfield(defaultParams, 'frameMaskValue')
    frameMaskValue = p.Results.frameMaskValue;
else
    frameMaskValue = defaultParams.frameMaskValue;
end

if ~isfield(defaultParams, 'numberOfGlints')
    numberOfGlints = p.Results.numberOfGlints;
else
    numberOfGlints = defaultParams.numberOfGlints;
end


%% Load up the frame of interest
videoInObj = VideoReader(grayVideoName);
nFrames = floor(videoInObj.Duration*videoInObj.FrameRate);
videoSizeX = videoInObj.Width;
videoSizeY = videoInObj.Height;
grayVideo = zeros(videoSizeY,videoSizeX,nFrames,'uint8');


%thisFrame = readFrame(videoInObj);
%thisFrame = squeeze(thisFrame);
for ii = 1:nFrames
    thisFrame = readFrame(videoInObj);
    %        thisFrame = imadjust(thisFrame,[],[],p.Results.glintGammaCorrection);
    grayVideo(:,:,ii) = rgb2gray (thisFrame);
end

thisFrame = squeeze(grayVideo(:,:,p.Results.frameNumber));

% open video file, if asked
if p.Results.openVideo
    [recordedErrorFlag, consoleOutput] = system(['open ''' grayVideoName '''']);
end

% present the video frame

figure;
imshow(thisFrame, 'Border', 'tight')
hold on

%% Guess initial pupil position
% begin user input
fprintf('Define pupil boundary in figure.\n')
string = 'Define the pupil boundary by clicking along the pupil perimeter. Press ENTER when finished.';
hText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
[x,y] = ginput;

delete(hText)
% fit an ellipse to the inputted points
[ellipseFitParams] = constrainedEllipseFit(x,y, ellipseTransparentLB, ellipseTransparentUB, []);

% convert the ellipse params from transparent params to explicit params
explicitEllipseFitParams = ellipse_transparent2ex(ellipseFitParams);

% convert the explicit ellipse params to implicit
pFitImplicit = ellipse_ex2im(explicitEllipseFitParams);
% write the implicit function on teh basis of these params
fh=@(x,y) pFitImplicit(1).*x.^2 +pFitImplicit(2).*x.*y +pFitImplicit(3).*y.^2 +pFitImplicit(4).*x +pFitImplicit(5).*y +pFitImplicit(6);
% superimpose the ellipse using fimplicit
hold on
fHandle = fimplicit(fh,[1, videoSizeX, 1, videoSizeY],'Color', 'green','LineWidth',1);
set(gca,'position',[0 0 1 1],'units','normalized')
axis off;

% ask if we need to redo ellipse placement
pupilCheckChoice = GetWithDefault('>> Satisfied with ellipse fit? Enter ''y'' to proceed, or ''n'' to redraw. [y/n]', 'y');
if ~strcmp(pupilCheckChoice, 'y')
    delete(fHandle);
    
    pupilEllipseDoneFlag = false;
    while ~pupilEllipseDoneFlag
        string = 'Define the pupil boundary by clicking along the pupil perimeter. Press ENTER when finished.';
        hText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
        [x,y] = ginput;
        
        delete(hText)
        % fit an ellipse to the inputted points
        [ellipseFitParams] = constrainedEllipseFit(x,y, ellipseTransparentLB, ellipseTransparentUB, []);
        
        % convert the ellipse params from transparent params to explicit params
        explicitEllipseFitParams = ellipse_transparent2ex(ellipseFitParams);
        
        % convert the explicit ellipse params to implicit
        pFitImplicit = ellipse_ex2im(explicitEllipseFitParams);
        % write the implicit function on teh basis of these params
        fh=@(x,y) pFitImplicit(1).*x.^2 +pFitImplicit(2).*x.*y +pFitImplicit(3).*y.^2 +pFitImplicit(4).*x +pFitImplicit(5).*y +pFitImplicit(6);
        % superimpose the ellipse using fimplicit
        hold on
        fHandle = fimplicit(fh,[1, videoSizeX, 1, videoSizeY],'Color', 'green','LineWidth',1);
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off;
        
        pupilCheckChoice = GetWithDefault('>> Satisfied with ellipse fit? Enter ''y'' to proceed, or ''n'' to redraw. [y/n]', 'y');
      
        switch pupilCheckChoice
            case 'y'
                pupilEllipseDoneFlag = true;
                
            case 'n'
                pupilEllipseDoneFlag = false;
                delete(fHandle);
            otherwise
        end
    end
end

%% Figure out the pupil frame

% figure out smaller ellipse axis
if explicitEllipseFitParams(3) > explicitEllipseFitParams(4)
    circleRadius = explicitEllipseFitParams(4);
else
    circleRadius = explicitEllipseFitParams(3);
end

% we'll take the center of the ellipse, and then extend out along from the
% expanded pupil radius to define the pupilFrameMask
initialParams.pupilFrameMask = [round(explicitEllipseFitParams(2)-explicitEllipseFitParams(4)*p.Results.pupilMaskDilationFactor) ...
    round(videoSizeX - (explicitEllipseFitParams(1)+explicitEllipseFitParams(3)*p.Results.pupilMaskDilationFactor)) ...
    round(videoSizeY - (explicitEllipseFitParams(2)+explicitEllipseFitParams(4)*p.Results.pupilMaskDilationFactor)) ...
    round(explicitEllipseFitParams(1)-explicitEllipseFitParams(3)*p.Results.pupilMaskDilationFactor)];

%% Figure out initial pupil range
% make the lower bound a little smaller, and upper bound bigger, than the
% user-inputted pupil ellipse
initialParams.pupilRange = [round(circleRadius*p.Results.pupilRangeContractor) round(circleRadius*p.Results.pupilRangeDilator)];

%% Figure out the glinFrametMask
% Ask the user to define the position of the two glints
fprintf('Define glint position in figure.\n')
string = sprintf('Define the glint position by clicking each of the %d glints.', numberOfGlints);
hText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
[x,y] = ginput(2);
gHandle = plot(x ,y, '+', 'Color', 'red');

% ask if we need to redo glint placement
glintCheckChoice = GetWithDefault('>> Satisfied with glint locations? Enter ''y'' to proceed, or ''n'' to redraw. [y/n]', 'y');
if ~strcmp(glintCheckChoice, 'y')
    delete(gHandle);   
    glintDoneFlag = false;
    while ~glintDoneFlag
        string = sprintf('Define the glint position by clicking each of the %d glints.', numberOfGlints);
                hText = text(1,10,string, 'FontSize', 16, 'BackgroundColor', 'white');
                [x,y] = ginput(2);
                gHandle = plot(x ,y, '+', 'Color', 'red');
                glintCheckChoice = GetWithDefault('>> Satisfied with glint locations? Enter ''y'' to proceed, or ''n'' to redraw. [y/n]', 'y');
        switch glintCheckChoice
            case 'y'
                glintDoneFlag = true;
            case 'n'
                glintDoneFlag = false;
                delete(gHandle);
        end
    end
end

% assume the middle x coordinate of the glintFrameMask should be the
% average of the two x positions of each glint
glintXPosition = mean(x);

% define upper and lower glint positions
glintYPositionLower = max(y);
glintYPositionUpper = min(y);

% expand beyond these positions to define to the glintFrameMask
initialParams.glintFrameMask = [round(glintYPositionUpper - p.Results.glintMaskPaddingFactor) ...
    round(videoSizeX - (glintXPosition + p.Results.glintMaskPaddingFactor)) ...
    round(videoSizeY - (glintYPositionLower + p.Results.glintMaskPaddingFactor)) ...
    round(glintXPosition - p.Results.glintMaskPaddingFactor)];
close all

%% Figure out the pupilCircleThresh
% define a pupil mask. we're interested in figuring out what values make up
% the user-defined pupil

% instantiate mask
pupilMask = zeros(size(thisFrame));

% add circle to mask, corresponding to the position of the user-defined
% circle. we'll make the circle a slightly smaller radius so we're not
% accidentally getting any iris
pupilMask = insertShape(pupilMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*p.Results.pupilMaskShrinkFactor],'Color','white');
%binarize the mask
pupilMask = im2bw(pupilMask);
% conver thisFrame so we can do some math with it
%thisFrameRGB = rgb2gray(thisFrame);
thisFrameRGB = thisFrame;

% apply the pupilMask to the image, which gives us just the maskedPupil
maskedPupil = immultiply(thisFrameRGB,pupilMask);
% set all values of 0 (ie not pupil) to NaN, for ease of understanding the
% statistics
maskedPupilNaN=double(maskedPupil);
maskedPupilNaN(maskedPupil == 0) = NaN;

% make irisMask
irisMask = zeros(size(thisFrame));
% we'll define two circles, the inner corresponding to the inner iris-pupil
% boundary, the outer corresponding to some circle in the middle of the
% iris. we find these circles by dilating the original pupilCircle, first
% by a little bit (to make the innerIrisMask), then by a little bit more
% (to create the outerIrisMask)
innerIrisMask = insertShape(irisMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*p.Results.innerDilationFactor],'Color','white');
outerIrisMask = insertShape(irisMask,'FilledCircle',[explicitEllipseFitParams(1) explicitEllipseFitParams(2) circleRadius*p.Results.outerDilationFactor],'Color','white');
% binarize these masks
innerIrisMask = im2bw(innerIrisMask);
outerIrisMask = im2bw(outerIrisMask);
% take the difference, which should just be the iris
differentialIrisMask = outerIrisMask - innerIrisMask;
differentialIrisMask = im2bw(differentialIrisMask);

% apply this mask to the image
maskedIris = immultiply(thisFrameRGB, differentialIrisMask);
maskedIrisNaN = double(maskedIris);
% set all 0 values to NaN, again for ease of statistical analysis
maskedIrisNaN(maskedIris == 0) = NaN;

% the findPupilPerimeter code. first we have to manipulate the image a
% little bit, to mimic some of the settings applied to the relevant region
% as part of the findPupilPerimeter routine. we want to figure out the
% proper value that will be used there, so we'll set up the environment so
% that it'll be the same
% gamma correct the image
thisFrameMasked = imadjust(thisFrame,[],[],pupilGammaCorrection);

% conver to grayscale
%thisFrameMasked = rgb2gray(thisFrameMasked);

% make the image, according to pupilFrameMask
thisFrameMasked((1:initialParams.pupilFrameMask(1)),:) = frameMaskValue; %top
thisFrameMasked(:, (end - initialParams.pupilFrameMask(2):end)) = frameMaskValue; %left
thisFrameMasked((end - initialParams.pupilFrameMask(3):end),:) = frameMaskValue; %bottom
thisFrameMasked(:, (1:initialParams.pupilFrameMask(4))) = frameMaskValue; %right

% smooth the image
I = thisFrameMasked;
filtSize = round([0.01*min(size(I)) 0.01*min(size(I)) 0.01*min(size(I))]);
padP = padarray(I,[size(I,1)/2 size(I,2)/2], 128);
h = fspecial('gaussian',[filtSize(1) filtSize(2)],filtSize(3));
pI = imfilter(padP,h);
pI = pI(size(I,1)/2+1:size(I,1)/2+size(I,1),size(I,2)/2+1:size(I,2)/2+size(I,2));

% figure out the intensity value that differentiates the pupil from the
% iris
if strcmp(p.Results.intensityDividerComputeMethod, 'mean')
    % one way to do so is to take the average of the values corresponding
    % to the pupil and iris, such that our dividing point is somewhere in
    % between
    intensityDivider = nanmean([maskedPupilNaN(:); maskedIrisNaN(:)]);
elseif strcmp(p.Results.intensityDividerComputeMethod, 'irisMaskMinimum')
    % alternatively, we can take the dividing point as the minimum value
    % observed in the iris
    intensityDivider = min(maskedIrisNaN(:));
else
    warning('Intensity divider compute method not found. Please use either ''mean'' or ''irisMaskMinimum''')
end

% i don't know of an analytical way to solve this quantile function, so
% i'll brute-force check what pupilCircleThresh value provides a cutoff
% closest to our intended intensityDivider
counter = 1;
for xx = p.Results.potentialThreshValues
    y(counter) = quantile(double(pI(:)),xx);
    counter = counter+1;
end
[minValue, potentialIndices] = min(abs(y-intensityDivider));

pupilCircleThresh = p.Results.potentialThreshValues(min(potentialIndices)-1);
initialParams.pupilCircleThresh = pupilCircleThresh;

if p.Results.verbose
    initialParams
end


end