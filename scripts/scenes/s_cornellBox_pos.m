% s_cornellBox_pos
% Used to illustrate how to set object position at absolute world
% positions.

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

% Note: When you want to move the same object again, be sure to use the new
% node returned as the position marker of where the object is.
[~, newRoot] = thisR.set('asset', rootST1.name, 'world position', [0.012 0.028 0.125]);

%% Write and render
piWrite(thisR);
% Render 
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);

%% Move the checker board to another place
[~, newRoot] = thisR.set('asset', newRoot.name, 'world position', [0.025 0.05 0.005]);

%% Write and render
piWrite(thisR);
% Render 
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);

%% Move the checker board to another place
[~, newRoot] = thisR.set('asset', newRoot.name, 'world position', [-0.08 0.04 -0.1]);

%% Write and render
piWrite(thisR);
% Render 
[scene, result] = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);