function simulateStringham()
%% Get the photoreceptors
photoreceptorClasses = {'LConeTabulatedAbsorbance',...
    'MConeTabulatedAbsorbance',...
    'SConeTabulatedAbsorbance',...
    'Melanopsin'};

calibration = OLGetCalibrationStructure('CalibrationType','BoxALiquidShortCableDEyePiece1_ND02','CalibrationDate','latest');
S = calibration.describe.S;


%% Make background spectrum
% background: 5.0 log cd/m2 white stimulus

%% Make narrow-band spectra


% for LMS -- average of relative excitation for L and M cones
% same for mel
end