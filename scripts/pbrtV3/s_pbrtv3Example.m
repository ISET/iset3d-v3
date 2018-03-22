%% Test a simple pbrtv3 scene (teapot).
% 
% TL SCIEN 2017

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
recipe = piRead(fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt'),'version',3);

%% Add a realistic camera
recipe.set('camera','realistic');
recipe.set('lensfile',fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal',35); 

%% Change render quality
recipe.set('filmresolution',[128 128]);
recipe.set('pixelsamples',128);
recipe.set('maxdepth',1); % Number of bounces

%% Render
% ~ 20 seconds on an 8 core machine
oiName = 'teapotTest';
recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));

piWrite(recipe);
[oi, result] = piRender(recipe);

ieAddObject(oi);
oiWindow;

oi = oiSet(oi,'gamma',0.5);

