%% s_360CameraRig
% Render an ODS panorama for a scene
%
% TL, Scien Stanford, 2017
%
%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

% PARAMETERS
% -------------------

% Rendering parameters
sceneName = 'bathroom';
filmResolution = [2048*2 2048];
pixelSamples = 1024;
bounces = 8;
gcloudFlag = 1;

% Save parameters
saveDir = '/sni-storage/wandell/users/tlian/360Scenes/ODS';
saveDir = fullfile(piRootPath,'local');

workingDir = fullfile(saveDir,'workingFolder'); % Save to data server directly to avoid limited space issues


% Check working directory
if(~exist(workingDir,'dir'))
    mkdir(workingDir);
end

% Check save directory
if(~exist(saveDir,'dir'))
    mkdir(saveDir);
end

% Setup gcloud
if(gcloudFlag)
    gCloud = gCloud('dockerImage','gcr.io/primal-surfer-140120/pbrt-v3-spectral-gcloud',...
        'cloudBucket','gs://primal-surfer-140120.appspot.com');
    gCloud.renderDepth = false;
    gCloud.clusterName = 'trisha';
    gCloud.maxInstances = 20;
    gCloud.init();
end


%% Select scene
[pbrtFile,rigOrigin] = selectBitterliScene(sceneName);
recipe = piRead(pbrtFile,'version',3);

%% Figure set camera location
recipe.set('from',rigOrigin);
recipe.set('to',rigOrigin + [0 0 -1]);
recipe.set('up',[0 1 0])

% Set render quality
recipe.set('filmresolution',filmResolution);
recipe.set('pixelsamples',pixelSamples);
recipe.integrator.maxdepth.value = bounces;

for ipd = [64]
    
    recipe.camera = struct('type','Camera','subtype','environment');
    angleTo = 90; angleFrom = 90;
    recipe.camera.ipd = struct('value',ipd*10^-3,'type','float');
    recipe.camera.poleMergeAngleTo = struct('value',angleTo,'type','float');
    recipe.camera.poleMergeAngleFrom = struct('value',angleFrom,'type','float');
    %recipe.convergencedistance = struct('value',1,'type','float'); % Default
    %is infinity
    
    sceneName = sprintf('ODS_%d_%d_%d_%d.pbrt',filmResolution(1),filmResolution(2),pixelSamples,bounces);
    recipe.set('outputFile',fullfile(saveDir,sceneName));
    
    % Split render into multiple pieces to be run on gCloud
    tileNumX = 4;
    tileNumY = 4;
    if(gcloudFlag)
        % See if tile num is a integer factor of the resolution
        tileWidthPx = filmResolution(1)/tileNumX;
        tileHeightPx = filmResolution(2)/tileNumY;
        if(mod(tileWidthPx,1) ~= 0 || mod(tileHeightPx,1) ~= 0 )
            error('Resolution needs to be a multiple of the tile number.')
        end
        cropSpacingX = linspace(0,1,tileNumX+1);
        cropSpacingY = linspace(0,1,tileNumY+1);
        
        count = 1;
        for xi = 1:tileNumX
            for yi = 1:tileNumY
                cropWindow{yi,xi} = [cropSpacingX(xi) cropSpacingX(xi+1) cropSpacingX(yi) cropSpacingX(yi+1)];
                % Make a new recipe for every window
                currRecipe = copy(recipe);
                currRecipe.set('cropwindow',cropWindow{yi,xi});
                currRecipe.set('outputFile',fullfile(saveDir,sprintf('%d_%d.pbrt',yi,xi)));
                allRecipes{count} = currRecipe;
                piWrite(currRecipe);
                count = count+1;
            end
        end
        
        
    else
        % Standard render
        piWrite(recipe);
        [scene, result] = piRender(recipe);
        
        vcAddObject(scene);
        sceneWindow;
        
        % Save the OI along with location information
        [~,n,e] = fileparts(sceneName);
        sceneFilename = fullfile(saveDir,strcat(n,'.mat'));
        save(sceneFilename,'ipd','angleTo','angleFrom');
    end
    
end

%% Render in gCloud

finalImage = cell(tileNumY,tileNumX);


if(gcloudFlag)
    
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
        
        % Get tile position
        oiName = oiGet(oi,'name');
        C = strsplit(oiName,'-');
        C = C{1};
        C = strsplit(C,'_');
        xIndex = str2double(C{2});
        yIndex = str2double(C{1});
        
        finalImage{yIndex,xIndex} = oiGet(oi,'photons');
        
    end
    
    finalPhotons = cell2mat(finalImage);
    oi = oiSet(oi,'photons',finalPhotons);
    vcAddAndSelectObject(oi);
    oiWindow;
    
    sceneName = sprintf('ODS_%d_%d_%d_%d.mat',filmResolution(1),filmResolution(2),pixelSamples,bounces);
    oiFilename = fullfile(saveDir,sceneName);
    
    save(oiFilename,'oi');
    fprintf('Saved oi at %s \n',oiFilename);
end
