function assetRecipe = piAssetDownload(session,sessionname,nassets,varargin)
% Download assets from a flywheel session
%
%  fname = piAssetDownload(session,sessionname,nassets,varargin)
%
% Description
%
% Inputs
% Optional key/value parameters
% Outputs
%

% Examples: 
%{
fname = piAssetDownload(session,sessionname,ncars);
%}

%% Parse the inputs

p = inputParser;
p.addRequired('session',@(x)(isa(x,'flywheel.model.Session')));
p.addRequired('sessionname',@ischar);
p.addRequired('nassets',@isnumeric);
p.addParameter('scitran',[],@(x)(isa(x,'scitran')));

p.parse(session, sessionname, nassets, varargin{:});
st = p.Results.scitran;

if isempty(st)
    st = scitran('stanfordlabs');
end
% varargin = ieParamFormat(varargin);
% 
% vFunc = @(x)(strncmp(class(x),'flywheel.model',14) || ...
%             (iscell(x) && strncmp(class(x{1}),'flywheel.model',14)));
% p.addRequired('session',vFunc);
% 
% p.addParameter('sessionname','car')
% p.addParameter('ncars',1)
% p.addParameter('ntrucks',0);
% p.addParameter('npeople',0);
% p.addParameter('nbuses',0);
% p.addParameter('ncyclist',0); 
% sessionName = p.Results.sessionname;
% ncars = p.Results.ncars;
%%

%%
% Create Assets obj struct
% Download random cars from flywheel

% Find how many cars are in the database?
% stPrint(hierarchy.acquisitions{whichSession},'label','') % will be disable

% These files are within an acquisition (dataFile)
containerID = idGet(session,'data type','session');
fileType    = 'archive';
[resourceFiles, resource_acqID] = st.dataFileList('session', containerID, fileType);
fileType_json ='source code'; % json
[recipeFiles, recipe_acqID] = st.dataFileList('session', containerID, fileType_json);

nDatabaseAssets = length(resourceFiles);

assetRecipe = cell(nassets,1);
if nassets <= nDatabaseAssets
    assetList = randperm(nDatabaseAssets,nassets);
    nDownloads = nassets;
    nRequired = 0;
else 
    nDownloads = nDatabaseAssets;
    nRequired = nassets-nDatabaseAssets;
    assetList = randperm(nDatabaseAssets,nDatabaseAssets);
    assetList_required = randperm(nDatabaseAssets,nRequired);
end

for ii = 1:nDownloads
    [~,n,~] = fileparts(resourceFiles{assetList(ii)}{1}.name);
    [~,n,~] = fileparts(n); % extract file name
    % Download the scene to a destination zip file
    localFolder = fullfile(piRootPath,'local',n);
    if ~exist(localFolder,'dir'), mkdir(localFolder);end
    destName_recipe = fullfile(localFolder,sprintf('%s.json',n));
    destName_resource = fullfile(localFolder,sprintf('%s.zip',n));
    
    st.fileDownload(recipeFiles{assetList(ii)}{1}.name,...
        'container type', 'acquisition' , ...
        'container id',  recipe_acqID{assetList(ii)} ,...
        'destination',destName_recipe);
    
    st.fileDownload(resourceFiles{assetList(ii)}{1}.name,...
        'container type', 'acquisition' , ...
        'container id',  resource_acqID{assetList(ii)} ,...
        'unzip', true, ...
        'destination',destName_resource);
    assetRecipe{ii}   = destName_recipe;
    if ~exist(assetRecipe{ii},'file'), error('File not found');end 
end
%   disp('NOT YET IMPLEMENTED. WE WANT MORE CARS.');
%   New car geometry will overwrite the old one, thus two cars are created 
%   with shared geometry, but different materials.
for jj = 1:nRequired
    [~,n,~] = fileparts(resourceFiles{assetList_required(jj)}{1}.name);
    assetRecipe{nDownloads+jj} = fullfile(localFolder, sprintf('%s.json',n));
    if ~exist(assetRecipe{ii},'file'), error('File not found');end 
end

fprintf('%d Files downloaded.\n',nassets);
end







