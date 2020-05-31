function [thisR] = piAssetAddBatch(renderRecipe,assets,varargin)
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
trafficAssets = {'car', 'pedestrian', 'bus', 'truck', 'bicycle'};
for ll = 1: length(assetsnameList)
    if find(piContains(trafficAssets,assetsnameList{ll}))
        if ~isfield(thisR.assets,'motion')
            [thisR.assets.motion] = deal([]);
        end        
        thisR = AddMaterialandGeometry(assets,assetsnameList{ll},material,geometry,thisR);
    else
        thisR = AddMaterialandGeometry(assets,assetsnameList{ll},material,geometry,thisR);
    end
end
end

function thisR = AddMaterialandGeometry(assets,assetname,material,geometry,thisR)

for ii = 1:length(assets.(assetname))
    if material
        try
        nObj  = fieldnames(assets.(assetname)(ii).material.list);
        catch
            fprintf('No %s list if found', assetname);
            continue;
        end
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
    if isfield(scene,'scale'),scene=rmfield(scene,'scale');end
    % add motion slot
    if geometry
        numScene = length(scene);
        numObj   = length(assets.(assetname)(ii).geometry);
        for hh = 1:numObj
            %% 
            if isfield(assets.(assetname)(ii).geometry,'scale')
                assets.(assetname)(ii).geometry=rmfield(assets.(assetname)(ii).geometry,'scale');
            end
            scene(numScene+hh) = assets.(assetname)(ii).geometry(hh);
            %% 
        end
    end
    if exist(assets.(assetname)(1).geometryPath,'dir')
        assetPath = fullfile(piRootPath,'local',assets.(assetname).index);
        scenePath = fileparts(thisR.outputFile);
        copyfile(assetPath, scenePath);
    end
    thisR.assets = scene;
end

end

