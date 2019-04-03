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
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end

%% Read the scene file for the Remote Data site

% sceneName = 'white-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath,'local');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);
inFile = fullfile(inFolder,sceneName,sceneFileName);
recipe = piRead(inFile);

outFolder = fullfile(tempdir,sceneName);
outFile = fullfile(outFolder,[sceneName,'.pbrt']);
recipe.set('outputFile',outFile);

%% Change render quality

recipe.set('film resolution',[192 192]);
recipe.set('pixel samples',96);
recipe.set('max depth',1); % Number of bounces

%% Render
piWrite(recipe);

%%  Create the scene
[scene, result] = piRender(recipe);

%%  Show the radiance

ieAddObject(scene); sceneWindow;
% scene = sceneSet(scene,'gamma',0.5);

%% Show the depth map
scenePlot(scene,'depth map');

%%