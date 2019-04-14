%% Automatically assemble an automotive scene and render using Google Cloud
%
%    t_piDrivingScene_demo
%
% Dependencies
%    ISETCloud, ISET3d, ISETCam and scitran
%
% Description:
%   Generate driving scenes using the gcloud (kubernetes) methods.  The
%   scenes are built by sampling roads from the Flywheel database.
%
%   To delete the cluster when you are done execute the command
%
%       gcloud container clusters delete cloudrendering
%
% Author: Zhenyi Liu;
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

% Initializing takes a few minutes
tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-west1b-standard-32cpu-120m-flywheel');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     =[];  % clear job list

% Print out the gcp parameters for the user
str = gcp.configList;

%%  Example scene creation

% This can take 20-30 minutes

% Available sceneTypes: city1, city2, city3, city4, citymix, suburb
sceneType = 'city3';

% To see the available roadTypes use piRoadTypes
roadType = 'city_cross_4lanes_002';

% Avaliable trafficflowDensity: low, medium, high
trafficflowDensity = 'medium';

% Choose a timestamp(1~360), which is the moment in the SUMO

% simulation that we record the data. 
timestamp = 30;

% Choose whether we want to enable cloudrender
cloudRender = 1;

%% Only for Demo

% Copy trafficflow from data folder to local folder
trafficflowPath   = fullfile(piRootPath,'data','sumo_input','demo',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));
localTF = fullfile(piRootPath,'local','trafficflow');

if ~exist(localTF,'dir'), mkdir(localTF);end
copyfile(trafficflowPath,localTF);
%% Scene Generation

% 1~2 minutes
tic
disp('*** Scene Generating.....')
[thisR_scene,road] = piSceneAuto('sceneType',sceneType,...
    'roadType',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'timeStamp',timestamp,...
    'cloudRender',cloudRender,...
    'scitran',st);
disp('*** Scene Generation completed.')
toc

thisR_scene.metadata.sumo.trafficflowdensity = trafficflowDensity;
thisR_scene.metadata.sumo.timestamp          = timestamp;

%% Add a skymap and add SkymapFwInfo to fwList

dayTime = '14:30';
[thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];

%% Render parameters
thisR_scene.set('film resolution',[1280 720]);
thisR_scene.set('pixel samples',128);
thisR_scene.set('film diagonal',10);
thisR_scene.set('nbounces',10);
thisR_scene.set('aperture',1);
lensname = 'wide.56deg.6.0mm.dat';
thisR_scene.camera = piCameraCreate('realistic','lensFile',lensname,'pbrtVersion',3);

%% Place the camera

% To place the camera, we find a car and place a camera at the front
% of the car.  We find the car using the trafficflow information.

load(fullfile(piRootPath,'local',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity)),'trafficflow');
thisTrafficflow = trafficflow(timestamp);

%{
% We can assign the camera to a random car in the scene this way
nextTrafficflow = trafficflow(timestamp+1);
CamOrientation = 270;
camPos = {'left','right','front','rear'};
camPos = camPos{3};
[thisCar,thisR_scene] = piCamPlace('thistrafficflow',thisTrafficflow,...
    'CamOrientation',CamOrientation,...
    'thisR',thisR_scene,'camPos',camPos,'oriOffset',0);

fprintf('Velocity of Ego Vehicle: %.2f m/s \n', thisCar.speed);

% Assign motion blur to the camera based on its motion
thisR_scene = piMotionBlurEgo(thisR_scene,'nextTrafficflow',nextTrafficflow,...
                               'thisCar',thisCar,...
                               'fps',60);
%}

camPos = 'front';
thisVelocity   = 0 ;
CamOrientation = 270;
thisR_scene.lookAt.from = [0;3;40];
thisR_scene.lookAt.to   = [0;1.9;150];
thisR_scene.lookAt.up   = [0;1;0];

% Open at time zero
thisR.camera.shutteropen.type = 'float';
thisR.camera.shutteropen.value = 0;  

% Shutter duration
thisR.camera.shutterclose.type = 'float';
thisR.camera.shutterclose.value = 1/200;   % 5 ms exposure

%% Write out the scene into a PBRT file

if piContains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
    thisR_scene.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.name));
    thisR_scene.inputFile = fullfile(outputDir,[strcat(sceneType,'_',road.name),'.pbrt']);
end

% We might use md5 to hash the parameters and put them in the file
% name.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_%s_v%0.1f_f%0.2f%s_o%0.2f_%i%i%i%i%i%0.0f.pbrt',...
                            sceneType,...
                            dayTime,...
                            thisVelocity,...
                            thisR_scene.lookAt.from(3),...
                            camPos,...
                            CamOrientation,...
                            clock);
thisR_scene.outputFile = fullfile(outputDir,filename);

% Write the recipe for the scene we generated
piWrite(thisR_scene,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

%% Upload the information to Flywheel.

% This creates a new acquisition in the scenes_pbrt session.
% Each acquisition is a particular scene, like this one.
gcp.fwUploadPBRT(thisR_scene,'scitran',st,'road',road);

%% Add this target scene to the target list

addPBRTTarget(gcp,thisR_scene);
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

% Show the target list to the user
gcp.targetsList;

%% This sends the rendering job on google cloud

% It takes about 30 mins depends on the complexity of the scene. 
% (Majority of the time is used to load data(texture and geometry), 
% Render a slightly better quality image would be a good choice.

% Calling this starts the job and lets you know about it.
gcp.render(); 

%% Monitor the processes on GCP
%
% The best way to monitor jobs progress is to go to the web page
%
%   https://console.cloud.google.com 
%
% And then go to the Kubernetes part
%

% You can get a lot of information about the job this way
%{   
   podname = gcp.podsList
   gcp.PodDescribe(podname{1})    % Prints out what has happened
   cmd = gcp.Podlog(podname{1});  % Creates a command to show the running log
%}

%% Download files from Flywheel

destDir = fullfile(outputDir,'renderings');

disp('Downloading PBRT dat and converting to ISET...');
ieObject = gcp.fwBatchProcessPBRT('scitran',st,'destination dir',destDir);

%% Show the OI and some metadata

oiWindow(ieObject);
ieNewGraphWin;
imagesc(ieObject.metadata.meshImage)

%% Remove all jobs.

% Anything that i still running is a stray that never completed. We should
% say more about this. Also, we need to kill the kubernetes cluster

% gcp.jobsDelete();

%% Close the cluster

% In the terminal

% gcloud container clusters delete cloudrendering

%% END

