function [ blinksStruct ] = loadBlinks(varargin)
% Function to easily load blinks data.

% Syntax: 
%   [ blinksStruct ] = loadBlinks
%
% Description:
%   We are interested in looking at the amount of blinking or reflexive eye
%   closure as measured through pupillometry to relate these measures to
%   similar activity measured through EMG. The routine analyzeDroppedFrames
%   computes the number of blink frames in a window around the light pulse
%   (with a slight lag, but in a manner that directly mirrors our EMG
%   analysis approach), averaged across trials of a given stimulus type for
%   subject. The routine will either compute this analysis (which requires
%   all relevant files synced) or load a previously-computed version of
%   this analysis.
%
% Outputs:
%   - blinksStruct            - a struct, with first level subfield that
%                               displays group, second level subfield that
%                               describes stimulus direction, and third
%                               level subfield that describes contrast
%                               level. At the innermost level, the mean
%                               number of dropped frames for a given
%                               subject for trials of that type with good
%                               pupillometry, are presented.
%
% Optional key-value pairs:
%   - runAnalyzeDroppedFrames - a logical that controls whether to run the
%                               analysis or just load a prior version. The
%                               default is 'false', or load the prior
%                               version

%% Input parser
p = inputParser; p.KeepUnmatched = true;

p.addParameter('runAnalyzeDroppedFrames',false,@islogical);

% Parse and check the parameters
p.parse(varargin{:});

%% Determine whether we're computing dropped frames
if p.Results.runAnalyzeDroppedFrames
    
    % compute dropped frames
    [blinksStruct] = analyzeDroppedFrames;
    
else
    
    % otherwise, just load in previously-run analysis
    load(fullfile(getpref('melSquintAnalysis', 'melaAnalysisPath'), 'melSquintAnalysis', 'pupil', 'droppedFramesAnalysis', 'droppedFramesResults.mat'));
    blinksStruct = droppedFramesMeanStruct;

    
end


end