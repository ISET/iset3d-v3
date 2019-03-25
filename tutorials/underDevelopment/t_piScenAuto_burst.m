%% Automatically generate an automotive scene
%
%    t_piSceneAutoGeneration
%
% Description:
%   Illustrates the use of ISETCloud, ISET3d, ISETCam and Flywheel to
%   generate driving scenes.  This example works with the PBRT-V3
%   docker container (not V2).
%
% Author: ZL
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud, SUMO

%{
% Example - let's make a small example to run, if possible.  Say two
cars, no buildings.  If we can make it run in 10 minutes,
that would be good.
%
%}

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

% The Google cloud platform (gcp) includes a large number of
% parameters that define the cluster. We also use the gcp object to
% store certain parameters about the rendering.

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');
% gcp = gCloud('configuration','gcp-pbrtv3-central-64cpu-120m');
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');
toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     =[];      % clear job list

% Print out the gcp parameters for the user
str = gcp.configList;

%% Helpful for debugging
% clearvars -except gcp st thisR_scene

%%  Example scene creation
%
% This is where we pull down the assets from Flywheel and assemble
% them into an asset list.  That is managed in piSceneAuto

tic
sceneType = 'city4';
% roadType = 'cross';
% sceneType = 'highway';
% roadType = 'cross';
% roadType = 'highway_straight_4lanes_001';
roadType = 'straight_2lanes_parking';

trafficflowDensity = 'medium';

dayTime = 'noon';

% Choose a timestamp(1~360), which is the moment in the SUMO
% simulation that we record the data.  This could be fixed or random,
% and since SUMO runs
timestamp = 21;

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

% fwList contains information about objects in Flywheel that you will
% use to render this scene.  It is a long string of the container IDS
% and file names.
%
dayTime = 'noon';
[thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];

%% Add a camera to one of the cars

% To place the camera, we find a car and place a camera at the front
% of the car.  We find the car using the trafficflow information.
%
load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',road.name,trafficflowDensity)),'trafficflow');
thisTrafficflow = trafficflow(timestamp);
nextTrafficflow = trafficflow(timestamp+1);
%%

CamOrientation =270;
[thisCar,from,to,ori] = piCamPlace('thistrafficflow',thisTrafficflow,...
    'CamOrientation',CamOrientation);

thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up = [0;1;0];
thisVelocity = thisCar.speed
%%

thisR_scene = piMotionBlurEgo(thisR_scene,'nextTrafficflow',nextTrafficflow,...
                               'thisCar',thisCar,...
                               'fps',125); % set shutter time 8ms.
%% Render parameters
% This could be set by default, e.g.,

% Could look like this
%  autoRender = piAutoRenderParameters;
%  autoRender.x = y;
%
% Default is a relatively low samples/pixel (256).

% thisR_scene.set('camera','realistic');
% thisR_scene.set('lensfile',fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat'));
xRes = 1280;% for poster
yRes = 720;
pSamples = 128;
thisR_scene.set('film resolution',[xRes yRes]);
thisR_scene.set('pixel samples',pSamples);
thisR_scene.set('fov',45);
thisR_scene.film.diagonal.value=10;
thisR_scene.film.diagonal.type = 'float';
thisR_scene.integrator.maxdepth.value = 5;
thisR_scene.integrator.subtype = 'bdpt';
thisR_scene.sampler.subtype = 'sobol';
thisR_scene.integrator.lightsamplestrategy.type = 'string';
thisR_scene.integrator.lightsamplestrategy.value = 'spatial';
%%
nimages = 8;
% for the first image we do nothing
% start from the second image, we update the status of the car by a time of
% 0.033s, the activetranform will be
% incremented by amount of (posTo-posFrom)/30;
t_readOut = 1/30;
for ii = 1:nimages
    egoFrom.pos    = thisR_scene.camera.motion.activeTransformStart.pos;
    egoFrom.rotate = thisR_scene.camera.motion.activeTransformStart.rotate;
    egoTo.pos      = thisR_scene.camera.motion.activeTransformEnd.pos;
    egoTo.rotate   = thisR_scene.camera.motion.activeTransformEnd.rotate;
    %% update the status of the ego vehicle
    egoAdd.pos  = t_readOut*(egoTo.pos - egoFrom.pos);
    egoAdd.rotate = t_readOut* (egoTo.rotate - egoFrom.rotate);
%     thisR_scene.camera.motion.activeTransformStart.pos    = ...
%         thisR_scene.camera.motion.activeTransformStart.pos + egoAdd.pos;
%     thisR_scene.camera.motion.activeTransformStart.rotate = ...
%         thisR_scene.camera.motion.activeTransformStart.rotate + egoAdd.rotate;
%     thisR_scene.camera.motion.activeTransformEnd.pos      = ...
%         thisR_scene.camera.motion.activeTransformEnd.pos + egoAdd.pos;
%     thisR_scene.camera.motion.activeTransformEnd.rotate   = ...
%         thisR_scene.camera.motion.activeTransformEnd.rotate + egoAdd.rotate;
    thisR_scene.lookAt.from = thisR_scene.lookAt.from + egoAdd.pos;
    %% deal with other moving objects 
    for jj = 1: length(thisR_scene.assets)
        if ~isempty(thisR_scene.assets(jj).motion)
           objFrom.pos = thisR_scene.assets(jj).position;
           objTo.pos = thisR_scene.assets(jj).motion.position;
           objAdd.pos  = t_readOut*(objTo.pos - objFrom.pos);
           thisR_scene.assets(jj).position = ...
               thisR_scene.assets(jj).position + objAdd.pos;
           thisR_scene.assets(jj).motion.position = ...
               thisR_scene.assets(jj).motion.position + objAdd.pos;
           
           if isfield(thisR_scene.assets(jj).motion,'rotate') 
           objFrom.rotate = thisR_scene.assets(jj).rotate;
           objTo.rotate   = thisR_scene.assets(jj).motion.rotate;
           objAdd.rotate  = t_readOut*(objTo.rotate - objFrom.rotate);
           thisR_scene.assets(jj).rotate = ...
               thisR_scene.assets(jj).rotate + objAdd.rotate;
           thisR_scene.assets(jj).motion.rotate = ...
               thisR_scene.assets(jj).motion.rotate + objAdd.rotate;
           end
        end
    end
%% Write out the scene into a PBRT file

if contains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
    thisR_scene.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.name));
    thisR_scene.inputFile = fullfile(outputDir,[strcat(sceneType,'_',road.name),'.pbrt']);
end

% We might use md5 to has the parameters and put them in the file
% name.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('burst_%d.pbrt',ii);
thisR_scene.outputFile = fullfile(outputDir,filename);


% Do the writing
piWrite(thisR_scene,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

% Upload the information to Flywheel.
gcp.fwUploadPBRT(thisR_scene,'scitran',st,'road',road);

% Tell the gcp object about this target scene
addPBRTTarget(gcp,thisR_scene);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));
end
%% Describe the target to the user

gcp.targetsList;

%% This invokes the PBRT-V3 docker image

gcp.render();
%% save gcp.targets

%% Monitor the processes on GCP

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

%% Download files from Flywheel
disp('*** Data downloading...');
[scene,scene_mesh,label]   = gcp.fwDownloadPBRT('scitran',st);
disp('*** Data downloaded');

%% Show the rendered image using ISETCam

% Some of the images have rendering artifiacts.  These are partially
% removed using piFireFliesRemove
%
for ii =1:length(scene)
    scene_corrected{ii} = piFireFliesRemove(scene{ii});
    ieAddObject(scene_corrected{ii}); 
    sceneWindow;
    sceneSet(scene_corrected{ii},'gamma',0.75);
    %oiSet(scene_corrected{ii},'gamma',0.85);
    pngFigure = oiGet(scene_corrected{ii},'rgb image');
    figure;
    imshow(pngFigure);
    % Get the class labels, depth map, bounding boxes for ground
    % truth. This usually takes about 15 secs
    tic
    scene_label{ii} = piSceneAnnotation(scene_mesh{ii},label{ii},st);toc
    [sceneFolder,sceneName]=fileparts(label{ii});
    sceneName = strrep(sceneName,'_mesh','');
    irradiancefile = fullfile(sceneFolder,[sceneName,'_ir.png']);
    imwrite(pngFigure,irradiancefile); % Save this scene file

%     % Visualization of the ground truth bounding boxes
%     vcNewGraphWin;
%     imshow(pngFigure);
%     fds = fieldnames(scene_label{ii}.bbox2d);
%     for kk = 1
%         detections = scene_label{ii}.bbox2d.(fds{kk});
%         r = rand; g = rand; b = rand;
%         if r< 0.2 && g < 0.2 && b< 0.2
%             r = 0.5; g = rand; b = rand;
%         end
%         for jj=1:length(detections)
%             pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
%                 detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
%                 detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];
%             
%             rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',2);
%             t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,num2str(jj));
%             t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,fds{kk});
%             t.Color = [0 0 0];
%             t.BackgroundColor = [r g b];
%             t.FontSize = 15;
%         end
%     end
%     drawnow;

end
sceneWindow;
truesize;

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.JobsRmAll();

%% END

