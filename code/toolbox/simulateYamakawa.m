% This routine is an attempt to simulate the model put forth by Yamakawa
% and colleagues
% (https://www.nature.com/articles/s41598-019-44035-3#ref-CR34) that
% predicts brightness from any arbitrary stimulus on the basis of cone and
% melanopsin stimulus intensities. The purpose of this simulation is to see
% how their approach relates to our discomfort ratings results. Note that
% it's useful to play with the contrastLevels variable, as the form of the
% responses changes with stimulus intensity, and contrast as coded here is
% a very arbitrary quantity.

melBrightness = [];
LMSBrightness = [];
LFBrightness = [];

contrastLevels = [100, 200, 400];
%contrastLevels = [100000 200000 400000];

for ii = 1:length(contrastLevels)
    melBrightness(ii) = 4.84e-3*(contrastLevels(ii))^1.1 + 2.31*(0)^0.48;
end

for ii = 1:length(contrastLevels)
    LMSBrightness(ii) = 4.84e-3*(0)^1.1 + 2.31*(contrastLevels(ii))^0.48;
end

for ii = 1:length(contrastLevels)
    LFBrightness(ii) = 4.84e-3*(contrastLevels(ii))^1.1 + 2.31*(contrastLevels(ii))^0.48;
end


figure;  hold on;
plot(log10(contrastLevels), melBrightness, 'Color', 'b');
plot(log10(contrastLevels), LMSBrightness, 'Color', 'r');
plot(log10(contrastLevels), LFBrightness, 'Color', 'k');
legend('Melanopsin', 'LMS', 'LightFlux', 'Location', 'NorthWest')
xticks(log10(contrastLevels))
xlim([log10(contrastLevels(1)) - 0.05, log10(contrastLevels(end)) + 0.05]);
xticklabels(contrastLevels);
xlabel('Contrast')
ylabel('Brightness')