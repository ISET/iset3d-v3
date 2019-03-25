%% s_yeahrightScene
% Render a the yeahright scene for calibration purposes
%
% Description:
%    Render a yeahright scene for calibration purposes. This scene uses the
%    integrator subtype 'path' with 3 bounces. Generates a reflection
%    scene, and uses a perspective camera, not a lens.
%
% History:
%    XX/XX/17  TL/BW  SCIEN 2017
%    03/25/19  JNM    Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Read the pbrt scene
fname = fullfile(piRootPath, 'data', 'yeahright', 'yeahright.pbrt');
if ~exist(fname, 'file'), piPBRTFetch('yeahright', 'pbrtversion', 3); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Add a camera
%{
thisR = recipeSet(thisR, 'camera', 'realistic');
thisR.camera.specfile.value = ...
    fullfile(piRootPath, 'data', 'lens', 'dgauss.22deg.50.0mm.dat');
thisR.camera.filmdistance.value = 50;
thisR.camera.aperture_diameter.value = 8;
%}

% Make the sensor really big so we can see the edge of the lens and the
% vignetting.
% This takes roughly a 90 seconds to render on a 6 core machine.
% Why does this take so long? There seems to be a lot of NaN returns for
% the radiance, maybe tracing the edges of the lens is difficult in some
% way? The weighting of the rays might also be incorrect in PBRTv2.
% thisR.camera.filmdiag.value = 100;
thisR = recipeSet(thisR, 'rays per pixel', 256);
thisR = recipeSet(thisR, 'film resolution', 128);
thisR = recipeSet(thisR, 'bounces', 3);

%% Write out a new pbrt file
[p, n, e] = fileparts(fname);
thisR.outputFile = fullfile(piRootPath, 'local', 'yeahright', [n, e]);
piWrite(thisR, 'overwrite pbrt file', true, 'overwrite resources', true);

%% Render with the Docker container
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
scene = piRender(thisR); %, 'reuse', true);

% Show it in ISET
ieAddObject(scene);
sceneWindow;

%% End