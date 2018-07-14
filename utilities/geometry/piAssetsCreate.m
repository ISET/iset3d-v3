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

%% Cars
% Create Assets obj struct
% Download random cars from flywheel, reuse some of the cars as intances
% if the cars required are less then what we have on the flywheel. 
% Obj Instance should be used, but better with different color for carbody. 

projects = st.search('project','project label exact','Graphics assets');
sessions = st.list('sessions',idGet(projects{1},'data type','project'));
% Find how many cars we have in our session
whichSession = 1;
stPrint(hierarchy.acquisitions{whichSession},'label','')
file{1} = st.search('file',...
    'session label exact','spaceship',...
    'acquisition label contains','Car',...
    'file name exact','Car_1.zip',...
    'file type','archive');
file{2} = st.search('file',...
    'session label exact','spaceship',...
    'acquisition label contains','Car',...
    'file name exact','Car_2.zip',...
    'file type','archive');
% Example of how to randomly select acquisitions from a specific
% session
whichSession = 1;
nAcqs = length(hierarchy.acquisitions{whichSession});
if inputs.nCars <= nAcqs
    p = randperm(nAcqs,inputs.nCars); % generate random unique integers
    for jj = 1: length(p)
        % will change file file{p(jj)}{1} back to file{p(jj)} 07/12
        [~,n,e] = fileparts(file{p(jj)}{1}.file.name);
        fname = fullfile(piRootPath,'local',sprintf('%s%s',n,e));
        % download
        %file = file{p(jj)};
        localFile = st.fileDownload(file{p(jj)}{1},'destination',fname);
        localFolder = fullfile(piRootPath,'local');
        unzip(localFile,localFolder);
        fname = fullfile(localFolder, sprintf('%s/%s.pbrt',n,n));
        if ~exist(fname,'file'), error('File not found'); end
        thisR_tmp = piRead(fname,'version',3);
        geometry = piGeometryRead(thisR_tmp);
        assets(jj).class = 'car';
        assets(jj).material =thisR_tmp.materials.list;
        assets(jj).geometry = geometry;
        assets(jj).geometryPath = fullfile(piRootPath,'local',sprintf('Car_%d',jj),...
            'scene','PBRT','pbrt-geometry');
        fprintf('%d car created \n',jj);
    end
    disp('All done!\n')
else
    disp('NOT ENOUGH CARS.\n');
    % create object instance
end



% for ii=1:inputs.nCars
%     
%     currentClass = 'car';
%     %     nClass = length(assets.(currentClass));
%     %
%     %     assets(ii).class = currentClass;
%     
%     % Download a random car obj from flywheel car session
%     
%     % list the acquisition labels in the first session
%     whichSession = 1;
%     stPrint(hierarchy.acquisitions{whichSession},'label','')
%     file = st.search('file',...
%         'session label exact','spaceship',...
%         'acquisition label contains','Car',...
%         'file name contains','zip');
%     % Example of how to randomly select acquisitions from a specific
%     % session
%     whichSession = 1;
%     nAcqs = length(hierarchy.acquisitions{whichSession});
%     nSamples = 2;
%     assets(ii).id = randi(nAcqs);
%     fname     = fullfile(piRootPath,'local',sprintf('car_%d/car_%d.zip',ii,ii));
%     localFile = st.fileDownload(file{assets(ii).id},'destination',fname);
%     destinationDir = fileparts(fname);
%     unzip(localFile,destinationDir);
%     filename = fullfile(piRootPath,'local',sprintf('car_%d/Car_%d.pbrt',ii,ii));
%     % Read scene.pbrt
%     thisR = piRead(filename,'version',3);
%     %     piMaterialGroupAssign(thisR); Materials has been assigned before up
%     geometry = piGeometryRead(thisR);
%     assets(ii).class = 'car';
%     assets(ii).material =thisR.materials.list;
%     assets(ii).geometry = geometry;
%     assets(ii).geometryPath = fullfile(piRootPath,'local',sprintf('car_%d',ii),...
%         'scene','PBRT','pbrt-geometry');
% end



end
function coloro=piColorPick(varargin)
% Color library, what is the common color 
p = inputParser;
p.addParameter()
end