%% Set up a simple scene as an example
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'simple scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 
thisR.assets.show;

%% Select the subtree
thisAssetName = 'mirror_B';
id = thisR.get('asset', thisAssetName, 'id');
[st, index] = thisR.assets.subtree(id);
[~, st] = st.stripID([], true);

%% Plot the subtree
st.show;
% Save
outPath = fullfile(piRootPath, 'local', 'simplesceneST.mat');
save(outPath, 'st');

%% Chop the tree
thisR.assets = thisR.assets.chop(id);
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Merge the subtree back
assetName = 'root';
thisR.set('asset', assetName, 'graft', st); % Graft the subtree under this asset.
thisR.assets.show;

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Another example
thisAssetName = 'Sphere_O';
thisSt = thisR.get('asset', thisAssetName, 'subtree');
thisR.set('asset', thisAssetName, 'chop');
thisR.assets.show;

% Graft the tree under
thisR.set('asset', 'figure_6m_B', 'graft', thisSt);
thisR.assets.show;

% Shift the sphere towards camera by 1m
thisR.set('asset', thisAssetName, 'world translate', [0 0 -1]);
thisR.set('asset', thisAssetName, 'scale', 0.3);

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
