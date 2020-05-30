%% Test a pbrtv3 scene with material property modified.
%
% Creates an image with glass and a mirror and text and some assets.
% The materials are pulled in from Cinema 4D.  They can be edited for
% specularity and diffusivity and type.  More explanation of this will
% appear later.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the scene and create a render recipe 

fname = fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% The render recipe here loads in the scene file in PBRT.  
thisR = piRead(fname,'version',3);

%% Set the rendering quality

% The spatial resolution of the film
thisR.set('film resolution',[640 480]);

% The number of rays that we cast per pixel
thisR.set('pixel samples',8);

% Algorithms used by PBRT V3 to render
thisR.integrator.maxdepth.value = 10;
thisR.integrator.subtype = 'bdpt';
thisR.sampler.subtype = 'sobol';

%% Add skymap

% Outdoor scenes with a sky map are much more realistic than scenes
% with a few specific light sources.
%
% We are storing sky maps in the ISET3D repository.  At some point we
% will also put them on Flywheel.
thisR = piSkymapAdd(thisR,'noon');

%% Assign Materials and Color

% The recipe already includes materials.  This prints out the ones
% that are in the recipe.
piMaterialList(thisR);

% Assign from the material names to the numerical material properties.
% These are placed in the recipe.
piMaterialGroupAssign(thisR);

% Print again just to check.
piMaterialList(thisR);

%% Read a geometry file exported by C4d and extract asset information

% The return is a struct that contains the position, rotating, size
% and nested structures defining the asset information.  This can run
% on any scene exported from Cinema 4D.
scene_1 = piGeometryRead(thisR);

%% Add two cars from the Flywheel database

assets = piFWAssetCreate('ncars',2,'nbuses',1);


%% Move assets

% Cars are built into the database with a default orientation and
% position.  The coordinate frame (x,y,z) is arranged so that the
% camera is on the z-axis at a negative z value.  The implicit image
% of the car for the stored asset data is in the (x,y) plane with the
% car front facing in the positive x direction and the top of the car
% in the positive y direction. (This is called left hand coordinates).
%
% Straight out of the database the asset nodes are centered at (0,0,0).  
%

% The translation sets up a new position by translating the mesh
%
%   current  = [x,y,z] -> [x + heading, y, z + heading]
%

% Asset 1 - translate
heading = 2.55;  % Do we translate the position of the asset?  
side    = 0;  % Which side is exposed to the camera
Translation_1 = [heading 0 side];

assets(1).geometry = piAssetTranslate(assets(1).geometry,Translation_1);

% You could rotate if you like
rotation = -90;
assets(1).geometry = piAssetRotate(assets(1).geometry,rotation);
% 
% Asset 2 - translate
heading = -2.55; 
side    = 10;
Translation_2 = [heading 0 side];
assets(2).geometry = piAssetTranslate(assets(2).geometry,Translation_2);

% You could rotate if you like
rotation = 90;
assets(2).geometry = piAssetRotate(assets(2).geometry,rotation);

%% Assemble the objects with the scene here

[thisR_scene,scene_2] = piAssetAddBatch(thisR,scene_1,assets);

%% Write out scene and materials

[~,n,e] = fileparts(fname); 
thisR_scene.set('outputFile',fullfile(piRootPath,'local','cartest',[n,e]));
piWrite(thisR_scene); 

%% Write out geometry -- 
% lights are turned off for default.
piGeometryWrite(thisR_scene, scene_2,'lightsFlag',false); 

%% Render irradiance

tic, irradianceImg = piRender(thisR_scene); toc
ieAddObject(irradianceImg); sceneWindow;

%% Label the pixels by mesh of origin
meshImage = piRender(thisR_scene,'renderType','mesh'); 
vcNewGraphWin;imagesc(meshImage);colormap(jet);title('Mesh')

%% Create a label map
labelMap(1).name = 'road';
labelMap(1).id = 1;
labelMap(1).name = 'car';
labelMap(1).id = 2;
labelMap(1).color = [0 0 1];
labelMap(2).name='person';
labelMap(2).id = 3;
labelMap(2).color = [0 1 0];
labelMap(3).name='truck';
labelMap(3).id = 4;
labelMap(3).color = [1 0 0];
labelMap(4).name='bus';
labelMap(4).id = 5;
labelMap(4).color = [1 0 1];

%% Get bounding box

obj = piBBoxExtract(thisR_scene, scene_2, irradianceImg, meshImage, labelMap);

% obj = piBBoxExtract(thisR_scene, scene_2, assets, irradianceImg, meshImage, labelMap);
 
%% Change the camera lens
%{ 
% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% thisR.version can tell us, but piCameraCreate does not take a thisR as
% input. For now let's put things in manually. 

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat');
thisR.camera.lensfile.value = lensFile;
% exist(lensFile,'file')

% Attach the lens
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 1; % mm
thisR.camera.aperturediameter.type = 'float';

% Focus at roughly meter away. 
thisR.camera.focusdistance.value = 1; % meter
thisR.camera.focusdistance.type = 'float';

% Use a 1" sensor size
thisR.film.diagonal.value = 16; 
thisR.film.diagonal.type = 'float';
%}