function fname = piAssetDownload(session,sessionname,nassets,varargin)
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
[zipFiles, acqID] = st.dataFileList('session', containerID, fileType, ...
    'asset',sessionname);

nDatabaseAssets = length(zipFiles);

fname = cell(nassets,1);

if nassets <= nDatabaseAssets
    assetList = randperm(nDatabaseAssets,nassets);
    nDownloads = nassets;
else 
    nDownloads = nDatabaseAssets;
    nRequired = nassets-nDatabaseAssets;
    assetList = randperm(nDatabaseAssets,nDatabaseAssets);
    assetList_required = randperm(nDatabaseAssets,nRequired);
end

for ii = 1:nDownloads
    [~,n,e] = fileparts(zipFiles{assetList(ii)}{1}.name);
    % Download the scene to a destination zip file
    destName = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
    st.fileDownload(zipFiles{assetList(ii)}{1}.name,...
        'container type', 'acquisition' , ...
        'container id',  acqID{assetList(ii)} ,...
        'unzip', true, ...
        'destination',destName);
    % Save the file name of the scene in the folder
    localFolder = fileparts(destName);
    fname{ii}   = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
    if ~exist(fname{ii},'file'), error('File not found');
    end
end
%   disp('NOT YET IMPLEMENTED. WE WANT MORE CARS.');
%   New car geometry will overwrite the old one, thus two cars are created 
%   with shared geometry, but different materials.
for jj = 1:nRequired
    [~,n,~] = fileparts(zipFiles{assetList_required(jj)}{1}.name);
    fname{nDownloads+jj} = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
end

fprintf('%d Files downloaded.\n',nassets);
end







