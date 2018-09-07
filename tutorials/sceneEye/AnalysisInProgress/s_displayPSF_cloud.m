%% s_displayPSF_cloud.m
%
% Generate PSF images for different displays. These images will be given to
% the decomposition code in order to optimize for the images across the
% planes.
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
saveDirName = sprintf('psfDisplay_%s',currDate);
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

clusterName = 'psf-display';
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

%% Intialize parameters
ch_names = {'r','g','b'};

% Displays
displaySets = {[1.2],...
    [1.1 1.3],...
    [1.0 1.4],...
    [0.8 1.6]};
    % [0.6 1.8]}; % Too many...

%% Generate the "display" image

s = 512;
if(mod(s,2) ~= 0)
    error('Display size must be even.');
end

% Show images
%{
figure(1);
subplot(1,3,1); imshow(psfImage(:,:,1));
subplot(1,3,2); imshow(psfImage(:,:,2));
subplot(1,3,3); imshow(psfImage(:,:,3));
%}

% Write out images
imageFilenames = cell(1,3);
for ii = 1:3
    psfImage = zeros(s,s,3);
    centerPx = floor(s/2)+1;
    psfImage(centerPx,centerPx,ii) = 1;
    
    imageFilenames{ii} = fullfile(saveDir,sprintf('%s_pixel_%i.png',ch_names{ii},s));
    imwrite(psfImage,imageFilenames{ii})
end


%% Render the images
% Big loop:
% 1) Loop over display sets (display seperation)
% 2) Loop over displays within set (should only be 2)
% 3) Loop over focal stack
% 4) Loop over color channels
pi = 1;
for ii = 1:length(displaySets) % Display seperation
    
    % Calculate focal stack for this display
    
    deltaFocus = 0.1;
    if(length(displaySets{ii}) == 1)
        focalStack = displaySets{ii};
    else
        focalStack = min(displaySets{ii}):0.1:max(displaySets{ii});
    end
    
    for kk = 1:length(displaySets{ii}) % Displays
        
        currDistDpt = displaySets{ii}(kk);
        distance = 1/currDistDpt;
        planeFOV = 20;
        width = 2*tand(planeFOV/2)*distance;
        dispSize = [width width];
        
        for jj = 1:length(focalStack) % Focal stack
            
            currAccom = focalStack(jj);
            
            for ll = 1:length(ch_names) % Color channel
                
                % Read lit pixel image
                currImageFn = imageFilenames{ll};
                [currImage, ~, alpha] = imread(currImageFn);
                
                % Remove alpha channel if present
                if(~isempty(alpha))
                    imwrite(currImage,currImageFn);
                    fprintf('Overwrote (removed alpha channel): \n "%s".',currImageFn);
                end
                
                myScene = sceneEye('texturedPlane',...
                    'planeDistance',distance,...
                    'planeSize',dispSize,...
                    'planeTexture',currImageFn);
                
                myScene.fov = planeFOV;
                myScene.accommodation = currAccom;
                sceneNavarro.pupilDiameter = 4;
                
                % HQ
                myScene.resolution = 512;
                myScene.numRays = 1024;
                myScene.numBounces = 1;
                myScene.numCABands = 16;
               
                %LQ
                %{
                myScene.resolution = s;
                myScene.numRays = 128;
                myScene.numBounces = 1;
                myScene.numCABands = 1;
                %}
                
                myScene.name = sprintf('psf_%i_%0.1f_%0.2f_%s',...
                    ii,...
                    currDistDpt,...
                    myScene.accommodation,...
                    ch_names{ll});
                
                % To speed up rendering, only render center of image where
                % the pixel is lit. We will fill in the rest of the image
                % with 0's.
                % For an image of size s x s, the center pixel should be at
                centerPx = floor(s/2)+1;
                
                % Let's take a approixmately a 4th of the image
                cropSize = round(s/4);
                if(mod(cropSize,2) ~= 0)
                    cropSize = cropSize+1;
                end
                
                % Calculate limits of the window assuming image is square
                 % +1 because I think PBRT takes the inner pixels of the range.
                x_left = centerPx - (cropSize/2);
                x_right = centerPx + (cropSize/2)+1;
                y_top = x_left;
                y_bottom = x_right;
                
                % Calculate crop window inputs
                px_window = [x_left x_right y_top y_bottom];
                crop_window = px_window/s;
                pad_px = abs([0 s 0 s] - px_window); % Used to repad the image 
                
                % Save for gCloud
                pad_px_all{pi} = pad_px;
                pi = pi+1;
                
                % Set crop window
                myScene.recipe.set('cropwindow',crop_window);
                
                % Double check the padding value
                img = zeros(s,s);
                img(centerPx,centerPx) = 1;
                crop_img = img(x_left:x_right,y_top:y_bottom);
                new_image = padarray(crop_img,[pad_px(1) pad_px(3)],0,'pre');
                new_image = padarray(new_image,[pad_px(2) pad_px(4)],0,'post');
                
                %{
                % Plot
                figure(1); subplot(1,3,1);
                imagesc(img); axis image;
                subplot(1,3,2); imagesc(crop_img); axis image;
                subplot(1,3,3); imagesc(new_image); axis image;
                
                if(sum(sum(new_image - img)) ~= 0)
                    error('Something wrong with padding and crop window!');
                end
                
                %}
                
                % Check if last render
                
                if(ii == length(displaySets) &&...
                   ll == length(ch_names) && ...
                   jj == length(focalStack) && ...
                   kk == length(displaySets{ii}))
                    fprintf('Uploading zip... \n');
                    uploadFlag = true;
                else
                    uploadFlag = false;
                end
                [cloudFolder,zipFileName] =  ...
                    sendToCloud(gcp,myScene,'uploadZip',uploadFlag);

                %{
                % Normal Render
                [oi, result] = myScene.render;
                % vcAddAndSelectObject(oi);
                % oiWindow;
                
                % Pad array
                oi = oiPad(oi,[pad_px(1) pad_px(3)],1e6,'pre');
                oi = oiPad(oi,[pad_px(2) pad_px(4)],1e6,'post');
                
                ieAddObject(oi);
                oiWindow;
                
                % Check size
                new_s = oiGet(oi,'size');
                if(new_s(1) ~= s || new_s(2) ~= s)
                    error('Something wrong with padding or crop window!')
                end
                
                % Check peak pixel
                illum = oiGet(oi,'illuminance');
                [~, peak_px] = max(illum(:));
                [I,J] = ind2sub(size(illum),peak_px);
                if(I ~= centerPx || J ~= centerPx)
                    warning('Center pixel may not align.');
                    figure();
                    subplot(1,3,1); imshow(currImage); 
                    title('Original Image')
                    subplot(1,3,2); imshow(illum); 
                    title('Rendered Image (Illum)')
                    rgb = oiGet(oi,'rgb');
                    subplot(1,3,3); imshow(rgb); 
                    title('Rendered Image (rgb)')
                    pause;
                end
               %}
                    
            end
        end
    end
end

%% Render
gcp.render();

%% Check for completion

% Save the gCloud object in case MATLAB closes
gCloudName = sprintf('%s_gcpBackup_%s',mfilename,currDate);
save(fullfile(saveDir,gCloudName),'gcp','saveDir','pad_px_all');

% Pause for user input (wait until gCloud job is done)
x = 'N';
while(~strcmp(x,'Y'))
    x = input('Did the gCloud render finish yet? (Y/N)','s');
end


%% Download the data

[oiAll, seAll] = downloadFromCloud(gcp);

for ii=1:length(oiAll)
    
    oi = oiAll{ii};
    
    % Pad array
    pad_px = pad_px_all{ii};
    oi = oiPad(oi,[pad_px(1) pad_px(3)],1e6,'pre');
    oi = oiPad(oi,[pad_px(2) pad_px(4)],1e6,'post');
    
    ieAddObject(oi);
    oiWindow;
    
    myScene = seAll{ii};
    
    saveFilename = fullfile(saveDir,[myScene.name '.mat']);
    save(saveFilename,'oi','myScene');
    
end