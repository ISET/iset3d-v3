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

% Add a point source
thisR     = piLightDelete(thisR, 'all');
radius_mm = 2;
lightGrid = makeDiskGrid('depth',1,'center', [0 0],'grid',[101 101],'spacing',0.05,'diskradius',radius_mm/1000);
addGridToRecipe(thisR,lightGrid)



thisR.show('objects');


% Try a camera now

thisR.set('camera',cameraOmni);   
thisR.set('spatial resolution',300*[1 1]);
thisR.set('rays per pixel',10);
thisR.set('focus distance',.1);    % In meters   % Q: CHanging this helps nothing?
thisR.set('film distance',0.002167);    % In meters  %Setting film distance does do something
thisR.set('film diagonal',5);


piWrite(thisR)
oi = piRender(thisR,'render type','radiance');
figure(1);clf;
imagesc(oi.data.photons(:,:,1))



%%
%thisR.set('asset','pointarray_512_64-1712','scale',[5 5 1]);
% pa.thisR.set('asset','pointarray_512_64-1712','translate',[0 0 20000]); % Move it 2 meters further

%thisR.set('asset','face-2425','worldtranslate',[0 0 -3]); % Put closer STILL GETS IMAGED???
%thisR.set('asset','face-2425','translate',[0 0 -100]); % Put closer STILL GETS IMAGED???


thisR.show('objects');

% thisR.outputFile= '/home/thomas42/Documents/MATLAB/iset3d/local/flatSurface/flatSurface.pbrt'
piWrite(thisR)
piAssetGeometry(thisR);

%% Compare the two cameras


for c=1:numel(cameras)
    %piWRS(thisR);
    
    thisR.camera = cameras{c};
    
    
    thisR.set('spatial resolution',300*[1 1]);
    thisR.set('rays per pixel',10);
    
    
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
    
    close all
    
    oi{c}.name=oiLabels{c};
    
    toc;
end

%%
save(fullfile(piRootPath,'local','psffar.mat'),'-v7.3')


