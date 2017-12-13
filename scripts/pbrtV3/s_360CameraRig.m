%% s_360CameraRig
% Simulate a 360 camera rig output using PBRTv3 and ISET. The configuration
% is set up to match the Facebook rig.
%
% TL, Scien Stanford, 2017
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Calculate camera locations

% We will manually shift all cameras according to the rig origin, so we
% will leave this blank for now. With pbrt2ISET it's difficult to tell
% where the scene origin is, so this is not as useful as it was before. 
basePlateHeight = 0; 

% Match FacebookSurround setup.
numCamerasCircum = 14;

% Which subset of cameras to render
whichCameras = [0] + 1; % Facebook indexes starting from 0. 

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
%recipe = piRead('/home/tlian/living-room-2/scene.pbrt','version',3);
recipe = piRead('/Users/trishalian/GitRepos/pbrt-v3-scenes-Bitterli/living-room-2/scene.pbrt','version',3);

% Place the camera rig around 5 ft above the table. I found this value
% through trial and error (e.g. moving the camera around manually).
% This is specific to the living room scene. 
rigOrigin = [0.9476 1.3018 3.4785] + [0 0.600 0];

%% Change the camera lens

recipe.camera = struct('type','Camera','subtype','realistic');

% Focus at roughly meter away. 
recipe.camera.focusdistance.value = 1.5; % meter
recipe.camera.focusdistance.type = 'float';

% Use a 1" sensor size
recipe.film.diagonal.value = 16; 
recipe.film.diagonal.type = 'float';

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
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','fisheye.87deg.6.0mm_v3.dat');
    else
        % Circumference cameras
        lensFile = fullfile(piRootPath,'scripts','pbrtV3','wide.56deg.6.0mm_v3.dat');
    end
    
    % Attach the lens
    recipe.camera.lensfile.value = lensFile; % mm
    recipe.camera.lensfile.type = 'string';
    
    % Set the aperture to be the largest possible.
    recipe.camera.aperturediameter.value = 10; % mm (something very large)
    recipe.camera.aperturediameter.type = 'float';

    %% Set render quality
    recipe.set('filmresolution',[128 128]);
    recipe.set('pixelsamples',256);
    recipe.integrator.maxdepth.value = 1;
    
    %% Set camera lookAt
    
    % PBRTv3 has units of meters, so we scale here.
    origin = camOrigins(ii,:)*10^-3 + rigOrigin;
    target = camTargets(ii,:)*10^-3 + rigOrigin;
    up = camUps(ii,:)*10^-3 + rigOrigin.*camUps(ii,:);
    recipe.set('from',origin);
    recipe.set('to',target);
    recipe.set('up',up);
    
    recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));
    
    piWrite(recipe);
    [oi, result] = piRender(recipe);
    
    vcAddObject(oi);
    oiWindow;
 
    % Save the OI along with location information
    saveLocation = '/sni-storage/wandell/users/tlian/360Scenes/livingRoom';
    if(~exist(saveLocation,'dir'))
        warning('Save location does not exist. Using defualt.')
        saveLocation = fullfile(piRootPath,'local');
    end
    oiFilename = fullfile(saveLocation,oiName);
    save(oiFilename,'oi','origin','target','up','rigOrigin');
    
    clear oi
end
