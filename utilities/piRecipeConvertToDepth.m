function depthRecipe = piRecipeConvertToDepth(recipe,varargin)
% Convert radiance recipe to a corresponding depth map recipe
%
% Syntax:
%    depthRecipe = piRecipeConvertToDepth(recipe,varargin)
%
% Input
%  recipe - a typical radiance input recipe
%
% Return
%  depthRecipe - the radiance recipe is converted to a depth recipe for the
%  same file
%
% TL, SCIEN Stanford, 2017

%% Verify and clone the radiance recipe

p = inputParser;
p.addRequired('recipe',@(x)isequal(class(x),'recipe'));
p.parse(recipe,varargin{:});

depthRecipe = copy(recipe);

%% Adjust the recipe values

% Assign metadata integrator
if(recipe.version == 3)
    integrator = struct('type','Integrator','subtype','metadata');
else 
    integrator = struct('type','SurfaceIntegrator','subtype','metadata');
end
integrator.strategy.value = 'depth'; 
integrator.strategy.type = 'string';
depthRecipe.integrator = integrator;

% Change sampler type for better depth sampling
sampler = struct('type','Sampler','subtype','stratified');
sampler.jitter.value = 'false';
sampler.jitter.type = 'bool';
sampler.pixelsamples.value = 8;
sampler.pixelsamples.type = 'integer';
sampler.xsamples.value= 1;
sampler.xsamples.type = 'integer';
sampler.ysamples.value = 1;
sampler.ysamples.type = 'integer';
depthRecipe.sampler = sampler;

% Change filter for better depth sampling
filter = struct('type','PixelFilter','subtype','box');
filter.xwidth.value = 0.5;
filter.xwidth.type = 'float';
filter.ywidth.value = 0.5;
filter.ywidth.type = 'float';
depthRecipe.filter = filter;

% Error checking
if(isempty(recipe.outputFile))
    error('Recipe output file is empty.');
end

% Assign the right depth output file.  Deep copy issue here?
[workingFolder, name, ~] = fileparts(recipe.outputFile);
depthFile   = fullfile(workingFolder,strcat(name,'_depth.pbrt'));
depthRecipe.outputFile = depthFile;

end

