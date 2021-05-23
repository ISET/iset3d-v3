
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Load recipe
thisR = piRecipeDefault('scene name', 'MacBethCheckerCus');

%% Check the lighting condition
piLightGet(thisR)
piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,...
                    'type', 'spot',...
                    'cone angle', 50,...
                    'camera coordinate', true);
%% 
piMaterialPrint(thisR)
piMaterialSet(thisR, 'InnerLeft', 'spectrumkd', 'spds/macbeth-4.spd');
piMaterialSet(thisR, idx, 'stringtype', 'matte');
tmp = piMaterialGet(thisR, 'idx', idx, 'param', 'name');

%% To determine the range of object depths in the scene

% [depthRange, depthHist] = piSceneDepth(thisR);
% histogram(depthHist(:)); xlabel('Depth (m)'); grid on
depthRange = [3.2668, 7.1679];  % Chess set distances in meters%% Write

%% Add camera with lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR = piCameraTranslate(thisR, 'x shift', 0.4,... 
                                 'z shift', -5);
thisR = piCameraRotate(thisR, 'y rot', -3);

% Set the focus into the middle of the depth range of the objects in the
% scene.
% d = lensFocus(lensfile,mean(depthRange));   % Millimeters
% thisR.set('film distance',d);
thisR.set('focal distance',mean(depthRange));

% This is the size of the film/sensor in millimeters (default 22)
thisR.set('film diagonal',33);
%% Write recipe

piWrite(thisR, 'overwritematerials', true);

%% Render

oi = piRender(thisR, 'render type', 'illuminant');
oiWindow(oi);
oi = oiSet(oi, 'fov', 2);

%% Create sensor model for calculation 
sensor = sensorIMX363;
% sensor = sensorSet(sensor, 'size', [600 600]);
sensor = sensorSet(sensor, 'auto exp', 1);
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), [], oi);
sensorGet(sensor, 'size')
sensor = sensorCompute(sensor, oi);

sensorWindow(sensor);
truesize;

%%  This is how to pull out data from an MCC
rPatch = 4; cPatch = 6;
cp = chartCornerpoints(sensor);
[rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,0.5);

rectHandles = chartRectsDraw(sensor,rects);
fullData = true;
data = cell(rPatch*cPatch,1);
thisLightData = chartPatchData(sensor,mLocs,(pSize(1)/2),fullData);

%%
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%%
cp = chartCornerpoints(ip);
[rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,0.5);
rectHandles = chartRectsDraw(ip,rects);
fullData = true;
data = cell(rPatch*cPatch,1);
thisLightData = chartPatchData(ip,mLocs,(pSize(1)/2),fullData);


%% End

