% s_snellen.m
%
% Render decomposed images to form final retinal image for the multi-planar
% display.
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
saveDirName = sprintf('snellenDisplay_%s',currDate);
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

clusterName = 'snellen-display-thin';
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

%% Load the images

decompType = {'jacobi2'};
% imageDirMain = '/Users/tlian/Dropbox (Facebook)/Analysis/MultipleSnellenAnalysis_HQ/DisplayImages/';
imageDirMain = '/Users/tlian/Dropbox (Facebook)/Analysis/MultipleSnellenAnalysis/DisplayImages/';
% imageDirMain = '/Users/tlian/Dropbox (Facebook)/Analysis/SingleSnellenAnalysis/DisplayImages/';

% displaySets = {[1.2],...
%     [1.1 1.3],...
%     [1.0 1.4],...
%     [0.8 1.6],...
%     [0.6 1.8]};
displaySets = {[0.6 1.8]};
% displaySets = {[1.2],...
%     [0.6 1.2 1.8],...
%     [0.8 1.2 1.6],...
%     [1.0 1.2 1.4],...
%     [1.1 1.2 1.3]};

% displaySets = {[1.2],...
%     [1.1 1.3]};
% displaySets = {[0.6 1.2 1.8]};

%% Render the images

for dd = 1:length(decompType)
    
    currDcmp = decompType{dd};
    imageDir = fullfile(imageDirMain,currDcmp);
    
    for ii = 1:length(displaySets)
        
        currDisplaySets = displaySets{ii};
        
        for jj = 1:length(currDisplaySets)
            
            currDist = currDisplaySets(jj);
            imageTexture = fullfile(imageDir,...
                sprintf('display%0.1f_%0.1fto%0.1f_%s.png',...
                        currDist,...
                        max(currDisplaySets),...
                        min(currDisplaySets),...
                        currDcmp));
            
            % Remove alpha channel
            [currImage, ~, alpha] = imread(imageTexture);
            if(~isempty(alpha))
                imwrite(currImage,imageTexture);
                fprintf('Overwrote (removed alpha channel): \n "%s".',imageTexture);
            end
            
            distance = 1/currDist;
            planeFOV = 20;
            width = 2*tand(planeFOV/2)*distance;
            sz = [width width];
            
            myScene = sceneEye('texturedPlane',...
                'planeDistance',distance,...
                'planeSize',sz,...
                'planeTexture',imageTexture,...
                'useDisplaySPD',1,...
                'gamma','false');
            % Note: We set gamma to false since the images are already linear.
            
            myScene.fov = 20;
            myScene.accommodation = 1.2;
            myScene.pupilDiameter = 4;
            
            % HQ
%             myScene.resolution = 1024;
%             myScene.numRays = 4096;
%             myScene.numBounces = 1;
%             myScene.numCABands = 16;
            

            myScene.resolution = 512;
            myScene.numRays = 256;
            myScene.numBounces = 1;
            myScene.numCABands = 16;
            myScene.debugMode = 1;
            
            %LQ
%             myScene.resolution = 128;
%             myScene.numRays = 128;
%             myScene.numBounces = 1;
%             myScene.numCABands = 0;
            
            myScene.name = sprintf(...
                'ri%0.1f_%0.1fto%0.1f_%s_%0.2f',...
                currDist,...
                max(currDisplaySets),...
                min(currDisplaySets),...
                currDcmp,...
                myScene.accommodation);
            
            % Cloud render
            % ----------------
%             if(ii == length(displaySets) &&...
%                jj == length(currDisplaySets) && ...
%                dd == length(decompType))
%                 fprintf('Uploading zip... \n');
%                 uploadFlag = true;
%             else
%                 uploadFlag = false;
%             end
%             [cloudFolder,zipFileName] =  ...
%                 sendToCloud(gcp,myScene,'uploadZip',uploadFlag);
            % ----------------
            
            
            % Normal Render
            % ----------------
            
        myScene.debugMode = true;
        [oi, result] = myScene.render;
        ieAddObject(oi);
        sceneWindow
        oiWindow;
        
        %{
        rgb = sceneGet(oi,'rgb');
        load('/Users/tlian/Dropbox (Facebook)/Analysis/SingleSnellenAnalysis/NavarroGroundTruth/snellenNavarro_1.20.mat');
        rgbGT = oiGet(outNavarro,'rgb');
        figure();
        subplot(1,3,1); imshow(rgbGT);
        title('Navarro GT')
        subplot(1,3,2); imshow(rgb);
        title('Pinhole of Display')
        subplot(1,3,3); imagesc((rgbGT-rgb));
        axis off; colorbar; axis image;
        
        figure();
        currImage = im2double(currImage);
        subplot(1,3,1); imshow(currImage);
        title('Display Image')
        subplot(1,3,2); imshow(rgb);
        title('Pinhole of Display')
        subplot(1,3,3); imagesc((currImage-rgb));
        axis off; colorbar; axis image;
        % ----------------
            %}
            
            %{
    % Get RGB values
    rgbMean1 = squeeze(mean(mean(currImage.^(1/2.2),1),2));
    fprintf('Mean RGB1: %0.2f %0.2f %0.2f \n',rgbMean1)
    
    srgb = oiGet(oi,'rgb');
    rgbMean2 = squeeze(mean(mean(srgb,1),2));
    fprintf('Mean sRGB: %0.2f %0.2f %0.2f \n',rgbMean2)
    
    drgb = getDisplayRGB(oi);
    rgbMean3 = squeeze(mean(mean(drgb,1),2));
    fprintf('Mean dRGB: %0.2f %0.2f %0.2f \n',rgbMean3)
     
     scale12 = mean(rgbMean1./rgbMean2);
     scale13 = mean(rgbMean1./rgbMean3);
     
     figure();
     subplot(1,3,1);
     imshow(currImage.^(1/2.2));
     subplot(1,3,2);
     imshow(srgb.*scale12);
     subplot(1,3,3);
     imshow(drgb.*scale13);
            %}
        end
    end
    
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

[oiAll, seAll] = downloadFromCloud(gcp);

for ii=1:length(oiAll)
    
    oi = oiAll{ii};
    ieAddObject(oi);
    oiWindow;
    
    myScene = seAll{ii};
    
    saveFilename = fullfile(saveDir,[myScene.name '.mat']);
    save(saveFilename,'oi','myScene');
    
end