%% Test a pbrtv3 scene with material property modified.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Read the scene and create a render recipe 
% fname = fullfile(piRootPath,'data','V3','checkerboard','checkerboard.pbrt');
fname = '/Users/zhenyiliu/Desktop/cross/cross.pbrt';
if ~exist(fname,'file'), error('File not found'); end
% The render recipe here loads in the scene file in PBRT.  
thisR_road = piRead(fname,'version',3);
%% Set the rendering quality
thisR_road.set('film resolution',[1920 1080]);
thisR_road.set('pixel samples',8);
thisR_road.integrator.maxdepth.value = 10;
thisR_road.integrator.subtype = 'bdpt';
thisR_road.sampler.subtype = 'sobol';
%% Add skymap
thisR_road = piSkymapAdd(thisR_road,'dusk');
%% Assign Materials and Color
piMaterialGroupAssign(thisR_road);
piMaterialList(thisR_road);
%% Add buildings on road
% buildingList = piAssetCreate('nbuilding',8);% Create a building list from lib/flywheel
buildingList = piBuildingListCreate;
buildinglib.building = buildingList;
% Create a building position list
buildingPosList = piBuildingPosList(buildinglib.building,thisR_road);
buildingPlaced = piBuildingPlace(buildinglib,buildingPosList);
buildingplaced.building = buildingPlaced;
% Add buildings on road
thisR_building = piAssetAdd(thisR_road, buildingplaced);
%% Add two cars from the Flywheel database

% assets = piAssetCreate('ncars',2,'nbuses',2);

%% generate trafficflow from Sumo simulator
SumoInputPath = fullfile(piRootPath,'data','sumo_input','cross_state.xml');
trafficflow = piSumoRead(SumoInputPath);

piTrafficflowDisplay(trafficflow);
% Roadtype = piRoadTypeGeneration('name','cross');
% trafficflow = piTrafficflowGeneration(Roadtype);

assetsPlaced = piAssetPlace(trafficflow,'timestamp',10);

%% Assemble the objects with the scene here
for ii = 1: length(assetsPlaced)
thisR_scene{ii} = piAssetAdd(thisR_road,assetsPlaced{ii});
end
thisR_scene = thisR_scene{1};
% thisR_scene= piAssetAdd(thisR_road,assets);
%% Write out scene and materials

[~,n,e] = fileparts(fname); 
% gray = '/Volumes/group/data/NN_Camera_Generalization/Pbrt_Assets_Generation/pbrt_assets/tmp_zhenyi';
% thisR_scene.set('outputFile',fullfile(gray,'cartest',[n,e]));
thisR_scene.set('outputFile',fullfile(piRootPath,'local','cross_road',[n,e]));
piWrite(thisR_scene); % 

% thisR_road.set('outputFile',fullfile(piRootPath,'local','cross',[n,e]));
% piWrite(thisR_road); % 

%% Write out geometry -- 
% lights are turned off for default.
% piGeometryWrite(thisR_scene, scene_2,'lightsFlag',ture); 
% piGeometryWrite(thisR_scene, scene_2); 

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