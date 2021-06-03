function sceneR = piRecipeMerge(sceneR, objectRs, varargin)
% Add multiple object recipes into a base scene recipe
%
% Synopsis:
%   sceneR = piRecipeMerge(sceneR, objects, varargin)
% 
% Brief description:
%   Merges objects information (material, texture, assets) from two recipes
%   into one. 
%
% Inputs:
%   sceneR    - scene recipe
%   objectRs  - a single object recipe or a cell array of object recipes
%   
% Optional key/val pairs
%   material -  The user can decide to NOT add materials.  Default is true
%   texture  -  Same
%   asset    -  Same
%
% Returns:
%   sceneR   - scene recipe with added objects
%
% See also
%

%% Parse input
p = inputParser;
p.addRequired('sceneR', @(x)isequal(class(x),'recipe'));
p.addRequired('objectRs', @(x)isequal(class(x),'recipe') || iscell);

% So far, we add materials, textures, and assets.  We have not yet
% addressed lights.  The user can 
p.addParameter('material',true);
p.addParameter('texture',true);
p.addParameter('asset',true);

p.parse(sceneR, objectRs, varargin{:});

sceneR       = p.Results.sceneR;
materialFlag = p.Results.material;
textureFlag  = p.Results.texture;
assetFlag    = p.Results.asset;

%%  The objects can be a cell or a recipe

if ~iscell(objectRs)
    % Make it a cell
    recipelist{1} = objectRs;
else
    % A cell array of recipes
    recipelist = objectRs;
end

%% For each object recipe, add the object to the scene

for ii = 1:length(recipelist)
    thisR = recipelist{ii};
    
    if assetFlag
        
        % Get the asset names in the object
        names = thisR.get('assetnames');
        
        % Get the subtree starting just below the root
        thisOBJsubtree = thisR.get('asset', names{2}, 'subtree');
        
        % Graft the asset three into the scene.  We graft it onto the root
        % of the main scene.
        sceneR.set('asset', 'root', 'graft', thisOBJsubtree);
        
        % Copy meshes from objects folder to scene folder here
        sourceDir = thisR.get('input dir');
        dstDir    = sceneR.get('output dir');
        
        % Copy the assets from source to destination
        sourceAssets = fullfile(sourceDir, 'scene/PBRT/pbrt-geometry');
        if exist(sourceAssets, 'dir')&& ~isempty(dir(fullfile(sourceAssets,'*.pbrt')))
            dstAssets = fullfile(dstDir,    'scene/PBRT/pbrt-geometry');
            copyfile(sourceAssets, dstAssets);
        else
            copyfile(sourceDir, dstDir);
        end
    end
    
    if materialFlag
        % Combines the material lists in the two recipes
        if ~isempty(sceneR.materials)
            sceneR.materials.list = [sceneR.materials.list; thisR.materials.list];
        else
            sceneR.materials = thisR.materials;
        end
    end
    
    if textureFlag
        % Combines the lists in the recipes, and then the files
        if ~isempty(sceneR.textures)
            sceneR.textures.list = [sceneR.textures.list; thisR.textures.list];
        else
            sceneR.textures = thisR.textures;
        end
        
        % Copy texture files
        sourceDir = thisR.get('output dir');
        dstDir    = sceneR.get('output dir');        
        sourceTextures = fullfile(sourceDir, 'textures');        
        if exist(sourceTextures, 'dir')
            copyfile(sourceTextures, dstDir);
        end
    end
end

end

