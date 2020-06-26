function val = piLightGet(thisR, varargin)
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
   thisR = piRecipeDefault;
   piLightGet(thisR)
   piLightGet(thisR,'idx',1)
   piLightGet(thisR,'idx',1,'param','range')
   piLightGet(thisR,'idx',1,'param','type')
   piLightGet(thisR,'idx',1,'param','from')
%}
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

end