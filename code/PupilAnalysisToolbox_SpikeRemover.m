function [iy, removePoints] = PupilAnalysisToolbox_SpikeRemover(iy)
% [iy, removePoints] = SpikeRemover(iy, params);
params.BadPercentChangeThreshold = 0.8;

params.VelocitySmoothingParam = 5;
params.VelocityMarginWindowSize = 5;
params.VelocityOffsetThreshold = 0.02;
params.VelocityOnsetThreshold = -0.02;
params.VelocitySearchWindowSize = 5;

% Remove points exceeding the % percent change threshold
%removePoints = find(abs(iy) > params.BadPercentChangeThreshold);
%iy(removePoints) = NaN;

% Go through the velocity signal and try to find the onset of a blink event
velocityTrace = diff(smooth(iy, params.VelocitySmoothingParam));
foundPeaks = [];

v = 0;
while v < length(velocityTrace)
    v = v+1;
    if velocityTrace(v) < params.VelocityOnsetThreshold
        onsetCandidatePeak = v;
        % Search ahead in the window to find if we
        % exceed the offset threshold also
        if v+params.VelocitySearchWindowSize > length(velocityTrace)
            searchIndices = v:length(velocityTrace);
        else
            searchIndices = v:v+params.VelocitySearchWindowSize;
        end
        for vv = searchIndices
            if velocityTrace(vv) > params.VelocityOffsetThreshold
                offsetCandidatePeak = vv;
                v = offsetCandidatePeak+params.VelocityMarginWindowSize;
                
                if (onsetCandidatePeak-params.VelocityMarginWindowSize) < 1
                    startIdx = 1;
                else
                    startIdx = (onsetCandidatePeak-params.VelocityMarginWindowSize);
                end
                if (offsetCandidatePeak+params.VelocityMarginWindowSize) > length(velocityTrace)
                    endIdx = length(velocityTrace);
                else
                    endIdx = (offsetCandidatePeak+params.VelocityMarginWindowSize);
                end
                foundPeaks = [foundPeaks startIdx:endIdx];
                break;
            end
        end
        
    end
    iy(foundPeaks) = NaN;
end

v = 0;
while v < length(velocityTrace)
    v = v+1;
    if velocityTrace(v) > params.VelocityOffsetThreshold
        onsetCandidatePeak = v;
        % Search ahead in the window to find if we
        % exceed the offset threshold also
        if v+params.VelocitySearchWindowSize > length(velocityTrace)
            searchIndices = v:length(velocityTrace);
        else
            searchIndices = v:v+params.VelocitySearchWindowSize;
        end
        for vv = searchIndices
            if velocityTrace(vv) < params.VelocityOnsetThreshold
                offsetCandidatePeak = vv;
                v = offsetCandidatePeak+params.VelocityMarginWindowSize;
                if (onsetCandidatePeak-params.VelocityMarginWindowSize) < 1
                    startIdx = 1;
                else
                    startIdx = (onsetCandidatePeak-params.VelocityMarginWindowSize);
                end
                if (offsetCandidatePeak+params.VelocityMarginWindowSize) > length(velocityTrace)
                    endIdx = length(velocityTrace);
                else
                    endIdx = (offsetCandidatePeak+params.VelocityMarginWindowSize);
                end
                foundPeaks = [foundPeaks startIdx:endIdx];
                break;
            end
        end
    end
    iy(foundPeaks) = NaN;
end
removePoints = [foundPeaks];