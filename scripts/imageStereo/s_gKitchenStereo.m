%% s_gKitchenStereo
%
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Init a default recipe 

% This the MCC scene
thisR = piRecipeDefault('scene name','kitchen');
fromOrig = thisR.get('from');

thisR.summarize;
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);

%%
oDist = thisR.get('object distance');
thisR.set('object distance',oDist - 0.2);

thisR.summarize;
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);

%%
thisR.set('from',fromOrig + [0 0 -0.5]);
thisR.summarize;
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);

%%
scenePlot(scene,'depth map');


%%
