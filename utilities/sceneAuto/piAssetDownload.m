function assetRecipe = piAssetDownload(session, nassets, varargin)
% Download assets from a flywheel session
%
% Syntax:
%   assetRecipe = piAssetDownload(session, nassets, [varargin])
%
% Description:
%    Download the assets from a flywheel.io session.
%
% Inputs:
%    session     - Session. A flywheel model session object.
%    nassets     - Numeric. The number of assets.
%
% Outputs:
%    assetRecipe - Object. A recipe object containing all of the
%                  aforementioned assets from flywheel.io.
%
% Optional key/value pairs:
%    acquisition - String. A string representing the acquision
%                  (hierarchy.acquisition). Default ''.
%    resources   - Boolean. Whether or not to download external resources.
%                  Default true.
%    scitran     - Object. A scitran instance object. Default []. If
%                  default, instantiates an instance of stanfordlabs.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/10/19  JNM  Documentation pass, create 2nd example.

% Examples:
%{
    % ETTBSkip
    fname = piAssetDownload(session, sessionname, ncars);
%}
%{
    % This example downloads a single car.
    st = scitran('stanfordlabs');
    hierarchy = st.projectHierarchy('Graphics assets');
    projects = hierarchy.project;
    sessions = hierarchy.sessions;
    acquisitions = hierarchy.acquisitions;
    for ii = 1:length(sessions)
        if isequal(lower(sessions{ii}.label),'car')
            carSession = sessions{ii};
            break;
        end
    end
    assetRecipe = piAssetDownload(...
        carSession, 1, 'resources', 1, 'scitran', st);
%}

%% Parse the inputs
p = inputParser;
% varargin = ieParamFormat(varargin);
p.addRequired('session', @(x)(isa(x, 'flywheel.model.Session')));
p.addRequired('nassets', @isnumeric);
p.addParameter('acquisition', '', @ischar);
p.addParameter('resources', true);
p.addParameter('scitran', [], @(x)(isa(x, 'scitran')));

p.parse(session, nassets, varargin{:});
acquisitionname = p.Results.acquisition;
resourcesFlag = p.Results.resources;
st = p.Results.scitran;

if isempty(st), st = scitran('stanfordlabs'); end

%%
containerID = idGet(session, 'data type', 'session');
fileType = 'CG Resource';
[resourceFiles, resource_acqID] = ...
    st.dataFileList('session', containerID, fileType);
fileType_json ='source code'; % json
[recipeFiles, recipe_acqID] = ...
    st.dataFileList('session', containerID, fileType_json);

%%
if isempty(acquisitionname)
    nDatabaseAssets = length(resourceFiles);
    assetList = randi(nDatabaseAssets, nassets, 1);
    % count objectInstance
    downloadList = piObjectInstanceCount(assetList);

    nDownloads = length(downloadList);
    assetRecipe = cell(nDownloads, 1);

    for ii = 1:nDownloads
        [~, n, ~] = ...
            fileparts(resourceFiles{downloadList(ii).index}{1}.name);
        [~, n, ~] = fileparts(n); % extract file name
        % Download the scene to a destination zip file

        localFolder = fullfile(piRootPath, 'local', n);
        destName_recipe = fullfile(localFolder, sprintf('%s.json', n));
        % we might not need to download zip files every time, use
        % resourceCombine.m 08/14 --zhenyi
        destName_resource = fullfile(localFolder, sprintf('%s.zip', n));
        % if file exists, skip
        if ~exist(localFolder, 'dir') && ~exist(destName_recipe, 'file')
            mkdir(localFolder)
            st.fileDownload(...
                recipeFiles{downloadList(ii).index}{1}.name, ...
                'container type', 'acquisition' , ...
                'container id', recipe_acqID{downloadList(ii).index} , ...
                'destination', destName_recipe);
            if resourcesFlag
                st.fileDownload(resourceFiles{...
                    downloadList(ii).index}{1}.name, ...
                    'container type', 'acquisition' , ...
                    'container id', ...
                    resource_acqID{downloadList(ii).index} , ...
                    'unzip', true, ...
                    'destination', destName_resource);
            end
        else
            fprintf('%s found \n', n);
        end
        assetRecipe{ii}.name = destName_recipe;
        assetRecipe{ii}.count = downloadList(ii).count;
        assetRecipe{ii}.fwInfo = [...
            resource_acqID{downloadList(ii).index}, ' ', ...
            resourceFiles{downloadList(ii).index}{1}.name];
        % if ~exist(assetRecipe{ii}.name, 'file')
        %    error('File not found');
        % end
    end

    fprintf('%d Files downloaded.\n', nDownloads);
else
    % download acquisition by given name;
    for ii = 1:length(recipeFiles)
        if piContains(lower(recipeFiles{ii}{1}.name), acquisitionname)
            thisRecipe = recipeFiles{ii}{1};
            thisResource = resourceFiles{ii}{1};
            thisRecipeID =  recipe_acqID{ii};
            thisResourceID = resource_acqID{ii};
            break;
        end
    end
    [~, n, ~] = fileparts(thisRecipe.name);
    [~, n, ~] = fileparts(n); % extract file name
    % Download the scene to a destination zip file
    localFolder = fullfile(piRootPath, 'local', n);

    destName_recipe = fullfile(localFolder, sprintf('%s.json', n));
    destName_resource = fullfile(localFolder, sprintf('%s.zip', n));
    if ~exist(localFolder, 'dir'), mkdir(localFolder); end
    st.fileDownload(thisRecipe.name, ...
        'container type', 'acquisition' , ...
        'container id', thisRecipeID , ...
        'destination', destName_recipe);
    if resourcesFlag
        st.fileDownload(thisResource.name, ...
            'container type', 'acquisition' , ...
            'container id', thisResourceID, 'unzip', true, ...
            'destination', destName_resource);
    end
    assetRecipe.name = destName_recipe;
    assetRecipe.fwInfo = [thisResourceID, ' ', thisResource.name];
    fprintf('%s downloaded.\n', n);
end
end
