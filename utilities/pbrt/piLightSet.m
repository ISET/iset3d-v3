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
%   print:   Printout the list of lights
%
% Returns
%   lightSource:  Modified light source
%
% Zheng,BW, SCIEN, 2020
%
% TODO
%   Build a switch statement for the param value, checking it is a
%   legitimate part of the light source structure
%
% See also
%   piLightDelete, piLightAdd, piLightGet
%

% Examples
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
    warning('Unkown parameters: "%s" not applicable for light type: "%s"', param, thisR.lights{idx}.type)
end

%%
