function assetRecipe = piAssetDownload(session, nassets, varargin)
% Download assets from a flywheel database
%
% Syntax:
%   assetRecipe = piAssetDownload(session, nassets, [varargin])
%
% Description:
%   Given a flywheel.io session download recipes for some number of assets.
%   The session might be, say, 'cars', and the recipes for each asset are
%   stored in the acquisitions of the 'cars' session.
%
% Inputs:
%    session     - Session. A flywheel model session object.
%    nassets     - Numeric. The number of assets.
%
% Outputs:
%    assetRecipe - Cell. A cell array containing all of the aforementioned
%                  assets from flywheel.io.
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
%    04/18/19  JNM  Merge Master in (resolve conflicts), add in string-only
%                   varargin parsing.

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
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) ...
                | isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.addRequired('session', @(x)(isa(x, 'flywheel.model.Session')));
p.addRequired('nassets', @isnumeric);
p.addParameter('resources', true);
p.addParameter('acquisitionlabel',  '',@ischar);
p.addParameter('resources', true);

p.parse(session, nassets, varargin{:});
acquisitionlabel = p.Results.acquisitionlabel;
resourcesFlag = p.Results.resources;

%%  Download the recipes
if isempty(acquisitionlabel)
    acqs = session.acquisitions();

    % No specific recipe, randomly choose them
    nDatabaseAssets = length(acqs);
    assetList = randi(nDatabaseAssets, nassets, 1);
    
    % Assets we want to download
    downloadList = piObjectInstanceCount(assetList);
    nDownloads = length(downloadList);
    assetRecipe = cell(nDownloads, 1);

    for ii = 1:nDownloads
        thisIdx = downloadList(ii).index;
        acqLabel = acqs{thisIdx}.label;
        localFolder = fullfile(piRootPath, 'local', ...
            'AssetLists', acqLabel);
        destName_recipe = fullfile(localFolder, ...
            sprintf('%s.json', acqLabel));
        thisRecipe = stFileSelect(acqs{thisIdx}.files, ...
            'type', 'source code');
        destName_resource = fullfile(localFolder, ...
            sprintf('%s.zip', acqLabel));
        thisResource = stFileSelect(acqs{thisIdx}.files, ...
            'type', 'CG Resource');

        % if file exists, skip
        if ~exist(localFolder, 'dir') && ~exist(destName_recipe, 'file')
            mkdir(localFolder)
            thisRecipe{1}.download(destName_recipe);
            % fprintf('%s is downloaded \n', thisRecipe{1}.name);
            if resourcesFlag
                thisResource{1}.download(destName_resource);
                fprintf('%s is downloaded \n', thisResource{1}.name);
                unzip(destName_resource);
                delete([destName_resource, '.zip']);
            end
        else
            % fprintf('%s found \n',acqLabel);
        end
        assetRecipe{ii}.name = destName_recipe;
        assetRecipe{ii}.count = downloadList(ii).count;
        assetRecipe{ii}.fwInfo = ...
            [acqs{thisIdx}.id, ' ', thisResource{1}.name];
    end

    fprintf('%d Files downloaded.\n', nDownloads);
else
    % Download recipe from an acq with a specific label
    thisAcq = session.acquisitions.findOne(...
        sprintf('label=%s', acquisitionlabel));
    localFolder = fullfile(piRootPath, 'local', acquisitionlabel);
    
    destName_recipe = fullfile(localFolder, ...
        sprintf('%s.json', acquisitionlabel));
    thisRecipe = stFileSelect(thisAcq.files, 'type', 'source code');
    destName_resource = fullfile(localFolder, ...
        sprintf('%s.zip', acquisitionlabel));
    thisResource = stFileSelect(thisAcq.files, 'type', 'CG Resource');
    if ~exist(localFolder, 'dir') && ~exist(destName_recipe, 'file')
        mkdir(localFolder)
        thisRecipe{1}.download(destName_recipe);
        % fprintf('%s is downloaded \n', thisRecipe{1}.name);
        if resourcesFlag
            % We always unzip the resource and remove the zip file
            thisResource{1}.download(destName_resource);
            % fprintf('%s is downloaded \n', thisResource{1}.name);
            unzip(destName_resource, localFolder);
            delete(destName_resource);
        end
    else
        % fprintf('%s found \n', acquisitionlabel);
    end

    assetRecipe{1}.name = destName_recipe;
    assetRecipe{1}.fwInfo = [thisAcq.id, ' ', thisResource{1}.name];
    assetRecipe{1}.count = nassets;

    fprintf('%s downloaded.\n', acquisitionlabel);
end

end
