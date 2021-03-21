function texture = piTextureCreate(name, varargin)
% Initialize a texture with specific parameters
%
% Synopsis
%   texture = piTextureCreate(name,varargin);
%
% Inputs:
%   name    - name of a texture
%
% Optional key/val pairs
%
%   The key/val options depend on the type of texture.  Use
%
%       piTextureProperties(textureType) 
%
%   to see the properties that you can set for each texture type.
%
% Outputs:
%   texture - new texture with parameters
%
% ZLY, 2021
% 
% See also
%

% Examples
%{
  piTextureCreate('list available types')
%}
%{
  texture = piTextureCreate('checkerboard_texture',...
        'type', 'checkerboard',...
        'uscale', 8,...
        'vscale', 8,...
        'tex1', [.01 .01 .01],...
        'tex2', [.99 .99 .99]);
%}

%% List availble type

validTextures = {'constant','scale','mix','bilerp','imagemap',...
    'checkerboard','dots','fbm','wrinkled','marble','windy'};

if isequal(ieParamFormat(name),'listavailabletypes')
    texture = validTextures;
    return;
end

%% Needed rather than ieParamFormat because of PBRT syntax issues

for ii=1:2:numel(varargin)
    varargin{ii} = strrep(varargin{ii}, ' ', '_');
end

%% Parse inputs
p = inputParser;
p.addRequired('name', @ischar);
p.addParameter('type', 'constant', @ischar);
p.addParameter('format', 'spectrum', @ischar);
p.KeepUnmatched = true;
p.parse(name, varargin{:});

tp   = ieParamFormat(p.Results.type);
form = ieParamFormat(p.Results.format);

%% Construct material struct
texture.name = name;
texture.format = form;

switch tp
    % Any-D
    % Constant, Scale, Mix
    case 'constant'
        texture.type = 'constant';
        
        texture.value.type = 'float';
        texture.value.value = [];
    case 'scale'
        texture.type = 'scale';
        
        texture.tex1.type = 'float';
        texture.tex1.value = [];
        
        texture.tex2.type = 'float';
        texture.tex2.value = [];
        
    case 'mix'
        texture.type = 'mix';
        
        texture.tex1.type = 'float';
        texture.tex1.value = [];
        
        texture.tex2.type = 'float';
        texture.tex2.value = [];
        
        texture.amount.type = 'float';
        texture.amount.value = [];
        
    % 2D
    % Bilerp, Image, UV, Checkerboard, Dots        
    case 'bilerp'
        texture.type = 'bilerp';
        
        texture.v00.type = 'float';
        texture.v00.value = [];
        
        texture.v01.type = 'float';
        texture.v01.value = [];        
    
        texture.v10.type = 'float';
        texture.v10.value = [];
        
        texture.v11.type = 'float';
        texture.v11.value = [];
        
        % Common property for 2D texture
        texture.mapping.type = 'string';
        texture.mapping.value = '';
        
        texture.uscale.type = 'float';
        texture.uscale.value = [];
        
        texture.vscale.type = 'float';
        texture.vscale.value = [];
        
        texture.udelta.type = 'float';
        texture.udelta.value = [];
        
        texture.vdelta.type = 'float';
        texture.vdelta.value = [];
        
        texture.v1.type = 'vector';
        texture.v1.value = [];
        
        texture.v2.type = 'vector';
        texture.v2.value = [];
    case 'imagemap'
        texture.type = 'imagemap';
        
        texture.filename.type = 'string';
        texture.filename.value = '';
        
        texture.wrap.type = 'string';
        texture.wrap.value = '';
        
        texture.maxanisotropy.type = 'float';
        texture.maxanisotropy.value = [];
        
        texture.trilinear.type = 'bool';
        texture.trilinear.value = [];
        
        texture.scale.type = 'float';
        texture.scale.value = [];
        
        texture.gamma.type = 'bool';
        texture.gamma.value = [];
        
        % Basis features
        texture.basis.type = 'string';
        texture.basis.value = '';
        
        texture.basisone.type = 'spectrum';
        texture.basisone.value = [];
        
        texture.basistwo.type = 'spectrum';
        texture.basistwo.value = [];
        
        texture.basisthree.type = 'spectrum';
        texture.basisthree.value = [];
        
        
        % Common property for 2D texture
        texture.mapping.type = 'string';
        texture.mapping.value = '';
        
        texture.uscale.type = 'float';
        texture.uscale.value = [];
        
        texture.vscale.type = 'float';
        texture.vscale.value = [];
        
        texture.udelta.type = 'float';
        texture.udelta.value = [];
        
        texture.vdelta.type = 'float';
        texture.vdelta.value = [];
        
        texture.v1.type = 'vector';
        texture.v1.value = [];
        
        texture.v2.type = 'vector';
        texture.v2.value = [];
    case 'checkerboard'
        texture.type = 'checkerboard';
        
        texture.dimension.type = 'integer';
        texture.dimension.value = [];
        
        texture.tex1.type = 'float';
        texture.tex1.value = [];
        
        texture.tex2.type = 'float';
        texture.tex2.value = [];
        
        texture.aamode.type = 'string';
        texture.aamode.value = '';
        
        % Common property for 2D texture
        texture.mapping.type = 'string';
        texture.mapping.value = '';
        
        texture.uscale.type = 'float';
        texture.uscale.value = [];
        
        texture.vscale.type = 'float';
        texture.vscale.value = [];
        
        texture.udelta.type = 'float';
        texture.udelta.value = [];
        
        texture.vdelta.type = 'float';
        texture.vdelta.value = [];
        
        texture.v1.type = 'vector';
        texture.v1.value = [];
        
        texture.v2.type = 'vector';
        texture.v2.value = [];
        
    case 'dots'
        texture.type = 'dots';
        
        texture.inside.type = 'float';
        texture.inside.value = [];
        
        texture.outside.type = 'float';
        texture.outside.value = [];
        
         % Common property for 2D texture
        texture.mapping.type = 'string';
        texture.mapping.value = '';
        
        texture.uscale.type = 'float';
        texture.uscale.value = [];
        
        texture.vscale.type = 'float';
        texture.vscale.value = [];
        
        texture.udelta.type = 'float';
        texture.udelta.value = [];
        
        texture.vdelta.type = 'float';
        texture.vdelta.value = [];
        
        texture.v1.type = 'vector';
        texture.v1.value = [];
        
        texture.v2.type = 'vector';
        texture.v2.value = []; 
        
    % 3D
    % Checkerboard, FBm, Wrinkled, Marble, Windy
    case 'fbm'
        texture.type = 'fbm';
        
        texture.octaves.type = 'integer';
        texture.octaves.value = [];
        
        texture.roughness.type = 'float';
        texture.roughness.vlaue = [];
        
    case 'wrinkled'
        texture.type = 'wrinkled';
        
        texture.octaves.type = 'integer';
        texture.octaves.value = [];
        
        texture.roughness.type = 'float';
        texture.roughness.value = [];
        
    case 'marble'
        texture.type = 'marble';
        
        texture.octaves.type = 'integer';
        texture.octaves.value = [];
        
        texture.roughness.type = 'float';
        texture.roughness.value = [];
        
        texture.scale.type = 'float';
        texture.scale.value = [];
        
        texture.variation.type = 'float';
        texture.variation.value = [];
    case 'windy'
        % This texture is missing. Something to check
        texture.type = 'windy';
    otherwise
        warning('Texture type: %s does not exist', tp)
        return;
end

%% Put in key/val

for ii=1:2:numel(varargin)
    thisKey = varargin{ii};
    thisVal = varargin{ii + 1};
    
    if isequal(thisKey, 'type')
        % Skip since we've taken care of material type above.
        continue;
    end
    
    keyTypeName = strsplit(thisKey, '_');
    
    % keyName is the property name. if it follows 'TYPE_NAME', we need
    % later, otherwise we need the first one.
    if piMaterialIsParamType(keyTypeName{1})
        keyName = ieParamFormat(keyTypeName{2});
    else
        keyName = ieParamFormat(keyTypeName{1});
    end
    
    
    if isfield(texture, keyName)
        texture = piTextureSet(texture, sprintf('%s value', keyName),...
                                thisVal);
    else
        warning('Parameter %s does not exist in texture %s',...
                    keyName, texture.type)
    end    
end


%%
%{
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
%}
end