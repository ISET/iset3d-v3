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

%{
recipe.set('pixel samples',32);
recipe.set('film resolution',[1280 1024]);
recipe.set('camera type','realistic');
recipe.set('film diagonal', 6);
recipe.set('lensfile',fullfile(piRootPath,'data','lens','fisheye.87deg.6.0mm.dat'));
recipe.set('focus distance',4);
%}

recipe.set('outputFile','/Users/hblasinski/Documents/MATLAB/iset3d/local/test/test.pbrt');
recipe.integrator.subtype = 'spectralvolpath';

recipe = piSceneSubmerge(recipe,1,1,1);


piWrite(recipe,'creatematerials',true);

outFile = '/Users/hblasinski/Desktop/test.dat';
ieObject = piDat2ISET(outFile,...
                'label','radiance',...
                'recipe',recipe,...
                'scaleIlluminance',false);
            
ieAddObject(ieObject);