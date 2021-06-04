function lght = piLightCreate(lightName, varargin)
%% Create a light source struct for a recipe
%
% Synopsis:
%   lght = piLightCreate(lightName,varargin)
%
% Inputs:
%   lightName   - name of the light
%
% Optional key/val pairs
%   type   - light type. Default is point light.  The light specific
%    properties depend on the light type. To see the light types use
%   
%      lightTypes = piLightCreate('list available types');
%
%    Properties for each light type can be found
%
%        piLightProperties(lightTypes{3})
%
%    Look here for the PBRT website information about lights.
%
% Description:
%   In addition to creating a light struct, various light properties can be
%   specified in key/val pairs.
%
% Returns
%   lght   - light struct
%
% See also
%   piLightSet, piLightGet, piLightProperties
%

% Examples
%{
  piLightCreate('list available types')
%}
%{
 lgt = piLightCreate('point light 1')
%}
%{
 lgt = piLightCreate('spot light 1', 'type','spot','rgb spd',[1 1 1])
%}

%% Check if the person just wants the light types

validLights = {'distant','goniometric','infinite','point','area','projection','spot'};

if isequal(ieParamFormat(lightName),'listavailabletypes')
    lght = validLights;
    return;
end

%% Parse inputs

% We replace spaces in the varargin parameter with an underscore. For
% example, 'rgb I' becomes 'rgb_I'. For an explanation, see the code at the
% end of this function.
for ii=1:2:numel(varargin)
    varargin{ii} = strrep(varargin{ii}, ' ', '_');
end

p = inputParser;
p.addRequired('lightName', @ischar);

p.addParameter('type','point',@(x)(ismember(x,validLights)));
p.KeepUnmatched = true;
p.parse(lightName, varargin{:});

%% Construct light struct
lght.type = p.Results.type;
lght.name = p.Results.lightName;

% PBRT allows wavelength by wavelength adjustment - would enable that
% someday.
lght.specscale.type = 'float';
lght.specscale.value = 1;

lght.spd.type = 'rgb';
lght.spd.value = [1 1 1];
switch ieParamFormat(lght.type)
    case 'distant'        
        lght.cameracoordinate = true;

        lght.from.type = 'point';
        lght.from.value = [];
        
        lght.to.type = 'to';
        lght.to.value = [];
        
        % Potentially has rotationation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = {};
        
        lght.translation.type = 'translation';
        lght.translation.value = {};
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = {};
        
        lght.scale.type = 'scale';
        lght.scale.value = {};        
        
    case 'goniometric'        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
    case 'infinite'        
        lght.nsamples.type = 'integer';
        lght.nsamples.value = [];
        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = {};
        
        lght.translation.type = 'translation';
        lght.translation.value = {};
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = [];
        
        lght.scale.type = 'scale';
        lght.scale.value = {};  
    case 'point'                
        lght.cameracoordinate = true;

        lght.from.type = 'point';
        lght.from.value = [];
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = {};
        
        lght.translation.type = 'translation';
        lght.translation.value = {};
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = {};
        
        lght.scale.type = 'scale';
        lght.scale.value = {};        
        
    case 'projection'        
        lght.fov.type = 'float';
        lght.fov.value = [];
        
        lght.mapname.type = 'string';
        lght.mapname.value = '';
        
    case {'spot', 'spotlight'}        
        lght.cameracoordinate = true;

        lght.from.type = 'point';
        lght.from.value = [];
        
        lght.to.type = 'to';
        lght.to.value = [];
        
        lght.coneangle.type = 'float';
        lght.coneangle.value = [];
        
        lght.conedeltaangle.type = 'float';
        lght.conedeltaangle.value = [];
        
        % Potentially has rotation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = {};
        
        lght.translation.type = 'translation';
        lght.translation.value = {};
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = {};
        
        lght.scale.type = 'scale';
        lght.scale.value = {};
        
    case {'area', 'arealight'}        
        lght.twosided.type = 'bool';
        lght.twosided.value = [];
        
        lght.nsamples.type = 'integer';
        lght.nsamples.value = [];
        
        lght.shape.type = 'shape';
        lght.shape.value = [];
        
        % Potentially has rotationation, transformation or concatransformaiton
        lght.rotation.type = 'rotation';
        lght.rotation.value = {};
        
        lght.translation.type = 'translation';
        lght.translation.value = {};
        
        lght.ctform.type = 'ctform';
        lght.ctform.value = {};
        
        lght.scale.type = 'scale';
        lght.scale.value = {};
end


%% Set additional key/val pairs

% We can set some, but not all, of the light properties on creation. We use
% a method that does not require us to individually list and set every
% possible property for every possible light.
%
% This code, however, is not complete.  It works for many cases, but it can
% fail.  Here is why.
%
% PBRT uses strings to represent properties, such as
%
%    'rgb spd', or 'cone angle'
%
% ISET3d initializes the light this way
%
%   piLightCreate(lightName, 'type','spot','rgb spd',[1 1 1])
%   piLightCreate(lightName, 'type','spot','float coneangle',10)
%
% We parse the parameter values, such as 'rgb spd', so that we can
% set the struct entries properly.  We do this by 
% 

for ii=1:2:numel(varargin)
    thisKey = varargin{ii};
    thisVal = varargin{ii + 1};
    
    if isequal(thisKey, 'type')
        % Skip since we've taken care of light type above.
        continue;
    end
    
    % This is the new key value we are stting.  Generally, it is the part
    % before the 'underscore'
    keyTypeName = strsplit(thisKey, '_');
    
    % But if  the first parameter is 'TYPE_NAME', we need the second value.
    % 
    if piLightISParamType(keyTypeName{1})
        keyName = ieParamFormat(keyTypeName{2});
    else
        keyName = ieParamFormat(keyTypeName{1});
    end
    
    % Now we run the lightSet.  We see whether this light structure has a
    % slot that matches the keyName.  
    if isfield(lght, keyName)
        % If the slot exists, we set it and we are good.
        lght = piLightSet(lght, sprintf('%s value', keyName),...
                              thisVal);
    else
        % If the slot does not exist, we tell the user, but do not
        % throw an error.
        warning('Parameter %s does not exist in light %s',...
                    keyName, lght.type)
    end
end

end
