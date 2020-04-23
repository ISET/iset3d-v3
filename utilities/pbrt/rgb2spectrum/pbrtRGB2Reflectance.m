function [reflectance,wave] = pbrtRGB2Reflectance(rgb, varargin)
% Implements the PBRT method for converting rgb to spectral reflectance
%
% Syntax:
%   reflectance = pbrtRGB2Reflectance(rgbValues)
%
% Inputs:
%   rgbValues   - RGB values 3 numbers
%
% Outputs:
%   reflectance - Reflectance spectrum data derived from the formula in
%                 the PBRT source code
%   wave        - Sample wavelengths used in this calculation
%
% Description:
%   We copied the rgb2reflectance part of the PBRT v3 code. That section
%   converts RGB values into reflectance spectrum.  There are separate
%   functions for the illuminant, and we are going to build different
%   functions for body tissue.
%
% ZLY, 2020
%
% Examples:
%    ieExamplesPrint('pbrtRGB2Reflectance');
%
% See also
%  

%Examples:
%{
    % White
    rgb = [1, 1, 1]; wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);
    ieNewGraphWin; 
    plot(wave, r); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0.8 1])
%}
%{
    % Red
    rgb = [1, 0, 0]; wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);
    ieNewGraphWin;
    plot(wave, r); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])
%}
%{
    % Green
    rgb = [0, 1, 0]; wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);
    ieNewGraphWin;
    plot(wave, r); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])
%}
%{
    % Blue
    rgb = [0, 0, 1]; wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);
    ieNewGraphWin; 
    plot(wave, r);
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])
%}
%{
    % White
    rgb = [1, 1, 1]; wave = [365:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);
    ieNewGraphWin; 
    plot(wave, r); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0.8 1])
%}

%% Spectrum default

% The default wavelength samples in PBRT.  Don't ask.
wavelength = [
    380.000000, 390.967743, 401.935486, 412.903229, 423.870972,...
    434.838715, 445.806458, 456.774200, 467.741943, 478.709686,...
    489.677429, 500.645172, 511.612915, 522.580627, 533.548340,...
    544.516052, 555.483765, 566.451477, 577.419189, 588.386902,...
    599.354614, 610.322327, 621.290039, 632.257751, 643.225464,...
    654.193176, 665.160889, 676.128601, 687.096313, 698.064026,...
    709.031738, 720.000000];

%% parse input
p = inputParser;

p.addRequired('rgb', @isnumeric);
p.addParameter('wave', wavelength, @isnumeric)

p.parse(rgb, varargin{:});

rgb     = p.Results.rgb;
wave    = p.Results.wave;

%% RGBRefl2Spec*

% These are copied from the source code and stored in ISET3d. Here we use
% linear extrapolation if the range of wavelength specified is wider than
% PBRT stored samples
extrapVal = 'extrap';
RGBRefl2SpectWhite   = ieReadSpectra('RGBRefl2SpectWhite.mat', wave, extrapVal);
RGBRefl2SpectCyan    = ieReadSpectra('RGBRefl2SpectCyan.mat', wave, extrapVal);
RGBRefl2SpectBlue    = ieReadSpectra('RGBRefl2SpectBlue.mat', wave, extrapVal);
RGBRefl2SpectGreen   = ieReadSpectra('RGBRefl2SpectGreen.mat', wave, extrapVal);
RGBRefl2SpectMagenta = ieReadSpectra('RGBRefl2SpectMagenta.mat', wave, extrapVal);
RGBRefl2SpectYellow  = ieReadSpectra('RGBRefl2SpectYellow.mat', wave, extrapVal);
RGBRefl2SpectRed     = ieReadSpectra('RGBRefl2SpectRed.mat', wave, extrapVal);

%% Convert to RGB reflectance spectrum 

% Initialize the reflectance spectrum
reflectance = zeros(numel(wave),1);

if rgb(1) <= rgb(2) && rgb(1) <= rgb(3)
    % Compute reflectance with red channel as minimum
    reflectance = reflectance + rgb(1) * RGBRefl2SpectWhite;
    
    if rgb(2) <= rgb(3)
        reflectance = reflectance + (rgb(2) - rgb(1)) * RGBRefl2SpectCyan;
        reflectance = reflectance + (rgb(3) - rgb(2)) * RGBRefl2SpectBlue;
    else
        reflectance = reflectance + (rgb(3) - rgb(1)) * RGBRefl2SpectCyan;
        reflectance = reflectance + (rgb(2) - rgb(3)) * RGBRefl2SpectGreen;
    end
    
elseif rgb(2) <= rgb(1) && rgb(2) <= rgb(3)
    % Compute reflectance with green channel as minimum
    reflectance = reflectance + rgb(2) * RGBRefl2SpectWhite;
    
    if rgb(1) <= rgb(3)
        reflectance = reflectance + (rgb(1) - rgb(2)) * RGBRefl2SpectMagenta;
        reflectance = reflectance + (rgb(3) - rgb(1)) * RGBRefl2SpectBlue;
    else
        reflectance = reflectance + (rgb(3) - rgb(2)) * RGBRefl2SpectMagenta;
        reflectance = reflectance + (rgb(1) - rgb(3)) * RGBRefl2SpectRed;
    end
else
    % Compute reflectance with blue channel as minimum
    reflectance = reflectance + rgb(3) * RGBRefl2SpectWhite;
    
    if rgb(1) <= rgb(2)
        reflectance = reflectance + (rgb(1) - rgb(3)) * RGBRefl2SpectYellow;
        reflectance = reflectance + (rgb(2) - rgb(1)) * RGBRefl2SpectGreen;
    else
        reflectance = reflectance + (rgb(2) - rgb(3)) * RGBRefl2SpectYellow;
        reflectance = reflectance + (rgb(1) - rgb(2)) * RGBRefl2SpectRed;
    end
end

reflectance = reflectance * 0.94;

end