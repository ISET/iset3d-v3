%% s_whiteSceneV3
% Render a blank white scene for calibration purposes
%
% Description:
%    Render a blank white scene for the purpose of calibration.
%
% History:
%    XX/XX/17  TL   SCIEN 2017
%    03/19/19  JNM  Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read the pbrt scene
% The scene consists of an infinite light source and a white disk with
% radius 1 meter placed at 1 meter away from the camera.
fname = fullfile(piRootPath, 'data', 'whiteScene', 'whiteSceneV3.pbrt');

% Read the main scene pbrt file. Return it as a recipe
recipe = piRead(fname, 'version', 3);

%% Add a camera
recipe.camera = struct('type', 'Camera', 'subtype', 'realistic');

lensFile = fullfile(piRootPath, 'scripts', 'pbrtV3', ...
    'wide.56deg.6.0mm_v3.dat');
% Attach the lens
recipe.camera.lensfile.value = lensFile; % mm
recipe.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
recipe.camera.aperturediameter.value = 10; % mm (something very large)
recipe.camera.aperturediameter.type = 'float';

% Focus at roughly meter away.
recipe.camera.focusdistance.value = 1.5; % meter
recipe.camera.focusdistance.type = 'float';

% Use a 1" sensor size
recipe.film.diagonal.value = 16;
recipe.film.diagonal.type = 'float';

% Change the sampler
recipe.sampler.subtype = 'halton';

recipe.set('filmresolution', [2048 2048]);
recipe.set('pixelsamples', 2048);
recipe.integrator.maxdepth.value = 1;

%% Write out a new pbrt file
% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath, 'local', 'whiteScene');

% We copy the pbrt scene directory to the working directory
[p, n, e] = fileparts(fname);
copyfile(p, workingDirectory);

% Write the edited pbrt scene file, based on recipe, to the working dir.
recipe.outputFile = fullfile(workingDirectory, [n, e]);
piWrite(recipe);

%% Render with the Docker container
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
oi = piRender(recipe); %, 'reuse', true);

% Show it in ISET
ieAddObject(oi);
oiWindow;
