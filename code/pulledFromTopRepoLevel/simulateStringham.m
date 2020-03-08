function simulateStringham()
%% Get the photoreceptors
observerAge = 29;
photoreceptorClasses = {'LConeTabulatedAbsorbance',...
    'MConeTabulatedAbsorbance',...
    'SConeTabulatedAbsorbance',...
    'Melanopsin'};
fieldSize = 5.75;
luminanceCdM2 = 5;
pupilDiameter = 5; % note this is a guess!

S = [380 2 201];
wavelengths = S(1):S(2):S(1)+S(3)*S(2) - S(2);


for i = 1:length(photoreceptorClasses)
    spectralSensitivity.(photoreceptorClasses{i}) = GetHumanPhotoreceptorSS(S,...
        photoreceptorClasses(i),...
        fieldSize,...
        observerAge,...
        pupilDiameter);
    
    spectralSensitivity.(photoreceptorClasses{i}) = spectralSensitivity.(photoreceptorClasses{i});
end

spectralSensitivity.luminance = (spectralSensitivity.LConeTabulatedAbsorbance + spectralSensitivity.MConeTabulatedAbsorbance - spectralSensitivity.SConeTabulatedAbsorbance)./3;
spectralSensitiivty.luminance = spectralSensitivity.luminance/(max(spectralSensitivity.luminance));
%% predict the discomfort
alpha = 0.60;
beta = 2.02;
slope = 2.89;
intercept = -4.86;

discomfortThreshold = 5;

%d = log10(((alpha.*spectralSensitivity.Melanopsin).^beta +((spectralSensitivity.LConeTabulatedAbsorbance + spectralSensitivity.MConeTabulatedAbsorbance)./2).^beta).^(1/beta)).*2.89 - 4.86;
d = log10(((alpha.*spectralSensitivity.Melanopsin).^beta +((spectralSensitivity.LConeTabulatedAbsorbance + spectralSensitivity.MConeTabulatedAbsorbance)./2).^beta).^(1/beta));


for ii = 1:S(3)
   % at each wavelength, figure out the amount of contrast necessary to produce a discomfort rating of 5
   wavelength = wavelengths(ii);
   
   melanopsinSensitivity = spectralSensitivity.Melanopsin(ii);
   luminanceSensitivity = spectralSensitivity.luminance(ii);
   
   
    pulseSize(ii) = (10^(beta*(discomfortThreshold - intercept)/slope)/(alpha^beta*melanopsinSensitivity^beta + luminanceSensitivity^beta))^(1/beta);
end
%% Ddd stringham values
% from https://apps.automeris.io/wpd/
stringhamValues = [ ...
439.23710978604, -0.2802363043506501
459.7258271951362, -0.6471900697610974
479.10733076113644, -0.3460027021058236
499.05062551151644, -0.05541915117502616
518.9208464866128, -0.010074437819088705
539.4826376709926, -0.13178936565467597
559.2026189641063, -0.2386557023526506
579.1973576522857, -0.34342400976915166
599.1903425698586, -0.4460780492874493
619.1593592891384, -0.8531704275303011
639.7193967029114, -0.9727710874676851];

%% Plot
figure; hold on;
plot(wavelengths, -log10(pulseSize./(min(pulseSize))), 'Color', 'k');
plot(stringhamValues(:,1), stringhamValues(:,2), 'r');
xlabel('Wavelength (nm)')
ylabel('Sensitivity (log-scale)')
legend('Sub-Additive Mode', 'Stringham Results')
end