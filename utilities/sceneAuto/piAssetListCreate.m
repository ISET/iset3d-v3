function assetlist = piAssetListCreate(varargin)
%% Create an assetList for street elements on flywheel 
% Input: 
%        class: session name on flywheel;
%        subclass: acquisition names on flywheel;
% Output: 
%       assetList: Assigned assets libList used for street elements;
%
%
%%

p = inputParser;
p.addParameter('class','');
p.addParameter('subclass','');
p.addParameter('scitran',[]);
p.parse(varargin{:});

st = p.Results.scitran;

if isempty(st)
    st = scitran('stanfordlabs');
end

sessionname = p.Results.class;
acquisitionname  = p.Results.subclass;

%%
hierarchy = st.projectHierarchy('Graphics assets');
sessions     = hierarchy.sessions;

%%
for ii=1:length(sessions)
    if isequal(lower(sessions{ii}.label),sessionname)
        thisSession = sessions{ii};
        break;
    end
end
containerID = idGet(thisSession,'data type','session');
fileType_json ='source code'; % json
[recipeFiles, recipe_acqID] = st.dataFileList('session', containerID, fileType_json);
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = st.dataFileList('session', containerID, fileType);
%%
nDatabaseAssets = length(recipeFiles);
% assetList = randi(nDatabaseAssets,nassets,1);
% % count objectInstance
% downloadList = piObjectInstanceCount(assetList);
% assetRecipe = cell(nDownloads,1);

%%

if isempty(acquisitionname)
    for ii = 1:nDatabaseAssets
        [~,n,~] = fileparts(recipeFiles{ii}{1}.name);
        [~,n,~] = fileparts(n); % extract file name
        % Download the scene to a destination zip file
        localFolder = fullfile(piRootPath,'local','AssetLists',n);

        destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
        if ~exist(localFolder,'dir')
            mkdir(localFolder)
        end
        st.fileDownload(recipeFiles{ii}{1}.name,...
            'container type', 'acquisition' , ...
            'container id',  recipe_acqID{ii} ,...
            'destination',destName_recipe);
        %%
        thisR = jsonread(destName_recipe);
%         assetRecipe{ii}.name   = destName_recipe;
%         assetRecipe{ii}.count  = downloadList(ii).count;
        assetlist(ii).name = n;
        assetlist(ii).material.list = thisR.materials.list;
        assetlist(ii).material.txtLines = thisR.materials.txtLines;
        assetlist(ii).geometry = thisR.assets;
        assetlist(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
        assetlist(ii).fwInfo       = [resource_acqID{ii},' ',resourceFiles{ii}{1}.name];
    end
    
    fprintf('%d files added to the list.\n',nDatabaseAssets);
else
    kk=1;
    for ii=1:length(recipeFiles)
        if contains(lower(recipeFiles{ii}{1}.name),acquisitionname)
            thisAcq{kk} = recipeFiles{ii}{1};
            thisID{kk} =  recipe_acqID{ii};
            resFile{kk} = resourceFiles{ii}{1};
            resID{kk} = resource_acqID{ii};
            kk = kk+1;
        end
    end
    for dd = 1:length(thisAcq)
    [~,n,~] = fileparts(thisAcq{dd}.name);
    [~,n,~] = fileparts(n); % extract file name
    % Download the scene to a destination zip file
    localFolder = fullfile(piRootPath,'local','AssetLists',n);

    destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
    if ~exist(localFolder,'dir')
        mkdir(localFolder)
    end
    st.fileDownload(thisAcq{dd}.name,...
        'container type', 'acquisition' , ...
        'container id',  thisID{dd} ,...
        'destination',destName_recipe);
        thisR = jsonread(destName_recipe);
%         assetRecipe{dd}.name   = destName_recipe;
%         assetRecipe{dd}.count  = downloadList(dd).count;
        assetlist(dd).name = n;
        assetlist(dd).material.list     = thisR.materials.list;
        assetlist(dd).material.txtLines = thisR.materials.txtLines;
        assetlist(dd).geometry          = thisR.assets;
        assetlist(dd).geometryPath      = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
        assetlist(dd).fwInfo            = [resID{dd},' ',resFile{dd}.name];
    end
    fprintf('%s added to the list.\n',n);
end
end