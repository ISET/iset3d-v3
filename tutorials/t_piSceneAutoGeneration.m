%% Automatically generate a scene.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end 

%% Initialize your cluster, we will upload all necessary resources to cloud buckets in advance
tic
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');
gcp = gCloud('configuration','gcp-pbrtv3-central-32cpu-120m');

toc
% test
gcp.renderDepth = 1;
gcp.renderMesh  =1;
% Show where we stand
str = gcp.configList;
%% clear job list

gcp.targets =[];
%% Scene Autogeneration by parameters
tic
sceneType = 'city2';
roadType = 'cross';
trafficflowDensity = 'medium';
dayTime = 'cloudy';
% Choose a timestamp(1~360)  
timestamp = 12;
% Normally we want only one scene per generation. 
nScene = 1;
% Choose whether we want to enable cloudrender 
cloudRender = 1; 
% Return an array of render recipe according to given number of scenes.
% takes about 150 seconds
[thisR_scene,road] = piSceneAuto('sceneType',sceneType,...
                                 'roadType',roadType,...
                                 'trafficflowDensity',trafficflowDensity,...
                                 'dayTime',dayTime,...
                                 'timeStamp',timestamp,...
                                 'nScene',nScene,...
                                 'cloudRender',cloudRender);
toc                      
thisR_scene = piSkymapAdd(thisR_scene,'cloudy');
%% Add Camera
% load in trafficflow
load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_trafficflow.mat',road.roadinfo.name)),'trafficflow');
% from = thisR_scene.assets(3).position;
% % from = from+ [100;0;0];
% to = from+[-20;0;0]; % look from Camera 2
% % bundle a camera on a random Car

% CamOrientation = 180;
[from,to,ori] = piCamPlace('trafficflow',trafficflow,...
                           'timestamp',timestamp);
% position
% from = thisR_scene.get('from');
% to   = thisR_scene.get('to');
thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up = [0;1;0];
% thisR_scene.set('from',from + [0 50 -20]);
% thisR_scene.set('to',to + [0 0 100]);

%% Render parameter
% Default is a relatively low resolution (256).
% thisR_scene.set('camera','realistic');
% thisR_scene.set('lensfile',fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat'));
thisR_scene.set('film resolution',[1280 720]);
thisR_scene.set('pixel samples',128);
thisR_scene.set('fov',45);
thisR_scene.film.diagonal.value=10;
thisR_scene.film.diagonal.type = 'float';
thisR_scene.integrator.maxdepth.value = 10;
thisR_scene.integrator.subtype = 'path';
thisR_scene.sampler.subtype = 'sobol';
% Set up data for upload

%% Write out the scene
outputDir = fullfile(piRootPath,'local','city2_cross_4lanes_002');
if ~exist(outputDir,'dir'), mkdir(outputDir); end
% [p,n,e] = fileparts(fname); 
% thisR_scene.outputFile = fullfile(outputDir,sprintf('%s-wide56deg6mm-%d%s',n,time,e));
filename = sprintf('%s_%s_%s_ts%d.pbrt',sceneType,roadType,dayTime,timestamp);
outputFile = fullfile(outputDir,filename);
thisR_scene.set('outputFile',outputFile);
%%
piWrite(thisR_scene,'creatematerials',true,'overwriteresources',false,'lightsFlag',false); 

%% Set parameters for multiple scenes, same geometry and materials
gcp.uploadPBRT(thisR_scene,'material',true,'geometry',true,'resources',false);
addPBRTTarget(gcp,thisR_scene);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

%% Describe the targets

gcp.targetsList;

%% This invokes the PBRT-V3 docker image
gcp.render();
%%
cnt = 0;
while cnt < length(gcp.targets)
    cnt = podSucceeded(gcp);
    pause(5);
end
%{
%  You can get a lot of information about the job this way
podname = gcp.Podslist
gcp.PodDescribe(podname{2})
gcp.Podlog(podname{2});
%}
% Keep checking for the data, every 15 sec, and download it is there
%% Download files from gcloud bucket
[scene,scene_mesh]   = gcp.downloadPBRT(thisR_scene);
disp('Data downloaded');

% Show it in ISET
for ii = 1:length(scene)
    ieAddObject(scene{ii});
end
% oiWindow;oiSet(scene,'gamma',0.7);
sceneWindow;
sceneSet(scene,'gamma',0.7);

vcNewGraphWin;imagesc(scene_mesh);colormap(jet);title('Mesh')

%% Remove all jobs
% gcp.JobsRmAll();

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

obj = piBBoxExtract(thisR_scene, scene_mesh, irradianceImg, meshImage, labelMap);

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