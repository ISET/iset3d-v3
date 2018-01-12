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
gcloudFlag = 0;
sceneName = 'livingRoom';
filmResolution = [128 128];
pixelSamples = 128;
bounces = 1;
saveDir = '/sni-storage/wandell/users/tlian/360Scenes/';
%saveDir = '/Users/trishalian/RenderedData/360Renders/';
sceneDir = '/sni-storage/wandell/users/tlian/360Scenes/scenes';
workingDir = fullfile(saveDir,'workingFolder'); % Save to data server directly to avoid limited space issues
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

switch sceneName
    case('whiteRoom')
        pbrtFile = fullfile(sceneDir,'living-room-2','scene.pbrt');
        rigOrigin = [0.9476 1.3018 3.4785] + [0 0.600 0];
    case('livingRoom')
        pbrtFile = fullfile(sceneDir,'living-room','scene.pbrt');
        rigOrigin = [2.7007    1.5571   -1.6591];
        forward = [-0.9618    0.0744    0.2635];
        up = [0.0718    0.9972   -0.0197];
    case('bathroom')
        pbrtFile = fullfile(sceneDir,'bathroom','scene.pbrt');
        rigOrigin = [0.3   1.667   -1.5];
    otherwise
        error('Scene not recognized.');
end

%% Calculate camera locations

% We will manually shift all cameras according to the rig origin, so we
% will leave this blank for now. With pbrt2ISET it's difficult to tell
% where the scene origin is, so this is not as useful as it was before. 
basePlateHeight = 0; 

% Match FacebookSurround setup.
numCamerasCircum = 14;

% Which subset of cameras to render
whichCameras = [1:2:14] + 1; % Facebook indexes starting from 0. 

% Calculates the correct lookAts for each of the cameras. 
% First camera is the one looking up
% Followed by the cameras around the circumference
% Followed by the two cameras looking down.
[camOrigins, camTargets, camUps, camI] = mapSurround360Cameras(numCamerasCircum, ...
    whichCameras,basePlateHeight);

%%  Switch coordinates
% There is a coordinate switch for this scene compared to the coordinate
% system we use in mapSurround360Cameras. Specifically:
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

for ii = 1:size(camOrigins,1)
    
    % Follow Facebook's naming conventions for the cameras
    oiName = sprintf('cam%i',camI(ii)); 
    
    %% Change the lens depending on the camera
    % We will use a wide angle lens that is our closest match to the Facebook
    % lens.
    if(camI(ii) == 0 || camI(ii) == (numCamerasCircum+1) || camI(ii) == (numCamerasCircum+2))
        % Top and bottom cameras
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','fisheye.87deg.6.0mm_v3.dat');
        recipe.film.diagonal.value = 16;
        recipe.film.diagonal.type = 'float';
    else
        % Circumference cameras
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.6.0mm_v3.dat');
        % Use a 1" sensor size
        recipe.film.diagonal.value = 16;
        recipe.film.diagonal.type = 'float';
    end
    
    % Attach the lens
    recipe.camera.lensfile.value = lensFile; % mm
    recipe.camera.lensfile.type = 'string';
    
    % Set the aperture to be the largest possible.
    recipe.camera.aperturediameter.value = 10; % mm (something very large)
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
    
    
    % Look straight down/up
    %{
    forward = recipe.lookAt.to-recipe.lookAt.from;
    forward = forward./norm(forward);
    up = recipe.lookAt.up - recipe.lookAt.from;
    up = up./norm(up);
    recipe.set('from',rigOrigin);
    recipe.set('up',rigOrigin+forward);
    recipe.set('to',rigOrigin + [up(1) up(2) up(3)]);
    %}
    %recipe.set('from',[0 0 0]);
    %recipe.set('up',[1 0 0]);
    %recipe.set('to',[0 2 0]);
    
    recipe.set('outputFile',fullfile(workingDir,strcat(oiName,'.pbrt')));
    
    piWrite(recipe);
    
    if(gcloudFlag)
        gCloud.upload(recipe);
    else
        
        [oi, result] = piRender(recipe);
        vcAddObject(oi);
        oiWindow;
        
        % Fast depth render
        %[depthMap, result] = piRender(recipe,'renderType','depth');
        %figure(ii+1);
        %imagesc(depthMap); colorbar;
        
        %{
        [coordMap, ~] = piRender(recipe,'renderType','coordinates');
        figure(ii+1); 
        subplot(1,3,1); imagesc(coordMap(:,:,1)); axis image; colorbar; title('x-axis')
        subplot(1,3,2); imagesc(coordMap(:,:,2)); axis image; colorbar; title('y-axis')
        subplot(1,3,3); imagesc(coordMap(:,:,3)); axis image; colorbar; title('z-axis')
        
        rgb = oiGet(oi,'rgb');
        fig = figure(ii+1);
        imshow(rgb);
        title('Click to get coordinates. Press return when done.');
        [x, y] = getpts(fig);
        for jj = 1:size(x,1)
            fprintf('(%0.3f %0.3f %0.3f)\n',coordMap(round(y(jj)),round(x(jj)),:));
        end
        %}
            
    % Save the OI along with location information
    oiFilename = fullfile(saveLocation,oiName);
    save(oiFilename,'oi','origin','target','up','rigOrigin');
    
    clear oi
    
    % Delete the .dat file if it exists (to avoid running out of local storage space)
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
    
    gCloud.render();
    
    % Save the gCloud object in case MATLAB closes
    save(fullfile(workingDir,'gCloudBackup.mat'),'gCloud');
    
    % Pause for user input (wait until gCloud job is done)
    x = 'N';
    while(~strcmp(x,'Y'))
        x = input('Did the gCloud render finish yet? (Y/N)','s');
    end
    
    % Set the DAT output folder to the data directory so we avoid running
    % out of space on our local folder.
    % TODO: Maybe we should set the output folder in the recipe to the
    % remote data directory?
    for ii = 1:length(gCloud.targets)
        [path,name,ext] = fileparts(gCloud.targets(ii).local);
        gCloud.targets(ii).local = fullfile(saveLocation,strcat(name,ext));
    end
    
    % Double check that the saveLocation exists, or else the gsync will
    % fail quietly, which is dangerous!
    if(~exist(saveLocation,'dir'))
        mkdir(saveLocation);
    end
    
    objects = gCloud.download();
    
    for ii = 1:length(objects)
        
        oi = objects{ii};
        
        % Save optical image to the appropriate folder
        oiName = oiGet(oi,'name');
        % "Fix" name. (OI name now has date, but we want to use the "camX"
        % name when saving)
        C = strsplit(oiName,'-');
        oiName = C{1};
        oiFilename = fullfile(saveLocation,strcat(oiName,'.mat'));
        save(oiFilename,'oi','origin','target','up','rigOrigin');
        fprintf('Saved oi at %s \n',oiFilename);
        
%         vcAddAndSelectObject(oi);
%         oiWindow;
        
%         % Delete dat file to save space
%         [p,n,e] = fileparts(gCloud.targets(ii).local);
%         
%         datFile = fullfile(p,'renderings',strcat(n,'.dat'));
%         if(exist(datFile,'file'))
%             delete(datFile);
%         end
    
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

