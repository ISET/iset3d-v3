function material = piMaterialSet(material, param, val, varargin)
%% 
%
% Synopsis
%    material = piMaterialSet(material, param, val, varargin)
%
% Brief description
%   Set one of the material properties.
%
% Inputs:
%   material    - material struct.
%   param       - material property
%   val         - property value
%
% Optional key/value pairs
%   type        - property type
%   val         - property val
%
% Returns
%   material    -  modified material struct
%
% See also
%   piMaterialGet, piMaterial*

% Examples:
%{
    mat = piMaterialCreate('new material', 'kd', [400 1 800 1]);
    mat = piMaterialSet(mat, 'kd val', [1 1 1]);
    mat = piMaterialSet(mat, 'kd', [0.5 0.5 0.5]);
%}

%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName    = lower(nameTypeVal{1});

% Whether it is specified to set a type or a value.
if numel(nameTypeVal) > 1
    pTypeVal = nameTypeVal{2};
elseif isstruct(val)
    % Set a whole struct
    pTypeVal = '';
elseif ischar(nameTypeVal{1})
    % If nameTypeVal has only one part and it is a name of a field
    pTypeVal = 'val';
end

p = inputParser;
p.addRequired('material', @(x)(isstruct(x)));
p.addRequired('param', @ischar);
p.addRequired('val', @(x)(ischar(x) || isstruct(x) || isnumeric(x) || islogical(x)));

p.parse(material, param, val, varargin{:});

%% if obj is a material struct
% materialInfo has no meaning
% isfield(material, pName)
if true
    % Set name or type
    if isequal(pName, 'name') || isequal(pName, 'type')
        material.(pName) = val;
        return;
    end
    
    % Set a whole struct
    if isempty(pTypeVal)
        material.(pName) = val;
        return;
    end
    
    % Set parameter type
    if isequal(pTypeVal, 'type')
        material.(pName).type = type;
        return;
    end
    
    % Set parameter value
    if isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        material.(pName).value = val;

        % Changing property type if the user doesn't specify it.
        if isnumeric(val)
            if numel(val) == 3
                material.(pName).type = 'rgb';
            elseif numel(val) > 3
                if piMaterialISEEM(val)
                    material.(pName).type = 'photolumi';
                else
                    material.(pName).type = 'spectrum';
                end
            else
                % if not a rgb or specrum type, it's a single float.
                material.(pName).type = 'float';
            end
        elseif ischar(val)
            % It is a file name, so the type has to be spectrum or texture,
            % depending on the extension
            [~, ~, e] = fileparts(val); % Check extension
            if isequal(e, '.spd')
                material.(pName).type = 'spectrum';
            else
                material.(pName).type = 'texture';
            end
        elseif islogical(val)
            material.(pName).type = 'bool';
        end
    end
else
    warning('Parameter: %s does not exist in material type: %s',...
                pName, material.type);
end

%%
% NOTE: keep it longer for a while
%{
%% Conditions where we need to convert spectrum from numeric to char
if piContains(param, ['spectrum', 'rgb', 'color']) && isnumeric(val)
    val = strrep(strcat('[', num2str(val), ']'), ' ', ' ');
end

%% Check recipe version

%% Do the set
switch param
    case 'fluorophoreeem'
        fluorophoresName = val;
        if isempty(fluorophoresName)
            obj.materials.list{idx}.photolumifluorescence = '';
            obj.materials.list{idx}.floatconcentration = [];
        else
            wave = 365:5:705; % By default it is the wavelength range used in pbrt

            if ~strcmp(val, 'custom')
                fluorophores = fluorophoreRead(fluorophoresName,'wave',wave);

                % Here is the excitation emission matrix
                eem = fluorophoreGet(fluorophores,'eem');
            else
                eem = varargin{1};
            end
            % The data are converted to a vector like this
            flatEEM = eem';
            vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];
            obj.materials.list{idx}.photolumifluorescence = vec;
        end
    case 'fluorophoreconcentration'
        obj.materials.list{idx}.floatconcentration = val;
    case 'delete'
        % Delete one of the field in this material struct
        if isfield(obj.materials.list{idx}, val)
            obj.materials.list{idx} = rmfield(obj.materials.list{idx}, val);
        end
    otherwise
        % Set the rgb or spetrum value.  We should check that the param is
        % a valid field from below.
        obj.materials.list{idx}.(param) = val;
        
        % Clean up the unnecessary color fields 
        if strncmp(param,'texture',7)
            % if a texture do this
            switch param(end-2:end)
                case 'kd'
                    piMaterialSet(obj, idx, 'delete', 'rgbkd');
                    piMaterialSet(obj, idx, 'delete', 'spectrumkd');
                    piMaterialSet(obj, idx, 'delete', 'colorkd');
                case 'ks'
                    piMaterialSet(obj, idx, 'delete', 'rgbks');
                    piMaterialSet(obj, idx, 'delete', 'spectrumks');
                    piMaterialSet(obj, idx, 'delete', 'colorks');
                case 'kr'
                    piMaterialSet(obj, idx, 'delete', 'rgbkr');
                    piMaterialSet(obj, idx, 'delete', 'spectrumkr');
                    piMaterialSet(obj, idx, 'delete', 'colorkr');
            end
        else
            % otherwise not a texture so do this
            switch param
                case 'spectrumkd'
                    piMaterialSet(obj, idx, 'delete', 'rgbkd');
                    piMaterialSet(obj, idx, 'delete', 'colorkd');
                case 'rgbkd'
                    piMaterialSet(obj, idx, 'delete', 'spectrumkd');
                    piMaterialSet(obj, idx, 'delete', 'colorkd');
                case 'colorkd'
                    piMaterialSet(obj, idx, 'delete', 'spectrumkd');
                    piMaterialSet(obj, idx, 'delete', 'rgbkd');
                case 'spectrumks'
                    piMaterialSet(obj, idx, 'delete', 'rgbks');
                    piMaterialSet(obj, idx, 'delete', 'colorks');
                case 'rgbks'
                    piMaterialSet(obj, idx, 'delete', 'spectrumks');
                    piMaterialSet(obj, idx, 'delete', 'colorks');
                case 'colorks'
                    piMaterialSet(obj, idx, 'delete', 'spectrumks');
                    piMaterialSet(obj, idx, 'delete', 'rgbks');
                case 'spectrumkr'
                    piMaterialSet(obj, idx, 'delete', 'rgbkr');
                    piMaterialSet(obj, idx, 'delete', 'colorkr');
                case 'rgbkr'
                    piMaterialSet(obj, idx, 'delete', 'spectrumkr');
                    piMaterialSet(obj, idx, 'delete', 'colorkr');
                case 'colorkr'
                    piMaterialSet(obj, idx, 'delete', 'spectrumkr');
                    piMaterialSet(obj, idx, 'delete', 'rgbkr');
            end
        end
end
%}
end
