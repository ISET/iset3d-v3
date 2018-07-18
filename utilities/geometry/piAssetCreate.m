function assets = piAssetsCreate(thisR_tmp, varargin)
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

%%
p = inputParser;

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.addParameter('nCars',1);
p.addParameter('nTrucks',0);
p.addParameter('nPeople',0);
p.addParameter('nBuses',0);
p.addParameter('nCyclist',0);
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(thisR_tmp,varargin{:});
inputs = p.Results;
st = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

hierarchy = st.projectHierarchy('Graphics assets','project id','5b3eac08d294db0016bb1a2b');
% projects = st.search('project','project label exact','Computer Graphics')
assets = [];
% cnt = 1;
projects = st.search('project','project label exact','Graphics assets');
sessions = st.list('sessions',idGet(projects{1},'data type','project'));
%% Cars
% Create Assets obj struct
% Download random cars from flywheel
 
% Find how many cars we have in our session
whichSession = 1;
stPrint(hierarchy.acquisitions{whichSession},'label','') % will be disable 

carSession = st.search('session',...
    'project label exact','Graphics assets',...
    'session label exact','car');
% These files are within an acquisition (dataFile)
zipFiles = st.fileDataList('session',...
    idGet(carSession{1},'data type','session'),...
    'archive');

nAcqs = length(hierarchy.acquisitions{whichSession});
if inputs.nCars <= nAcqs
    p = randperm(nAcqs,inputs.nCars);
    for jj = 1: length(p)
        [~,n,e] = fileparts(zipFiles{p(jj)}.file.name);
        fname = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
        % download
        localFile = st.fileDownload(zipFiles{p(jj)},'destination',fname);
        localFolder = fullfile(piRootPath,'local');
        unzip(localFile,localFolder);
        fname = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
        if ~exist(fname,'file'), error('File not found'); end
        thisR_tmp = piRead(fname,'version',3);
        geometry = piGeometryRead(thisR_tmp);
        assets(jj).class = 'car';
        assets(jj).material =thisR_tmp.materials.list;
        assets(jj).geometry = geometry;
        assets(jj).geometryPath = fullfile(piRootPath,'local',sprintf('Car_%d',p(jj)),...
            'scene','PBRT','pbrt-geometry');
        fprintf('%d car created \n',jj);
    end
    disp('All done!')
else
    disp('NOT ENOUGH CARS.');
    % we might create object instance in the future.
end

end