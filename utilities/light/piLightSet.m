function lght = piLightSet(lght, param, val, varargin)
% Set a light source parameter
%
% Synopsis
%  thisR = piLightSet(thisR, lightIdx, param, val, varargin)
%
% Inputs
%   obj:    Recipe containing a lightSource cell array / A light struct
%   lightIdx: Index into which light in the cell array / [] if obj is a
%             light struct
%   param:    The parameter to set
%   val:      The new value
%
% Optional key/val pairs
%   print:   - Printout the list of lights
%  'update'  - update an existing light source.
%
% The list of settable light parameters is determined by the light
% parameters in PBRT. That is defined on this web-page
%
%      https://www.pbrt.org/fileformat-v3.html#lights
%
% Here is a partial list and there are some examples below
%
%  'type'  - The type of light source to insert. Can be the following:
%             'point'   - Casts the same amount of illumination in all
%                         directions. Takes parameters 'to' and 'from'.
%             'spot'    - Specify a cone of directions in which light is
%                         emitted. Takes parameters 'to','from',
%                         'coneangle', and 'conedeltaangle.'
%             'distant' - A directional light source "at
%                         infinity". Takes parameters 'to' and 'from'.
%             'area'    - convert an object into an area light. (TL: Needs
%                         more documentation; I'm not sure how it's used at
%                         the moment.)
%             'infinite' - an infinitely far away light source that
%                          potentially casts illumination from all
%                          directions. Takes no parameters.
%
%  'spectrum' - The spectrum that the light will emit. Read
%                          from ISETCam/ISETBio light data. See
%                          "isetbio/isettools/data/lights" or
%                          "isetcam/data/lights."
%  'spectrum scale'  - scale the spectrum. Important for setting
%                          relative weights for multiple light sources.
%  'camera coordinate' - true or false. automatically place the light
%                            at the camera location.
%
% ieExamplesPrint('piLightSet');
%
% Zheng,BW, SCIEN, 2020
%
% See also
%   piLightCreate, piLightDelete, piLightAdd, piLightGet
%

% Examples:
%{
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    thisR = piLightAdd(thisR, 'type', 'spot', 'cameracoordinate', true);
    
    piLightGet(thisR);
    lightNumber = 1;
    thisR = piLightSet(thisR, lightNumber, 'light spectrum', 'D50')
    thisR = piLightSet(thisR, lightNumber, 'coneAngle', 5);

    thisR = piLightAdd(thisR, 'type', 'spot',...
                        'light spectrum', 'blueLEDFlood',...
                        'spectrumscale', 10000,...
                        'cameracoordinate', true);
    lightNumber = 2;
    thisR = piLightSet(thisR, lightNumber, 'coneAngle', 20);
    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}
%{
    % Apply translation and rotation on light
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    thisR = piLightAdd(thisR, 'type', 'spot', 'cameracoordinate', true);
    
    piLightGet(thisR);
    lightNumber = 1;
    piLightSet(thisR, lightNumber, 'light spectrum', 'D50')
    piLightSet(thisR, lightNumber, 'coneAngle', 10);
    thisR = piLightRotate(thisR, lightNumber, 'x rot', 7);
    thisR = piLightTranslate(thisR, lightNumber, 'x shift', 1.2);

    thisR = piLightAdd(thisR, 'type', 'spot',...
                        'light spectrum', 'blueLEDFlood',...
                        'spectrumscale', 10000,...
                        'cameracoordinate', true);
    lightNumber = 2;
    thisR = piLightSet(thisR, lightNumber, 'coneAngle', 20);

    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}

%{
    light = piLightCreate('new light');
    light = piLightSet(light, 'spectrum val', 'D50');
    light = piLightSet(light, 'from val', [10 10 10]);
%}

%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName = nameTypeVal{1};

% Whether it is specified to set a type or a value.
if numel(nameTypeVal) > 1
    pTypeVal = nameTypeVal{2};
else
    % Set a whole struct
    pTypeVal = '';
end

p = inputParser;
p.addRequired('lght', @isstruct);
p.addRequired('param', @ischar);
p.addRequired('val', @(x)(ischar(x) || isstruct(x) || isnumeric(x) || isbool));

p.parse(lght, param, val, varargin{:});

%%
if isfield(lght, pName)
    % Set name, type or camera coordinate
    if isequal(pName, 'name') || isequal(pName, 'type') ||...
            isequal(pName, 'cameracoordinate')
        lght.(pName) = val;
        return;
    end
    
    % Set the whole struct
    if isempty(pTypeVal)
        lght.(pName) = val;
        return
    end
    
    % Set parameter type
    if isequal(pTypeVal, 'type')
        lght.(pName).type = type;
        return;
    end
    
    % Set parameter value
    if isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        lght.(pName).value = val;
        
        % Changing property type if the user doesn't specify it.
        if isequal(pName, 'spectrum') || isequal(pName, 'scale')
            if numel(val) == 3 && ~ischar(val)
                lght.(pName).type = 'rgb';
            elseif numel(val) > 3 || ischar(val)
                lght.(pName).type = 'spectrum';
            end
            return;
        end
    end
else
    warning('Parameter: %s does not exist in light type: %s',...
                pName, lght.type);
end
%% Old version
%{
%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p  = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe') || isa(x, 'struct')));
p.addRequired('lightIdx', @isnumeric);
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(obj, lightIdx, param, val, varargin{:});
idx = p.Results.lightIdx;

if isa(obj, 'recipe')
    obj.lights{idx} = piLightSet(obj.lights{idx}, [], param, val);

elseif isa(obj, 'struct')
    if isfield(obj, param)
        if isnumeric(val) && isequal(size(val), [3 1])
            val = val';
        end
        obj.(param) = val;
    else
        obj.(param) = val;
        warning('Parameters: "%s" not in current fields of light type: "%s". Adding', param, obj.type)
    end
end
%}
%%
