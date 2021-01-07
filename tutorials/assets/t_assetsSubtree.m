%% Chop and graft a subtree
%
% Assets are stored as trees.  We can add and remove subtrees, say taking
% one subtree for scene1 and moving it into scene2.
% 
% ZLY/BW
%
% See also
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Simple base scene
sceneName = 'simple scene';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

%% Select a subtree

thisR.assets.show;

% Get the subtree under the mirror branch
thisAssetName = 'mirror_B';

% Could become
%
%  thisR.get('asset',thisAssetName,'subtree');
%
id = thisR.get('asset', thisAssetName, 'id');
st = thisR.assets.subtree(id);
[~, st] = st.stripID([], true);
st.names
st.show;

%% Chop a subtree, deleting the black mirror

thisR.assets = thisR.assets.chop(id);
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Graft the subtree back onto the root

assetName = 'root';
thisR.set('asset', assetName, 'graft', st); % Graft the subtree under this asset.

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Extract the lighting subtree

id = thisR.get('asset', 'sky_B', 'id');
[st, index] = thisR.assets.subtree(id);
[~, st] = st.stripID([], true);
st.names
st.show;

%% Add the lighting to another scene

sceneName = 'sphere';
thisR = piRecipeDefault('scene name',sceneName);
thisR = piLightAdd(thisR, 'type', 'distant', ...
    'light spectrum', [9000 0.001],...
    'camera coordinate', true);

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

thisR.assets.show;

%%  Not yet understood.  Ask ZLY

% We add the light onto the root of the Sphere scene.  That works, but the
% rendering doesn't make sense to me.

assetName = 'root';
thisR.set('asset', assetName, 'graft', st); % Graft the subtree under this asset.
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

%%