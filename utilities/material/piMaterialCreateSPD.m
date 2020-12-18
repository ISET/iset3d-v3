function vec = piMaterialCreateSPD(wave, spd, varargin)
% Generate spectrum in PBRT version with wavelength and the spd
%
% Synopsis:
%   vec = piMaterialCreateSPD(wave, spd, varargin)
%
% Inputs:
%   

% Examples 
%{
wave = 400:10:700;
spd = 300:10:600;
vec = piMaterialCreateSPD(wave, spd);
%}

%% parse input
p = inputParser;
p.addRequired('wave', @isvector);
p.addRequired('spd', @isvector);
p.parse(wave, spd, varargin{:});

%% Check if wave and spd have same length
if numel(wave) ~= numel(spd)
    warning('Length of wavelength: %d does not match length of spd: %d Please double check',...
            numel(wave), numel(spd));
    vec = [];
else
    %%
    vec = zeros(1, 2 * numel(wave));
    vec(1:2:end) = wave;
    vec(2:2:end) = spd;
end
end