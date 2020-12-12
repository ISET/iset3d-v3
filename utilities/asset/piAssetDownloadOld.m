function assetRecipe = piAssetDownloadOld(session,nassets,varargin)
% Download assets from a flywheel database
%
% Syntax
%   assetRecipe = piAssetDownload(session,nassets,varargin)
%
% Brief description
%   Given a session download recipes for some number of assets.  The
%   session might be, say, 'cars', and the recipes for each asset are
%   stored in the acquisitions of the 'cars' session.
%
% Inputs
%   session:  A flywheel.model.Session
%   nassets:  An integer of how many assets from the session.
%
% Optional key/value parameters
%    resources:    Logical, download the resource file, too.
%    acquisitionlabel:   The label of a specific acquisition you want
%
% Outputs
%   assetRecipe:  Cell array of describing the assets
%
% Description
%   When an acquisitionlabel is given, the nassets describes how many
%   times that asset is used in the scene.
%
% See also
%  

% Examples:
%{
% ETTBSkip
fname = piAssetDownload(session,sessionname,ncars);
%}

%% Parse the inputs
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('session',@(x)(isa(x,'flywheel.model.Session')));
p.addRequired('nassets',@isnumeric);
p.addParameter('acquisitionlabel','',@ischar);
p.addParameter('resources',true);

p.parse(session, nassets, varargin{:});
acquisitionlabel = p.Results.acquisitionlabel;
resourcesFlag   = p.Results.resources;

%%  Download the recipes

if isempty(acquisitionlabel)
    acqs = session.acquisitions();

    % No specific recipe, randomly choose them
    nDatabaseAssets = length(acqs);
    assetList = randi(nDatabaseAssets,nassets,1);
    
    % Assets we want to download
    downloadList = piObjectInstanceCount(assetList);
    
    nDownloads = length(downloadList);
    assetRecipe = cell(nDownloads,1);
    
    for ii = 1:nDownloads
        thisIdx = downloadList(ii).index;
        acqLabel = acqs{thisIdx}.label;
        localFolder = fullfile(piRootPath,'local','AssetLists', acqLabel);
        destName_recipe = fullfile(localFolder,sprintf('%s.json',acqLabel));
        thisRecipe = stFileSelect(acqs{thisIdx}.files,'type','source code');
        destName_resource = fullfile(localFolder,sprintf('%s.zip',acqLabel));
        thisResource = stFileSelect(acqs{thisIdx}.files,'type','CG Resource');
        
        % if file exists, skip
        if ~exist(localFolder,'dir') && ~exist(destName_recipe,'file')
            mkdir(localFolder)
            thisRecipe{1}.download(destName_recipe);
            % fprintf('%s is downloaded \n',thisRecipe{1}.name);
            if resourcesFlag
                thisResource{1}.download(destName_resource);
                fprintf('%s is downloaded \n',thisResource{1}.name);
                unzip(destName_resource);
                delete(destName_resource);
            end
        else
            % fprintf('%s found \n',acqLabel);
        end
        assetRecipe{ii}.name   = destName_recipe;
        assetRecipe{ii}.count  = downloadList(ii).count;
        assetRecipe{ii}.fwInfo = [acqs{thisIdx}.id,' ',thisResource{1}.name];
    end
    
    fprintf('%d Files downloaded.\n',nDownloads);
else
    % Download recipe from an acq with a specific label
    thisAcq = session.acquisitions.findOne(sprintf('label=%s',acquisitionlabel));
    localFolder = fullfile(piRootPath,'local',acquisitionlabel);
    
    destName_recipe = fullfile(localFolder,sprintf('%s.json',acquisitionlabel));
    thisRecipe = stFileSelect(thisAcq.files,'type','source code');
    destName_resource = fullfile(localFolder,sprintf('%s.zip',acquisitionlabel));
    thisResource = stFileSelect(thisAcq.files,'type','CG Resource');
    if ~exist(localFolder,'dir') && ~exist(destName_recipe,'file')
        mkdir(localFolder)
        thisRecipe{1}.download(destName_recipe);
        % fprintf('%s is downloaded \n',thisRecipe{1}.name);
        if resourcesFlag
            % We always unzip the resource and remove the zip file
            thisResource{1}.download(destName_resource);
            % fprintf('%s is downloaded \n',thisResource{1}.name);
            unzip(destName_resource,localFolder);
            delete(destName_resource);
        end
    else
        % fprintf('%s found \n',acquisitionlabel);
    end
    
    assetRecipe{1}.name  = destName_recipe;
    assetRecipe{1}.fwInfo = [thisAcq.id,' ',thisResource{1}.name];
    assetRecipe{1}.count  = nassets;

    fprintf('%s downloaded.\n',acquisitionlabel);
end

end







