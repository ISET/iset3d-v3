function lght = piLightTranslate(lght, varargin)
% Translate the from and to values of a light source
%
% Syntax
%   thisR = piLightTranslate(thisR, idx, varargin)
%
% Brief summary
%   A light source is at a position (from) and shines at a position
%   (to). Translating a light means translating its 'from' and 'to
%   positions.
%
% Inputs:
%    thisR:  Rendering recipe
%    idx:    Index of the light that we are changing
%
% Optional key/val pairs
%    xshift, yshift, zshift:  Translation for each of the directions
%                    (meters).  Default is 0.
%                    
%    fromto:  The value of the fromto flag governs whether the from,
%             to or both are  shifted.
%        from - Change the from position but keep light's direction
%               pointed at the same spot  
%        to   - Stay at the from position but adjust the to by the
%               shift
%        both - Change both the from and to by the same amount (default)
%
% Returns
%    thisR:  The modified recipe
%
% See also
%


% Examples
%{
    ieInit;
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    spotLight = piLightCreate('new spot', 'type', 'spot',...
                'cameracoordinate', true,...
                'spd val', 'D50',...
                'coneangle val', 5);
    spotLight = piLightTranslate(spotLight, 'x shift', 1);
    thisR.set('light', 'add', spotLight);

    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}
%{
    ieInit;
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    spotLight = piLightCreate('new spot', 'type', 'spot',...
                'cameracoordinate', true,...
                'spd val', 'D50',...
                'coneangle val', 5);
    thisR.set('light', 'add', spotLight);
    thisR.set('light', 'translate', 'new spot', [1 0 0]);

    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}
%% Parse

% Remove spaces, force lower case
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('lght', @isstruct);

p.addParameter('xshift', 0, @isscalar);
p.addParameter('yshift', 0, @isscalar);
p.addParameter('zshift', 0, @isscalar);
p.addParameter('fromto', 'both', @(x)(ismember(x,{'from','to','both'})));
p.addParameter('up', [0, 1, 0], @isnumeric);

p.parse(lght, varargin{:});

lght  = p.Results.lght;
xshift = p.Results.xshift;
yshift = p.Results.yshift;
zshift = p.Results.zshift;
fromto = p.Results.fromto;
up = p.Results.up;

%% Adjust the from
if ~isfield(lght, 'from')
    warning('Light type: %s does not have from field', lght.type);
    return;
end
from = piLightGet(lght, 'from val');

if isfield(lght, 'to')
    to = piLightGet(lght, 'to val');
    direction = to - from; % The to to - from.
    direction = direction/norm(direction);

    % The three should follow the 'left hand rule' for the axis
    lightX = cross([0 1 0],direction); lightX = lightX/norm(lightX);
    lightY = cross(lightX,direction); lightY = lightY/norm(lightY);
    % We want cameraY to be pointing in the same to as lookAt.up
    % up = thisR.get('up');
    if lightY*up' < 0, lightY = -1*lightY; end
    lightX = reshape(lightX, size(direction)); lightY = reshape(lightY, size(direction));
    
else
    warning('This light does not have to. Only translating from.');
    lightX = reshape([1 0 0], size(from)); lightY = reshape([0 1 0], size(from));
    direction = reshape([0 0 1], size(from));
end

shift = xshift*lightX + yshift*lightY + zshift*direction;

switch fromto
    case 'from'
        lght = piLightSet(lght, 'from val', from + shift);
    case 'to'
        if isfield(lght, 'to')
            lght = piLightSet(lght, 'to val', lght.to.val + shift);
        else
            warning('This light does not have to. It cannot be changed');
        end
    case 'both'
        lght = piLightSet(lght, 'from val', from + shift);
        if isfield(lght, 'to')
            lght = piLightSet(lght, 'to val', lght.to.value + shift);
        else
            warning('This light does not have to. It cannot be changed');
        end
    otherwise
        error('Unknown "from to" type %s', fromto);
end

%{
idx = numel(thisR.lights);
lightSource = thisR.lights{end};
%}

end