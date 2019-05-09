function assetlist = piAssetListCreate(varargin)
% Create an assetList for street elements on flywheel
%
% Syntax:
%   assetlist = piAssetListCreate([varargin])
%
% Description:
%    Create an assetList for the street elements taken from flywheel.io.
%
% Inputs:
%    None.
%
% Outputs:
%    assetList - Struct. Assigned assets libList used for street elements.
%
% Optional key/value pairs:
%    class     - String. The session name on flywheel. Default ''.
%    subclass  - String. The acquisition names on flywheel. Default ''.
%    scitran   - Object. The scitran Object. Default empty [], which then
%                activates a session at stanfordlabs.
%

% History:
%    XX/XX/XX   Z   Created by Zhenyi
%    04/10/19  JNM  Documentation pass, add example.
%    04/18/19  JNM  Merge Master in (resolve conflicts)
%    05/09/19  JNM  Merge Master in again

% Examples:
%{
    assetList = piAssetListCreate('class', 'suburb')
%}

%% Initialize
p = inputParser;
p.addParameter('class', '');
p.addParameter('subclass', '');
p.addParameter('scitran', []);
p.parse(varargin{:});
st = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

sessionname = p.Results.class;
acquisitionname = p.Results.subclass;

%% Find all the acuisitions
project = st.lookup('wandell/Graphics auto/assets');
session = project.sessions.findOne(sprintf('label=%s', sessionname));
acqs = session.acquisitions();
nDatabaseAssets = length(acqs);

if isempty(acquisitionname)
    %% No acquisition name. Loop across all of them.
    %
    % We had a variable called thisIdx, but it was undefined.
    % So I replaced it with the loop variable, ii.
    % Causing problems, I fear (BW).
    for ii = 1:nDatabaseAssets
        acqLabel = acqs{ii}.label;
        localFolder = fullfile(piRootPath, 'local', ...
            'AssetLists', acqLabel);
        destName_recipe = fullfile(localFolder, ...
            sprintf('%s.json', acqLabel));
        if ~exist(localFolder,'dir'), mkdir(localFolder); end

        % Download the recipe and the resources
        thisRecipe = stFileSelect(acqs{ii}.files, 'type', 'source code');
        thisResource = stFileSelect(acqs{ii}.files, 'type', 'CG Resource');
        thisRecipe{1}.download(destName_recipe);

        % Read the recipe and create an entry in the assetlist
        thisR = jsonread(destName_recipe);
        assetlist(ii).name = acqLabel;
        assetlist(ii).material.list = thisR.materials.list;
        assetlist(ii).material.txtLines = thisR.materials.txtLines;
        assetlist(ii).geometry = thisR.assets;
        assetlist(ii).geometryPath = ...
            fullfile(localFolder, 'scene', 'PBRT', 'pbrt-geometry');
        assetlist(ii).fwInfo = [acqs{ii}.id, ' ', thisResource{1}.name];
    end

    fprintf('%d files added to the asset list.\n',nDatabaseAssets);
else
    %% We have the name, so just one.
    % [Note: BW - Not sure why we have a loop on dd]
    thisAcq = stSelect(acqs, 'label', acquisitionname);
    for dd = 1:length(thisAcq)
        acqLabel = thisAcq{dd}.label;
        localFolder = ...
            fullfile(piRootPath, 'local', 'AssetLists', acqLabel);

        destName_recipe = fullfile(localFolder, ...
            sprintf('%s.json', acqLabel));
        if ~exist(localFolder, 'dir'), mkdir(localFolder); end
        thisRecipe = stFileSelect(thisAcq{dd}.files, ...
            'type', 'source code');
        thisResource = stFileSelect(thisAcq{dd}.files, ...
            'type', 'CG Resource');
        thisRecipe{1}.download(destName_recipe);
        thisR = jsonread(destName_recipe);
        assetlist(dd).name = acqLabel;
        assetlist(dd).material.list = thisR.materials.list;
        assetlist(dd).material.txtLines = thisR.materials.txtLines;
        assetlist(dd).geometry = thisR.assets;
        assetlist(dd).geometryPath = fullfile(localFolder, 'scene', ...
            'PBRT', 'pbrt-geometry');
        assetlist(dd).fwInfo = [thisAcq{dd}.id, ' ', thisResource{1}.name];
    end
    fprintf('%s added to the list.\n', acqLabel);
end
end