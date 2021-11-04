%% Script with charts at different depths and positions 
% This script is written as part of a class project on autofocus  psych211 
%
% The aim is to generate a scene with objects at controllable depths 
% Supervised by thomas goossens

ieInit;


thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';



%% Determine necessary radius of target
filmdistance_mm=37.959 % mm
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
bb=lens.bbmGetValue('all')




%% Create the two cameras and choose a lens
lensname='dgauss.22deg.50.0mm_aperture6.0';
cameraOmni = piCameraCreate('omni','lensfile',[lensname '.json']);
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm/1000;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=12;

cameras = {cameraOmni}; oiLabels = {'cameraOmni'};

%% Build the scene

thisR=piRecipeDefault('scene name','flatsurface');


% Aligned along z axis

% Set camera and camera position
filmZPos_m           = -1.5;
thisR.lookAt.from= [0 0 filmZPos_m];
thisR.lookAt.to = [0 0 0];




%% Calculate equivalent position
principalIm = lens.BBoxModel.imSpace.principalPoint(1);
principalObj = lens.BBoxModel.obSpace.principalPoint(1);
focalObj= lens.BBoxModel.obSpace.focalPoint(1);
focalIm= lens.BBoxModel.imSpace.focalPoint(1);

fObj = abs(focalObj-principalObj)
fIm = abs(focalIm-principalIm)

%Desired image angle and hence image height
him_mm = 3/2
zim=(filmdistance_mm-principalIm);
uim = atand(him_mm/zim)

% Object height inferred from same angle in nodal point
distanceFromFilm_mm=5000
zobj_mm=((distanceFromFilm_mm)-abs(filmdistance_mm-principalObj))
uobj = uim
hobj_mm=zobj_mm*tand(uobj) 

hobj_meter=hobj_mm/1000
%%



lens.bbmGetValue('objectfocalpoint')


% add char
scale = 0.1
piChartAddatDepth(thisR,3,[0 0],scale);
piChartAddatDepth(thisR,3,[0.1 0],scale);
piChartAddatDepth(thisR,distanceFromFilm_mm/1000,[-hobj_meter 0],scale);



% 
%% Set Camera
thisR.set('camera',cameraOmni);
thisR.set('spatial resolution',600*[1 1]);
thisR.set('rays per pixel',10);
thisR.set('film diagonal',20); % Original



%% Set integrator

thisR.integrator.subtype = 'path';
thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1;


%% Write and render

piWrite(thisR);

disp('start render')
[oi,results] = piRender(thisR,...
    'docker image name',thisDocker, ...
    'render type','radiance');




%%
oiWindow(oi)