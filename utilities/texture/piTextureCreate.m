function texture = piTextureCreate(thisR, varargin)
% Initialize a texture with specific parameters
%
% Synopsis
%   texture = piTextureCreate(thisR);

% Examples
%{
    thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');
    texture = piTextureCreate(thisR);
%}
%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;
p.parse(varargin{:});

%% Get how many textures exist already
val = numel(piTextureGet(thisR, 'print', false));
idx = val + 1;
%% Construct texture structure
texture.name = strcat('Default texture ', num2str(idx));
thisR.textures.list{idx} = texture;

if isempty(varargin)
    % if no parameters, provide a default constant texture
    texture.format = 'float';
    texture.type = 'constant';
    texture.floatvalue = 1;
    thisR.textures.list{idx} = texture;
else
    for ii=1:2:length(varargin)
        texture.(varargin{ii}) = varargin{ii+1};
        piTextureSet(thisR, idx, varargin{ii}, varargin{ii+1});
    end
end
end