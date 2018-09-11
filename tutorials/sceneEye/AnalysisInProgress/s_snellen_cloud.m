%% s_snellen.m
%
% Render:
% (1) The scene through a perspective/pinhole camera. This image will pass
%     into the decomposition code.
% (2) A retinal image of the original scene through the eye model. This
%     will be used as the ground truth.
%
%
% TL ISETBIO Team, 2017
    

%% Initialize ISETBIO
ieInit;
if ~mcDockerExists, mcDockerConfig; end % check whether we can use docker
if ~mcGcloudExists, mcGcloudConfig; end % check whether we can use google cloud sdk;

%% Initialize save folder
% Since rendering these images often takes a while, we will save out the
% optical images into a folder for later processing.
currDate = datestr(now,'mm-dd-yy_HH_MM');
saveDirName = sprintf('snellen_%s',currDate);
saveDir = fullfile(isetbioRootPath,'local',saveDirName);
if(~exist(saveDir,'dir'))
    mkdir(saveDir);
end

%% Initialize cluster
tic

dockerAccount= 'tlian';
projectid = 'renderingfrl';
dockerImage = 'gcr.io/renderingfrl/pbrt-v3-spectral-gcloud';
cloudBucket = 'gs://renderingfrl';

clusterName = 'snellen';
zone         = 'us-central1-a';    
instanceType = 'n1-highcpu-32';

gcp = gCloud('dockerAccount',dockerAccount,...
    'dockerImage',dockerImage,...
    'clusterName',clusterName,...
    'cloudBucket',cloudBucket,...
    'zone',zone,...
    'instanceType',instanceType,...
    'projectid',projectid);
toc

% Render depth
gcp.renderDepth = true;

% Clear the target operations
gcp.targets = [];

%% Pinhole image

snellenDistanceDpt = 1.2;

% Single Snellen Analysis
%{
snellenFOV = 10;
width = 2*tand(snellenFOV/2)*(1/snellenDistanceDpt);
snellenSize = [width width];

scenePinhole = sceneEye('snellenSingle',...
    'objectDistance',1/snellenDistanceDpt,...
    'objectSize',[snellenSize snellenSize]);
%}

scenePinhole = sceneEye('snellenAtDepth');

% HQ
scenePinhole.debugMode = true; % Will use perspective camera
scenePinhole.accommodation = 0;
scenePinhole.resolution = 1024; 
scenePinhole.numRays = 512;
scenePinhole.fov = 20;
scenePinhole.name = 'snellenPinhole';

% LQ
%{
scenePinhole.debugMode = true; % Will use perspective camera
scenePinhole.accommodation = 0;
scenePinhole.resolution = 512; 
scenePinhole.numRays = 128;
scenePinhole.fov = 20;
scenePinhole.name = 'snellenPinhole';
%}

% Use direct lighting 
scenePinhole.numBounces = 1;
scenePinhole.recipe.integrator.subtype = 'directlighting';

%{
thisScene = scenePinhole.render();
ieAddObject(thisScene);
sceneWindow;
%}

[cloudFolder,zipFileName] =...
    sendToCloud(gcp,scenePinhole,'uploadZip',false);

%% Eye image

%{
sceneNavarro = sceneEye('snellenSingle',...
    'objectDistance',1/snellenDistanceDpt,...
    'objectSize',[snellenSize snellenSize]);
%}

sceneNavarro = sceneEye('snellenAtDepth');

sceneNavarro.pupilDiameter = 4;
sceneNavarro.accommodation = snellenDistanceDpt;

sceneNavarro.fov = scenePinhole.fov;
sceneNavarro.name = sprintf('snellenNavarro_%0.2f',snellenDistanceDpt);

sceneNavarro.resolution = scenePinhole.resolution;
sceneNavarro.numRays = 8192;
sceneNavarro.numCABands = 16;
sceneNavarro.numBounces = 3;

% LQ
%{
sceneNavarro.resolution = scenePinhole.resolution;
sceneNavarro.numRays = 128;
sceneNavarro.numCABands = 0;
sceneNavarro.numBounces = 1;
%}

%{
[cloudFolder,zipFileName] =  ...
    sendToCloud(gcp,sceneNavarro,'uploadZip',true);
%}

%% Render
gcp.render();

%% Check for completion
% Save the gCloud object in case MATLAB closes
gCloudName = sprintf('%s_gcpBackup_%s',mfilename,currDate);
save(fullfile(saveDir,gCloudName),'gcp','saveDir');
    
% Pause for user input (wait until gCloud job is done)
x = 'N';
while(~strcmp(x,'Y'))
    x = input('Did the gCloud render finish yet? (Y/N)','s');
end


%% Download the data

[ieAll, seAll] = downloadFromCloud(gcp);

% Pinhole
outPinhole = ieAll{1};
scenePinhole = seAll{1};

ieAddObject(outPinhole);
sceneWindow;

saveFilename = fullfile(saveDir,[scenePinhole.name '.mat']);
save(saveFilename,'outPinhole','scenePinhole');

% Navarro
%{
outNavarro = ieAll{2};
sceneNavarro = seAll{2};

ieAddObject(outNavarro);
oiWindow;

saveFilename = fullfile(saveDir,[sceneNavarro.name '.mat']);
save(saveFilename,'outNavarro','sceneNavarro');
%}

%% Save the RGB+D for pinhole

srgb = sceneGet(outPinhole,'rgb');
lrgb = srgb2lrgb(srgb);
imwrite(lrgb,fullfile(saveDir,'snellenImage_linear.png'));

depth = sceneGet(outPinhole,'depthmap');
dlmwrite(fullfile(saveDir,'snellenDepth.txt'),depth,'delimiter',' ');
