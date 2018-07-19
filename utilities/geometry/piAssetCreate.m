function asset = piAssetCreate(varargin)
% Create and combine assets using base information from a recipe
%
% Inputs
%  thisR - A rendering recipe
%
% Optional key/value parameters
%   nCars
%   nTrucks
%   nPeople
%   nBuses
%   nCyclist
%   scitran
%
% Returns
%   assets - Struct with the asset geometries and materials
%
% Zhenyi, Vistasoft Team, 2018

%% Parse input parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('ncars',1);
p.addParameter('ntrucks',0);
p.addParameter('npeople',0);
p.addParameter('nbuses',0);
p.addParameter('ncyclist',0); % Cyclist contains two class: rider and bike.
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(varargin{:});

inputs = p.Results;
st     = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

%%  Store up the asset information

hierarchy = st.projectHierarchy('Graphics assets');

projects     = hierarchy.project;
sessions     = hierarchy.sessions;
acquisitions = hierarchy.acquisitions;

asset = [];

%% Find the cars in the database

if p.Results.ncars > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'car')
            carSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random cars from flywheel
    
    % Find how many cars are in the database?
    % stPrint(hierarchy.acquisitions{whichSession},'label','') % will be disable
    
    % These files are within an acquisition (dataFile)
    containerID = idGet(carSession,'data type','session');
    fileType    = 'archive';
    [zipFiles, acqID] = st.fileDataList('session', containerID, fileType, ...
        'asset','car');
    
    nDatabaseCars = length(zipFiles);
    
    fname = cell(inputs.ncars,1);
    if inputs.ncars <= nDatabaseCars
        carList = randperm(nDatabaseCars,inputs.ncars);
        for jj = 1:inputs.ncars
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
            if ~exist(fname{jj},'file'), error('File not found'); end
            
        end
    else
        disp('NOT YET IMPLEMENTED. WE WANT MORE CARS.');
    end
end

%% Analyze the downloaded scenes in fname and create the returned asset

for jj=1:length(fname)
    thisR = piRead(fname{jj},'version',3);
    geometry = piGeometryRead(thisR);
    asset(jj).geometry = geometry;
    
    asset(jj).class = 'car';
    asset(jj).material = thisR.materials.list;
    
    localFolder = fileparts(fname{jj});
    asset(jj).geometryPath = fullfile(localFolder,'scene','PBRT','pbrt-geometry');
    fprintf('%d car created \n',jj);
end
disp('All done!')

end
