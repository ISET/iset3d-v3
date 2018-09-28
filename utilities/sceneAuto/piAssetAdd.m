function [thisR] = piAssetAdd(renderRecipe,assets,varargin)
% objects = assets;
% scene = scene_1;
% Assemble a scene with objects.
% Objects added by piAssetsCreate.m.
%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));
p.addParameter('material',true);
p.addParameter('geometry',true);
p.parse(renderRecipe,varargin{:});
thisR     = p.Results.renderRecipe;
material  = p.Results.material;
geometry  = p.Results.geometry;
%% Combine them with Main Scene thisR and Geometry Struct
assetsnameList = fieldnames(assets);
for ll = 1: length(assetsnameList)
    if isequal(assetsnameList{ll},'car')
        assetname = 'car';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll},'pedestrian')
        assetname = 'pedestrian';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll},'bus')
        assetname = 'bus';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);    
    elseif isequal(assetsnameList{ll},'tree')
        assetname = 'tree';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll},'truck')
        assetname = 'truck';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll},'bicycle')
        assetname = 'bicycle';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll},'streetlight')
        assetname = 'streetlight';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'building')
        assetname = 'building';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'tree')
        assetname = 'tree';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'streetlight')
        assetname = 'streetlight';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'station')
        assetname = 'station';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'bikerack')
        assetname = 'bikerack';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'bench')
        assetname = 'bench';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'callbox')
        assetname = 'callbox';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);
    elseif isequal(assetsnameList{ll}, 'billboard')
        assetname = 'billboard';
        thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR);    
    end
end
end
function thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR)
for ii = 1:length(assets.(assetname))
    if material
        nObj  = fieldnames(assets.(assetname)(ii).material.list);
        % add objects.material to thisR.materials.list
        for nn = 1:length(nObj)
            thisR.materials.list.(nObj{nn}) = assets.(assetname)(ii).material.list.(nObj{nn});
        end
        index = 1;
        for jj = length(thisR.materials.txtLines):(length(thisR.materials.txtLines) +...
                length(assets.(assetname)(ii).material.txtLines)-1)
            thisR.materials.txtLines(jj+1,:) = assets.(assetname)(ii).material.txtLines(index);
            index = index+1;
        end
    end
    %% add objects.geometry to scene(geometry struct)
    scene = thisR.assets;
    if geometry
        numScene = length(scene);
        numObj   = length(assets.(assetname)(ii).geometry);
        for hh = 1:numObj
            scene(numScene+hh) = assets.(assetname)(ii).geometry(hh);
        end
    end
    thisR.assets = scene;
    
end
end

