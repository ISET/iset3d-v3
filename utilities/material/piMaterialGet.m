function val = piMaterialGet(materials, varargin)
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
p.addRequired('materials', @iscell);
p.addParameter('idx', [], @isnumeric);
p.addParameter('param', '', @ischar);
p.addParameter('print', false);

p.parse(materials, varargin{:});
idx = p.Results.idx;
param = p.Results.param;

%% Check if any material exist
if isempty(materials), materialNames = {}; end

%% Return different values depending on inputs

if ~isempty(idx)
    % Just one of materials
    thisMaterial = materials{idx};
    if ~isempty(param)
        % A parameter of that material
        val = thisMaterial.(param);
    else
        val = thisMaterial;
    end
else
    % Return all material
    if isempty(material)
        val = {};
    else
        val = material;
    end
end

%% Print all textures

if p.Results.print
    disp('--------------------')
    disp('****Material Type****')
    for ii = 1:length(materialNames)
        fprintf('%d: name: %s     format: %s    type: %s\n', ii,...
                materials{ii}.name,...
                materials{ii}.type);
    end
    disp('********************')
    disp('--------------------')    
end
end