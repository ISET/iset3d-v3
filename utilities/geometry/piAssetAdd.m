function [thisR] = piAssetAdd(thisR,objects,varargin)
% objects = assets;
% scene = scene_1;
% Assemble a scene with objects.
% Objects added by piAssetsCreate.m.
%%
p = inputParser;
p.addParameter('material',true);
p.addParameter('geometry',true);
p.addParameter('placeobject',false)
p.parse(varargin{:});
material  = p.Results.material;
geometry  = p.Results.geometry;
placeobject  = p.Results.placeobject;
%% Combine them with Main Scene thisR and Geometry Struct

for ii = 1:length(objects)
    if material
        nObj  = fieldnames(objects(ii).material);
        % add objects.material to thisR.materials.list
        for nn = 1:length(nObj)
            thisR.materials.list.(nObj{nn}) = objects(ii).material.(nObj{nn});
        end
    end
    %% add objects.geometry to scene(geometry struct)
    scene = thisR.assets;
    if geometry
        numScene = length(scene);
        numObj   = length(objects(ii).geometry);
        for hh = 1:numObj
            scene(numScene+hh) = objects(ii).geometry(hh);
        end
        % copy geometrypath
        [f,~,~]=fileparts(thisR.inputFile);
        copyfile(objects(ii).geometryPath,fullfile(f,'scene','PBRT','pbrt-geometry'));
    end
    thisR.assets = scene;
end
end


