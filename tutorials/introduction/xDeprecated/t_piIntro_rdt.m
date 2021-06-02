%% Illustrate fetching scene from the archiva server using RDT
%
% Description:
%  This introduction downlaods a file stored at the archiva site
%  where we keep various larger PBRT files.  The script uses the
%  RemoteDataToolbox to download the scene file and then renders
%  the scene.
%
%  You must have the RemoteDataToolbox on your path to run this.
% 
% Dependencies
%
%    iset3d, (isetcam or isetbio), JSONio, RemoteDataToolbox
%
%  Check that you have the updated docker image of PBRT by running
%    docker pull vistalab/pbrt-v3-spectral
%
% TL,ZL,BW SCIEN 2017
%
% See also
%   t_piIntro_*
%

% History:
%   10/18/20  dhb  This was broken in many ways.  Had to fix a routine in
%                  RDT, and then get rid of a copy of some non-existent
%                  files.  Had to make variable names 'recipe' and 'thisR'
%                  consistent (went with 'thisR').
%   10/28/20  dhb  Since ChessSet is now part of ISET3d, change to kitchen
%                  scene to illustrate getting something we don't already have.

%% Initialize ISET and Docker
%
% Start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Check for RDT
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end

%% Read the scene file for the remote data site
%
% Specify name of scene and where we want the output.  The iset3d/local
% directory is ignored by git and is a place we can stash files we are
% working with, without clogging up the github repository.
%
% We happen to know there is a 'kitchen' scene stored on the server, with
% the scene name being 'scene.pbrt'.  We'll pull that down and render it.
sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
inFolder = fullfile(piRootPath,'local');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);
inFile = fullfile(inFolder,sceneName,sceneFileName);
thisR = piRead(inFile);

%% Change render quality
thisR.set('film diagonal',2);
thisR.set('film resolution',[192 192]);
thisR.set('pixel samples',96);
thisR.set('max depth',1); % Number of bounces
thisR.set('film distance',2);   % Two millimeters from the pinhole
thisR.get('from')
piCameraTranslate(thisR,'fromto','from','z shift',0.3);

%% Set up output file for rendering
outDir = fullfile(piRootPath,'local','renderings',sceneName);
outFile = fullfile(outDir,[sceneName,'.pbrt']);
thisR.set('outputFile',outFile);
piWrite(thisR,'overwrite geometry',false,...
    'overwrite materials',false,...
    'overwrite json',false);

%% Render!  
%
% Specifying 'render type','radiance' skips computing the depth map.
[scene, result] = piRender(thisR,'render type','radiance');

%  Show the rendered radiance.
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);
