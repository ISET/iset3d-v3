function metadataRecipe = piRecipeConvertToMetadata(recipe,varargin)
% Convert radiance recipe to a corresponding metadata map (e.g. depth) recipe
%
% Syntax:
%    metadataRecipe = piRecipeConvertToMetadata(recipe,varargin)
%
% Input
%  recipe - a typical radiance input recipe
%
% Return
%  metadataRecipe - the radiance recipe is converted to a a metadata recipe for the
%  same file. Metadata types include "depth,mesh,material,or coordinates(v3)"
%
% TL, SCIEN Stanford, 2017

%% Verify and clone the radiance recipe

p = inputParser;
p.addRequired('recipe',@(x)isequal(class(x),'recipe'));
p.addParameter('metadata','depth',@ischar); % By default it is a depth map
p.parse(recipe,varargin{:});
metadata = p.Results.metadata;

metadataRecipe = copy(recipe);
% there is a bug for containers.Map, so we need to create a new one.
if ~isempty(recipe.materials.list.keys)
    metadataRecipe.materials.list = containers.Map(recipe.materials.list.keys, recipe.materials.list.values);
end
if ~isempty(recipe.textures.list.keys)
    metadataRecipe.textures.list = containers.Map(recipe.textures.list.keys, recipe.textures.list.values);
end
%% Adjust the recipe values

if strcmp(metadata, 'illuminant') || strcmp(metadata, 'illuminantonly')
    % To estimate the illuminant, we write a new materials with a
    % white, matte surface.
    fprintf('Creating matte white surface version of the scene.\n');

    % Change the file name so we do not overwite the radiance materials
    % file.  The illuminant case sets all the materials to matte white.
    oFile = metadataRecipe.get('output basename');
    oDir  = metadataRecipe.get('output dir');
    metadataRecipe.set('output file',fullfile(oDir,[oFile,'_illuminant.pbrt']));

    totalReflection = metadataRecipe.materials.lib.totalreflect;
    
    % piMaterialTotalAssign(thisR)
%     mlist = metadataRecipe.materials.list;
    mlist = keys(metadataRecipe.materials.list);
    for ii = 1:numel(mlist)        
        totalReflection.name = mlist{ii};
        metadataRecipe.materials.list(mlist{ii}) = totalReflection;
    end
    
    
else % mesh or depth will come this way

    % Assign metadata integrator
    if(recipe.version == 3)
        integrator = struct('type','Integrator','subtype','metadata');
    else 
        integrator = struct('type','SurfaceIntegrator','subtype','metadata');
    end
    integrator.strategy.value = metadata; 
    integrator.strategy.type = 'string';
    metadataRecipe.integrator = integrator;

    % For version 3, we have to turn off the weighting on the camera
    if(recipe.version == 3)
        metadataRecipe.camera.noweighting.value = 'true';
        metadataRecipe.camera.noweighting.type = 'bool';
    end
    % Assign film datatype
    film = metadataRecipe.film;
    film.datatype.value = metadata;
    film.datatype.type = 'string';
    metadataRecipe.film = film;

    % Change sampler type for better depth sampling
    sampler = struct('type','Sampler','subtype','stratified');
    sampler.jitter.value = 'false';
    sampler.jitter.type = 'bool';
    sampler.xsamples.value= 1;
    sampler.xsamples.type = 'integer';
    sampler.ysamples.value = 1;
    sampler.ysamples.type = 'integer';
    metadataRecipe.sampler = sampler;

    % Change filter for better depth sampling
    filter = struct('type','PixelFilter','subtype','box');
    filter.xwidth.value = 0.5;
    filter.xwidth.type = 'float';
    filter.ywidth.value = 0.5;
    filter.ywidth.type = 'float';
    metadataRecipe.filter = filter;

    % TODO: Add flag into film

end

% Error checking
if(isempty(recipe.outputFile))
    error('Recipe output file is empty.');
end

% Assign the right depth output file.  Deep copy issue here?
[workingFolder, name, ~] = fileparts(recipe.outputFile);
metadataFile   = fullfile(workingFolder,sprintf('%s_%s.pbrt',name,metadata));
metadataRecipe.outputFile = metadataFile;

end

