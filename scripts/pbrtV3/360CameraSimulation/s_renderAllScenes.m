%% Render all the Bitterli scenes from their default camera positions
% This is useful if we want to show off the various scenes we have. Right
% now, this is automatically set to render in cloud. 

%% Initialize
clear; close all;
ieInit;

%% Set global parameters
filmResolution = [2048 2048];
pixelSamples = 2048;
bounces = 8;

lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','dgauss.22deg.6.0mm_v3.dat');
% These values should match the lens above
lensFocalLength = 6;
apertureDiameter = 2.046000;
filmDiag = 7;
focusDistance = 1.5;

sceneNames = {'whiteRoom','livingRoom','bathroom','bedroom','kitchen','bathroom2'};
saveDir = '/sni-storage/wandell/users/tlian/360Scenes/allScenes';

% Check save directory
if(~exist(saveDir,'dir'))
    mkdir(saveDir);
end

%% Setup gcloud
% Note: gCloud right now has some issues with overwriting files. Let's do it
% locally for now.

%{
gCloud = gCloud('dockerImage','gcr.io/primal-surfer-140120/pbrt-v3-spectral-gcloud',...
    'cloudBucket','gs://primal-surfer-140120.appspot.com');
gCloud.renderDepth = true;
gCloud.clusterName = 'trisha';
gCloud.maxInstances = 20;
gCloud.init();


% Needed parameters
allRecipes = cell(size(sceneNames,1),1);
%}

%% Loop through scenes
for ii = 1:length(sceneNames)
    
    workingDir = fullfile(saveDir,strcat(sceneNames{ii},'_workingDir'));
    
    % Check working directory
    if(~exist(workingDir,'dir'))
        mkdir(workingDir);
    end

    currScene = sceneNames{ii};
    
    % Setup save name
    oiName = sprintf('%sDefault_%i_%i_%i_%i',...
        currScene,...
        filmResolution(1),...
        filmResolution(2),...
        pixelSamples,...
        bounces);
    
    % Load scene
    [pbrtFile,rigOrigin] = selectBitterliScene(currScene);
    recipe = piRead(pbrtFile,'version',3);
    
    %% Change the camera parameters
    
    recipe.camera = struct('type','Camera','subtype','realistic');
    
    % Focus at roughly meter away.
    recipe.camera.focusdistance.value = focusDistance; % meter
    recipe.camera.focusdistance.type = 'float';
    
    % Change the sampler
    recipe.sampler.subtype = 'halton';
    
    recipe.film.diagonal.value = filmDiag; 
    recipe.film.diagonal.type = 'float';
    
    % Attach the lens
    recipe.camera.lensfile.value = lensFile; % mm
    recipe.camera.lensfile.type = 'string';
    
    % Set the aperture to be the largest possible.
    % PBRT-v3-spectral will automatically scale it down to the largest
    % possible aperture for the chosen lens.
    recipe.camera.aperturediameter.value = apertureDiameter; % mm
    recipe.camera.aperturediameter.type = 'float';
    
    %% Set render quality
    recipe.set('filmresolution',filmResolution);
    recipe.set('pixelsamples',pixelSamples);
    recipe.integrator.maxdepth.value = bounces;
    
    % Write out recipe
    recipe.set('outputFile',fullfile(workingDir,strcat(oiName,'.pbrt')));
    piWrite(recipe);
    
    %% Render

    [oi, result] = piRender(recipe);
    
    
    %% Set optical parameters parameters
    oi = oiSet(oi, 'optics focal length', lensFocalLength * 1e-3);
    oi = oiSet(oi,'optics fnumber',lensFocalLength/apertureDiameter);
    
    % Compute the horizontal field of view
    photons = oiGet(oi, 'photons');
    x = size(photons,2);
    y = size(photons,1);
    d = sqrt(x.^2 + y.^2);  % Number of samples along the diagonal
    fwidth= (filmDiag / d) * x;    % Diagonal size by d gives us mm per step
    fov = 2 * atan2d(fwidth / 2, lensFocalLength);
    
    % Store the horizontal field of view in degrees in the oi
    oi = oiSet(oi, 'fov', fov);
    
    vcAddObject(oi);
    oiWindow;
    
    %% Save
    
    % Save the OI along with location information
    oiFilename = fullfile(saveDir,oiName);
    save(oiFilename,'oi','focusDistance');
    
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


%{
%% Render in gCloud

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
save(fullfile(pwd,'gCloudBackup.mat'),'gCloud');

% Pause for user input (wait until gCloud job is done)
x = 'N';
while(~strcmp(x,'Y'))
    x = input('Did the gCloud render finish yet? (Y/N)','s');
end

objects = gCloud.download();

for ii = 1:length(objects)
    
    oi = objects{ii};
    
    % "Fix" name (remove date)
    oiName = oiGet(oi,'name');
    C = strsplit(oiName,'-');
    oiName = C{1};
    oiFilename = fullfile(saveDir,strcat(oiName,'.mat'));
    
    % Set optical parameters parameters
    oi = oiSet(oi, 'optics focal length', lensFocalLength * 1e-3);
    oi = oiSet(oi,'optics fnumber',lensFocalLength/apertureDiameter);
    
    % Compute the horizontal field of view
    photons = oiGet(oi, 'photons');
    x = size(photons,2);
    y = size(photons,1);
    d = sqrt(x.^2 + y.^2);  % Number of samples along the diagonal
    fwidth= (filmDiag / d) * x;    % Diagonal size by d gives us mm per step
    fov = 2 * atan2d(fwidth / 2, lensFocalLength);
    
    % Store the horizontal field of view in degrees in the oi
    oi = oiSet(oi, 'fov', fov);
    
    save(oiFilename,'oi','focusDistance');
    fprintf('Saved oi at %s \n',oiFilename);
    
end
%}