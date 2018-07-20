function fname = piAssetDownload(session, varargin)
%% Download assets from a flywheel session
%
%
% Example: 
%{
piAssetDownload(session,'sessionname','car','ncars',ncars);
%}
%%
p = inputParser;
varargin = ieParamFormat(varargin);

vFunc = @(x)(strncmp(class(x),'flywheel.model',14) || ...
            (iscell(x) && strncmp(class(x{1}),'flywheel.model',14)));
p.addRequired('session',vFunc);

p.addParameter('sessionname','car')
p.addParameter('ncars',1)
p.addParameter('ntrucks',0);
p.addParameter('npeople',0);
p.addParameter('nbuses',0);
p.addParameter('ncyclist',0); 
p.parse(session, varargin{:});
sessionName = p.Results.sessionname;
ncars = p.Results.ncars;
%%
st = scitran('stanfordlabs');
%%
% Create Assets obj struct
% Download random cars from flywheel

% Find how many cars are in the database?
% stPrint(hierarchy.acquisitions{whichSession},'label','') % will be disable

% These files are within an acquisition (dataFile)
containerID = idGet(session,'data type','session');
fileType    = 'archive';
[zipFiles, acqID] = st.fileDataList('session', containerID, fileType, ...
    'asset',sessionName);

nDatabaseCars = length(zipFiles);

fname = cell(ncars,1);
if ncars <= nDatabaseCars
    carList = randperm(nDatabaseCars,ncars);
    for jj = 1:ncars
        [~,n,e] = fileparts(zipFiles{carList(jj)}{1}.name);
        
        % Download the scene to a destination zip file
        destName = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
        st.fileDownload(zipFiles{carList(jj)}{1}.name,...
            'container type', 'acquisition' , ...
            'container id',  acqID{carList(jj)} ,...
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
    disp('NOT YET IMPLEMENTED. WE WANT MORE CARS.');
end
fprintf('%d Files downloaded',ncars);
end