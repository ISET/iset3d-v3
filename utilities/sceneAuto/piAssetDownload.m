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

p.parse(session, nassets, varargin{:});
acquisitionname = p.Results.acquisition;
resourcesFlag = p.Results.resources;
%%
acqs = session.acquisitions();
if isempty(acquisitionname)
    %%
    nDatabaseAssets = length(acqs);
    assetList = randi(nDatabaseAssets,nassets,1);
    % count objectInstance
    downloadList = piObjectInstanceCount(assetList);
    
    nDownloads = length(downloadList);
    assetRecipe = cell(nDownloads,1);
    
    
    for ii = 1:nDownloads
        thisIdx = downloadList(ii).index;
        acqName = acqs{thisIdx}.label;
        localFolder = fullfile(piRootPath,'local',acqName);
        destName_recipe = fullfile(localFolder,sprintf('%s.json',acqName));
        thisRecipe = stFileSelect(acqs{thisIdx}.files,'type','source code');
        destName_resource = fullfile(localFolder,sprintf('%s.zip',acqName));
        thisResource = stFileSelect(acqs{thisIdx}.files,'type','CG Resource');
        % if file exists, skip
        if ~exist(localFolder,'dir') && ~exist(destName_recipe,'file')
            mkdir(localFolder)
            thisRecipe{1}.download(destName_recipe);
            fprintf('%s is downloaded \n',thisRecipe{1}.name);
            if resourcesFlag
                thisResource{1}.download(destName_resource);
                fprintf('%s is downloaded \n',thisResource{1}.name);
            end
        else
            fprintf('%s found \n',acqName);
        end
        assetRecipe{ii}.name   = destName_recipe;
        assetRecipe{ii}.count  = downloadList(ii).count;
        assetRecipe{ii}.fwInfo = [thisResource{1}.id,' ',thisResource{1}.name];
        
    end
    
    fprintf('%d Files downloaded.\n',nDownloads);
else
    
    % download acquisition by given name;]
    thisAcq = session.acquisitions.findOne(sprintf('label=%s',acquisitionname));
    acqName = thisAcq.name;
    localFolder = fullfile(piRootPath,'local',acqName);
    
    destName_recipe = fullfile(localFolder,sprintf('%s.json',acqName));
    thisRecipe = stFileSelect(thisAcq.files,'type','source code');
    destName_resource = fullfile(localFolder,sprintf('%s.zip',acqName));
    thisResource = stFileSelect(thisAcq.files,'type','CG Resource');
    if ~exist(localFolder,'dir') && ~exist(destName_recipe,'file')
        mkdir(localFolder)
        thisRecipe{1}.download(destName_recipe);
        fprintf('%s is downloaded \n',thisRecipe{1}.name);
        if resourcesFlag
            thisResource{1}.download(destName_resource);
            fprintf('%s is downloaded \n',thisResource{1}.name);
        end
    else
        fprintf('%s found \n',acqName);
    end
    assetRecipe.name = destName_recipe;
    assetRecipe.fwInfo = [thisResource{1}.id,' ',thisResource{1}.name];
    fprintf('%s downloaded.\n',acqName);
end
end







