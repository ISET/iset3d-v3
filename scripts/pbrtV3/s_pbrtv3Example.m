%% Test a pbrtv3 scene.
% 
% TL SCIEN 2017

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

% Replace this with your own path. You can find the living room scene here:
% https://benedikt-bitterli.me/resources/
% or the direct link here:
% https://benedikt-bitterli.me/resources/pbrt-v3/living-room-2.zip

% WARNING: You will have to "clean up" the pbrt file before running, or
% else the parser will not read it correctly. Soon we will put up a cleaned
% up version of this scene somewhere, but right now it's too big. 
recipe = piRead('/Users/trishalian/GitRepos/pbrt-v3-scenes-Bitterli/living-room-2/scene.pbrt','version',3);

%% Change the camera lens

% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% recipe.version can tell us, but piCameraCreate does not take a recipe as
% input. For now let's put things in manually. 

recipe.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.6.0mm_v3.dat');recipe.camera.lensfile.value = lensFile;
% Attach the lens
recipe.camera.lensfile.value = lensFile; % mm
recipe.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
recipe.camera.aperturediameter.value = 1; % mm
recipe.camera.aperturediameter.type = 'float';

% Focus at roughly meter away. 
recipe.camera.focusdistance.value = 1; % meter
recipe.camera.focusdistance.type = 'float';

% Use a 1" sensor size
recipe.film.diagonal.value = 16; 
recipe.film.diagonal.type = 'float';

%% Change render quality
% This quality takes around 30 seconds to render on a machine with 8 cores.
recipe.set('filmresolution',[128 128]);
recipe.set('pixelsamples',128);
recipe.integrator.maxdepth.value = 1;

%% Render

oiName = 'livingRoomWideAngle';
recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));

piWrite(recipe);
[oi, result] = piRender(recipe);

ieAddObject(oi);
oiWindow;

oi = oiSet(oi,'gamma',0.5);
