function val = piLightGet(lght, param, varargin)
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

p = inputParser;
p.addRequired('lght', @isstruct);
p.addRequired('param', @ischar);

p.parse(lght, param, varargin{:});
%%
val = [];

if isfield(lght, pName)
    % If asking name, type or camera coordinate
    if isequal(pName, 'name') || isequal(pName, 'type') ||...
            isequal(pName, 'cameracoordinate')
        val = lght.(pName);
        return;
    end
    
    if isempty(pTypeVal)
        val = lght.(pName);
    elseif isequal(pTypeVal, 'type')
        val = lght.(pName).type;
    elseif isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        val = lght.(pName).value;
    end
else
    warning('Parameter: %s does not exist in light type: %s',...
            param, light.type);    
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