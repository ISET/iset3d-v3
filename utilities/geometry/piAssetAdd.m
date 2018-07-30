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
    %% place objects in a scene
    if placeobject
    % Find car obj
    % Check the size
    overlap = false;
    
    % rotate
    degree = randi([-180,180]);
    piObjectRotate(objects(ii).geometry,degree)
    
    % check intersection of bndbox
    % will change to global variables
    heading = randi([-50,50]);
    side = randi ([-10,10]);
    % translate
    piObjectTranslate(objects(ii).geometry,heading,side)
    if ii>1
        % check current obj and previous objs overlap area,
        curr_box = [objects(ii).geometry(2).size.pmin objects(ii).geometry(2).size.l objects(ii).geometry(2).size.w];
        for jj = 1:ii-1
            prev_box = [objects(jj).geometry(2).size.pmin objects(jj).geometry(2).size.l objects(jj).geometry(2).size.w];
            overlap = rectint(curr_box,prev_box);
            overlap(jj) = overlap(overlap>0);
        end
        if size(overlap)>1, overlap = true;
        end
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


