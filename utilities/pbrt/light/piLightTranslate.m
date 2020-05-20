function thisR = piLightTranslate(thisR, idx, varargin)
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

%% Adjust the from

from = thisR.lights{idx}.from;

if isfield(thisR.lights{idx}, 'to')
    to = thisR.lights{idx}.to; % The to to - from.
    to = to/norm(to);

    % The three should follow the 'left hand rule' for the axis
    lightX = cross([0 1 0],to); lightX = lightX/norm(lightX);
    lightY = cross(lightX,to); lightY = lightY/norm(lightY);
    % We want cameraY to be pointing in the same to as lookAt.up
    up = thisR.get('up');
    if lightY*up' < 0, lightY = -1*lightY; end
    lightX = reshape(lightX, size(to)); lightY = reshape(lightY, size(to));
    
else
    warning('This light does not have to. Only translating from.');
    lightX = reshape([1 0 0], size(from)); lightY = reshape([0 1 0], size(from));
    to = reshape([0 0 1], size(from));
end

shift = xshift*lightX + yshift*lightY + zshift*to;

switch fromto
    case 'from'
        piLightSet(thisR, idx, 'from', from + shift);
    case 'to'
        if isfield(thisR.lights{idx}, 'to')
            piLightSet(thisR, idx, 'to', to + shift);
        else
            warning('This light does not have to. It cannot be changed');
        end
    case 'both'
        piLightSet(thisR, idx, 'from', from + shift);
        if isfield(thisR.lights{idx}, 'to')
            piLightSet(thisR, numel(thisR.lights), 'to', to + shift);
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