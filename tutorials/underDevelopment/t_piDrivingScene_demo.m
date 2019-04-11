%% Automatically assemble an automotive scene and render using Google Cloud
%
%    t_piDrivingScene_demo
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

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     =[];  % clear job list

% Print out the gcp parameters for the user
str = gcp.configList;

%%  Example scene creation

% Avaliable sceneType: city1, city2, city3, city4, citymix, suburb
sceneType = 'city3';

% Avaliable roadType: 
%                   curve_6lanes_001
%                   straight_2lanes_parking
%                   city_cross_6lanes_001
%                   city_cross_6lanes_001_construct
%                   city_cross_4lanes_002
roadType = 'city_cross_4lanes_002';


% Avaliable trafficflowDensity: low, medium, high
trafficflowDensity = 'medium';

% Choose a timestamp(1~360), which is the moment in the SUMO
% simulation that we record the data. 
timestamp = 122;
% Choose whether we want to enable cloudrender
cloudRender = 1;
%
% Only for this Demo: Copy trafficflow from data folder to local folder
trafficflowPath   = fullfile(piRootPath,'data','demo',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));
localTF = fullfile(piRootPath,'local','trafficflow');
if ~exist(localTF,'dir'), mkdir(localTF);end
copyfile(trafficflowPath,localTF);
%% Scene Generation
tic
[thisR_scene,road] = piSceneAuto('sceneType',sceneType,...
    'roadType',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'timeStamp',timestamp,...
    'cloudRender',cloudRender,...
    'scitran',st);
toc

thisR_scene.metadata.sumo.trafficflowdensity = trafficflowDensity;
thisR_scene.metadata.sumo.timestamp          = timestamp;
%% Add a skymap and add SkymapFwInfor to fwList
dayTime = '14:30';
[thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];
%% Render parameters
xRes = 1280;
yRes = 720;
pSamples = 32;
thisR_scene.set('film resolution',[xRes yRes]);
thisR_scene.set('pixel samples',pSamples);
thisR_scene.set('film diagonal',10);
thisR_scene.set('nbounces',10);
thisR_scene.set('aperture size',1);
lensname = 'wide.56deg.6.0mm.dat';
thisR_scene.camera = piCameraCreate('realistic','lensFile',lensname,'pbrtVersion',3);

%% Add a camera to one of the cars

% To place the camera, we find a car and place a camera at the front
% of the car.  We find the car using the trafficflow information.

load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity)),'trafficflow');
thisTrafficflow = trafficflow(timestamp);
nextTrafficflow = trafficflow(timestamp+1);
%

CamOrientation =270;
camPos = {'left','right','front','rear'};
% camPos = camPos{randi(4,1)};
camPos = camPos{3};
[thisCar,from,to,ori] = piCamPlace('thistrafficflow',thisTrafficflow,...
    'CamOrientation',CamOrientation,...
    'thisR',thisR_scene,'camPos',camPos,'oriOffset',0);
thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up = [0;1;0];
fprintf('Velocity of Ego Vehicle: %.2f m/s', thisCar.speed);

%% Assign motion blur to camera

thisR_scene = piMotionBlurEgo(thisR_scene,'nextTrafficflow',nextTrafficflow,...
                               'thisCar',thisCar,...
                               'fps',60);
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
filename = sprintf('%s_%s_v%0.1f_f%0.2f%s_o%0.2f_%i%i%i%i%i%0.0f.pbrt',...
                            sceneType,dayTime,thisCar.speed,thisR_scene.lookAt.from(3),camPos,ori,clock);
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

% Describe the target to the user

gcp.targetsList;
%% This invokes the PBRT-V3 docker image
gcp.render(); 
%% Monitor the processes on GCP

[podnames,result] = gcp.Podslist('print',false);
nPODS = length(result.items);
cnt  = 0;
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
%% Download files from Flywheel
disp('*** Data downloading...');
[oi]   = gcp.fwDownloadPBRT('scitran',st);
disp('*** Data downloaded');

%% Show the rendered image using ISETCam
destDir = fullfile(outputDir,'renderings');
disp('*** Data processing...');
gcp.fwBatchProcessPBRT('scitran',st,'destination dir',destDir);
disp('*** Processing finished ***');


%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.JobsRmAll();

%% END

