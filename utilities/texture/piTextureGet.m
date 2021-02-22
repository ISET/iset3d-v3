function val = piTextureGet(texture, param, varargin)
% Read a texture struct in the recipe
%
% Synopsis:
%   val = piTextureGet(texture, param, varargin)
%
% Inputs
%   texture - texture struct
%   param   - parameter name 
%
% Description:
%   Param can be with format of 'PROPERTYNAME', 'PROPERTYNAME TYPE' or
%   'PROPERTYNAME VAL'. In the case of 'PROPERTYNAME', both type and value
%   of the property will be returned. Otherwise either type or value will be
%   returned.
%
% Returns
%   val: value of the parameter
%       
%
% ZLY, SCIEN, 2020, 2021
% See also
%   

% Examples:
%{
    texture = piTextureCreate('checkerboard_texture',...
                              'type', 'checkerboard',...
                              'uscale', 8,...
                              'vscale', 8,...
                              'tex1', [.01 .01 .01],...
                              'tex2', [.99 .99 .99]);
    val = piTextureGet(texture, 'tex1');
%}

%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName    = nameTypeVal{1};

pTypeVal = 'val';
if numel(nameTypeVal) > 1
    pTypeVal = nameTypeVal{2};
end

p = inputParser;
p.addRequired('texture', @isstruct);
p.addRequired('param', @ischar);

p.parse(texture, param, varargin{:});

%%
val = [];

if isfield(texture, pName)
    % If asking name or type, get the param and return.
    if isequal(pName, 'name') || isequal(pName, 'type') || isequal(pName, 'format')
        val = texture.(pName);
        return;
    end

    if isempty(pTypeVal)
        val = texture.(pName);
    elseif isequal(pTypeVal, 'type')
        val = texture.(pName).type;
    elseif isequal(pTypeVal, 'struct')
        val = texture.(pName);
    elseif isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        val = texture.(pName).value;
    end    
else
    warning('Parameter: %s does not exist in texture type: %s',...
            param, texture.type);
end


%% Old version
%{
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
%}
end