%% Package up data files for iset3d on the RdtClient
%
% We store PBRT data in a zip file containing the main scene PBRT file
% and all of its resources. The resources are represented in the scene
% file as relative directory locations, so when you download the zip
% file and unpack it, the scene.pbrt file can still find it.
%
% I put the zipped PBRT files in isetbio repository within the archiva
% server.  These PBRT files might get put into iset3d, rather than
% isetbio.  But for now sign in to download them as isetbio.
%
% The remote path for V2 and V3 files is becoming
%        
%      RdtClient.crp('/resources/scenes/pbrt/V{2,3}') 
%
% where you choose 2 or 3.  The default in piPBRTFetch is V2.
% 
% Wandell, January, 2018

%{
% Download a small scene by hand, not using piPBRTFetch
 rdt.crp('/resources/scenes/pbrt/V2');
a = rdt.searchArtifacts('whiteScene');
destinationFolder = fullfile(piRootPath,'local');
rdt.readArtifact(a,'destinationFolder',destinationFolder);

file = fullfile(destinationFolder,'whiteScene.zip');
unzip(file);

%}
%{
 rdt = RdtClient('isetbio');
 rdt.credentialsDialog;

 % Moving from /pbrt/file to /pbrt/V2/file
 chdir(fullfile(piRootPath,'local'));

 % Version 3 files
 % bathroom, bathroom2, bedroom, kitchen, white-room,living-room,
 % SimpleScene,
 zipFile = piPBRTFetch('living-room','unzip',false,'destinationFolder',fullfile(piRootPath,'local'));
 piPBRTPush(zipFile,'pbrtVersion','v3','rd',rdt);

 % Version 2 files
 % ChessSet, CityScene, NumbersAtDepth, MultiObject-City-1-Placement-2
 % plantsDusk, sanmiguel, whiteScene, yeahright, texturedPlane
 % SlantedBar, teapot-area, villaLights
 
 zipFile = piPBRTFetch('whiteScene','unzip',false,'destination folder',fullfile(piRootPath,'local'));
 piPBRTPush(zipFile,'pbrt version','v2','rd',rdt);

%}

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

%%  Upload the city scene, as per HB

chdir(fullfile(piRootPath,'local'))
artifactPath = fullfile(pwd,'CityScene.zip');

% Then to upload the artifact, I did this
rdt.crp('/resources/scenes/pbrt');
rdt.publishArtifact(artifactPath);

% Check that it is there.
a = rdt.listArtifacts('print',true);
