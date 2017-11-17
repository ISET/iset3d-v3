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

% Remote directory for all the PBRT scene files.
% Each is stashed with its own resources and a base scene file.
% We can change the camera, lookAt and such using piRead/piWrite
% sequences.
rdt.crp('/resources/scenes/pbrt');

% Some PBRT scenes are here
chdir(fullfile(piRootPath,'data'))

% 1
artifactPath = fullfile(pwd,'teapot-area.zip');
rdt.publishArtifact(artifactPath);

% 2
artifactPath = fullfile(pwd,'whiteScene.zip');
rdt.publishArtifact(artifactPath);

% Others were here, at least temporarily
% If ISETBIO is on your path, (not ISET), then this would work
chdir(fullfile(isetRootPath,'data','pbrtscenes'))

% 3
artifactPath = fullfile(pwd,'ChessSet.zip');
rdt.publishArtifact(artifactPath);

% 4
artifactPath = fullfile(pwd,'SlantedBar.zip');
rdt.publishArtifact(artifactPath);

% 5 
artifactPath = fullfile(pwd,'NumbersAtDepth.zip');
rdt.publishArtifact(artifactPath);

% 6 - sanmiguel done manually
%%  