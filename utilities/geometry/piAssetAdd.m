function [thisR] = piAssetAdd(thisR,assets,varargin)
% objects = assets;
% scene = scene_1;
% Assemble a scene with objects.
% Objects added by piAssetsCreate.m.
%%
p = inputParser;
p.addParameter('material',true);
p.addParameter('geometry',true);
p.parse(varargin{:});
material  = p.Results.material;
geometry  = p.Results.geometry;
%% Combine them with Main Scene thisR and Geometry Struct
if isfield(assets,'car')
for ii = 1:length(assets.car)
    if material
        nObj  = fieldnames(assets.car(ii).material.list);
        % add objects.material to thisR.materials.list
        for nn = 1:length(nObj)
            thisR.materials.list.(nObj{nn}) = assets.car(ii).material.list.(nObj{nn});
        end
        index = 1;
        for jj = length(thisR.materials.txtLines):(length(thisR.materials.txtLines)+...
                length(assets.car(ii).material.txtLines)-1)
            thisR.materials.txtLines{jj+1,:} = assets.car(ii).material.txtLines{index};
            index = index+1;
        end
    end
    %% add objects.geometry to scene(geometry struct)
    scene = thisR.assets;
    if geometry
        numScene = length(scene);
        numObj   = length(assets.car(ii).geometry);
        for hh = 1:numObj
            scene(numScene+hh) = assets.car(ii).geometry(hh);
        end
        % copy geometrypath
        [f,~,~]=fileparts(thisR.inputFile);
        copyfile(assets.car(ii).geometryPath,fullfile(f,'scene','PBRT','pbrt-geometry'));
        % Copy textures
        texture = fullfile(fileparts(fileparts(fileparts(assets.car(ii).geometryPath))),...
            'texture');
        copyfile(texture,fullfile(f,'texture'));
    end
    thisR.assets = scene;
    
end
end

if isfield(assets,'pedestrian')
for ii = 1:length(assets.pedestrian)
    if material
        nObj  = fieldnames(assets.pedestrian(ii).material.list);
        % add objects.material to thisR.materials.list
        for nn = 1:length(nObj)
            thisR.materials.list.(nObj{nn}) = assets.pedestrian(ii).material.list.(nObj{nn});
        end
        index = 1;
        for jj = length(thisR.materials.txtLines):(length(thisR.materials.txtLines) +...
                length(assets.pedestrian(ii).material.txtLines)-1)
            thisR.materials.txtLines(jj+1,:) = assets.pedestrian(ii).material.txtLines(index);
            index = index+1;
        end
    end
    %% add objects.geometry to scene(geometry struct)
    scene = thisR.assets;
    if geometry
        numScene = length(scene);
        numObj   = length(assets.pedestrian(ii).geometry);
        for hh = 1:numObj
            scene(numScene+hh) = assets.pedestrian(ii).geometry(hh);
        end
        % copy geometrypath
        [f,~,~]=fileparts(thisR.inputFile);
        copyfile(assets.pedestrian(ii).geometryPath,fullfile(f,'scene','PBRT','pbrt-geometry'));
        % Copy textures
        texture = fullfile(fileparts(fileparts(fileparts(assets.pedestrian(ii).geometryPath))),...
            'texture');
        copyfile(texture,fullfile(f,'texture'));
    end
    thisR.assets = scene;

end
end

%% Add Building
if isfield(assets,'building')
    assetname = 'building';
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
        % copy geometrypath
        [f,~,~]=fileparts(thisR.inputFile);
        copyfile(assets.(assetname)(ii).geometryPath,fullfile(f,'scene','PBRT','pbrt-geometry'));
        % Copy textures
        texture = fullfile(fileparts(fileparts(fileparts(assets.(assetname)(ii).geometryPath))),...
            'texture');
        copyfile(texture,fullfile(f,'texture'));
    end
    thisR.assets = scene;

end
end

end


