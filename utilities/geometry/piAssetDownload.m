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
[zipFiles, acqID] = st.fileDataList('session', containerID, fileType, ...
    'asset',sessionname);

nDatabaseAssets = length(zipFiles);

fname = cell(nassets,1);
if nassets <= nDatabaseAssets
    assetList = randperm(nDatabaseAssets,nassets);
    for jj = 1:nassets
        [~,n,e] = fileparts(zipFiles{assetList(jj)}{1}.name);
        
        % Download the scene to a destination zip file
        destName = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
        st.fileDownload(zipFiles{assetList(jj)}{1}.name,...
            'container type', 'acquisition' , ...
            'container id',  acqID{assetList(jj)} ,...
            'unzip', true, ...
            'destination',destName);
        
        % Unzip the file
        % localFolder = fullfile(piRootPath,'local');
        % unzip(localFile,localFolder);
        
        % Save the file name of the scene in the folder
        localFolder = fileparts(destName);
        fname{jj}   = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
        if ~exist(fname{jj},'file'), error('File not found'); 
        end 
    end
else
%     disp('NOT YET IMPLEMENTED. WE WANT MORE CARS.');
%   New car geometry will overwrite the old one, thus two cars are created 
%   with shared geometry, but different materials.
    nRequired = nassets-nDatabaseAssets;
    for jj = 1:nRequired
        assetList = randperm(nDatabaseAssets,nRequired);
        [~,n,e] = fileparts(zipFiles{assetList(jj)}{1}.name);
        % Download the scene to a destination zip file
        destName = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
        st.fileDownload(zipFiles{assetList(jj)}{1}.name,...
            'container type', 'acquisition' , ...
            'container id',  acqID{assetList(jj)} ,...
            'unzip', true, ...
            'destination',destName);
        % Unzip the file
        % localFolder = fullfile(piRootPath,'local');
        % unzip(localFile,localFolder);
        
        % Save the file name of the scene in the folder
        localFolder = fileparts(destName);
        fname{jj}   = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
        if ~exist(fname{jj},'file'), error('File not found');
        end
    end 
end
fprintf('%d Files downloaded.\n',nassets);
end







