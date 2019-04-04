function assetRecipe = piAssetDownload(session,nassets,varargin)
% Download assets from a flywheel session
%
%  fname = piAssetDownload(session,nassets,varargin)
%
% Description
%
% Inputs
% Optional key/value parameters
% Outputs
%

% Examples:
%{
% ETTBSkip
fname = piAssetDownload(session,sessionname,ncars);
%}

%% Parse the inputs

p = inputParser;
% varargin = ieParamFormat(varargin);
p.addRequired('session',@(x)(isa(x,'flywheel.model.Session')));
p.addRequired('nassets',@isnumeric);
p.addParameter('acquisition','',@ischar);
p.addParameter('resources',true);
p.addParameter('scitran',[],@(x)(isa(x,'scitran')));

p.parse(session, nassets, varargin{:});
acquisitionname = p.Results.acquisition;
resourcesFlag = p.Results.resources;
st = p.Results.scitran;

if isempty(st)
    st = scitran('stanfordlabs');
end
%%
containerID = idGet(session,'data type','session');
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = st.dataFileList('session', containerID, fileType);
fileType_json ='source code'; % json
[recipeFiles, recipe_acqID] = st.dataFileList('session', containerID, fileType_json);
%%
if isempty(acquisitionname)
    %%
    nDatabaseAssets = length(resourceFiles);
    assetList = randi(nDatabaseAssets,nassets,1);
    % count objectInstance
    downloadList = piObjectInstanceCount(assetList);
    
    nDownloads = length(downloadList);
    assetRecipe = cell(nDownloads,1);
    
    
    for ii = 1:nDownloads
        [~,n,~] = fileparts(resourceFiles{downloadList(ii).index}{1}.name);
        [~,n,~] = fileparts(n); % extract file name
        % Download the scene to a destination zip file
        
        localFolder = fullfile(piRootPath,'local',n);
        destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
        % we might not need to download zip files every time, use
        % resourceCombine.m 08/14 --zhenyi
        destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
        % if file exists, skip
        if ~exist(localFolder,'dir') && ~exist(destName_recipe,'file')
            mkdir(localFolder)
            piFwFileDownload(destName_recipe, ...
                recipeFiles{downloadList(ii).index}{1}.name, ...
                recipe_acqID{downloadList(ii).index});
            if resourcesFlag
                piFwFileDownload(destName_resource, ...
                    resourceFiles{downloadList(ii).index}{1}.name, ...
                    resource_acqID{downloadList(ii).index});
            end
            
        else
            fprintf('%s found \n',n);
        end
        assetRecipe{ii}.name   = destName_recipe;
        assetRecipe{ii}.count  = downloadList(ii).count;
        assetRecipe{ii}.fwInfo = [resource_acqID{downloadList(ii).index},' ',resourceFiles{downloadList(ii).index}{1}.name];
        %     if ~exist(assetRecipe{ii}.name,'file'), error('File not found');end
        
    end
    
    fprintf('%d Files downloaded.\n',nDownloads);
else
    
    % download acquisition by given name;
    for ii=1:length(recipeFiles)
        if piContains(lower(recipeFiles{ii}{1}.name),acquisitionname)
            thisRecipe = recipeFiles{ii}{1};
            thisResource = resourceFiles{ii}{1};
            thisRecipeID =  recipe_acqID{ii};
            thisResourceID = resource_acqID{ii};
            break;
        end
    end
    [~,n,~] = fileparts(thisRecipe.name);
    [~,n,~] = fileparts(n); % extract file name
    % Download the scene to a destination zip file
    localFolder = fullfile(piRootPath,'local',n);
    
    destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
    destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
    if ~exist(localFolder,'dir')
        mkdir(localFolder)
    end
    piFwFileDownload(destName_recipe, thisRecipe.name, thisRecipeID);
    if resourcesFlag
        piFwFileDownload(destName_resource, thisResource.name, thisResourceID);
    end
    assetRecipe.name = destName_recipe;
    assetRecipe.fwInfo = [thisResourceID,' ',thisResource.name];
    fprintf('%s downloaded.\n',n);
end
end







