function [ellipseArrayList, fixationTargetArray] = pickFramesForSceneEstimation(processedVideoName, varargin)
%% Input parser
p = inputParser; p.KeepUnmatched = true;

% Required
p.addOptional('processedVideoName', [], @(x)(isempty(x) || ischar(x)));

% Optional flow control params
p.addParameter('directions', {'center', 'up', 'down', 'left', 'right'}, @iscellstr);
p.addParameter('directionTargets', {[0; 0], [0; 27.5/2], [0; -27.5/2], [-27.5/2; 0], [27.5/2; 0]}, @iscell);
p.addParameter('saveName', [], @ischar);
p.addParameter('loadEllipseArrayList', false, @islogical);

% parse
p.parse(processedVideoName, varargin{:})
%% create ellipse array list
if ~p.Results.loadEllipseArrayList
    [recordedErrorFlag, consoleOutput] = system(['open ''' processedVideoName '''']);
    
    ellipseArrayList = [];
    fixationTargetArray = [];
    for ii = 1:length(p.Results.directions)
        if strcmp(p.Results.directions, 'center')
            
            frames.(p.Results.directions{ii}) = GetWithDefault('Enter frames in which the eye is fixated straight ahead', []);
        else
            frames.(p.Results.directions{ii}) = GetWithDefault(sprintf('Enter frames in which the eye is looking %s', p.Results.directions{ii}), []);
            
            
        end
        ellipseArrayList = [ellipseArrayList, frames.(p.Results.directions{ii})];
        fixationTargetArray = [fixationTargetArray, repmat(p.Results.directionTargets{ii}, 1, length(frames.(p.Results.directions{ii})))];
    end
    
    %% save out ellipse  array list and fixation target array
    if ~isempty(p.Results.saveName)
        save(p.Results.saveName, 'ellipseArrayList', 'fixationTargetArray', '-v7.3');
    end
else
    load(p.Results.saveName);
end

end