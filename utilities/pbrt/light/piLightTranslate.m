function [lightSource, idx] = piLightTranslate(thisR, idx, varargin)

% Examples
%{
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    thisR = piLightAdd(thisR, 'type', 'spot', 'cameracoordinate', true);
    
    piLightGet(thisR);
    lightNumber = 1;
    piLightSet(thisR, lightNumber, 'light spectrum', 'D50')
    piLightSet(thisR, lightNumber, 'coneAngle', 5);
    [~, lightNumber] = piLightTranslate(thisR, lightNumber, 'x shift', 1);

    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}
%% Parse

% Remove spaces, force lower case
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('thisR', @(x)isequal(class(x),'recipe'));

p.addParameter('xshift', 0, @isscalar);
p.addParameter('yshift', 0, @isscalar);
p.addParameter('zshift', 0, @isscalar);
p.addParameter('fromto', 'both', @(x)(ismember(x,{'from','to','both'})));

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
xshift = p.Results.xshift;
yshift = p.Results.yshift;
zshift = p.Results.zshift;
fromto = p.Results.fromto;

%% Adjust the position

position = thisR.lights{idx}.position;

if isfield(thisR.lights{idx}, 'direction')
    direction = thisR.lights{idx}.direction; % The direction to - from.
    direction = direction/norm(direction);

    % The three should follow the 'left hand rule' for the axis
    lightX = cross([0 1 0],direction); lightX = lightX/norm(lightX);
    lightY = cross(lightX,direction); lightY = lightY/norm(lightY);
    % We want cameraY to be pointing in the same direction as lookAt.up
    up = thisR.get('up');
    if lightY*up' < 0, lightY = -1*lightY; end
    lightX = reshape(lightX, size(direction)); lightY = reshape(lightY, size(direction));
    
else
    warning('This light does not have direction. Only translating position.');
    lightX = reshape([1 0 0], size(position)); lightY = reshape([0 1 0], size(position));
    direction = reshape([0 0 1], size(position));
end

shift = xshift*lightX + yshift*lightY + zshift*direction;

switch fromto
    case 'from'
        piLightSet(thisR, idx, 'from', position + shift);
    case 'to'
        if isfield(thisR.lights{idx}, 'direction')
            piLightSet(thisR, idx, 'to', direction + shift);
        else
            warning('This light does not have direction. It cannot be changed');
        end
    case 'both'
        piLightSet(thisR, idx, 'from', position + shift);
        if isfield(thisR.lights{idx}, 'direction')
            piLightSet(thisR, numel(thisR.lights), 'to', direction + shift);
        else
            warning('This light does not have direction. It cannot be changed');
        end
    otherwise
        error('Unknown "from to" type %s', fromto);
end

idx = numel(thisR.lights);
lightSource = thisR.lights{end};
end