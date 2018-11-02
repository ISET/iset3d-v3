%% Automatically generate a scene.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end 

%% Initialize your cluster, we will upload all necessary resources to cloud buckets in advance
tic
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');
% gcp = gCloud('configuration','gcp-pbrtv3-central-64cpu-120m');
% gcp-pbrtv3-central-high-64cpu-flywheel
% gcp-pbrtv3-central-32cpu-120m-flywheel
toc
% test
gcp.renderDepth = 1;
gcp.renderMesh  = 1;
% Show where we stand
str = gcp.configList;
%
st = scitran('stanfordlabs');

 %% clear job list

gcp.targets =[];
%% Scene Autogeneration by parameters
clearvars -except gcp st thisR_scene
%%
tic
sceneType = 'city3';
% roadType = 'cross';
% sceneType = 'highway';
roadType = 'cross';
% roadType = 'highway_straight_4lanes_001';
trafficflowDensity = 'medium';
dayTime = 'noon';
% Choose a timestamp(1~360)  
timestamp = 95;
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
                                 'cloudRender',cloudRender,...
                                 'scitran',st);
toc

%% Add a skymap and add SkymapFwInfor to fwList
dayTime = 'noon';
[thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];

%%
%% Bundle the camera to a ramdom selected car from trafficflow
% load in trafficflow
load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',road.name,trafficflowDensity)),'trafficflow');
% from = thisR_scene.assets(3).position;
thisTrafficflow = trafficflow(timestamp);
nextTrafficflow = trafficflow(timestamp+1);
CamOrientation  = 270;
[thisCar,from,to,ori] = piCamPlace('thisTrafficflow',thisTrafficflow,...
                           'CamOrientation',CamOrientation);
thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up   = [0;1;0];
% Add motion info
thisR_road  = piMotionBlurEgo(thisR_scene,...
                              'fps',30,...
                              'nextTrafficflow',nextTrafficflow,...
                              'thisCar',thisCar);

%% Render parameter
% Default is a relatively low samples/pixel (256).
% thisR_scene.set('camera','realistic');
% thisR_scene.set('lensfile',fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat'));
xRes = 1280;
yRes = 720;
pSamples = 256;
thisR_scene.set('film resolution',[xRes yRes]);
thisR_scene.set('pixel samples',pSamples);
thisR_scene.set('fov',45);
thisR_scene.film.diagonal.value=10;
thisR_scene.film.diagonal.type = 'float';
thisR_scene.integrator.maxdepth.value = 10;
thisR_scene.integrator.subtype = 'bdpt';
thisR_scene.sampler.subtype = 'sobol';
% thisR_scene.integrator.lightsamplestrategy.type = 'string';
% thisR_scene.integrator.lightsamplestrategy.value = 'spatial';
% Write out the scene
if contains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
    thisR_scene.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.name));
    thisR_scene.inputFile = fullfile(outputDir,[strcat(sceneType,'_',road.name),'.pbrt']);
end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_sp%d_%s_%s_ts%d_from_%0.2f_%0.2f_%0.2f_ori_%0.2f_%i_%i_%i_%i_%i_%0.0f.pbrt',sceneType,pSamples,roadType,dayTime,timestamp,thisR_scene.lookAt.from,ori,clock);
sceneInfo.sceneType = sceneType;
sceneInfo.resolution = [xRes yRes];
sceneInfo.pSamples  = pSamples;
sceneInfo.roadType  = roadType;
sceneInfo.dayTime   = dayTime;
sceneInfo.timestamp = timestamp;
sceneInfo.lookAt    = thisR_scene.lookAt;
sceneInfo.ori       = ori;
outputFile = fullfile(outputDir,filename);
thisR_scene.set('outputFile',outputFile);

%%
piWrite(thisR_scene,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow); 

% fwUploadPBRT upload scene.pbrt file to up
gcp.fwUploadPBRT(thisR_scene,'scitran',st,'road',road);

%
addPBRTTarget(gcp,thisR_scene,sceneInfo);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

%% Describe the targets

gcp.targetsList;

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
gcp.PodDescribe(podname{1})
 gcp.Podlog(podname{1});
%}
% Keep checking for the data, every 15 sec, and download it is there
%% Download files from gcloud bucket
[scene,scene_mesh,label]   = gcp.fwDownloadPBRT('scitran',st);
disp('Data downloaded');

%% Show it in ISET

for ii =1:length(scene)
    scene_oi{ii} = piWhitepixelsRemove(scene{ii});
    xCrop = oiGet(scene_oi{ii},'cols')-xRes;
    yCrop = oiGet(scene_oi{ii},'rows')-yRes;
    scene_crop{ii} = oiCrop(scene_oi{ii},[xCrop/2 yCrop/2 xRes-1 yRes-1]);
%     scene_crop{ii}.depthMap = imcrop(scene_crop{ii}.depthMap,[xCrop/2 yCrop/2 xRes-1 yRes-1]);
    ieAddObject(scene_crop{ii});
    oiSet(scene_crop{ii},'gamma',0.85);
    pngFigure = oiGet(scene_crop{ii},'rgb image');
    % get ground truth infomation, usually it takes about 15 secs 
    tic
    scene_label{ii} = piSceneAnnotation(scene_mesh{ii},label{ii},st);toc
    [sceneFolder,sceneName]=fileparts(label{ii});
    sceneName = strrep(sceneName,'_mesh','');
    irradiancefile = fullfile(sceneFolder,[sceneName,'_ir.png']);
    imwrite(pngFigure,irradiancefile); % Save this scene file
    
    %% Visulization
    figure;
    imshow(pngFigure);
    fds = fieldnames(scene_label{ii}.bbox2d);
    for kk = 5
    detections = scene_label{ii}.bbox2d.(fds{kk});
    r = rand; g = rand; b = rand;    
    if r< 0.2 && g < 0.2 && b< 0.2
        r = 0.5; g = rand; b = rand;
    end
    for jj=1:length(detections)
        pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
            detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
            detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];
        
        rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',2);
        t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,num2str(jj));
       %t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,fds{kk});
        t.Color = [0 0 0];
        t.BackgroundColor = [r g b];
        t.FontSize = 15;
    end
    end
    drawnow;
    
end
oiWindow;
truesize;


%% Remove all jobs
% gcp.JobsRmAll();

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