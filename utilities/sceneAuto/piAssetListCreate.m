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
project = st.lookup('wandell/Graphics assets');
session     = project.sessions.findOne(sprintf('label=%s',sessionname));
acqs = session.acquisitions();
%%
nDatabaseAssets = length(acqs);
if isempty(acquisitionname)
    for ii = 1:nDatabaseAssets
        acqLabel = acqs{thisIdx}.label;
        localFolder = fullfile(piRootPath,'local','AssetLists',acqLabel);
        destName_recipe = fullfile(localFolder,sprintf('%s.json',acqLabel));
        if ~exist(localFolder,'dir')
            mkdir(localFolder)
        end
        thisRecipe = stFileSelect(acqs{thisIdx}.files,'type','source code');
        thisResource = stFileSelect(acqs{thisIdx}.files,'type','CG Resource');
        thisRecipe{1}.download(destName_recipe);
        %%
        thisR = jsonread(destName_recipe);
        assetlist(ii).name = acqLabel;
        assetlist(ii).material.list = thisR.materials.list;
        assetlist(ii).material.txtLines = thisR.materials.txtLines;
        assetlist(ii).geometry = thisR.assets;
        assetlist(ii).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
        assetlist(ii).fwInfo       = [acqs{thisIdx}.id,' ',thisResource{1}.name];
    end
    
    fprintf('%d files added to the list.\n',nDatabaseAssets);
else
    thisAcq = stSelect(acqs,'label',acquisitionname);
    for dd = 1:length(thisAcq)
        acqLabel = thisAcq{dd}.label;
        localFolder = fullfile(piRootPath,'local','AssetLists',acqLabel);
        
        destName_recipe = fullfile(localFolder,sprintf('%s.json',acqLabel));
        if ~exist(localFolder,'dir')
            mkdir(localFolder)
        end
        thisRecipe = stFileSelect(thisAcq{dd}.files,'type','source code');
        thisResource = stFileSelect(thisAcq{dd}.files,'type','CG Resource');
        thisRecipe{1}.download(destName_recipe);
        thisR = jsonread(destName_recipe);
        assetlist(dd).name = acqLabel;
        assetlist(dd).material.list     = thisR.materials.list;
        assetlist(dd).material.txtLines = thisR.materials.txtLines;
        assetlist(dd).geometry          = thisR.assets;
        assetlist(dd).geometryPath      = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
        assetlist(dd).fwInfo            = [thisAcq{dd}.id,' ',thisResource{1}.name];
    end
    fprintf('%s added to the list.\n',acqLabel);
end
end