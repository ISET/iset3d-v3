function [spectrumVec,wave] = pbrtRGB2Spectrum(rgb, varargin)
% Implements the PBRT method for converting rgb to spectral vector
%
% Syntax:
%   [spectrumVec, wave] = pbrtRGB2Spectrum(rgbValues)
%
% Inputs:
%   rgbValues   - RGB values 3 numbers
%
% Outputs:
%   spectrumVec - Spectrum data derived from the formula in the PBRT source
%                 code. Implemented reflectance and illuminant for now.
%   wave        - Sample wavelengths used in this calculation
%
% Optional:
%   wave        - Sampl wavelengths
%   type        - Spectrum data type. Current only supports 
%   
% Description:
%   We copied the rgb2reflectance and rgb2illuminant part of the PBRT v3
%   code. That section converts RGB values into spectral data. We are going
%   to build different functions for body tissue.
%
% ZLY, 2020
%
% Examples:
%    ieExamplesPrint('pbrtRGB2Spectrum');
%
% See also
%  

%Examples:
%{
    % White
    rgb = [1, 1, 1]; wave = [380:5:705];

    % Reflectance
    type = 'reflectance'
    reflectance = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, reflectance); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0.8 1])

    % Illuminant
    type = 'illuminant'
    illuminant = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, illuminant); grid on
    xlabel('Wavelength (nm)'); ylabel('Illuminant'); ylim([0.8 1])
%}
%{
    % Red
    rgb = [1, 0, 0]; wave = [380:5:705];

    % Reflectance
    type = 'reflectance'
    reflectance = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, reflectance); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])

    % Illuminant
    type = 'illuminant'
    illuminant = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, illuminant); grid on
    xlabel('Wavelength (nm)'); ylabel('Illuminant'); ylim([0 1])
%}
%{
    % Green
    rgb = [0, 1, 0]; wave = [380:5:705];

    % Reflectance
    type = 'reflectance'
    reflectance = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, reflectance); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])

    % Illuminant
    type = 'illuminant'
    illuminant = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, illuminant); grid on
    xlabel('Wavelength (nm)'); ylabel('Illuminant'); ylim([0 1])
%}
%{
    % Blue
    rgb = [0, 0, 1]; wave = [380:5:705];

    % Reflectance
    type = 'reflectance'
    reflectance = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, reflectance); grid on
    xlabel('Wavelength (nm)'); ylabel('Reflectance'); ylim([0 1])

    % Illuminant
    type = 'illuminant'
    illuminant = pbrtRGB2Spectrum(rgb, 'wave', wave, 'type', type);
    ieNewGraphWin; 
    plot(wave, illuminant); grid on
    xlabel('Wavelength (nm)'); ylabel('Illuminant'); ylim([0 1])
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

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('rgb', @isnumeric);
p.addParameter('type', 'reflectance', @ischar);
p.addParameter('wave', wavelength, @isnumeric);

p.parse(rgb, varargin{:});

rgb     = p.Results.rgb;
type    = p.Results.type; 
wave    = p.Results.wave;

%% Switch among possible types

switch type
    case 'reflectance'
        % RGBRefl2Spect*

        % These are copied from the source code and stored in ISET3d
        RGB2SpectWhite   = ieReadSpectra('RGBRefl2SpectWhite.mat', wave);
        RGB2SpectCyan    = ieReadSpectra('RGBRefl2SpectCyan.mat', wave);
        RGB2SpectBlue    = ieReadSpectra('RGBRefl2SpectBlue.mat', wave);
        RGB2SpectGreen   = ieReadSpectra('RGBRefl2SpectGreen.mat', wave);
        RGB2SpectMagenta = ieReadSpectra('RGBRefl2SpectMagenta.mat', wave);
        RGB2SpectYellow  = ieReadSpectra('RGBRefl2SpectYellow.mat', wave);
        RGB2SpectRed     = ieReadSpectra('RGBRefl2SpectRed.mat', wave);
        
        % Scaling factor
        scalingFactor = 0.94;
        
    case 'illuminant'
        % RGBIllum2Spect*

        % These are copied from the source code and stored in ISET3d
        RGB2SpectWhite   = ieReadSpectra('RGBIllum2SpectWhite.mat', wave);
        RGB2SpectCyan    = ieReadSpectra('RGBIllum2SpectCyan.mat', wave);
        RGB2SpectBlue    = ieReadSpectra('RGBIllum2SpectBlue.mat', wave);
        RGB2SpectGreen   = ieReadSpectra('RGBIllum2SpectGreen.mat', wave);
        RGB2SpectMagenta = ieReadSpectra('RGBIllum2SpectMagenta.mat', wave);
        RGB2SpectYellow  = ieReadSpectra('RGBIllum2SpectYellow.mat', wave);
        RGB2SpectRed     = ieReadSpectra('RGBIllum2SpectRed.mat', wave);
        
        % Scaling factor
        scalingFactor = 0.86445;
        
    otherwise
        error('Unkown spectrum data type %s.', type)
        
end
%% Convert RGB to spectrum

% Initialize the illuminant spectrum
spectrumVec = zeros(numel(wave),1);

if rgb(1) <= rgb(2) && rgb(1) <= rgb(3)
    % Compute reflectance with red channel as minimum
    spectrumVec = spectrumVec + rgb(1) * RGB2SpectWhite;
    
    if rgb(2) <= rgb(3)
        spectrumVec = spectrumVec + (rgb(2) - rgb(1)) * RGB2SpectCyan;
        spectrumVec = spectrumVec + (rgb(3) - rgb(2)) * RGB2SpectBlue;
    else
        spectrumVec = spectrumVec + (rgb(3) - rgb(1)) * RGB2SpectCyan;
        spectrumVec = spectrumVec + (rgb(2) - rgb(3)) * RGB2SpectGreen;
    end
    
elseif rgb(2) <= rgb(1) && rgb(2) <= rgb(3)
    % Compute reflectance with green channel as minimum
    spectrumVec = spectrumVec + rgb(2) * RGB2SpectWhite;
    
    if rgb(1) <= rgb(3)
        spectrumVec = spectrumVec + (rgb(1) - rgb(2)) * RGB2SpectMagenta;
        spectrumVec = spectrumVec + (rgb(3) - rgb(1)) * RGB2SpectBlue;
    else
        spectrumVec = spectrumVec + (rgb(3) - rgb(2)) * RGB2SpectMagenta;
        spectrumVec = spectrumVec + (rgb(1) - rgb(3)) * RGB2SpectRed;
    end
else
    % Compute reflectance with blue channel as minimum
    spectrumVec = spectrumVec + rgb(3) * RGB2SpectWhite;
    
    if rgb(1) <= rgb(2)
        spectrumVec = spectrumVec + (rgb(1) - rgb(3)) * RGB2SpectYellow;
        spectrumVec = spectrumVec + (rgb(2) - rgb(1)) * RGB2SpectGreen;
    else
        spectrumVec = spectrumVec + (rgb(2) - rgb(3)) * RGB2SpectYellow;
        spectrumVec = spectrumVec + (rgb(1) - rgb(2)) * RGB2SpectRed;
    end
end

spectrumVec = spectrumVec * scalingFactor;

end