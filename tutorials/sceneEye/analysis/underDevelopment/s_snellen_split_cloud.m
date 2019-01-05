%% s_snellen.m
%
% Render:
%   A retinal image of the original scene through the eye model. This
%     will be used as the ground truth. To achieve a very high resolution
%     image, we split the image into multiple pieces before sending to the
%     cloud.
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

clusterName = 'snellen-navarro';
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

%% Eye image

%{
snellenFOV = 10;
width = 2*tand(snellenFOV/2)*(1/snellenDistanceDpt);
snellenSize = [width width];

scenePinhole = sceneEye('snellenSingle',...
    'objectDistance',1/snellenDistanceDpt,...
    'objectSize',[snellenSize snellenSize]);
%}

sceneNavarro = sceneEye('snellenAtDepth');

sceneNavarro.pupilDiameter = 4;
sceneNavarro.accommodation = 1.2;

sceneNavarro.fov = 20;
sceneNavarro.name = sprintf('snellenNavarro_%0.2f',1.2);

% HQ
sceneNavarro.resolution = 1024;
sceneNavarro.numRays = 8192;
sceneNavarro.numCABands = 16;
sceneNavarro.numBounces = 3;

% LQ
% sceneNavarro.resolution = 256;
% sceneNavarro.numRays = 128;
% sceneNavarro.numCABands = 0;
% sceneNavarro.numBounces = 1;

n = 4;
assert(mod(sceneNavarro.resolution/n,1) == 0); % Must be divisible
sceneMosaic = cell(n,n);

deltaCropWindow = 1/n;
xMin = -deltaCropWindow; xMax = 0;
for x = 1:n
    xMin = xMin+deltaCropWindow;
    xMax = xMax+deltaCropWindow;
    
    yMin = -deltaCropWindow; yMax = 0;
    for y = 1:n
       
        yMin = yMin+deltaCropWindow;
        yMax = yMax+deltaCropWindow;
        
        currScene = copy(sceneNavarro);
        % currScene.recipe  = copy(sceneNavarro.recipe);
        
        currScene.recipe.set('cropwindow',...
            [xMin xMax yMin yMax])
        currScene.name = [sceneNavarro.name sprintf('_%i_%i',y,x)];
        
        if(x == n && y == n)
            uploadFlag = true;
        else
            uploadFlag = false;
        end
        [cloudFolder,zipFileName] =  ...
            sendToCloud(gcp,currScene,'uploadZip',uploadFlag);
        
        fprintf('------------ \n');
        fprintf('(%i,%i) \n',x,y);

        sceneMosaic{y,x} = currScene;
        
    end
end

% A hack
% Remove the crop window in sceneNavarro
% Long story short we have some issues with deep copying the recipe
sceneNavarro.recipe.set('cropwindow',[0 1 0 1]);
sceneNavarro.recipe.camera = currScene.recipe.camera;

%% Render
gcp.render();

%% Check for completion
% Save the gCloud object in case MATLAB closes
gCloudName = sprintf('%s_gcpBackup_%s',mfilename,currDate);
save(fullfile(saveDir,gCloudName),'gcp','saveDir','sceneMosaic','sceneNavarro');

% Pause for user input (wait until gCloud job is done)
x = 'N';
while(~strcmp(x,'Y'))
    x = input('Did the gCloud render finish yet? (Y/N)','s');
end


%% Download the data

[ieAll, seAll] = downloadFromCloud(gcp);

% Recombine pieces
photonsCombined = cell(size(sceneMosaic));
depthMapCombined  = cell(size(sceneMosaic));
for ii=1:length(seAll)
    
    ieObj = ieAll{ii};
    
    ieAddObject(ieObj);
    oiWindow;
    
    myScene = seAll{ii};
    
    % Figure out piece location
    y = str2double(myScene.name(end-2));
    x = str2double(myScene.name(end));
    
    depthMapCombined{y,x} = oiGet(ieObj,'depth map');
    photonsCombined{y,x} = oiGet(ieObj,'photons');
end

% Make a new oi to put everything in
outNavarro = piOICreate(cell2mat(photonsCombined));
outNavarro = setOI(sceneNavarro,outNavarro);
outNavarro = oiSet(outNavarro,'depth map',cell2mat(depthMapCombined));

ieAddObject(outNavarro);
oiWindow;

saveFilename = fullfile(saveDir,[sceneNavarro.name '.mat']);
save(saveFilename,'outNavarro','sceneNavarro');
