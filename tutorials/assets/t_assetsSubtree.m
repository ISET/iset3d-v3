%% Assets: chop and graft a subtree
%
% Assets are stored as trees.  We can add (graft) and remove (chop)
% subtrees. This script chops a subtree and restores it.  It also copies a
% lighting tree from the SimpleScene to a sphere scene.  
% 
% ZLY/BW
%
% See also 
%   tls_assets.mlx
%

%% Initialize
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Simple base scene

sceneName = 'simple scene';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%% Render

piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Select a subtree

% Show the whole tree
thisR.assets.show;

% Get the subtree under the black mirror
assetName = 'mirror_B';
mirrorSubtree = thisR.get('asset',assetName,'subtree');

% The subtree is just another tree.
mirrorSubtree.names

%% Chop off the black mirror subtree

id = thisR.get('assets',assetName,'id');
thisR.assets = thisR.assets.chop(id);

% Notice that the mirror_B is now gone.
thisR.assets.show;

%% Render without the black mirror

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name',sprintf('%s - mirror removed',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Graft the subtree back onto the root and render

% We can do this because we snagged it before chopping
assetName = 'root';
thisR.set('asset', assetName, 'graft', mirrorSubtree);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name',sprintf('%s - mirror restored',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Extract the lighting subtree

assetName = 'sky_B';
lightingSubtree = thisR.get('assets',assetName,'subtree');
lightingSubtree.names
lightingSubtree.show;

%% Render another scene

sceneName = 'sphere';
thisR = piRecipeDefault('scene name',sceneName);
blueLight = piLightCreate('blueLight','type', 'distant', ...
    'spd', [9000 0.001],...
    'cameracoordinate', true);
thisR.set('light','add',blueLight);

thisR.assets.show;

piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);

%% Add first scene lighting to the sphere scene

assetName = 'root';
thisR.set('asset', assetName, 'graft', lightingSubtree); 
thisR.assets.show;

piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s - light added',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% END

