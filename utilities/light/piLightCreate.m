function light = piLightCreate(thisR, varargin)
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
    lightSpectrum = fullfile(thisP,[n,'.mat']);
    if ~exist(lightSpectrum,'file')
        warning('Could not find an exact match to %s on the path\n',lightSpectrum);
    end
end
type = p.Results.type;

%% Construct a lightsource structure
% Different types of lights that we know how to add.

light.name = 'Default light';
light.spectrumscale = 1;
light.lightspectrum = lightSpectrum;
light.cameracoordinate = false;
light.type = type;
if ~isequal(type,'infinite')
    light.from = [0 0 0];
    if ~isequal(type,'point')
        light.to = [0 0 1];
    end
end

%% Deal with cone angle stuff in these cases
switch type
    case 'spot'
        light.coneangle = 30;
        light.conedeltaangle = 5;
    case 'laser'       
        light.coneangle = 5;
        light.conedeltaangle = 1;
    otherwise
        % Do nothing
end

%% Add the light to the recipe

val = numel(piLightGet(thisR,'print',false));
thisR.lights{val+1} = light;
idx = val + 1;

%% Now if the user sent in any additional arguments ...

for ii=1:2:length(varargin)
    piLightSet(thisR,idx,varargin{ii},varargin{ii+1});
end

end
