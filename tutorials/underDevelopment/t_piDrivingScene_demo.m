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
sceneType = 'city1';

% To see the available roadTypes use piRoadTypes
roadType = 'city_cross_4lanes_002';

% Avaliable trafficflowDensity: low, medium, high
trafficflowDensity = 'medium';

% Choose a timestamp(1~360), which is the moment in the SUMO

% simulation that we record the data. 
timestamp = 15;

% Choose whether we want to enable cloudrender
cloudRender = 1;

%% Only for Demo

% Copy trafficflow from data folder to local folder
trafficflowPath   = fullfile(piRootPath,'data','sumo_input','demo',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));
localTF = fullfile(piRootPath,'local','trafficflow');

if ~exist(localTF,'dir'), mkdir(localTF);end
copyfile(trafficflowPath,localTF);
disp('*** Copied traffic flow')

%% Scene Generation

% 20 seconds
tic
disp('*** Scene Generating.....')
[thisR,road] = piSceneAuto('sceneType',sceneType,...
    'roadType',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'timeStamp',timestamp,...
    'cloudRender',cloudRender,...
    'scitran',st);
thisR.metadata.sumo.trafficflowdensity = trafficflowDensity;
thisR.metadata.sumo.timestamp          = timestamp;
toc

disp('*** Scene Generation completed.')

%% Add a skymap and add SkymapFwInfo to fwList

dayTime = '13:30';
[thisR,skymapfwInfo] = piSkymapAdd(thisR,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];
disp('Skymap added')

%% Render parameters
lensname = 'wide.56deg.6.0mm.dat';
thisR.camera = piCameraCreate('realistic','lens file',lensname);

thisR.set('film resolution',[1280 720]);
thisR.set('pixel samples',64);   % 1024 for high resolution
thisR.set('film diagonal',10);
thisR.set('nbounces',10);
thisR.set('aperture',1);
disp('Camera created')

%% Place the camera

% To place the camera, we find a car and place a camera at the front
% of the car.  We find the car using the trafficflow information.
tfFileName = sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity);

% Full path to file
tfFileName = fullfile(piRootPath,'local','trafficflow',tfFileName);

% Load the trafficflow variable, which contains the whole time series
load(tfFileName,'trafficflow');

% Choose the time stamp
thisTrafficflow = trafficflow(timestamp);

%{
% We can assign the camera to a random car in the scene this way
nextTrafficflow = trafficflow(timestamp+1);
CamOrientation = 270;
camPos = {'left','right','front','rear'};
camPos = camPos{3};
[thisCar,thisR] = piCamPlace('thistrafficflow',thisTrafficflow,...
    'CamOrientation',CamOrientation,...
    'thisR',thisR,'camPos',camPos,'oriOffset',0);

fprintf('Velocity of Ego Vehicle: %.2f m/s \n', thisCar.speed);

% Assign motion blur to the camera based on its motion
thisR = piMotionBlurEgo(thisR,'nextTrafficflow',nextTrafficflow,...
                               'thisCar',thisCar,...
                               'fps',60);
%}

camPos = 'front';
cameraVelocity = 0 ;            % Camera velocity
CamOrientation = 270;           % Not sure
thisR.lookAt.from = [0;3;40];   % X,Y,Z
thisR.lookAt.to   = [0;1.9;150];
thisR.lookAt.up   = [0;1;0];

thisR.set('exposure time',1/200);
disp('Camera positioned')

%% Write out the scene into a PBRT file

if piContains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
    thisR.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.name));
    thisR.inputFile = fullfile(outputDir,[strcat(sceneType,'_',road.name),'.pbrt']);
end

% We might use md5 to hash the parameters and put them in the file
% name.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_%s_v%0.1f_f%0.2f%s_o%0.2f_%i%i%i%i%i%0.0f.pbrt',...
                            sceneType,...
                            dayTime,...
                            cameraVelocity,...
                            thisR.lookAt.from(3),...
                            camPos,...
                            CamOrientation,...
                            clock);
thisR.outputFile = fullfile(outputDir,filename);

% Write the recipe for the scene we generated
piWrite(thisR,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

% edit(thisR.outputFile)
disp('Scene written');
%% Upload the information to Flywheel.

% This creates a new acquisition in the scenes_pbrt session.
% Each acquisition is a particular scene, like this one.
gcp.fwUploadPBRT(thisR,'scitran',st,'road',road);
disp('Scene uploaded')
%% Add this target scene to the target list

% Current targets
gcp.targetsList;

% Add a target to the list
gcp.addPBRTTarget(thisR);

% Show the updated target list to the user
gcp.targetsList;

% You can delete a single target from the list this way
%{
 val = 1;
 gcp.targetDelete(val);
 gcp.targetsList;
%}

%% Send the rendering job to the google cloud

% It takes about 30 mins depends on the complexity of the scene. 
% (Majority of the time is used to load data(texture and geometry), 
% Render a slightly better quality image would be a good choice.

% Calling this starts the job and lets you know about it.
gcp.render(); 
disp('Initiated rendering');
%% Monitor the processes on GCP
%
% One way to monitor jobs progress is to go to the web page
%
%   https://console.cloud.google.com 
%
% And then go to the Kubernetes part
%
nActive = gcp.jobsList;

% You can get a lot of information about the job this way
%{   
   podname = gcp.podsList
   gcp.PodDescribe(podname{end})    % Prints out what has happened
   cmd = gcp.Podlog(podname{end});  % Creates a command to show the running log
%}

%% Download files from Flywheel

% Run this after the render command is complete.  We put the pause here so
% that running the whole script will not execute until you are ready.
disp('Pausing for rendering to complete')
pause;

%%
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

