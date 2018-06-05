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

pFitImplicit = ellipse_ex2im(ellipse_transparent2ex(ellipseFitParams));
fh=@(x,y) pFitImplicit(1).*x.^2 +pFitImplicit(2).*x.*y +pFitImplicit(3).*y.^2 +pFitImplicit(4).*x +pFitImplicit(5).*y +pFitImplicit(6);
% superimpose the ellipse using fimplicit or ezplot (ezplot
% is the fallback option for older Matlab versions)
hold on
fimplicit(fh,[1, videoSizeX, 1, videoSizeY],'Color', 'green','LineWidth',1);
set(gca,'position',[0 0 1 1],'units','normalized')
axis off;

end