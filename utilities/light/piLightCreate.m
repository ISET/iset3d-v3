function lght = piLightCreate(name, varargin)
%%
% Create a light source struct for a recipe
%
% Synopsis:
%   light = piLightCreate(thisR,varargin)
%
% Inputs:
%   name                    - name of the light
%
% Optional key/val pairs
%   type                    - light type (e.g., point, spot,
%                               distant). Default is point light
%   other light properties  - depending on light types. Default values can
%                             be found on PBRT website.
%
% Description:
%   The light properties should be given in key/val pairs. For keys. it
%   should follow the format of 'TYPE KEYNAME'. It's easier for us to
%   extract type and parameter name using space.
%
% Returns
%   lght                    - created light
%
%
% See also
%   piLightSet, piLightGet
%

% Examples
%{
   lgt = piLightCreate('new light', '')
%}
%%
% Replace the space in potential parameters. For example, 'rgb I' won't
% pass parse with the space, but we need the two parts in the string apart
% to extract type and key. So we replace space with '_' and use '_' as
% key word.
for ii=1:2:numel(varargin)
    varargin{ii} = strrep(varargin{ii}, ' ', '_');
end
%% Parse inputs
p = inputParser;
p.addRequired('name', @ischar);
p.addParameter('type','point',@ischar);
p.KeepUnmatched = true;
p.parse(name, varargin{:});

type = ieParamFormat(p.Results.type);
%% Construct light struct
lght.name = name;

% PBRT allows wavelength by wavelength adjustment - would enable that
% someday.
lght.specscale.type = 'float';
lght.specscale.value = 1;

switch type
    case 'distant'
        lght.type = 'distant';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.cameracoordinate = false;

        lght.from.type = 'point';
        lght.from.value = [];
        
        lght.to.type = 'to';
        lght.to.value = [];
        
        % Potentially has rotationation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = [];
        
        lght.translation.type = 'translation';
        lght.translation.value = [];
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = [];        
        
    case 'goniometric'
        lght.type = 'goniometric';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
    case 'infinite'
        lght.type = 'infinite';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.nsamples.type = 'integer';
        lght.nsamples.value = [];
        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = [];
        
        lght.translation.type = 'translation';
        lght.translation.value = [];
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = [];  
    case 'point'
        lght.type = 'point';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.cameracoordinate = false;

        lght.from.type = 'point';
        lght.from.value = [];
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = [];
        
        lght.translation.type = 'translation';
        lght.translation.value = [];
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = [];        
        
    case 'projection'
        lght.type = 'projection';

        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.fov.type = 'float';
        lght.fov.value = [];
        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
    case {'spot', 'spotlight'}
        lght.type = 'spotl';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.cameracoordinate = false;

        lght.from.type = 'point';
        lght.from.value = [];
        
        lght.to.type = 'point';
        lght.to.value = [];
        
        lght.coneangle.type = 'float';
        lght.coneangle.value = [];
        
        lght.conedeltaangle.type = 'float';
        lght.conedeltaangle.value = [];
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = [];
        
        lght.translation.type = 'translation';
        lght.translation.value = [];
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = [];
        
    case {'area', 'arealight'}
        lght.type = 'area';
        
        lght.spectrum.type = 'spectrum';
        lght.spectrum.value = [];
        
        lght.twosided.type = 'bool';
        lght.twosided.value = [];
        
        lght.nsamples.type = 'integer';
        lght.nsamples.value = [];
        
        lght.shape.type = 'shape';
        lght.shape.value = [];
        
        % Potentially has rotationation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = [];
        
        lght.translation.type = 'translation';
        lght.translation.value = [];
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = [];
end


%% Put in key/val

for ii=1:2:numel(varargin)
    thisKey = varargin{ii};
    thisVal = varargin{ii + 1};
    
    if isequal(thisKey, 'type')
        % Skip since we've taken care of light type above.
        continue;
    end
    
    keyTypeName = strsplit(thisKey, '_');
    
    % keyName is the property name. If it follows 'TYPE_NAME', we need
    % later, otherwise we need the first one.
    if piLightISParamType(keyTypeName{1})
        keyName = ieParamFormat(keyTypeName{2});
    else
        keyName = ieParamFormat(keyTypeName{1});
    end
    
    if isfield(lght, keyName)
        lght = piLightSet(lght, sprintf('%s value', keyName),...
                              thisVal);
    else
        warning('Parameter %s does not exist in material %s',...
                    keyName, lght.type)
    end
end

%% Old version
%{
%%
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
        lght.rotationate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];
        lght.translationition = [0 0 0];
        lght.shape = [];
        lght.booltwosided = false;
        lght.integersamples = 1;
    otherwise
        % Do nothing
end
%}
end
