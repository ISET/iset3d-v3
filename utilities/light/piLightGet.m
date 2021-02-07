function [val, txt] = piLightGet(lght, param, varargin)
% Read a light source struct in the recipe
%
% Inputs
%   thisR:  Recipe
%
% Optional key/val pairs
%   idx:     Index of the light to address
%   param:   Parameter of the indexed light to return
%   print:   Printout the list of lights
%
% Returns
%   val:  Depending on the input arguments
%      - Cell array of light source structures (idx and param both empty)
%      - One of the light sources  (param empty)
%      - A parameter of one of the light sources  (idx and param both set)
%
% ZLY, SCIEN, 2020
%
% See also
%   piLightDelete, piLightAdd, piLightSet

% Examples:
%{
    lght = piLightCreate('new light');
    lght = piLightSet(lght, 'spectrum val', 'D50');
    lght = piLightSet(lght, 'from val', [10 10 10]);
    spd = piLightGet(lght, 'spectrum val');
    fromType = piLightGet(lght, 'from type');
    from = piLightGet(lght, 'from');
%}
%% Parse inputs

% Check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName    = nameTypeVal{1};
if numel(nameTypeVal) > 1
    pTypeVal = nameTypeVal{2};
else
    pTypeVal = '';
end

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lght', @isstruct);
p.addRequired('param', @ischar);
p.addParameter('pbrttext', false, @islogical);

p.parse(lght, param, varargin{:});

pbrtText = p.Results.pbrttext;
%%
val = [];

if isfield(lght, pName)
    % If asking name, type or camera coordinate
    if (isequal(pName, 'name') || isequal(pName, 'type') ||...
            isequal(pName, 'cameracoordinate')) || isempty(pTypeVal)
        val = lght.(pName);
    end
    
    if isequal(pTypeVal, 'type')
        val = lght.(pName).type;
    elseif isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        val = lght.(pName).value;
    end
else
    warning('Parameter: %s does not exist in light type: %s',...
            param, light.type);    
end

%% compose pbrt text
txt = '';
if pbrtText && ~isempty(val) &&...
            (isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val') || isequal(pName, 'type'))
    switch pName
        case 'type'
            if ~isequal(val, 'area')
                txt = sprintf('LightSource "%s"', val);
            else
                txt = sprintf('AreaLightSource "diffuse"');
            end
        case 'spectrum'
            spectrumScale = lght.specscale.value;
            if ischar(lght.spectrum.value)
                lightSpectrum = sprintf('"spds/lights/%s_%f.spd"', lght.spectrum.value, spectrumScale);
            elseif isnumeric(lght.spectrum.value)
                lightSpectrum = ['[' ,piNum2String(lght.spectrum.value * spectrumScale),']'];
            end
            switch lght.type
                case {'point', 'goniometric', 'projection', 'spot', 'spotlight'} % I
                    txt = sprintf(' "%s I" %s', lght.spectrum.type, lightSpectrum);
                case {'distant', 'infinite', 'area'} % L
                    txt = sprintf(' "%s L" %s', lght.spectrum.type, lightSpectrum);
            end
        case 'from'
            txt = sprintf(' "point from" [%.4f %.4f %.4f]', val(1), val(2), val(3));
        case 'to'
            txt = sprintf(' "point to" [%.4f %.4f %.4f]', val(1), val(2), val(3));
        case 'mapname'
            txt = sprintf(' "string mapname" "%s"', val);
        case 'fov'
            txt = sprintf(' "float fov" [%.4f]', val);
        case 'nsamples'
            txt = sprintf(' "integer nsamples" [%d]', val);
        case 'coneangle'
            txt = sprintf(' "float coneangle" [%.4f]', coneangle);
        case 'conedeltaangle'
            txt = sprintf(' "float conedeltaangle" [%.4f]', conedeltaangle);
        case 'twosided'
            if val
                txt = sprintf(' "bool twosided" "%s"', 'true');
            else
                txt = sprintf(' "bool twosided" "%s"', 'false');
            end   
        case 'shape'
            txt = piShape2Text(val);
        case 'translation'
            txt = {}; % Change to cells 
            for ii=1:numel(val)
                txt{end + 1} = sprintf('Translate %.3f %.3f %.3f',...
                    val{ii}(1), val{ii}(2),...
                    val{ii}(3));
            end
        case 'rotation'
            % Copying from Zhenyi's code, Which does not account for multiple
            % rotations I think
            %{
                % might remove this;
                if iscell(rotate)
                    rotate = rotate{1};
                end
            %}
            txt = {}; % Change to cells 

            for ii=1:numel(val)
                curRot = val{ii};
                curRot = curRot(:)';
                txt{end + 1} = sprintf('Rotate %.3f %d %d %d', curRot(1),...
                                    curRot(2), curRot(3), curRot(4));
            end
        case 'ctform'
            for ii=1:numel(val)
                txt{end + 1} = sprintf('ConcatTransform [%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f]', val{ii}(:));
            end
        case 'scale'
            for ii=1:numel(val)
                txt{end + 1} = sprintf('Scale %.3f %.3f %.3f', val{ii}(1), val{ii}(2), val{ii}(3));
            end
    end
end
%% Old version
%{
%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('idx',[],@isnumeric);
p.addParameter('param','',@ischar);
p.addParameter('print',true);

% Add this parameter to determine if we want to use the new piLightAdd
p.addParameter('newversion', 0, @islogical);

p.parse(thisR, varargin{:});
idx = p.Results.idx;
param = p.Results.param;

%% Directly get the results 
lightSources = thisR.lights;

%% If an index and param are sent, just return that value

if ~isempty(idx)
    % Just one of the lights
    thisLight = lightSources{idx};
    if ~isempty(param)
        switch param
            case 'spd'
                % spd = piLightGet(thisR,'idx',1,'param','spd');
                val = ieReadSpectra(thisLight.lightspectrum);
                val = val*thisLight.spectrumscale;
            otherwise
                % A parameter of that light
                val = thisLight.(param);
        end        
    else
        val = thisLight;
    end
else
    % OK, all of the lights
    val = lightSources;
end


%% Print all the light sources

if p.Results.print
    disp('---------------------')
    disp('*****Light Type******')
    for ii = 1:length(lightSources)
        if isfield(lightSources{ii},'spectrum')
            fprintf('%d: name: %s     type: %s     spectrum:  %s\n', ii,...
                lightSources{ii}.name,lightSources{ii}.type,lightSources{ii}.lightspectrum);
        else
            fprintf('%d: name: %s     type: %s\n', ii,...
                lightSources{ii}.name,lightSources{ii}.type);
        end
            
    end
    disp('*********************')
    disp('---------------------')
end
%}
end