%% Render a blank white scene for calibration purposes
%
% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene
% This scene consists of an infinite light source and a white disk placed 1
% meter away from the camera. The disk itself has a radius of 1 meter as
% well.
fname = fullfile(piRootPath,'data','whiteScene','whiteScene.pbrt');

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Add a camera
thisR = recipeSet(thisR,'camera','realistic');
thisR.camera.specfile.value = fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat');
thisR.camera.filmdistance.value = 50;
thisR.camera.aperture_diameter.value = 8;

% Make the sensor really big so we can see the edge of the lens and the
% vignetting.
% This takes roughly a 90 seconds to render on a 6 core machine.
% Why does this take so long? There seems to be a lot of NaN returns for
% the radiance, maybe tracing the edges of the lens is difficult in some
% way? The weighting of the rays might also be incorrect in PBRTv2. 
thisR.camera.filmdiag.value = 100;

thisR = recipeSet(thisR,'pixelsamples',256);
thisR = recipeSet(thisR,'filmresolution',128);

%% Write out a new pbrt file

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);

% oname = fullfile(workingDirectory,'whiteScene.pbrt');
piWrite(thisR, 'overwrite', true);

%% Render with the Docker container

oi = piRender(oname);

% Show it in ISET
vcAddObject(oi); oiWindow;   
