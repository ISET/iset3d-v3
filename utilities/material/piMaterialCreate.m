function material = piMaterialCreate(name, varargin)
%%
% 
% Synopsis:
%   material = piMaterialCreate(name, varargin);
%
% Brief description:
%   Create material with parameters.
%
% Inputs:
%   name                      - name of the material
%
% Optional key/val:
%   type                      - material type. Default is matte
%   other material properties - depending on material types. Default values
%                               can be found on PBRT website.
%                               https://pbrt.org/fileformat-v3.html#materials
%
% Description:
%   The material properties should be given in key/val pairs. For keys. it
%   should follow the format of 'TYPE KEYNAME'. It's easier for us to
%   extract type and parameter name using space.
%   Syntax is: 
%       material = piMaterialCreate(NAME, 'type', [MATERIAL TYPE],...
%                                   [PROPERTYTYPE PROPERTYNAME], [VALUE]); 
%       material = piMaterialCreate(NAME, 'type', [MATERIAL TYPE],...
%                                   [PROPERTYNAME PROPERTYTYPE], [VALUE]);
%
% Returns:
%   material                  - created material
%

% Examples
%{
    %   
    material = piMaterialCreate('new material', 'type', 'kdsubsurface',...
                                'kd rgb',[1, 1, 1]);
    material = piMaterialCreate('new material',...
                                'kd rgb',[1, 1, 1]);
    material = piMaterialCreate('new material', 'type', 'uber',...
                                'spectrum kd', [400 1 800 1]);
%}
%%
% Replace the space in potential parameters. For example, 'rgb kd' won't
% pass parse with the space, but we need the two parts in the string apart
% to extract type and key. So we replace space with '_' and use '_' as
% key word.
for ii=1:2:numel(varargin)
    varargin{ii} = strrep(varargin{ii}, ' ', '_');
end
%% Parse inputs
p = inputParser;
p.addRequired('name', @ischar);
p.addParameter('type', 'matte', @ischar);
p.KeepUnmatched = true;
p.parse(name, varargin{:});

tp = ieParamFormat(p.Results.type);
%% Construct material struct
material.name = name;

% Fluorescence EEM and concentration
material.fluorescence.type = 'photolumi';
material.fluorescence.value = [];

material.concentration.type = 'float';
material.concentration.value = [];

switch tp
    % Different materials have different properties
    case 'disney'
        material.type = 'disney';
        
        material.color.type = 'spectrum';
        material.color.value = [];
        
        material.anisotropic.type = 'float';
        material.anisotropic.value = [];
        
        material.clearcoat.type = 'float';
        material.clearcoat.value = [];
        
        material.clearcoatgloss.type = 'float';
        material.clearcoatgloss.value = [];
        
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.metallic.type = 'float';
        material.metallic.value = [];
        
        material.roughness.type = 'float';
        material.roughness.value = [];
        
        material.scatterdistance.type = 'spectrum';
        material.scatterdistance.value = [];
        
        material.sheen.type = 'float';
        material.sheen.value = [];
        
        material.sheentint.type = 'float';
        material.sheentint.value = [];
        
        material.spectrans.type = 'float';
        material.spectrans.value = [];
        
        material.speculartint.type = 'float';
        material.speculartint.value = [];
        
        % disney material thin surfaces mode
        material.thin.type = 'bool';
        material.thin.value = [];
        
        material.difftrans.type = 'spectrum';
        material.difftrans.value = [];
        
        material.flatness.type = 'spectrum';
        material.flatness.value = [];
        
    case 'fourier'
        material.type = 'fourier';
        
        material.bsdffile.type = 'string';
        material.bsdffile.value = '';
    case 'glass'
        material.type = 'glass';
        
        material.kr.type = 'spectrum';
        material.kr.value = [];
        
        material.kt.type = 'spectrum';
        material.kt.value = [];
        
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    case 'hair'
        % If "sigma_a" is specified, then all other parameters related to 
        % hair color are ignored, if present. Otherwise, if "color" is 
        % specified, the eumelanin and pheomelanin parameters are ignored, 
        % if present. If no hair color parameters are specified, a 
        % eumelanin concentration of 1.3 is used, giving brown hair.
        material.type = 'hair';
        
        material.sigma_a.type = 'spectrum';
        material.sigma_a.value = [];
        
        material.color.type = 'spectrum';
        material.color.value = [];
        
        material.eumelanin.type = 'float';
        material.eumelanin.value = [];
        
        material.pheomelanin.type = 'float';
        material.pheomelanin.value = [];
        
        % Additional parameters
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.beta_m.type = 'float';
        material.beta_m.value = [];
        
        material.beta_n.type = 'float';
        material.beta_n.value = [];
        
        material.alpha.type = 'float';
        material.alpha.value = [];
        
    case 'kdsubsurface'
        material.type = 'kdsubsurface';
        
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.mfp.type = 'float';
        material.mfp.value = [];
        
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.kr.type = 'spectrum';
        material.kr.value = [];
          
        material.kt.type = 'spectrum';
        material.kt.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    case 'matte'
        material.type = 'matte';
        
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.sigma.type = 'spectrum';
        material.sigma.value = [];
        
    case 'metal'
        material.type = 'metal';
        
        material.eta.type = 'spectrum';
        material.eta.value = [];
        
        material.k.type = 'spectrum';
        material.k.value = [];
        
        material.roughness.type = 'float';
        material.roughness.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    case 'mirror'
        material.type = 'mirror';
        
        material.kr.type = 'spectrum';
        material.kr.value = [];
    case 'mix'
        material.type = 'mix';
        
        material.amount.type = 'spectrum';
        material.amount.value = [];
        
        material.namedmaterial1.type = 'string';
        material.namedmaterial1.value = '';
        
        material.namedmaterial2.type = 'string';
        material.namedmaterial2.value = '';
    case 'plastic'
        material.type = 'plastic';
        
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.ks.type = 'spectrum';
        material.ks.value = [];
        
        material.roughness.type = 'float';
        material.roughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    case 'substrate'
        material.type = 'substrate';
        
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.ks.type = 'spectrum';
        material.ks.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    case 'subsurface'
        material.type = 'subsurface';
        
        % Note this is the 'name' parameter in PBRT website.
        material.subname.type = 'string';
        material.subname.value = '';
        
        material.sigma_a.type = 'spectrum';
        material.sigma_a.value = [];
        
        material.sigma_prime_s.type = 'spectrum';
        material.sigma_prime_s.value = [];
        
        material.scale.type = 'float';
        material.scale.value = [];
        
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.kr.type = 'spectrum';
        material.kr.value = [];
        
        material.kt.type = 'spectrum';
        material.kt.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
        
    case 'translucent'
        material.type = 'translucent';
        
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.ks.type = 'spectrum';
        material.ks.value = [];
        
        material.reflect.type = 'spectrum';
        material.reflect.value = [];
        
        material.transmit.type = 'spectrum';
        material.transmit.value = [];
        
        material.roughness.type = 'float';
        material.roughness.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
        
    case 'uber'
        material.type = 'uber';
        
        % Will be removed in PBRTv4
        material.kd.type = 'spectrum';
        material.kd.value = [];
        
        material.ks.type = 'spectrum';
        material.ks.value = [];
        
        material.kr.type = 'spectrum';
        material.kr.value = [];
        
        material.kt.type = 'spectrum';
        material.kt.value = [];
        
        material.roughness.type = 'float';
        material.roughness.value = [];
        
        material.uroughness.type = 'float';
        material.uroughness.value = [];
        
        material.vroughness.type = 'float';
        material.vroughness.value = [];
        
        material.eta.type = 'float';
        material.eta.value = [];
        
        material.opacity.type = 'spectrum';
        material.opacity.value = [];
        
        material.remaproughness.type = 'bool';
        material.remaproughness.value = [];
    otherwise
        warning('Material type: %s does not exist', tp)
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
    
    
    if isfield(material, keyName)
        material = piMaterialSet(material, sprintf('%s value', keyName),...
                                thisVal);
    else
        warning('Parameter %s does not exist in material %s',...
                    keyName, material.type)
    end
end

%%
%{
%% Get how many materials exist already
if isfield(thisR.materials, 'list')
    val = numel(piMaterialGet(thisR, 'print', false));
else
    val = 0;
end
idx = val + 1;


%% Construct material structure
material.name = strcat('Default material ', num2str(idx));
thisR.materials.list{idx} = material;

if isempty(varargin)
    material.stringtype = 'matte';
    thisR.materials.list{idx} = material;
else
    for ii=1:2:length(varargin)
        material.(varargin{ii}) = varargin{ii+1};
        piMaterialSet(thisR, idx, varargin{ii}, varargin{ii+1});
    end
end
%}
%%
%{
m.name = '';
m.linenumber = [];

m.string = '';
m.floatindex = [];

m.texturekd = '';
m.texturekr = '';
m.textureks = '';

m.rgbkr =[];
m.rgbks =[];
m.rgbkd =[];
m.rgbkt =[];

m.colorkd = [];
m.colorks = [];
m.colorreflect = [];
m.colortransmit = [];
m.colormfp = [];

m.floaturoughness = [];
m.floatvroughness = [];
m.floatroughness =[];
m.floateta = [];

m.spectrumkd = '';
m.spectrumks ='';
m.spectrumkr = '';
m.spectrumkt ='';
m.spectrumk = '';
m.spectrumeta ='';
m.stringnamedmaterial1 = '';
m.stringnamedmaterial2 = '';
m.texturebumpmap = '';
m.bsdffile = '';
m.boolremaproughness = '';

% Added photolumi for fluorescence materials
m.photolumifluorescence = '';
m.floatconcentration = [];
%}
end
