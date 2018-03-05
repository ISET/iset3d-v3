%% s_360CameraRig
% Simulate a 360 camera rig output using PBRTv3 and ISET. The configuration
% is set up to match the Facebook rig.
%
% TL, Scien Stanford, 2017
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

% PARAMETERS
% -------------------

% Rendering parameters
gcloudFlag = 0;
sceneName = 'whiteRoom';
%xRes = 2704; %round(2704/16);
%yRes = 2028; %round(2028/16);
% filmResolution = [xRes yRes];
filmResolution = [128 128];
pixelSamples = 128;
bounces = 1;

% Save parameters
%saveName = strcat(sceneName,'-Google');
saveName = sceneName;
saveDir = '/sni-storage/wandell/users/tlian/360Scenes/';
%saveDir = '/Users/trishalian/RenderedData/360Renders/';    
workingDir = fullfile(saveDir,'workingFolder'); % Save to data server directly to avoid limited space issues

% Camera parameters
% By default, cam0 is a fisheye pointing up and cam(N+1) and cam(N+2) are
% fisheyes pointing down, where N = numCamerasCircum. This is according to
% the convention of the Surround360 rig.
numCamerasCircum = 14; % 14 for Facebook, 16 for Google
whichCameras = [1] + 1; % Index convention starts from 0. 
radius = 175.54;% 175.54 mm for Facebook, 140 mm for Google
% -------------------

% Setup gcloud
if(gcloudFlag)
    gCloud = gCloud('dockerImage','gcr.io/primal-surfer-140120/pbrt-v3-spectral-gcloud',...
        'cloudBucket','gs://primal-surfer-140120.appspot.com');
    gCloud.renderDepth = true;
    gCloud.clusterName = 'trisha';
    gCloud.maxInstances = 20;
    gCloud.init();  
end

% Check working directory
if(~exist(workingDir,'dir'))
    mkdir(workingDir);
end

% Setup save directory
saveLocation = fullfile(saveDir, ...
    sprintf('%s_%i_%i_%i_%i',...
    sceneName,...
    filmResolution(1),...
    filmResolution(2),...
    pixelSamples,...
    bounces));
if(~exist(saveLocation,'dir'))
    warning('Save location does not exist. Creating...')
    mkdir(saveLocation);
end
    
    
%% Select scene

[pbrtFile,rigOrigin] = selectBitterliScene(sceneName);

%% Calculate camera locations

% Calculates the correct lookAts for each of the cameras. 
% First camera is the one looking up
% Followed by the cameras around the circumference
% Followed by the two cameras looking down.
[camOrigins, camTargets, camUps, camI] = mapSurround360Cameras(numCamerasCircum, ...
    whichCameras,radius);

%%  Switch coordinates
% There is a coordinate switch for these pbrt scenes compared to the
% coordinate system we use in mapSurround360Cameras. Specifically:
% Our Y == Scene Z
% Our Z == Scene Y
% Our X == Scene X
% We simply flip the coordinates here. 

camOrigins = [camOrigins(:,1) camOrigins(:,3) camOrigins(:,2)];
camTargets = [camTargets(:,1) camTargets(:,3) camTargets(:,2)];
camUps = [camUps(:,1) camUps(:,3) camUps(:,2)];

%% Read the file
recipe = piRead(pbrtFile,'version',3);

%% Change the camera lens

recipe.camera = struct('type','Camera','subtype','realistic');

% Focus at roughly meter away. 
recipe.camera.focusdistance.value = 1.5; % meter
recipe.camera.focusdistance.type = 'float';

% Render subset of image
%recipe.film.cropwindow.value = [0.5 1 0.5 1];
%recipe.film.cropwindow.type = 'float';

% Change the sampler
recipe.sampler.subtype = 'halton';

%% Loop through each camera in the rig and render.

% For gCloud
rigInfo = cell(size(camOrigins,1),5);
allRecipes = cell(size(camOrigins,1),1); 

for ii = 1:size(camOrigins,1)
    
    % Follow Facebook's naming conventions for the cameras
    oiName = sprintf('cam%i',camI(ii)); 
    
    %% Change the lens depending on the camera
    % We will use a wide angle lens that is our closest match to the Facebook
    % lens.
    if(camI(ii) == 0 || camI(ii) == (numCamerasCircum+1) || camI(ii) == (numCamerasCircum+2))
        % Top and bottom cameras
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','fisheye.87deg.6.0mm_v3.dat');
    else
        % Circumference cameras
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.6.0mm_v3.dat');
        %lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.3.0mm_v3.dat');
    end
    
    % Set sensor size
    recipe.film.diagonal.value = 16; % Facebook (1")
    %recipe.film.diagonal.value = 8; % Google Jump (~1/2.3") Bumped up a bit to try to get more FOV
    recipe.film.diagonal.type = 'float';
        
    % Attach the lens
    recipe.camera.lensfile.value = lensFile; % mm
    recipe.camera.lensfile.type = 'string';
    
    % Set the aperture to be the largest possible.
    % PBRT-v3-spectral will automatically scale it down to the largest
    % possible aperture for the chosen lens. 
    recipe.camera.aperturediameter.value = 10; % mm 
    recipe.camera.aperturediameter.type = 'float';

    %% Set render quality
    recipe.set('filmresolution',filmResolution);
    recipe.set('pixelsamples',pixelSamples);
    recipe.integrator.maxdepth.value = bounces;
    
    %% Set camera lookAt
    
    % PBRTv3 has units of meters, so we scale here.
    origin = camOrigins(ii,:)*10^-3 + rigOrigin;
    target = camTargets(ii,:)*10^-3 + rigOrigin;
    up = camUps(ii,:)*10^-3 + rigOrigin.*camUps(ii,:);
    recipe.set('from',origin);
    recipe.set('to',target);
    recipe.set('up',up);
    
    % Do some calculations to have the camera look straight down/up
    %{
    forward = recipe.lookAt.to-recipe.lookAt.from;
    forward = forward./norm(forward);
    up = recipe.lookAt.up - recipe.lookAt.from;
    up = up./norm(up);
    recipe.set('from',rigOrigin);
    recipe.set('up',rigOrigin+forward);
    recipe.set('to',rigOrigin + [up(1) up(2) up(3)]);
    %}
    
    recipe.set('outputFile',fullfile(workingDir,strcat(oiName,'.pbrt')));
    
    piWrite(recipe);
    
    if(gcloudFlag)
        % Save all generated recipes in a cell matrix to be uploaded to
        % gCloud later in the script. 
        allRecipes{ii} = copy(recipe);
        
        % Save rig info in a large cell matrix. We will save these in the
        % optical image after we download the rendered data from gCloud. 
        rigInfo{ii,1} = oiName;
        rigInfo{ii,2} = origin;
        rigInfo{ii,3} = target;
        rigInfo{ii,4} = up;
        rigInfo{ii,5} = rigOrigin;
        
    else
        
        [oi, result] = piRender(recipe);
        ieAddObject(oi)
        oiWindow;
        
        
        % Render coordinate maps (x,y,z coordinates)
        [coordMap, ~] = piRender(recipe,'renderType','coordinates');
        figure(ii+1); 
        subplot(1,3,1); imagesc(coordMap(:,:,1)); axis image; colorbar; title('x-axis')
        subplot(1,3,2); imagesc(coordMap(:,:,2)); axis image; colorbar; title('y-axis')
        subplot(1,3,3); imagesc(coordMap(:,:,3)); axis image; colorbar; title('z-axis')
        
        % Open the RGB image and let the user click on the image; return
        the corresponding coordinates. This is helpful when trying to place
        area lights into the pbrt scene file. 
        rgb = oiGet(oi,'rgb');
        fig = figure(ii+2);
        imshow(rgb);
        title('Click to get coordinates. Press return when done.');
        [x, y] = getpts(fig);
        for jj = 1:size(x,1)
            fprintf('(%0.3f %0.3f %0.3f)\n',coordMap(round(y(jj)),round(x(jj)),:));
        end
        
        
    % Save the OI along with location information
    oiFilename = fullfile(saveLocation,oiName);
    save(oiFilename,'oi','origin','target','up','rigOrigin');
    
    clear oi
    
    % Delete the .dat file if it exists (to avoid running out of local
    % storage space. Since the oi has already been saved, the .dat file is
    % redundant at this point.
    [p,n,e] = fileparts(recipe.outputFile);
    datFile = fullfile(p,'renderings',strcat(n,'.dat'));
    if(exist(datFile,'file'))
        delete(datFile);
    end
    datFileDepth = fullfile(p,'renderings',strcat(n,'_depth.dat'));
    if(exist(datFileDepth,'file'))
        delete(datFileDepth);
    end
        
    end
    
end

%% Render in gCloud (if applicable)

if(gcloudFlag)
    
    % Upload all recipes to gCloud
    % Note: We have to do the upload here because we want to wait until all
    % pbrt files have been written out before we start uploading. This way
    % all the data needed to render all pbrt files is ready in the working
    % folder.(gCloud.upload only zips the working directory up once!)
    for ii = 1:length(allRecipes)
        gCloud.upload(allRecipes{ii});
    end
    
    gCloud.render();
    
    % Save the gCloud object in case MATLAB closes
    save(fullfile(workingDir,'gCloudBackup.mat'),'gCloud');
    
    % Pause for user input (wait until gCloud job is done)
    x = 'N';
    while(~strcmp(x,'Y'))
        x = input('Did the gCloud render finish yet? (Y/N)','s');
    end
    
    objects = gCloud.download();
    
    for ii = 1:length(objects)
        
        oi = objects{ii};
        
        % "Fix" name. (OI name now includes date, but we want to use the
        % "camX" name when saving)
        oiName = oiGet(oi,'name');
        C = strsplit(oiName,'-');
        oiName = C{1};
        oiFilename = fullfile(saveLocation,strcat(oiName,'.mat'));
        
        % Load up rig info
        % Match "camX" name with the ones recorded in the rigInfo cell matrix. 
        for jj = 1:size(rigInfo,1)
            if(strcmp(oiName,rigInfo{jj,1}))
                origin = rigInfo{jj,2};
                target = rigInfo{jj,3};
                up = rigInfo{jj,4};
                rigOrigin = rigInfo{jj,5};
                break;
            end
        end
        
        save(oiFilename,'oi','origin','target','up','rigOrigin');
        fprintf('Saved oi at %s \n',oiFilename);
    
    end
    
    
end
%% Render ODS panorama

%{
ieInit;

% Same calculations as before
basePlateHeight = 0; 
numCamerasCircum = 14;
whichCameras = [1] + 1; % Facebook indexes starting from 0. 
[camOrigins, camTargets, camUps, camI] = mapSurround360Cameras(numCamerasCircum, ...
    whichCameras,basePlateHeight);

%  Switch coordinates
camOrigins = [camOrigins(:,1) camOrigins(:,3) camOrigins(:,2)];
camTargets = [camTargets(:,1) camTargets(:,3) camTargets(:,2)];
camUps = [camUps(:,1) camUps(:,3) camUps(:,2)];

% Read the file
recipe = piRead(pbrtFile,'version',3);

% PBRTv3 has units of meters, so we scale here.
origin = camOrigins(1,:)*10^-3 + rigOrigin;
target = camTargets(1,:)*10^-3 + rigOrigin;
up = camUps(1,:)*10^-3 + rigOrigin.*camUps(1,:);
recipe.set('from',origin);
recipe.set('to',target);
recipe.set('up',up);
    
% Set render quality
recipe.set('filmresolution',[3000 1500]);
recipe.set('pixelsamples',2048);
recipe.integrator.maxdepth.value = 1;

for ipd = [64]
    
    recipe.camera = struct('type','Camera','subtype','environment');
    angleTo = 90; angleFrom = 90;
    recipe.camera.ipd = struct('value',ipd*10^-3,'type','float');
    recipe.camera.poleMergeAngleTo = struct('value',angleTo,'type','float');
    recipe.camera.poleMergeAngleFrom = struct('value',angleFrom,'type','float');
    %recipe.convergencedistance = struct('value',1,'type','float'); % Default
    %is infinity
    
    
    sceneName = sprintf('GT_%0.2f_%d_%d.pbrt',ipd,angleTo,angleFrom);
    recipe.set('outputFile',fullfile(piRootPath,'local',sceneName));
    
    piWrite(recipe);
    [scene, result] = piRender(recipe);
    
    vcAddObject(scene);
    sceneWindow;
    
    % Save the OI along with location information
    saveLocation = '/sni-storage/wandell/users/tlian/360Scenes/livingRoom';
    if(~exist(saveLocation,'dir'))
        warning('Save location does not exist. Using defualt.')
        saveLocation = fullfile(piRootPath,'local');
    end
    [~,n,e] = fileparts(sceneName);
    sceneFilename = fullfile(saveLocation,strcat(n,'.mat'));
    save(sceneFilename,'scene','ipd','angleTo','angleFrom');

end
%}

