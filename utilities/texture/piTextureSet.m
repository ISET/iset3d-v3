function texture = piTextureSet(texture, param, val, varargin)
% Set the parameter of a texture (idx)
%
% Inputs
%   texture - texture struct
%   param   - parameter name 
%   val     - value
%
% Optional key/val:
%   N/A
%
% Returns
%   texture
%
%
% ZLY, 2020, 2021
%
% See also

%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName    = lower(nameTypeVal{1});

if isstruct(val)
    % The user sent in a struct, we will loop through the entries and set
    % them all.
    pTypeVal = '';
else
    % Otherwise, we assume we are setting a specific val
    pTypeVal = 'val';
    
    % But we do allow the user to override the 'val'
    if numel(nameTypeVal) > 1
        pTypeVal = nameTypeVal{2};
    end
end

p = inputParser;
p.addRequired('texture', @(x)(isstruct(x)));
p.addRequired('param', @ischar);
p.addRequired('val', @(x)(ischar(x) || isstruct(x) || isnumeric(x) || islogical(x)));

p.parse(texture, param, val, varargin{:});

%% if obj is a texture struct
if isfield(texture, pName)
    % Set name or type
    if isequal(pName, 'name') || isequal(pName, 'type') || isequal(pName, 'format')
        texture.(pName) = val;
        return;
    end
    
    % Set a whole struct
    if isempty(pTypeVal)
        texture.(pName) = val;
        return;
    end

    % Set parameter type
    if isequal(pTypeVal, 'type')
        texture.(pName).type = type;
        return;
    end
    
    % Set parameter value
    if isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        texture.(pName).value = val;

        % Changing property type if the user doesn't specify it.
        if isnumeric(val)
            if numel(val) == 3
                texture.(pName).type = 'rgb';
            elseif numel(val) > 3
                texture.(pName).type = 'spectrum';
            elseif isinteger(val)
                texture.(pName).type = 'integer';
            else
                % if not a rgb or specrum type, it's a single float.
                texture.(pName).type = 'float';
            end
        elseif ischar(val)
            % It is a file name, so the type has to be spectrum or texture,
            % depending on the extension
            [~, ~, e] = fileparts(val); % Check extension
            if isequal(e, '.spd')
                texture.(pName).type = 'spectrum';
            else
                texture.(pName).type = 'string';
            end
        elseif islogical(val)
            texture.(pName).type = 'bool';
        end
    end
    
else
    warning('Parameter: %s does not exist in texture type: %s',...
                pName, texture.type);    
end
%% Old version
%{
%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('textureIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, textureIdx, param, val, varargin{:});
idx = p.Results.textureIdx;

%% Conditions where we need to convert spectrum from numeric to char
if contains(param, ['spectrum', 'rgb', 'color']) && isnumeric(val)
    val = strrep(strcat('[', num2str(val), ']'), '  ', ' ');
end

%%

thisR.textures.list{idx}.(param) = val;
%}
end