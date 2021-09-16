%% psf create
%
%  Simulating PSFs to compare the RTF method vs Omni method.  And
%  Zemax someday.
%

%% Init
clear;
ieInit;
if ~piDockerExists, piDockerConfig; end

thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';

%% Create the two cameras and choose a lens

cameraOmni = piCameraCreate('omni','lensfile','dgauss.22deg.3.0mm_aperture0.6_spectral.json');
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=0.002167;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=0.6;

cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.3.0mm.json-raytransfer-spectral.json');
cameraRTF.aperturediameter.value=0.6;
cameraRTF.aperturediameter.type='float';

% Collect up the cameras
cameras = {cameraOmni,cameraRTF};
oiLabels = {'cameraOmni','cameraRTF'};

%% Build the scene

% The scene is just the point array on the flat surface
pa = piAssetLoad('pointarray512');

thisR = pa.thisR;

piAssetSet(thisR,pa.mergeNode,'translate',[100 100 200]);


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


%% Add a grid of point sources (disk areas0
% Add a point source
radius_mm = 2;
depth_m = 0.5;
grid = [21 21];  % Make odd if you want a dot on optical axis
gridspacing_m = 0.05;
gridspacing_m = 0.005;
thisR     = piLightDelete(thisR, 'all');
lightGrid = piLightDiskGridCreate('depth',depth_m,'center', [0 0],'grid',grid,'spacing',gridspacing_m,'diskradius',radius_mm/1000);
piAddLights(thisR,lightGrid)

thisR.set('camera',cameraOmni);   
thisR.set('spatial resolution',1000*[1 1]);
thisR.set('rays per pixel',200);
thisR.set('film distance',0.002167);    % In meters  %Setting film distance does do something
thisR.set('film diagonal',5);

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
end

%%

save(fullfile(piRootPath,'local',['psf-depth_' num2str(depth_m) 'meters.mat']),'-v7.3')


