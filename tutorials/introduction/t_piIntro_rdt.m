%% This is the second in a series of scripts introducing iset3d calulcations
%
% Brief description:
%
%  This introduction downlaods a file stored in the Remote Data
%  Toolbox site where we keep various larger PBRT files.  The script
%  downloads and then renders it.
%
%  You must have the Remote Data Toolbox on your path to run this.
% 
% Dependencies
%
%    ISET3d, (ISETCam or ISETBio), JSONio, RemoteDataToolbox
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% TL,ZL, BW SCIEN 2017
%
% See also
%  t_piIntroduction*, t_piIntro*
%

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%{
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end
%}

%%
%{
thisR = piRecipeDefault('scene name','chessSet');
%}

% We need to copy the materials and geometry files by hand.
%

%% Read the scene file for the Remote Data site

% {
% sceneName = 'white-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath,'local');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);
inFile = fullfile(inFolder,sceneName,sceneFileName);
recipe = piRead(inFile);
%}

%% Change render quality

thisR.set('film diagonal',2);
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',96);
thisR.set('max depth',1); % Number of bounces
thisR.set('film distance',2);   % Two millimeters from the pinhole
thisR.get('from')
piCameraTranslate(thisR,'fromto','from','z shift',0.3);

%% Render
% {
outDir = fullfile(piRootPath,'local','renderings',sceneName);
outFile = fullfile(outDir,[sceneName,'.pbrt']);
recipe.set('outputFile',outFile);
%}
piWrite(thisR,'overwrite geometry',false,...
    'overwrite materials',false,...
    'overwrite json',false);

gFileIn = fullfile(inFolder,'scenes','ChessSet','ChessSet_geometry.pbrt')
gFileOut = fullfile(outDir,'ChessSet_geometry.pbrt')

copyfile(gFileIn,gFileOut);

mFileIn = fullfile(inFolder,'scenes','ChessSet','ChessSet_materials.pbrt')
mFileOut = fullfile(outDir,'ChessSet_materials.pbrt')
copyfile(mFileIn,mFileOut);

dir(outDir);

%%  Create the scene
[scene, result] = piRender(thisR,'render type','radiance');

%%  Show the radiance

sceneWindow(scene);
% scene = sceneSet(scene,'gamma',0.5);

%% Show the depth map
scenePlot(scene,'depth map');

%%