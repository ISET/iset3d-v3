function val = piMaterialGet(thisR, matInfo, param, varargin)
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

%%
if notDefined('param'), param = ''; end
%% Parse inputs

varargin = ieParamFormat(varargin);
param = ieParamFormat(param);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('matInfo', @(x)(ischar(x) || isscalar(x)));
p.addRequired('param', @ischar);
p.addParameter('print', false);

p.parse(thisR, matInfo, param, varargin{:});

%%
val = [];
% If assetInfo is a node name, find the id
if ischar(matInfo)
    matName = matInfo;
    matInfo = piMaterialFind(thisR, 'name', matInfo);
    if isempty(matInfo)
        warning('Could not find an asset with name: %s', matName);
        return;
    end
end

if isempty(matInfo) || matInfo > numel(thisR.materials.list)
    warning('Could not find material.')
    return;
end

if isempty(param)
    val = thisR.materials.list{matInfo};
else
    thisMat = thisR.get('materials', matInfo);
    if ~isfield(thisMat, param)
        warning('Mat: %s does not have field: %s', thisMat.name, param);
        return;
    end
    
    % If the parameter exists.
    switch param
        % Disney material
        case 'spectrumcolor'
            val = thisMat.spectrumcolor;
        case 'texturecolor'
            val = thisMat.texturecolor;
        case 'floatanisotropic'
            val = thisMat.floatanisotropic;
        case 'textureanisotropic'
            val = thisMat.textureanosotropic;
        case 'floatclearcoat'
            val = thisMat.floatclearcoat;
        case 'textureclearcoat'
            val = thisMat.floatclearcoat;
        case 'floatclearcoatgloss'
            val = thisMat.floatclearcoatgloss;
        case 'textureclearcoatgloss'
            val = thisMat.textureclearcoatgloss;
        case 'floateta'
            val = thisMat.floateta;
        case 'textureeta'
            val = thisMat.textureeta;
        case 'floatmetallic'
            val = thisMat.floatmetallic;
        case 'texturemetallic'
            val = thisMat.texturemetallic;
        case 'floatroughness'
            val = thisMat.floatroughness;
        case 'textureroughness'
            val = thisMat.textureroughness;
        case 'spectrumscatterdistance'
            val = thisMat.spectrumscatterdistance;
        case 'texturescatterdistance'
            val = thisMat.texturescatterdistance;
        case 'floatsheen'
            val = thisMat.floatsheen;
        case 'texturesheen'
            val = thisMat.texturesheen;
        case 'floatsheentint'
            val = thisMat.floatsheentint;
        case 'texturesheentint'
            val = thisMat.texturesheentint;
        case 'floatspectrans'
            val = thisMat.floatspectrans;
        case 'texturespectrans'
            val = thisMat.texturespectrans;
        case 'floatspeculartint'
            val = thisMat.floatspeculartint;
        case 'texturespeculartint'
            val = thisMat.texturespeculartint;
        % Disney BSDF
        case 'boolthin'
            val = thisMat.boolthin;
        case 'spectrumdifftrans'
            val = thisMat.spectrumdifftrans;
        case 'texturedifftrans'
            val = thisMat.texturedifftrans;
        case 'spectrumflatness'
            val = thisMat.spectrumflatness;
        case 'textureflatness'
            val = thisMat.textureflatness;
        % Fourier
        case 'stringbsdffile'
            val = thisMat.stringbsdffile;
        % Glass
        case 'spectrumkr'
            val = thisMat.spectrumkr;
        case 'texturekr'
            val = thisMat.texturekr;
        case 'spectrumkt'
            val = thisMat.spectrumkt;
        case 'texturekt'
            val = thisMat.texturekt;
        case 'floaturoughness'
            val = thisMat.floaturoughness;
        case 'textureuroughness'
            val = thisMat.textureuroughness;
        case 'floatvroughness'
            val = thisMat.floatvroughness;
        case 'texturevroughness'
            val = thisMat.texturevroughness;
        case 'boolremaproughness'
            val = thisMat.boolremaproughness;
        % Hair
        case 'spectrumsigmaa'
            val = thisMat.spectrumsigmaa;
        case 'texturesigmaa'
            val = thisMat.texturesigmaa;
        case 'floateumelanin'
            val = thisMat.
            
            
        otherwise
            warning('Unknown parameter: %s', param)
            val = thisMat.(param);
    end
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