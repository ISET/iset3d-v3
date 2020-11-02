function thisR = piMaterialSet(thisR, materialIdx, param, val, varargin)
%% Set the material properties
%
% Synopsis
%    thisR = piMaterialSet(thisR, materialIdx, param, val, varargin)
%
% Description
%   Set one of the material properties.  Works only for recipe version 2
%
% Inputs:
%    thisR
%    materialIdx
%    param
%    val
%
% Optional key/value pairs
%
% Returns
%   (thisR) modified recipe
%
% See also
%   piMaterialGet, piMaterial*


%% Parse inputs
param = ieParamFormat(param);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('materialIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

% varargin is not parsed. Due to multiple fluorophores. See below
p.parse(thisR, materialIdx, param, val); 
idx = p.Results.materialIdx;

%% Conditions where we need to convert spectrum from numeric to char
if piContains(param, ['spectrum', 'rgb', 'color']) && isnumeric(val)
    val = strrep(strcat('[', num2str(val), ']'), ' ', ' ');
end

%% Check recipe version

% Only works for recipeVer = 2.

%% Do the set
switch param
    case 'fluorophoreeem'
        fluorophoresName = val;
        if isempty(fluorophoresName)
            thisR.materials.list{idx}.photolumifluorescence = '';
            thisR.materials.list{idx}.floatconcentration = [];
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
            thisR.materials.list{idx}.photolumifluorescence = vec;
        end
    case 'fluorophoreconcentration'
        thisR.materials.list{idx}.floatconcentration = val;
    case 'delete'
        % Delete one of the field in this material struct
        if isfield(thisR.materials.list{idx}, val)
            thisR.materials.list{idx} = rmfield(thisR.materials.list{idx}, val);
        end
    otherwise
        % Set the rgb or spetrum value.  We should check that the param is
        % a valid field from below.
        thisR.materials.list{idx}.(param) = val;
        
        % Clean up the unnecessary color fields 
        if strncmp(param,'texture',7)
            % if a texture do this
            switch param(end-2:end)
                case 'kd'
                    piMaterialSet(thisR, idx, 'delete', 'rgbkd');
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkd');
                    piMaterialSet(thisR, idx, 'delete', 'colorkd');
                case 'ks'
                    piMaterialSet(thisR, idx, 'delete', 'rgbks');
                    piMaterialSet(thisR, idx, 'delete', 'spectrumks');
                    piMaterialSet(thisR, idx, 'delete', 'colorks');
                case 'kr'
                    piMaterialSet(thisR, idx, 'delete', 'rgbkr');
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkr');
                    piMaterialSet(thisR, idx, 'delete', 'colorkr');
            end
        else
            % otherwise not a texture so do this
            switch param
                case 'spectrumkd'
                    piMaterialSet(thisR, idx, 'delete', 'rgbkd');
                    piMaterialSet(thisR, idx, 'delete', 'colorkd');
                case 'rgbkd'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkd');
                    piMaterialSet(thisR, idx, 'delete', 'colorkd');
                case 'colorkd'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkd');
                    piMaterialSet(thisR, idx, 'delete', 'rgbkd');
                case 'spectrumks'
                    piMaterialSet(thisR, idx, 'delete', 'rgbks');
                    piMaterialSet(thisR, idx, 'delete', 'colorks');
                case 'rgbks'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumks');
                    piMaterialSet(thisR, idx, 'delete', 'colorks');
                case 'colorks'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumks');
                    piMaterialSet(thisR, idx, 'delete', 'rgbks');
                case 'spectrumkr'
                    piMaterialSet(thisR, idx, 'delete', 'rgbkr');
                    piMaterialSet(thisR, idx, 'delete', 'colorkr');
                case 'rgbkr'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkr');
                    piMaterialSet(thisR, idx, 'delete', 'colorkr');
                case 'colorkr'
                    piMaterialSet(thisR, idx, 'delete', 'spectrumkr');
                    piMaterialSet(thisR, idx, 'delete', 'rgbkr');
            end
        end
end

end
