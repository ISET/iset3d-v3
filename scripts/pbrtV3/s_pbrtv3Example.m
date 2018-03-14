%% Test a simple pbrtv3 scene (teapot).
% 
% TL SCIEN 2017

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
recipe = piRead(fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt'),'version',3);

%% Change render quality
recipe.set('filmresolution',[128 128]);
recipe.set('pixelsamples',128);
recipe.set('maxdepth',1); % Number of bounces

%% Render
% ~ 6 seconds on an 8 core machine

oiName = 'teapotTest';
recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));

piWrite(recipe);
[scene, result] = piRender(recipe);

ieAddObject(scene);
sceneWindow;

scene = sceneSet(oi,'gamma',0.5);
