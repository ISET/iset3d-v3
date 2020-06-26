function thisR = piLightSet(thisR, lightIdx, param, val, varargin)
% Set a light source parameter
%
% Synopsis
%  thisR = piLightSet(thisR, lightIdx, param, val, varargin)
%
% Inputs
%   thisR:    Recipe containing a lightSource cell array
%   lightIdx: Index into which light in the cell array
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

%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p  = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('lightIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, lightIdx, param, val, varargin{:});
idx = p.Results.lightIdx;

if isfield(thisR.lights{idx}, param)
    if isnumeric(val) && isequal(size(val), [3 1])
        val = val';
    end
    thisR.lights{idx}.(param) = val;
else
    warning('Unknown parameters: "%s" not applicable for light type: "%s"', param, thisR.lights{idx}.type)
end

%%
