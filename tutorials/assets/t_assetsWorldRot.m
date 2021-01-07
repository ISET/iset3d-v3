%% Rotation examples in object and world coordinates
%
%  ZLy/BW
%
% See also
%  t_assetsWorldPos, t_assets*
%

%%  Initialize

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set up a simple scene as an example

thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Setting a rotation for this asset

% This is the blue stick figure at 3 meters distance
assetName = 'figure_3m_O';

initialAng = thisR.get('asset', assetName, 'world rotation angle');
disp(initialAng)

% First rotation
[~,R1] = thisR.set('asset', assetName, 'rotation', [0 90 45]);

% Check rotation angle
rotAng = thisR.get('asset', assetName, 'world rotation angle');
disp(rotAng)

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Check if we can use the rotation angle to reproduce the rotation.

% Delete the rotation we applied above
thisR.set('asset', R1.name, 'delete');

% Apply the rotation angle
thisR.set('asset', assetName, 'rotation', rotAng);

% Render
piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Now rotate two assets, specified in world space

thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',64);  % A few more rays

% Zoom a bit
thisR.set('fov',25);
thisR.set('nbounces',5); 

thisR.set('asset', 'figure_3m_O', 'world rotate', [0 0 90]);
thisR.set('asset', 'figure_6m_O', 'world rotate', [0 0 90]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% END