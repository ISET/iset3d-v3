function thisR = piAssetAdd(thisR, thisR_asset)
%% Add a recipe(asset) to another recipe
% Input:
%      thisR: target recipe;
%      thisR_asset: to be added;
% Output:
%      thisR: Combined recipe.
%
% Zhenyi, SCIEN, 2019
% see also: piAssetAddBatch

%%
% add objects.materials to thisR.materials.list
try
    nObj  = fieldnames(thisR_asset.materials.list);
    for nn = 1:length(nObj)
        thisR.materials.list.(nObj{nn}) = thisR_asset.materials.list.(nObj{nn});
    end
    index = 1;
    for jj = length(thisR.materials.txtLines):(length(thisR.materials.txtLines) +...
            length(thisR_asset.materials.txtLines)-1)
        thisR.materials.txtLines(jj+1,:) = thisR_asset.materials.txtLines(index);
        index = index+1;
    end
    thisR.materials.txtLines = unique(thisR.materials.txtLines);
catch
    disp('No material is found.');
end


%% add objects.geometry to scene(geometry struct)
scene = thisR.assets;
if isfield(scene,'scale'),scene=rmfield(scene,'scale');end
numScene = length(scene);
numObj   = length(thisR_asset.assets);
if isempty(scene)
    scene = thisR_asset.assets;
else
    for hh = 1:numObj
        %%
        if isfield(thisR_asset.assets,'scale')
            thisR_asset.assets=rmfield(thisR_asset.assets,'scale');
        end        
        scene(numScene+hh) = thisR_asset.assets(hh);         
        %%
    end
end

textures = fullfile(fileparts(thisR_asset.inputFile), 'textures');
assetPath = fileparts(thisR_asset.outputFile);
scenePath = fileparts(thisR.outputFile);
copyfile(assetPath, scenePath);
copyfile(textures, [scenePath,'/textures']);
thisR.assets = scene;
end
