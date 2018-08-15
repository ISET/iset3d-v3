function asset = piAssetAssign(assetRecipe,varargin)
%% Assign properties to a asset stuct.
% 
%
%%
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('label','');
p.parse(varargin{:});
label = p.Results.label;
%%
for ii = 1: length(assetRecipe)
    thisR_tmp = jsonread(assetRecipe{ii}.name);
    fds = fieldnames(thisR_tmp);
    thisR = recipe;
    % assign the struct to a recipe class
    for dd = 1:length(fds)
        thisR.(fds{dd})= thisR_tmp.(fds{dd});
    end
    %% assign random color for carpaint
    mlist = fieldnames(thisR.materials.list);
    for kk = 1:length(mlist)
        if  contains(mlist{kk},'paint_base') && ~contains(mlist{kk},'paint_mirror')
            name = mlist{kk};
            material = thisR.materials.list.(name);    % A string labeling the material
            target = thisR.materials.lib.carpaintmix.paint_base;  %
            colorkd = piColorPick('random');
            piMaterialAssign(thisR,material.name,target,'colorkd',colorkd);
        end
    end
    %%    
    asset(ii).class = label;
    geometry = thisR.assets;
    for jj = 1:length(geometry)
        if ~isequal(lower(geometry(jj).name),'camera') && ...
                ~contains(lower(geometry(jj).name),'light')
            name = geometry(jj).name;
            break;
        end
    end
    [f,n,e] = fileparts(assetRecipe{ii}.name);
    asset(ii).name = name;
    asset(ii).index = n;
    asset(ii).geometry = geometry;
    if ~isequal(assetRecipe{ii}.count,1)
        for hh = 1: length(asset(ii).geometry)
            pos = asset(ii).geometry(hh).position;
            rot = asset(ii).geometry(hh).rotate;
            asset(ii).geometry(hh).position = repmat(pos,1,uint8(assetRecipe{ii}.count));
            asset(ii).geometry(hh).rotate = repmat(rot,1,uint8(assetRecipe{ii}.count));
        end
    end
    asset(ii).material.list = thisR.materials.list;
    asset(ii).material.txtLines = thisR.materials.txtLines;
    
    localFolder = fileparts(assetRecipe{ii}.name);
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d %s created \n',ii,label);
end
end