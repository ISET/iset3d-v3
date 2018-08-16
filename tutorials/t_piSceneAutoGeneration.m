%% Test a pbrtv3 scene with material property modified.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
%% Scene Autogeneration by parameters
sceneType = 'city';
roadType = 'crossroad';
trafficflowDensity = 'medium';
dayTime = 'day';
timestamp = 100;
nScene = 1;
% Return an array of render recipe according to given number of scene.
thisR_scene = piSceneAuto('sceneType',sceneType,...
                        'roadType',roadType,...
                        'trafficflowDensity',trafficflowDensity,...
                         'dayTime',dayTime,...
                         'timeStamp',timestamp,...
                          'nScene',nScene);






%% Render irradiance

tic, irradianceImg = piRender(thisR_scene); toc
ieAddObject(irradianceImg); sceneWindow;

%% Label the pixels by mesh of origin
meshImage = piRender(thisR_scene,'renderType','mesh'); 
vcNewGraphWin;imagesc(meshImage);colormap(jet);title('Mesh')

%% Create a label map
labelMap(1).name = 'road';
labelMap(1).id = 1;
labelMap(1).name = 'car';
labelMap(1).id = 2;
labelMap(1).color = [0 0 1];
labelMap(2).name='person';
labelMap(2).id = 3;
labelMap(2).color = [0 1 0];
labelMap(3).name='truck';
labelMap(3).id = 4;
labelMap(3).color = [1 0 0];
labelMap(4).name='bus';
labelMap(4).id = 5;
labelMap(4).color = [1 0 1];

%% Get bounding box

obj = piBBoxExtract(thisR_scene, scene_2, irradianceImg, meshImage, labelMap);

% obj = piBBoxExtract(thisR_scene, scene_2, assets, irradianceImg, meshImage, labelMap);
 
%% Change the camera lens
%{ 
% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% thisR.version can tell us, but piCameraCreate does not take a thisR as
% input. For now let's put things in manually. 

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat');
thisR.camera.lensfile.value = lensFile;
% exist(lensFile,'file')

% Attach the lens
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 1; % mm
thisR.camera.aperturediameter.type = 'float';

% Focus at roughly meter away. 
thisR.camera.focusdistance.value = 1; % meter
thisR.camera.focusdistance.type = 'float';

% Use a 1" sensor size
thisR.film.diagonal.value = 16; 
thisR.film.diagonal.type = 'float';
%}