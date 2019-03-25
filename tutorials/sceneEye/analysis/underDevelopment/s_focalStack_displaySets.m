%% s_focalStack_displaySets.m
%
% Generate focal stacks for sets of displays at different separations
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
saveDirName = sprintf('focalStack_%s',currDate);
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

clusterName = 'focal-stack';
zone         = 'us-central1-a';
instanceType = 'n1-highcpu-32';

gcp = gCloud('dockerAccount',dockerAccount,...
    'dockerImage',dockerImage,...
    'clusterName',clusterName,...
    'cloudBucket',cloudBucket,...
    'zone',zone,...
    'instanceType',instanceType,...
    'projectid',projectid,...
    'maxInstances',20);
toc

% Render depth
gcp.renderDepth = true;

% Clear the target operations
gcp.targets = [];

%% Set parameters

minDisplay = 0.6;
maxDisplay = 1.8;
focalStack = minDisplay:0.1:maxDisplay;

snellenDistanceDpt = 1.2;
snellenFOV = 10;
width = 2*tand(snellenFOV/2)*(1/snellenDistanceDpt);
snellenSize = [width width];

%% Render the images
nRenders = length(focalStack);

for ii = 1:nRenders % Display seperation
    
    
    %{
    sceneNavarro = sceneEye('snellenSingle',...
        'objectDistance',1/snellenDistanceDpt,...
        'objectSize',[snellenSize snellenSize]);
    %}
    sceneNavarro = sceneEye('snellenAtDepth');
    
        
    sceneNavarro.pupilDiameter = 4;
    sceneNavarro.accommodation = focalStack(ii);
    
    sceneNavarro.fov = 20;
    
    % HQ
    sceneNavarro.resolution = 1024;
    sceneNavarro.numRays = 2048;
    sceneNavarro.numCABands = 0;
    sceneNavarro.numBounces = 1;
    sceneNavarro.debugMode = true;
    
    % LQ
    %{
    sceneNavarro.resolution = 128;
    sceneNavarro.numRays = 128;
    sceneNavarro.numCABands = 0;
    sceneNavarro.numBounces = 1;
    sceneNavarro.debugMode = true; % Try this
    %}
    
    sceneNavarro.name = sprintf('snellen_%0.2f_%0.2f',...
        snellenDistanceDpt,...
        focalStack(ii));
    
    if(ii == nRenders)
        uploadFlag = true;
    else
        uploadFlag = false;
    end
    
    [cloudFolder,zipFileName] =  ...
        sendToCloud(gcp,sceneNavarro,'uploadZip',uploadFlag);
        
%     scene = sceneNavarro.render();
%     ieAddObject(scene);
%     sceneWindow;  
end

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

[sceneAll, seAll] = downloadFromCloud(gcp);

for ii=1:length(sceneAll)
    
    scene = sceneAll{ii};
  
    ieAddObject(scene);
    sceneWindow;
    
    myScene = seAll{ii};
    
    saveFilename = fullfile(saveDir,[myScene.name '.mat']);
    save(saveFilename,'scene','myScene');
    
end