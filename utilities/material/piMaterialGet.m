function val = piMaterialGet(thisR, varargin)
% Read a material struct in the recipe
%
% Inputs
%   thisR:  Recipe
%
% Optional key/val pairs
%   idx:    Index of the material to address
%   param:  Parameter of the indexed material to return
%   print:  Print out the list of textures
%
% Returns:
%   val: Depending on the input arguments
%       - Cell array of material structures (idx and param both empty)
%       - One of materials (param empty)
%       - A parameter of one of the materials (idx and param both set)
%
% ZLY, SCIEN, 2020
%
% See also
%

% Examples:
%{
    thisR = piRecipeDefault;
    materials = piMaterialGet(thisR);
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

%% Check if any material exist
if ~isfield(thisR.materials, 'list'), materialNames = {}; end

%% Return different values depending on inputs

if ~isempty(idx)
    % Just one of materials
    thisMaterial = thisR.materials.list{idx};
    if ~isempty(param)
        % A parameter of that material
        val = thisMaterial.(param);
    else
        val = thisMaterial;
    end
else
    % Return all textures
    if ~isfield(thisR.materials, 'list')
        val = {};
    else
        val = thisR.materials.list;
    end
end

%% Print all textures

if p.Results.print
    disp('--------------------')
    disp('****Material Type****')
    for ii = 1:length(materialNames)
        fprintf('%d: name: %s     format: %s    type: %s\n', ii,...
                thisR.material.list{ii}.name,...
                thisR.material.list{ii}.type);
    end
    disp('********************')
    disp('--------------------')    
end
end