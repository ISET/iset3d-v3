%% Test a pbrtv3 scene with material property modified.
%
% Creates an image with glass and a mirror and text and some objects.
% The materials are pulled in from Cinema 4D.  They can be edited for
% specularity and diffusivity and type.  More explanation of this will
% appear later.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
% FilePath = fullfile(piRootPath,'data','ChessSet');
FilePath = '/Volumes/group/wandell/data/NN_Camera_Generalization/pbrt_assets/car/car_2';
% FilePath = '/Users/zhenyiliu/git_repo/pbrt-v3-scenes/vw-van';
fname = fullfile(FilePath,'Car_2.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname,'version',3);


%% Change render quality

% [800 600] 32 - takes around 30 seconds to render on a machine with 8 cores.
% [300 150] 16 -

thisR.set('filmresolution',[640 480]);
thisR.set('pixelsamples',32);

thisR.integrator.maxdepth.value = 5;  %Multiple bounces of a ray allowed
% Add skymap
piAddSkymap(thisR,'day')
%% Assign Materials and Color

%it's helpful to check what current material properties are.
piMaterialList(thisR);
% assign all the materials according to its name
piMaterialGroupAssign(thisR);
% Check again.
piMaterialList(thisR);


%% Read a geometry file exported by C4d and extract objects information
scene_1 = piGeometryRead(thisR);

%% Write out
piGeometryWrite(thisR, scene_1);

%%
[~,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','car_2',[n,e]));
piWrite(thisR);

%% Render
tic, scene = piRender(thisR); toc

ieAddObject(scene); sceneWindow;


%% Add a traffic sign

trafficsign= piAssetsCreate('/Volumes/group/wandell/data/NN_Camera_Generalization/pbrt_assets/traffic_signs/schoolzone/schoolzone.pbrt');
piAssetsAdd(thisR, scene, trafficsign, car)

for ii= 1:length(fieldnames(thisR_sign.materials.list))
    index = length(fieldnames(thisR.materials.list));
    thisR.materials.list(index+ii)= thisR_sign.materials.list.(ii);
end
scene_1(3)=trafficsign;
scene_1(3).position = [0 1.84 -5];
scene_1(2).rotate = [45 0 1 0];
thisR.lookAt.from = [0 0 -20];
%% Write out
piGeometryWrite(thisR, scene_1);
%%
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','car_1',[n,e]));
piWrite(thisR);

%%
tic, scene = piRender(thisR); toc

ieAddObject(scene); sceneWindow;


%% Label the pixels by mesh of origin

meshImage = piRender(thisR,'renderType','mesh'); % This just returns a 2D image
vcNewGraphWin;imshow(meshImage)
image(meshImage);colormap(jet);title('Mesh')

% materialImage = piRender(thisR,'renderType','material'); % This just returns a 2D image
% vcNewGraphWin; 
% imagesc(materialImage); colormap(jet); title('Material')

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
 
 
%% Draw a bounding box
%  meshfile = '/Users/zhenyiliu/git_repo/iset3d/local/truck/renderings/Prius_mesh.dat';

 %  [classMap, instanceMap] = mergeMetadata(meshfile,labelMap);
 %  detections = getBndBox(classMap,instanceMap,labelMap,sceneMetadata(i));
 obj = piBBoxExtract(thisR, scene_1, scene, meshImage, labelMap);
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