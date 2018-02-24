%% Render a series of checkerboard images
% This script renders a series of randomly translated and rotated
% checkerboards through a realistic camera lens (pbrt-v3-spectral.) The
% checkerboard is generated using the texturedPlane scene, and then rotated
% and translated in a way that it approximately covers the camera's FOV but
% still remains in frame. These images can later be used to calibrate the
% camera intrinstics and extrinsics.
%
% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

% Set seed
rng(1);

% Set number of images to render
numImages = 5;

% gCloud Flag
gcloudFlag = 0;

% Setup gcloud
if(gcloudFlag)
    gCloud = gCloud('dockerImage','gcr.io/primal-surfer-140120/pbrt-v3-spectral-gcloud',...
        'cloudBucket','gs://primal-surfer-140120.appspot.com');
    gCloud.renderDepth = true;
    gCloud.clusterName = 'trisha';
    gCloud.maxInstances = 20;
    gCloud.init();  
end

%% Read the pbrt scene

fname = fullfile(piRootPath,'data','texturedPlane','texturedPlane_v3.pbrt');

% Read the main scene pbrt file.  Return it as a thisR
thisR = piRead(fname,'version',3);

% Setup working folder
workingDir = fullfile(piRootPath,'local','checkerboardCalibration');
if(~isdir(workingDir))
    mkdir(workingDir);
end
saveLocation = workingDir;

%% Attach the checkerboard texture

imageName = 'checkerboard.exr';
imageFile = fullfile(piRootPath,'data','imageTextures',imageName);

% We will need to scale the plane to match the texture size. We will do the
% scaling later, within the "for" loop. For now, let's get the dimensions
% of the image texture using it's JPG equivalent.
tmp = imread([imageFile(1:end-3) 'jpg']);
[h,w] = size(tmp);

% We copy the image texture into the working directory.
copyfile(imageFile,workingDir);

% Replace the dummy texture with the checkerboard texture
thisR = piWorldFindAndReplace(thisR,'dummyTexture.exr',imageName);

%% Add the camera

thisR.camera = struct('type','Camera','subtype','realistic');

% Focus at roughly meter away.
thisR.camera.focusdistance.value = 1.5; % meter
thisR.camera.focusdistance.type = 'float';

% Attach the lens
lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.6.0mm_v3.dat');
halfFOV = 56;
%lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','fisheye.87deg.6.0mm_v3.dat');
%halfFOV = 87;
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set film size
thisR.film.diagonal.value = 16;
thisR.film.diagonal.type = 'float';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 10; % mm (something very large)
thisR.camera.aperturediameter.type = 'float';

%% Set the render quality
% The intrinstics are dependent on the image resolution, so ideally you
% want to match your experimental image resolution. You can, however,
% calibrate at a lower resolution and then scale the intrinsics
% appropriately. See:
% https://dsp.stackexchange.com/questions/6055/how-does-resizing-an-image-affect-the-intrinsic-camera-matrix

thisR.set('filmresolution',[256 256]);
thisR.set('pixelsamples',128); % We don't need many pixel samples for this simple scene
thisR.integrator.maxdepth.value = 1; % No specularities, so we a max depth of 1 is enough.

%% Rotate and translate the plane and render

for ii = 1:numImages
    
    % Pick a distance along the optical axis (y-axis)
    yTranslate = randi([150 1000]);
    
    % Determine x and z rotation/translations based on the lens' FOV
    % Note: 1/2*halfFOV seems like a good approx to keep the checkerboard
    % within frame for this sensor.
    maxTranslate = floor(tand(halfFOV/2)*yTranslate);
    xTranslate = randi([-maxTranslate maxTranslate]);
    zTranslate = randi([-maxTranslate maxTranslate]);
    xRotate = randi([-45 45]);
    yRotate = randi([-90 90]);
    zRotate = randi([-45 45]);
    
    % Clear any existing transform in the recipe first!
    thisR = piClearObjectTransforms(thisR,'Plane');
    
    % Insert transforms
    % Warning: The order matters!
    thisR = piMoveObject(thisR,'Plane','Scale',[1 1 h/w].*1/3);
    thisR = piMoveObject(thisR,'Plane','Rotate',[xRotate 1 0 0]);
    thisR = piMoveObject(thisR,'Plane','Rotate',[yRotate 0 1 0]);
    thisR = piMoveObject(thisR,'Plane','Rotate',[zRotate 0 0 1]);
    thisR = piMoveObject(thisR,'Plane','Translate', ...
        [xTranslate yTranslate zTranslate]);
    
    % Set output file
    oiName = sprintf('img%d',ii);
    thisR.outputFile = fullfile(workingDir,strcat(oiName,'.pbrt'));
    
    piWrite(thisR);
    
    if(~gcloudFlag)
        % Write and render
        [oi,result] = piRender(thisR);
        vcAddObject(oi);
        oiWindow;
    else
        gCloud.upload(recipe);
    end
    
    % Save the OI
    oiFilename = fullfile(saveLocation,oiName);
    save(oiFilename,'oi');
    
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

%% Render in gCloud, if selected
if(gcloudFlag)
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
        
        % Save optical image to the appropriate folder
        oiName = oiGet(oi,'name');
        
        % "Fix" name. (OI name now has date, but we want to use the "imgX"
        % name when saving)
        C = strsplit(oiName,'-');
        oiName = C{1};
        oiFilename = fullfile(saveLocation,strcat(oiName,'.mat'));
        save(oiFilename,'oi');
        fprintf('Saved oi at %s \n',oiFilename);
        
        vcAddAndSelectObject(oi);
        oiWindow;
        
        % Delete dat file to save space
        [p,n,e] = fileparts(gCloud.targets(ii).local);
        
        datFile = fullfile(p,'renderings',strcat(n,'.dat'));
        if(exist(datFile,'file'))
            delete(datFile);
        end
        
    end
    
end



