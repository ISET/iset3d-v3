%%
% Example of rendering a cornell box specified with: (1) Setting the
% rendering parameters, (2) positioning the camera, (3) adding a lens, (4)
% write the recipe, (5)render irradiance and (6) compute the sensor image.

%% Initialize ISET and Docker
% Setup ISETcam and ISET3d system.
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
% The recipe includes all information of PBRT to do the rendering
thisR = cbBoxCreate;

%% Modify new rendering settings
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 

%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 25 cm from the front edge. The position of the 
% camera should be set to 25 + 15 = 40 cm from the origin
from = thisR.get('from');
newFrom = [0 0.125 -0.40]; % This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Add MCC
assetTreeName = 'mccCB';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);
T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003 0.125]);

%% Add bunny
assetTreeName = 'bunny';
[~, rootST2] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);

%% Build a lens
% List existing lens models
lensList;

lensfile = 'wide.77deg.4.38mm.json';
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('focus distance', 0.5);
thisR.set('film diagonal', 7.04); % mm

%% Write and render
tic
piWrite(thisR);
toc
% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = 'CBLens';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);

%%
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'exp time', 5e-3);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

%%
ip = ipCreate;
ip = ipCompute(ip, sensor);
ipWindow(ip);
ip = ipSet(ip, 'gammadisplay', 0.5);
