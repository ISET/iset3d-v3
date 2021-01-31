function lght = piLightCreate(varargin)
% Create a default light source struct for a recipe
%
% Synopsis
%   light = piLightCreate(thisR,varargin)
%
% Inputs:
%   thisR: 
%
% Optional key/val pairs
%   light spectrum:    SPD of the light, defined by a string
%   type:              Type of light source (e.g., point, spot,
%                      distant)
% Returns
%   thisR:  modified recipe.  But it is passed by pointer so the thisR
%           is not needed on the return.
%
% Description
%   Light sources are a struct
%
% See also
%   piLightSet, piLightGet
%

% Examples
%{
   thisR = piRecipeDefault;
%}
%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;
p.addParameter('lightspectrum','D65',@(x)(ischar(x)||isnumeric(x)));
p.addParameter('type','point',@ischar);
p.parse(varargin{:});

lightSpectrum = p.Results.lightspectrum;
if ischar(lightSpectrum)
    % User sent a char, so this must be a file on the path.  In fact, it
    % has to be a mat-file.  Usually we keep files in isetcam/data/lights
    % (or in isetbio same place).
    [thisP,n,~] = fileparts(lightSpectrum);
    lightSpectrum = fullfile(thisP, n);
    if ~exist([lightSpectrum, '.mat'],'file')
        warning('Could not find an exact match to %s on the path\n',lightSpectrum);
    end
end
type = p.Results.type;

%% Construct a lightsource structure
% Different types of lights that we know how to add.

lght.name = 'Default light';
lght.spectrumscale = 1;
lght.lightspectrum = lightSpectrum;
lght.type = type;
% Take care of area light and infinite light
if ~isequal(type, 'area')
    lght.cameracoordinate = false;
end

if ~isequal(type,'infinite') && ~isequal(type, 'area')
    lght.from = [0 0 0];
    if ~isequal(type,'point')
        lght.to = [0 0 1];
    end
end

%% Deal with cone angle stuff in these cases
switch type
    case 'spot'
        lght.coneangle = 30;
        lght.conedeltaangle = 5;
    case 'laser'       
        lght.coneangle = 5;
        lght.conedeltaangle = 1;
    case 'area'
        lght.rotate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];
        lght.position = [0 0 0];
        lght.shape = [];
        lght.booltwosided = false;
        lght.integersamples = 1;
    otherwise
        % Do nothing
end

end
