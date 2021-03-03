function lght = piLightSet(lght, param, val, varargin)
% Set a light source parameter
%
% Synopsis
%  lght = piLightSet(lght, param, val, varargin)
%
% Inputs
%   lght:    light struct
%   param:    The parameter to set
%   val:      The new value
%
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
% Zheng,BW, SCIEN, 2020 - 2021
%
% See also
%   piLightCreate, piLightGet
%

% Examples:
%{
    lgt = piLightCreate('new light');
    lgt
    lgt = piLightSet(lgt, 'spd', 'D50');
    lgt.spd
    lgt = piLightSet(lgt, 'from', [10 10 10]);
    lgt.from

    val.value = 'D50';
    val.type  = 'spectrum';
    lgt = piLightSet(lgt, 'spd', val);
    lgt.spd

%}


%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName       = nameTypeVal{1};

if isstruct(val) && ~isequal(pName, 'shape')
    % The user sent in a struct, we will loop through the entries and set
    % them all. Shape is an exception, because it has to be stored as
    % struct
    pTypeVal = '';
else
    % Otherwise, we assume we are setting a specific val
    pTypeVal = 'val';
    
    % But we do allow the user to override the 'val'
    if numel(nameTypeVal) > 1
        pTypeVal = nameTypeVal{2};
    end
end

p = inputParser;
p.addRequired('lght', @isstruct);
p.addRequired('param', @ischar);
p.addRequired('val', @(x)(ischar(x) || isstruct(x) || isnumeric(x) ||...
                            islogical(x) || iscell(x)));

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
    
    if isequal(pName, 'from') || isequal(pName, 'to')
        lght.cameracoordinate = false;
    end
    
    % Set parameter value
    if isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        lght.(pName).value = val;
        
        % Changing property type if the user doesn't specify it.
        if isequal(pName, 'spd') || isequal(pName, 'scale')
            if numel(val) == 3 && ~ischar(val)
                lght.(pName).type = 'rgb';
            elseif numel(val) == 2 && ~ischar(val)
                lght.(pName).type = 'blackbody';
            elseif (numel(val) > 3 && mod(numel(val), 2) == 0)|| ischar(val)
                lght.(pName).type = 'spectrum';
            end
            return;
        end
    end
else
    warning('Parameter: %s does not exist in light type: %s',...
                pName, lght.type);
end

end
