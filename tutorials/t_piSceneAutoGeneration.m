%% Automatically generate a scene.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end 

%% Initialize your cluster, we will upload all necessary resources to cloud buckets in advance
tic
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');
gcp = gCloud('configuration','gcp-pbrtv3-central-32cpu-120m');
% gcp = gCloud('configuration','gcp-pbrtv3-central-64cpu-120m');

toc
% test
gcp.renderDepth = 1;
gcp.renderMesh  =1;
% Show where we stand
str = gcp.configList;
%% clear job list

gcp.targets =[];
%% Scene Autogeneration by parameters
clearvars -except gcp 
%%
tic
sceneType = 'city4';
roadType = 'cross';
% sceneType = 'suburb1';
% roadType = 'straight_2lanes_parking';
% roadType = 'curve_6lanes_001';
trafficflowDensity = 'medium';
dayTime = 'cloudy';
% Choose a timestamp(1~360)  
timestamp = 90;
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
%%
dayTime = 'cloudy';
thisR_scene = piSkymapAdd(thisR_scene,dayTime);

% thisR_scene = piSkymapAdd(thisR_scene,'day');
%%
%% Add Camera
% load in trafficflow
load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_trafficflow.mat',road.roadinfo.name)),'trafficflow');
% from = thisR_scene.assets(3).position;
thisTrafficflow = trafficflow(timestamp);
CamOrientation = 270;
[from,to,ori] = piCamPlace('trafficflow',thisTrafficflow,...
                            'CamOrientation',CamOrientation);

thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up = [0;1;0];

%% Render parameter
% Default is a relatively low resolution (256).
% thisR_scene.set('camera','realistic');
% thisR_scene.set('lensfile',fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat'));
thisR_scene.set('film resolution',[1280 720]);
thisR_scene.set('pixel samples',1024);
thisR_scene.set('fov',45);
thisR_scene.film.diagonal.value=10;
thisR_scene.film.diagonal.type = 'float';
thisR_scene.integrator.maxdepth.value = 10;
thisR_scene.integrator.subtype = 'bdpt';
thisR_scene.sampler.subtype = 'sobol';

%% Write out the scene
if contains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.roadinfo.name));
end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_%s_%s_ts%d_%i_%i_%i_%i_%i_%0.0f.pbrt',sceneType,roadType,dayTime,timestamp,clock);
outputFile = fullfile(outputDir,filename);
thisR_scene.set('outputFile',outputFile);

%%
piWrite(thisR_scene,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow); 
%% tmp
% meshImage = piRender(thisR_scene,'renderType','mesh'); 
% vcNewGraphWin;imagesc(meshImage);colormap(jet);title('Mesh')
%% Set parameters for multiple scenes, same geometry and materials
gcp.uploadPBRT(thisR_scene,'material',true,'geometry',true,'resources',false);
addPBRTTarget(gcp,thisR_scene);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

%% Describe the targets

gcp.targetsList;
%%


%% This invokes the PBRT-V3 docker image
gcp.render();
%%
[podnames,result] = gcp.Podslist('print',false);
nPODS = length(result.items);
cnt = 0;
time = 0;
while cnt < length(nPODS)
    cnt = podSucceeded(gcp);
    pause(60);
    time = time+1;
    fprintf('******Elapsed Time: %d mins****** \n',time);
end
%{
%  You can get a lot of information about the job this way
podname = gcp.Podslist
gcp.PodDescribe(podname{2})
gcp.Podlog(podname{2});
%}
% Keep checking for the data, every 15 sec, and download it is there
%% Download files from gcloud bucket
[scene,scene_mesh]   = gcp.downloadPBRT();
disp('Data downloaded');

% Show it in ISET
tt=1;
for ii = 1:length(scene)
    scene_oi{ii} = piWhitepixelsRemove(scene{ii});
    scene_crop{ii} = oiCrop(scene_oi{ii},[160 90 1279 719]);
    ieAddObject(scene_crop{ii});
    sceneName = strsplit(scene_crop{ii}.name,'-');
    sceneName = sceneName{1};% get first cell
    
    oiSet(scene_crop{ii},'gamma',0.7);
    pngFigure = oiGet(scene_crop{ii},'rgb image');
    for tt = tt:tt+2
        if gcp.targets(tt).meshFlag && gcp.targets(tt).depthFlag
            Folder = fileparts(gcp.targets(tt).local);
            obj = piSceneAnnotate(gcp.targets(tt), thisR_scene, scene_crop{ii}, scene_mesh{ii});
        end
    end
    tt= tt+1;
    irradiancefile = sprintf('%s_ir.png',sceneName);
    imwrite(pngFigure,irradiancefile); % Save this scene file
    % process meshImage to label map
    % class map
    
    % Instance map
    
    % 2d Bounding box
    vcNewGraphWin;imagesc(scene_mesh{ii});colormap(jet);title('Mesh');
end
% oiWindow;oiSet(scene,'gamma',0.7);
oiWindow;
truesize;


%% Remove all jobs
% gcp.JobsRmAll();


%% Get bounding box

obj = piSceneAnnotate(thisR_scene, scene_mesh, irradianceImg, meshImage);

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