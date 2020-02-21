function lightSource = piLightSet(thisR, lightName, param, val, varargin)
% Set a light source struct parameter
%
%
% Inputs
%   thisR
%   lightName
%   param
%   val
%
% Optional key/val pairs
%   print:   Printout the list of lights
%
% Returns
%   lightSource:  Modified light source
%
% Zheng,BW, SCIEN, 2020
%
% See also
%   piLightDelete, piLightAdd, piLightGet
%
%
% Examples
%{
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    thisR = piLightAdd(thisR, 'type', 'spot', 'cameracoordinate', true);
    
    piLightGet(thisR);
    lightNumber = 1;
    piLightSet(thisR, lightNumber, 'coneAngle', 2);
    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}

%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('lightName');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, lightName, param, val, varargin{:});

%%
lightSources = thisR.lights;

if isnumeric(lightName)
    % Record the light
    thisLight = lightSources{lightName};
    idx = lightName;
elseif ischar(lightName)
    lightSourcesStruct = cell2mat(lightSources);
    find(lightSourcesStruct.name == lightName);
else
    error('Unknown lightName. It must be an integer or a char.');
end

% if strcmp(param, 'from')
%     param = 'position';
% elseif strcmp(param, 'to')
%     % As direction is easier to consider compare directly change the "to"
%     % vector, light only contains direction, so we change "to" if user
%     % insists providing "to" values.
%     param = 'direction';
%     if ~isfield(thisLight, 'position')
%         position = 0;
%     end
%     val = val - position;
% end
% 
% thisLight.(param) = val;

piLightAdd(thisR, param, val, 'update', idx);
    
%%
