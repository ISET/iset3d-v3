function r = pbrtRGB2Reflectance(rgb, varargin)
% pbrtReflectance
% Syntax:
%   reflectance = pbrtRGB2Reflectance(rgbValues)
%
% Description:
%   Copy the rgb2reflectance part from PBRT v3. Converts the RGB value
%   into reflectance spectrum
%
% Inputs:
%   rgbValues   - RGB values 3 numbers
%
% Outputs:
%   r           - reflectance spectrum data with the basis functions from
%   PBRT
%
% ZLY, 2020
%
% Examples
%{
    rgb = [1, 1, 1];
    wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);

    ieNewGraphWin;
    plot(wave, r);
    xlabel('Wavelength (nm)');
    ylabel('Reflectance');
    
    ylim([0 1])
%}

%{
    % Red
    rgb = [1, 0, 0];
    wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);

    ieNewGraphWin;
    plot(wave, r);
    xlabel('Wavelength (nm)');
    ylabel('Reflectance');
    
    ylim([0 1])
%}

%{
    % Green
    rgb = [0, 1, 0];
    wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);

    ieNewGraphWin;
    plot(wave, r);
    xlabel('Wavelength (nm)');
    ylabel('Reflectance');
    
    ylim([0 1])
%}

%{
    % Blue
    rgb = [0, 0, 1];
    wave = [380:5:705];
    r = pbrtRGB2Reflectance(rgb, 'wave', wave);

    ieNewGraphWin;
    plot(wave, r);
    xlabel('Wavelength (nm)');
    ylabel('Reflectance');
    
    ylim([0 1])
%}


%% Spectrum default
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

%% RGBRef2Spec*

RGBRefl2SpectWhite   = ieReadSpectra('RGBRefl2SpectWhite.mat', wave);
RGBRefl2SpectCyan    = ieReadSpectra('RGBRefl2SpectCyan.mat', wave);
RGBRefl2SpectBlue    = ieReadSpectra('RGBRefl2SpectBlue.mat', wave);
RGBRefl2SpectGreen   = ieReadSpectra('RGBRefl2SpectGreen.mat', wave);
RGBRefl2SpectMagenta = ieReadSpectra('RGBRefl2SpectMagenta.mat', wave);
RGBRefl2SpectYellow  = ieReadSpectra('RGBRefl2SpectYellow.mat', wave);
RGBRefl2SpectRed     = ieReadSpectra('RGBRefl2SpectRed.mat', wave);

%% Convert reflectance spectrum to RGB

% Initialize the reflectance spectrum
r = zeros(1, numel(wave));



if rgb(1) <= rgb(2) && rgb(1) <= rgb(3)
    % Compute reflectance with red channel as minimum
    r = r + rgb(1) * RGBRefl2SpectWhite;
    
    if rgb(2) <= rgb(3)
        r = r + (rgb(2) - rgb(1)) * RGBRefl2SpectCyan;
        r = r + (rgb(3) - rgb(2)) * RGBRefl2SpectCyan;
    else
        r = r + (rgb(3) - rgb(1)) * RGBRefl2SpectCyan;
        r = r + (rgb(2) - rgb(3)) * RGBRefl2SpectGreen;
    end
    
elseif rgb(2) <= rgb(1) && rgb(2) <= rgb(3)
    % Compute reflectance with green channel as minimum
    r = r + rgb(2) * RGBRefl2SpectWhite;
    
    if rgb(1) <= rgb(3)
        r = r + (rgb(1) - rgb(2)) * RGBRefl2SpectMagenta;
        r = r + (rgb(3) - rgb(1)) * RGBRefl2SpectBlue;
    else
        r = r + (rgb(3) - rgb(2)) * RGBRefl2SpectMagenta;
        r = r + (rgb(1) - rgb(3)) * RGBRefl2SpectRed;
    end
else
    % Compute reflectance with blue channel as minimum
    r = r + rgb(3) * RGBRefl2SpectWhite;
    
    if rgb(1) <= rgb(2)
        r = r + (rgb(1) - rgb(3)) * RGBRefl2SpectYellow;
        r = r + (rgb(2) - rgb(1)) * RGBRefl2SpectGreen;
    else
        r = r + (rgb(2) - rgb(3)) * RGBRefl2SpectYellow;
        r = r + (rgb(1) - rgb(2)) * RGBRefl2SpectRed;
    end
end

r = r * 0.94;

end