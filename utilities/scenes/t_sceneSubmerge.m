% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create a checkerboard 
%  The board wll have 8 x 7 blocks and be 2.4 x 2.1 meter in size.
squareSize = 0.3;

% The output will be written here
sceneName = 'calChecker';
outFile = fullfile(piRootPath,'local',sceneName,'calChecker.pbrt');
recipe = piCreateCheckerboard(outFile,'numX',8,'numY',7,'dimX',squareSize,'dimY',squareSize);

%% Define the camera


recipe.set('pixel samples',32);

recipe.set('film resolution',[640   480]);
% recipe.set('camera type','realistic');
% recipe.set('film diagonal', 6);
% recipe.set('lensfile',fullfile(piRootPath,'data','lens','fisheye.87deg.6.0mm.dat'));
% recipe.set('focus distance',4);


recipe.set('outputFile',fullfile(piRootPath,'local','underwater','underwater.pbrt'));
recipe.integrator.subtype = 'spectralvolpath';

recipe = piSceneSubmerge(recipe,4,4,4, 'cPlankton',10);


piWrite(recipe,'creatematerials',true);
[oi, result] = piRender(recipe,'dockerimagename','vistalab/pbrt-v3-spectral:underwater');

ieAddObject(oi);