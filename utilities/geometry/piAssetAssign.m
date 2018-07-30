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
    thisR_tmp = jsonread(assetRecipe{ii});
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
        if ~isequal(lower(geometry(jj).name),'camera')
            index = strfind(geometry(jj).name,'_');
            if isempty(index)
                name = geometry(jj).name;
            else
            name = geometry(jj).name(1:index(1)-1);
            end
            break;
        end
    end
    asset(ii).name = name;
    asset(ii).geometry = geometry;
    asset(ii).material = thisR.materials.list;
    
    localFolder = fileparts(assetRecipe{ii});
    asset(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d %s created \n',ii,label);
end
end