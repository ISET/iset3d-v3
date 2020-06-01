%% t_piFWAssets
%
% NEEDS MASSIVE UPDATING
%
%  In which our heroes explore how to upload and download assets to
%  Flywheel so we can get LMP and the gang to implement more features
%  that we want.
%
%

%%
st = scitran('stanfordlabs');

%% Find the project

% List them all
projectList = st.list('project','wandell');
stPrint(projectList,'label','');

% Search for the one we are interested in
project = st.search('project',...
    'project label exact','Graphics auto assets');

fprintf('\nThe Flywheel search response object is returned\n\n');
disp(project{1})

%% Find a session called space ship

session = st.search('session',...
    'project label exact','Graphics auto assets',...
    'session label exact','spaceship',...
    'summary',true);

%% Create an acquisition for the spaceship session

sessions = st.search('session',...
    'project label exact','Graphics auto assets',...
    'session label exact','spaceship',...
    'summary',true);

sessionID = st.objectParse(sessions{1});

acquisitionId = st.fw.addAcquisition(...
    struct('session', sessionID),'label', 'millenial-falcon'));

% We found the acquisition by a search.  It's in the right place.  But
% we could not see it in the browser.  Do we have to put a file in
% there?  That would be weird.

acquisition = st.search('acquisition',...
    'project label exact','Graphics auto assets',...
    'session label exact','spaceship',...
    'summary',true);

% Need to make sure we have these at hand.  Maybe they should go into data
% within iset3d.
st.fw.uploadFileToAcquisition(acquisitionId, 'millenium-falcon.obj');
st.fw.uploadFileToAcquisition(acquisitionId, 'millenium-falcon.mtl');

%% Down the files

% A way to list.  If you list, then use the file name and parent to
% download.
file = st.list('file',acquisitionId);
st.downloadFile(file{1}.name,...
    'container type','acquisition',...
    'container id',acquisitionId,...
    'destination','listDownload.obj');

%% Various ways to search
file = st.search('file',...
    'project label exact','Computer Graphics',...
    'session label exact','spaceship',...
    'summary',true);

file = st.search('file',...
    'project label exact','Computer Graphics',...
    'file name exact',file{2}.file.name,...
    'summary',true);

%% One way to download

newVersion = fullfile(pwd,'newVersion2.obj');
st.downloadFile(file{1},...
    'destination',newVersion);

%% Another way to get it
st.downloadFile(file{1}.file.name,...
    'container type','acquisition',...
    'container id',acquisitionId,...
    'destination',newVersion);

