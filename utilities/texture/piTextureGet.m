function val = piTextureGet(thisR, varargin)
% Read a texture struct in the recipe
%
% Inputs
%   thisR:  Recipe
%
% Optional key/val pairs
%   idx:    Index of the texture to address
%   param: Parameter of the indexed texture to return
%   print: Print out the list of textures
%
% Returns
%   val: Depending on the input arguments
%       - Cell array of texture structures (idx and param both empty)
%       - One of textures (param empty)
%       - A parameter of one of the textures (idx and param both set)
%
% ZLY, SCIEN, 2020
%
% See also
%   

% Examples:
%{
    thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');
    textures = piTextureGet(thisR);
%}
%% Parse inputs

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addParameter('idx', [], @isnumeric);
p.addParameter('param', '', @ischar);
p.addParameter('print', false);

p.parse(thisR, varargin{:});
idx = p.Results.idx;
param = p.Results.param;

%% Check if any textures exist
if ~isfield(thisR.textures, 'list'), textureNames = {}; end
%% Return different values depending on inputs

if ~isempty(idx)
    % Just one of the textures
    thisTexture = thisR.textures.list{idx};
    if ~isempty(param)
        % A parameter of that texture
        val = thisTexture.(param);
    else
        val = thisTexture;
    end
else
    % Return all textures
    if ~isfield(thisR.textures, 'list')
        val = {};
    else
        val = thisR.textures.list;
    end
end

%% Print all textures

if p.Results.print
    disp('--------------------')
    disp('****Texture Type****')
    for ii = 1:length(textureNames)
        fprintf('%d: name: %s     format: %s    type: %s\n', ii,...
                thisR.textures.list{ii}.name,...
                thisR.textures.list{ii}.format,...
                thisR.textures.list{ii}.type);
    end
    disp('********************')
    disp('--------------------')
end
end