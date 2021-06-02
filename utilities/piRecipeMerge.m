function sceneR = piRecipeMerge(sceneR, objectRs, varargin)
% Add objects information to scene recipe
%
% Synopsis:
%   sceneR = piRecipeMerge(sceneR, objects, varargin)
% 
% Brief description:
%   Add objects information (material, texture, assets) to a scene recipe.
%
% Inputs:
%   sceneR   - scene recipe
%   objectRs  - object recipe/ recipe list
%   
% Returns:
%   sceneR   - scene recipe with added objects.
%
%% Parse input
p = inputParser;
p.addRequired('sceneR', @(x)isequal(class(x),'recipe'));
p.addParameter('material',true);
p.addParameter('texture',true);
p.addParameter('asset',true);

p.parse(sceneR, varargin{:});

sceneR        = p.Results.sceneR;
materialFlag = p.Results.material;
textureFlag  = p.Results.texture;
assetFlag    = p.Results.asset;

%%
if ~iscell(objectRs)
    recipelist{1} = objectRs;
else
    recipelist = objectRs;
end
for ii = 1:length(recipelist)
    thisR = recipelist{ii};
    if assetFlag
        names = thisR.get('assetnames');
        thisOBJsubtree = thisR.get('asset', names{2}, 'subtree');
        [~,addedSubtree1] = sceneR.set('asset', 'root', 'graft', thisOBJsubtree);
        
        % copy meshes from objects folder to scene folder here?
        [sourceDir, ~, ~]=fileparts(thisR.outputFile);
        [dstDir, ~, ~]=fileparts(sceneR.outputFile);
        sourceAssets = fullfile(sourceDir, 'scene/PBRT/pbrt-geometry');
        dstAssets    = fullfile(dstDir,    'scene/PBRT/pbrt-geometry');
        copyfile(sourceAssets, dstAssets);
        
        % copy the ply files potentially in local folder
        plyFiles = dir(fullfile(sourceDir, '*.ply'));
        for jj = 1:numel(plyFiles)
            copyfile(fullfile(plyFiles(jj).folder, plyFiles(jj).name),dstDir);
        end
    end
    
    if materialFlag
        if ~isempty(sceneR.materials)
            sceneR.materials.list = [sceneR.materials.list; thisR.materials.list];
        else
            sceneR.materials = thisR.materials;
        end
    end
    
    if textureFlag
        if ~isempty(sceneR.textures)
            sceneR.textures.list = [sceneR.textures.list; thisR.textures.list];
        else
            sceneR.textures = thisR.textures;
        end
        [sourceDir, ~, ~]=fileparts(thisR.outputFile);
        [dstDir, ~, ~]=fileparts(sceneR.outputFile);
        sourceTextures = fullfile(sourceDir, 'textures');
        if exist(sourceTextures, 'dir')
            copyfile(sourceTextures, dstDir);
        end
    end
end
end

