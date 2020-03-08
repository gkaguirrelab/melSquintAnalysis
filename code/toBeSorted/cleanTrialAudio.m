function [ firstIndex, lastIndex ] = grabRelevantAudioIndices(audioData, FS)

%% generate smoothed RMS amplitude contour (a signal which more readily identifies where likely speech occurs)
%[X, FS] = audioread(audiofile);
X = audioData;

%F = [200 500 2800 3200];  # band limits

F = [100 300 2800 3200];  % band limits

A = [0 1 0];              % band type: 0=stop 1=pass

dev = [0.0001 10^(0.1/20)-1 0.0001]; % ripple/attenuation spec

[M,Wn,beta,typ] = kaiserord(F,A,dev,FS); % window parameters

b = fir1(M,Wn,typ,kaiser(M+1,beta),'noscale'); % filter design


Y = filter(b,1,X);

newFS = 200;
[rmsY,Time] = rmsLocal(Y, FS, newFS, 0.015); % note that this will resample our audio clips at 200 Hz



Nampsmooth = 7;

bb = hamming(Nampsmooth);

SrmsY = filtfilt(bb,1,rmsY);

SrmsY = SrmsY/max(SrmsY);
cleanedAudioSnippet = SrmsY;


%% Trim off the first 600 ms, find likely relevant speech window, then add 200 ms of buffer
firstIndex = round(0.6*newFS);
lastIndex = length(SrmsY);
threshold = 0.1*max(SrmsY);
collar = round(0.2*newFS);
firstIndex = firstIndex + min(find(SrmsY(firstIndex:lastIndex)>threshold)) - collar;
lastIndex = max(find((SrmsY) > threshold)) + collar;

end

function [Y,Time] = rmsLocal(X, InFS, OutFS, windowT)

windowN = round(InFS*windowT);
stepT = 1.0/OutFS;
InDur = length(X)/InFS;
Nout = floor(InDur/stepT)-3;
Y = zeros(Nout,1); Time = zeros(Nout,1);
for n = 1:Nout
    t1 = (n-1)*stepT; Time(n) = t1+windowT/2;
    s1 = floor(t1*InFS) + 1;
    Y(n) = std(X(s1:(s1+windowN)));
end

end % end local function