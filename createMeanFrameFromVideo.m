function [ meanFrame] = createMeanFrameFromVideo(videoFileName, varargin)

% input parser
p = inputParser; p.KeepUnmatched = true;

p.addOptional('videoFileName', [], @(x)(isempty(x) || ischar(x)));

p.addParameter('nFrames',Inf,@isnumeric);
p.addParameter('startFrame',1,@isnumeric);
p.addParameter('pupilGammaCorrection', 0.75, @isnumeric);
p.addParameter('centralTendency', 'mean', @ischar);
p.addParameter('displayMeanFrame', true, @islogical);
p.addParameter('saveMeanFrame', true, @islogical);
p.addParameter('saveName', [], @ischar);



p.parse(videoFileName, varargin{:})

% allow user to use GUI to select video
if isempty(videoFileName)
    [fileName, path] = uigetfile({'*.mp4;*.mov;*.avi'});
    videoFileName = [path, fileName];
end

% get some information about the video
videoInObj = VideoReader(videoFileName);
nFrames = floor(videoInObj.Duration*videoInObj.FrameRate);
videoSizeX = videoInObj.Width;
videoSizeY = videoInObj.Height;

cc = 0;
for ii = p.Results.startFrame:p.Results.startFrame+nFrames-1
    cc = cc+1;
    thisFrame = read(videoInObj,ii);
    thisFrame = imadjust(thisFrame,[],[],p.Results.pupilGammaCorrection);
    grayVideo(:,:,cc) = rgb2gray (thisFrame);
end

if strcmp(p.Results.centralTendency, 'mean')
    meanFrame = mean(grayVideo, 3);
elseif strcmp(p.Results.centralTendency, 'median')
    meanFrame = median(grayVideo, 3);
end

% display and save mean image
if p.Results.displayMeanFrame || p.Results.saveMeanFrame
    plotFig = figure;
    imshow(meanFrame, []);
    
    if p.Results.saveMeanFrame
        if isempty(p.Results.saveName)
            [pathstring, name, ~] = fileparts(videoFileName);
            saveName = fullfile(pathstring, [name, p.Results.centralTendency, '.png']);
        else
            saveName = p.Results.saveName;
        end
       saveas(plotFig, saveName);
    end
    
    if ~p.Results.displayMeanFrame
        close plotFig
    end
    
    
end



end