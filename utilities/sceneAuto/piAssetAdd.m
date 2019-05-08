function [thisR] = piAssetAdd(renderRecipe, assets, varargin)
% Assemble a scene with objects.
%
% Syntax:
%   thisR = piAssetAdd(renderRecipe, assets, [varargin])
%
% Description:
%    Add asset objects to a scene (render recipe). Objects are added to the
%    recipe by piAssetsCreate.
%
% Inputs:
%    renderRecipe - Object. A render recipe.
%    assets       - List. A list of the assets to add to the scene.
%
% Outputs:
%    thisR        - Object. The created render recipe.
%
% Optional key/value pairs:
%    material     - Boolean. A boolean indicating whether or not to add a
%                   objects.material to the render recipe.
%    geometry     - Boolean. A boolean indicating whether or not to add
%                   objects.geometry to the render recipe.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/09/19  JNM  Documentation pass
%    04/18/19  JNM  Merge Master in (resolve conflicts)

%%
% objects = assets;
% scene = scene_1;
p = inputParser;
p.addRequired('renderRecipe', @(x)isequal(class(x), 'recipe'));
p.addParameter('material', true);
p.addParameter('geometry', true);
p.parse(renderRecipe, varargin{:});
thisR = p.Results.renderRecipe;
material = p.Results.material;
geometry = p.Results.geometry;

%% Combine them with Main Scene thisR and Geometry Struct
assetsnameList = fieldnames(assets);
for ll = 1: length(assetsnameList)
    if isequal(assetsnameList{ll}, 'car')
        assetname = 'car';
        if ~isfield(thisR.assets, 'motion')
            [thisR.assets(:).motion] = deal([]);
        end
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'pedestrian')
        assetname = 'pedestrian';
        if ~isfield(thisR.assets, 'motion')
            [thisR.assets(:).motion] = deal([]);
        end
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'bus')
        assetname = 'bus';
        if ~isfield(thisR.assets, 'motion')
            [thisR.assets(:).motion] = deal([]);
        end
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'truck')
        assetname = 'truck';
        if ~isfield(thisR.assets, 'motion')
            [thisR.assets(:).motion] = deal([]);
        end
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'bicycle')
        assetname = 'bicycle';
        if ~isfield(thisR.assets, 'motion')
            [thisR.assets(:).motion] = deal([]);
        end
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'streetlight')
        assetname = 'streetlight';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'building')
        assetname = 'building';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'tree')
        assetname = 'tree';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'streetlight')
        assetname = 'streetlight';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'station')
        assetname = 'station';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'bikerack')
        assetname = 'bikerack';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'bench')
        assetname = 'bench';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'callbox')
        assetname = 'callbox';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    elseif isequal(assetsnameList{ll}, 'billboard')
        assetname = 'billboard';
        thisR = AddMaterialandGeometry(...
            assets, assetname, material, geometry, thisR);
    end
end
end

function thisR = AddMaterialandGeometry(...
    assets, assetname, material, geometry, thisR)
% Determine whether or not to add object's material and geometry to recipe.
%
% Syntax:
%   thisR = AddMaterialandGeometry(...
%       assets, assetname, material, geometry, thisR)
%
% Description:
%    This built-in function is designed to take in the provided recipe,
%    object, and additional identifying information about the object, and
%    modify that object's representation within the recipe as desired.
%
% Inputs:
%    assets    - Struct. The structure containing all of the assets.
%    assetname - String. The string containing the assets' name (type).
%    material  - Boolean. The boolean indicating whether or not to add
%                object.material to the recipe for the listed assets.
%    geometry  - Boolean. The boolean indicating whether or not to add
%                object.geometry to the recipe for the listed assets.
%    thisR     - Object. A recipe object to add all of the assets to.
%
% Outputs:
%    thisR     - Object. The modified recipe object.
%
% Optional key/value pairs:
%    None.
%

for ii = 1:length(assets.(assetname))
    if material
        nObj = fieldnames(assets.(assetname)(ii).material.list);
        % add objects.material to thisR.materials.list
        for nn = 1:length(nObj)
            thisR.materials.list.(nObj{nn}) = ...
                assets.(assetname)(ii).material.list.(nObj{nn});
        end
        index = 1;
        for jj = length(thisR.materials.txtLines):(...
                length(thisR.materials.txtLines) + ...
                length(assets.(assetname)(ii).material.txtLines) - 1)
            thisR.materials.txtLines(jj + 1, :) = ...
                assets.(assetname)(ii).material.txtLines(index);
            index = index + 1;
        end
    end

    %% add objects.geometry to scene(geometry struct)
    scene = thisR.assets;
    if isfield(scene, 'scale'), scene = rmfield(scene, 'scale'); end
    % add motion slot
    if geometry
        numScene = length(scene);
        numObj = length(assets.(assetname)(ii).geometry);
        for hh = 1:numObj
            if isfield(assets.(assetname)(ii).geometry, 'scale')
                assets.(assetname)(ii).geometry = ...
                    rmfield(assets.(assetname)(ii).geometry, 'scale');
            end
            scene(numScene + hh) = assets.(assetname)(ii).geometry(hh);
        end
    end
    if exist(assets.(assetname)(1).geometryPath, 'dir')
        assetPath = fullfile(piRootPath, 'local', ...
            assets.(assetname).index);
        scenePath = fileparts(thisR.outputFile);
        copyfile(assetPath, scenePath);
    end
    thisR.assets = scene;
end

end
