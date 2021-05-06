%% Assets: chop and graft a subtree
%
% Assets are stored as trees.  We can add (graft) and remove (chop)
% subtrees, say taking one subtree for scene1 and moving it into scene2.
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
%
% Show the tree
thisR.assets.showUI;
thisR.assets.show;

% Get the subtree under the black mirror branch
%
% This sequence might eventually become
%   thisR.get('asset',thisAssetName,'subtree');
thisAssetName = 'mirror_B';
id = thisR.get('asset', thisAssetName, 'id');
mirrorSubtree = thisR.assets.subtree(id);
[~, mirrorSubtree] = mirrorSubtree.stripID([], true);

% The subtree is just another
% tree.
mirrorSubtree.names
mirrorSubtree.show;

%% Chop off a subtree, deleting the black mirror
thisR.assets = thisR.assets.chop(id);
thisR.assets.show;

% Render without the black mirror
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name',sprintf('%s - mirror removed',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Graft the subtree back onto the root
% 
% We can do this because we snagged it before chopping
assetName = 'root';
thisR.set('asset', assetName, 'graft', mirrorSubtree);

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name',sprintf('%s - mirror restored',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Extract the lighting subtree
id = thisR.get('asset', 'sky_B', 'id');
[lightingSubtree, index] = thisR.assets.subtree(id);
[~, lightingSubtree] = lightingSubtree.stripID([], true);
lightingSubtree.names
lightingSubtree.show;

%% Render another scene
sceneName = 'sphere';
thisR = piRecipeDefault('scene name',sceneName);
thisR = piLightAdd(thisR, 'type', 'distant', ...
    'light spectrum', [9000 0.001],...
    'camera coordinate', true);
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Add first scene lighting to second
%
% Adding works, but we don't fully understand the rendering itself.
%
% Needs a little more thought and explanation.
assetName = 'root';
thisR.set('asset', assetName, 'graft', lightingSubtree); 
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s - light added',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Add the mirror to the sphere scene
%
% Adding works, but the mirror isn't visible. Maybe not in the FOV?
%
% Needs a little more thought and explanation.
assetName = 'root';
thisR.set('asset', assetName, 'graft', mirrorSubtree); 
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s - mirror added',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

