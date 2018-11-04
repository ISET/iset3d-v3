%% Change the material properties in a V3 PBRT scene
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname,'version',3);

%% Change render quality

% [800 600] 32 - takes around 30 seconds to render on a machine with 8 cores.
% [300 150] 16 -

thisR.set('filmresolution',[800 600]);
thisR.set('pixelsamples',16);

%% List material library
piSkymapAdd(thisR,'noon');
% it's helpful to check what current material properties are.
piMaterialList(thisR);
piMaterialGroupAssign(thisR);
fprintf('A library of materials\n\n');  % Needs a nicer print method
disp(thisR.materials.lib)

% This value determines the number of bounces.  To have glass we need
% to have at least 2 or more.  We start with only 1 bounce, so it will
% not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

%% Write out the pbrt scene file, based on thisR.
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','SimpleSceneExport',[n,e]));

% material.pbrt is supposed to overwrite itself.
piWrite(thisR);

%% Render
tic, scene = piRender(thisR,'render type','radiance'); toc
tic, scene = piRender(thisR); toc % By default, you will have depth map rendered with radiance image;

scene = sceneSet(scene,'name',sprintf('Glass on (%d)',thisR.integrator.maxdepth.value));
ieAddObject(scene); sceneWindow;

%% Change the sphere to glass

% For this scene, the BODY material is attached to ???? object.  We
% need to parse the geometry file to make sure.  This will happen, but
% has not yet.
target = thisR.materials.lib.plastic;    % Give it a chrome spd
rgbkr  = [0.5 0.5 0.5];              % Reflection
rgbkd  = [0.5 0.5 0.5];              % Scatter

piMaterialAssign(thisR, 'GLASS', target,'rgbkd',rgbkd,'rgbkr',rgbkr);
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','SimpleSceneExport',[n,'1',e]));
piWrite(thisR,'creatematerials',true);

%% Render again

tic, scene = piRender(thisR,'render type','radiance'); toc
scene = sceneSet(scene,'name','Glass off');
ieAddObject(scene); sceneWindow;

%%