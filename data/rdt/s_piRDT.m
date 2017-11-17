%% Package up data files for pbrt2ISET on the RdtClient
%

%% Create the rdt client object for interacting with the resources

% To just download, you only need the object
rdt = RdtClient('isetbio');

% To put things up you will need a password.  Enter it through the credentials
% dialog.
rdt.credentialsDialog;

%% Uploading the sanmiguel file in /resources/scenes/pbrt

% To start the pbrt scenes storage, I made a zip version of the sanmiguel file.
% On my computer it is here.  The file is about 250 MB
chdir(fullfile(piRootPath,'data'))
artifactPath = fullfile(pwd,'sanmiguel.zip');

% Then to upload the artifact, I did this
rdt.crp('/resources/scenes/pbrt');
rdt.publishArtifact(artifactPath);

% Check that it is there.
a = rdt.listArtifacts('print',true);

%% How to download 

rdt.crp('/resources/scenes/pbrt');
a = rdt.searchArtifacts('whiteScene');
destinationFolder = fullfile(piRootPath,'local');
rdt.readArtifact(a,'destinationFolder',destinationFolder);
file = fullfile(destinationFolder,'whiteScene.zip');
unzip(file);

%% Putting up some other pbrt scenes

% Remote directory
rdt.crp('/resources/scenes/pbrt');

chdir(fullfile(piRootPath,'data'))

% PBRT scenes
artifactPath = fullfile(pwd,'teapot-area.zip');
rdt.publishArtifact(artifactPath);

artifactPath = fullfile(pwd,'whiteScene.zip');
rdt.publishArtifact(artifactPath);




