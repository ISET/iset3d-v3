function material = piMaterialSet(material, param, varargin)
%% 
%
% Synopsis
%    thisR = piMaterialSet(material, materialIdx, param, val, varargin)
%
% Brief description
%   Set one of the material properties.
%
% Inputs:
%   material
%   materialInfo
%
% Optional key/value pairs
%   type    - property type
%   val     - property val
%
% Returns
%   obj     -  modified recipe or material struct
%
% See also
%   piMaterialGet, piMaterial*


%% Parse inputs

p = inputParser;
p.addRequired('material', @(x)(isstruct(x)));
p.addRequired('param', @ischar);
p.addParameter('type', '', @ischar);
p.addParameter('val', [], @(x)(ischar(x) || isnumeric(x)));

% varargin is not parsed. Due to multiple fluorophores. See below
p.parse(material, param, varargin{:});
type = p.Results.type;
val = p.Results.val;

%% if obj is a material struct
% materialInfo has no meaning

if ~isfield(material, param)
    warning('Parameter: %s does not exist in %s, returning.',...
                param, material.name)
    return;
end

if isequal(param, 'type')
    % If setting material type, get the value and return.
    material.(param) = val;
    return;
end

if ~isempty(type)
    material.(param).type = type;
end

if ~isempty(val)
    material.(param).value = val;

    % Changing property type if the user doesn't specify it.
    if isnumeric(val)
        if numel(val) == 3
            material.(param).type = 'rgb';
        elseif numel(value) > 3
            material.(param).type = 'spectrum';
        end
    elseif ischar(val)
        % It is a file name, so the type has to be spectrum or texture,
        % depending on the extension
        [~, ~, e] = fileparts(val); % Check extension
        if isempty(e) || isequal(e, '.spd')
            material.(param).type = 'spectrum';
        else
            material.(param).type = 'texture';
        end
    end
end
return;

%%
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
