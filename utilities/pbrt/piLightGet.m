function lightSources = piLightGet(thisR, varargin)
% Read a light source struct in the recipe
%
% Inputs
%   thisR:  Recipe
%
% Optional key/val pairs
%   print:   Printout the list of lights
%
% Returns
%   lightSources:  Cell array of light source structures
%
% ZLY, SCIEN, 2020
%
% See also
%   piLightDelete, piLightAdd, piLightSet

%% Parse inputs

varargin = ieParamFormat(varargin);
p  = inputParser;
p.addRequired('recipe', @(x)(isa(x,'recipe')));
p.addParameter('print',true);

% Add this parameter to determine if we want to use the new piLightAdd
p.addParameter('newversion', 0, @islogical);

p.parse(thisR, varargin{:});

%% Directly get the results 
lightSources = thisR.lights;

%% Print if needed
if p.Results.print
    disp('---------------------')
    disp('*****Light Type******')
    for ii = 1:length(lightSources)
        fprintf('%d: name: %s     type: %s\n', ii,lightSources{ii}.name,lightSources{ii}.type);
    end
    disp('*********************')
    disp('---------------------')
end
end