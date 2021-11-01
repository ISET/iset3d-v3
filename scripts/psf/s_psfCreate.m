%% psf create
%
%  Simulating PSFs to compare the RTF method vs Omni method.  And
%  Zemax someday.
%

ieInit;


thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';



%% Determine necessary radius of target
filmdistance_mm=36.990 % mm 
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
bb=lens.bbmGetValue('all')




%% Gaussian equations. Knowing z=0 at rear surface vertex by construction
scale=1
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);

objdistance_mm_fromfront = 1400; %Relative to rear surface vertxof lens
objdistance_mm_fromrear= objdistance_mm_fromfront+lensThickness %Relative to film position
objdistance_mm_fromfilm= objdistance_mm_fromrear+filmdistance_mm; %Relative to film position

diskradius_mm = 0.1/10;
impoint=lens.findImagePoint([0 diskradius_mm -objdistance_mm_fromrear],1,1)
spotsize_micron = impoint(1,2)*1e3
z_im_mm = impoint(1,3)




%% Create the two cameras and choose a lens
lensname='dgauss.22deg.50.0mm_aperture6.0';
cameraOmni = piCameraCreate('omni','lensfile',[lensname '.json']);
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm/1000;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=12;

cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.3.0mm_aperture0.6-raytransfer-spectral.json');
cameraRTF.aperturediameter.value=12;
cameraRTF.aperturediameter.type='float';

% Collect up the cameras
cameras = {cameraOmni,cameraRTF}; oiLabels = {'cameraOmni','cameraRTF'};

cameras = {cameraOmni}; oiLabels = {'cameraOmni'};

%% Build the scene

% The scene is just the point array on the flat surface

% General rules on naming
%
%   nsNounAction
%
% And when possibly in a protected name space or part of an object.
% So for example,
%
%     piAssetLoad, rather than loadAsset
%
% That way, piAsset<TAB> returns all the methods that deal with assets
% piLoad<TAB> would

% Suppose we an empty recipe, emptyR.
% Could we do this?
%
%   emptyR.create('grid');
%

%  Point source properties

grid = [21 21];  % Make odd if you want a dot on optical axis

gridspacing_m = 0.1;


% Find a good spot size and then scale accordingly
radiusREF_mm=diskradius_mm;
depthREF_m = objdistance_mm_fromfilm/1000;


depths = round([0.5 1],1);
depths=[depthREF_m]

for d=1:numel(depths)
    depth_m = depths(d);
    
    % Scale spotradius 
    scale = depth_m/depthREF_m;

    radius_mm =radiusREF_mm*scale;
    
    %% Build scene
    pa = piAssetLoad('pointarray512');
    
    thisR = pa.thisR;
    
    piAssetSet(thisR,pa.mergeNode,'translate',[100 100 200]);


    %% Add a grid of point sources (disk areas0

    
    
    
    thisR     = piLightDelete(thisR, 'all');
    lightGrid = piLightDiskGridCreate('depth',depth_m,'center', [0 0],'grid',grid,'spacing',gridspacing_m,'diskradius',radius_mm/1000);
    piAddLights(thisR,lightGrid)
    
    thisR.set('camera',cameraOmni);
    thisR.set('spatial resolution',600*[1 1]);
    thisR.set('rays per pixel',50000);
    %thisR.set('film distance',0.0466356);    % In meters  %Setting film distance does do something
    
    thisR.set('film diagonal',70*1e-3; % Original
    
    

    %% Compare the two cameras
    
    
    for c=1:numel(cameras)
        %piWRS(thisR);
        
        thisR.camera = cameras{c};
        
        
        
        thisR.show('objects');
        
        thisR.integrator.subtype = 'path';
        thisR.integrator.numCABands.type = 'integer';
        thisR.integrator.numCABands.value = 1;
        
        tic;
        piWrite(thisR);
        pause(10)
        disp('start render')
        [obj,results] = piRender(thisR,...
            'docker image name',thisDocker, ...
            'render type','radiance');
        oi{c}=obj;
        oi{c}.name=oiLabels{c};
        
        toc;
        
        % Put it within loop to allow for intermediary backup
        save(fullfile('/usr/local/scratch/thomas42/psf/',[lensname '-psf-depth_' num2str(depth_m) 'meters.mat']),'-v7.3')
    
    end
    
    %%
    
    
end

