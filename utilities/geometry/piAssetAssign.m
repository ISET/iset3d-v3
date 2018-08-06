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
    % assign random color for carpaint of cloth, 
    piMaterialGroupAssign(thisR);
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
            asset(ii).geometry(hh).position = repmat(pos,1,uint8(assetRecipe{ii}.count));
        end
    end
    asset(ii).material = thisR.materials.list;
    
    localFolder = fileparts(assetRecipe{ii}.name);
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d %s created \n',ii,label);
end
end