%% Test a pbrtv3 scene with material property modified.
%
% Creates an image with glass and a mirror and text and some objects.
% The materials are pulled in from Cinema 4D.  They can be edited for
% specularity and diffusivity and type.  More explanation of this will
% appear later.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Read pbrt_material files
FilePath = '/Users/zhenyiliu/Desktop/scene';
fname = fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

%% Change render quality
thisR.set('filmresolution',[640 480]);
thisR.set('pixelsamples',32);
thisR.integrator.maxdepth.value = 5;

%% Add skymap
piAddSkymap(thisR,'day')

%% Assign Materials and Color
% Check materials read from the file
piMaterialList(thisR);
% assign all the materials according to its name
piMaterialGroupAssign(thisR);
piMaterialList(thisR);

%% Read a geometry file exported by C4d and extract objects information
scene_1 = piGeometryRead(thisR);

%% Create two cars from flywheel
assets = piAssetsCreate(thisR,'ncars',2);

heading = -3;% along x a
side = -3;
% translate
assets(1).geometry = piObjectTranslate(assets(1).geometry,heading,side);
heading = 5;% along x a
side = 5;
% translate
assets(2).geometry = piObjectTranslate(assets(2).geometry,heading,side);

%% Assemble the objects with the scene here
scene_2 = piAssetsAdd(thisR,scene_1,assets);

%% Write out scene and materials
[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','scene',[n,e]));
piWrite(thisR); % 
%% Write out geometry -- 
piGeometryWrite(thisR, scene_2); 
%% Render irradiance
tic, irradianceImg = piRender(thisR); toc
ieAddObject(irradianceImg); sceneWindow;

%% Label the pixels by mesh of origin
meshImage = piRender(thisR,'renderType','mesh'); 
vcNewGraphWin;image(meshImage);colormap(jet);title('Mesh')

 %% Create a label map
 labelMap(1).name = 'car';
 labelMap(1).id = 7;
 labelMap(1).color = [0 0 1];
 labelMap(2).name='person';
 labelMap(2).id = 8;
 labelMap(2).color = [0 1 0];
 labelMap(3).name='truck';
 labelMap(3).id = 9;
 labelMap(3).color = [1 0 0];
 labelMap(4).name='bus';
 labelMap(4).id = 1;
 labelMap(4).color = [1 0 1];
 
%% Get bounding box

 obj = piBBoxExtract(thisR, scene_1, irradianceImg, meshImage, labelMap);
 %%
 
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