function recipe = piRecipeConvertToDepth(recipe,varargin)
% piRecipeConvertToDepth - Read a recipe and make the appropriate changes
% so that it will render a depth map.
%
%%
p = inputParser;
p.addRequired('recipe',@(x)isequal(class(x),'recipe'));
p.parse(recipe,varargin{:});

%% 

% Assign metadata integrator
integrator = struct('type','SurfaceIntegrator','subtype','metadata');
integrator.strategy.value = 'depth'; 
integrator.strategy.type = 'string';
recipe.integrator = integrator;

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
recipe.sampler = sampler;

% Change filter for better depth sampling
filter = struct('type','PixelFilter','subtype','box');
filter.xwidth.value = 0.5;
filter.xwidth.type = 'float';
filter.ywidth.value = 0.5;
filter.ywidth.type = 'float';
recipe.filter = filter;

end

