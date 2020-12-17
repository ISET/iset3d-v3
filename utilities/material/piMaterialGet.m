function res = piMaterialGet(material, param, varargin)
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
    materials = thisR.get('materials');
    matName = 'Patch01Material';
    thisMaterial = thisR.get('materials', matName);
%}

%% Parse inputs

param = ieParamFormat(param);

p = inputParser;
p.addRequired(material, @isstruct);
p.addRequired('param', @ischar);
p.addParameter('type', '', @ischar);
p.addParameter('val', '', @ischar);

p.parse(material, param, varargin{:});

%%
res = [];

if isfield(material, param)
    % If type and val are both empty, return the parameter struct
    if  ~isempty(type) && ~isempty(res)

    end    
else
    warning('Parameter: %s does not exist in material type: %s',...
            param, material.type);
end


%{
%% Return different values depending on inputs

if ~isempty(idx)
    % Just one of the textures
    thisMaterial = thisR.materials.list{idx};
    if ~isempty(param)
        % A parameter of that texture
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

%% Print all materials

if p.Results.print
    disp('--------------------')
    disp('****Material Type****')
    for ii = 1:length(materialNames)
        fprintf('%d: name: %s     format: %s    type: %s\n', ii,...
                thisR.materials.list{ii}.name,...
                thisR.materials.list{ii}.type);
    end
    disp('********************')
    disp('--------------------')    
end
%}
end