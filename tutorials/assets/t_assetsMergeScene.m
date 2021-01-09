%% Shows how to take assets from one scene and add to another
%
% Description:
%    Show how to take assets from one scene and add them into
%    another.
%
%    Currently mysterious in several places, as indicated BY COMMENTS IN
%    ALL CAPS inserted in the code below.
%
% See also tls_assets.mls

%% History
%    01/09/21  dhb  Added comments about things that I don't understand.

%% Initialize
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set up and render the simple scene as an example
sceneName = 'simple scene';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Render
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('%s',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Get and render a second scene (the coordinate scene)
%
% THIS SHOWS UP AS ENTIRELY BLACK, FOR REASONS I DON'T UNDERSTAND.  MAYBE
% THE COORDINATE SCENE DOES NOT HAVE A LIGHT SOURCE.  NEED TO EXPLAIN HERE.
assetSceneName = 'coordinate';
assetR = piRecipeDefault('scene name', assetSceneName);
assetR.assets.show;
assetR.set('film resolution',[200 150]);
assetR.set('rays per pixel',32);
assetR.set('fov',45);
assetR.set('nbounces',5); 

% Render
piWrite(assetR);
scene = piRender(assetR);
scene = sceneSet(scene,'name',sprintf('%s',assetSceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Add the coordinate scene assets to the simple scene
%
% Get the subtree from the coordinate scene to add.  
coordSubtreeName = 'Coordinate_B';
coordSubtree = assetR.get('asset', coordSubtreeName, 'subtree');

% Graft the extracted subtree under the root of the simple scene.
%
% THIS FIRST ONE DOESN'T HAVE ANY OBVIOUS VISIBLE EFFECT.  WHY NOT?
% DELETING IT MESSES UP THE ID NUMBERING AND BREAKS CODE BELOW, SO I LEFT
% IT IN.
thisR.assets.show;
assetName = 'root';
[~,addedSubtree1] = thisR.set('asset', assetName, 'graft', coordSubtree);

% Also graft it under the blue guy node of the simple scene
assetName = 'figure_3m_B';
[~,addedSubtree2] = thisR.set('asset', assetName, 'graft', coordSubtree);
thisR.assets.show;

%% Check the world position
%
% NOT CLEAR WHY WE ARE DOING THIS HERE.  IF THIS STAYS IN, EXPLAIN WHAT
% 'world position' IS, AND WHY WE WNAT TO KNOW IT FOR THE TWO ID'S WHERE IT
% IS GOTTEN.
names = thisR.assets.names;
posCoor = thisR.get('asset', '039ID_origin_O', 'world position');
posCoor2 = thisR.get('asset', '052ID_origin_O', 'world position');

% Translate added coordinate asset a little
%
% You have to know it's the 040ID version of the subtree, which you can
% figure out by using thisR.assets.print.  The particular translation was 
% chosen by hand.
%
% SAY WHERE THE GRAFTED SUBTREE ENDS UP IN SPACE BY DEFAULT.  THAT WOULD BE
% VERY HELPFUL IN UNDERSTANDING THESE OPERATIONS.
[~,T1] = thisR.set('asset', '040ID_Coordinate_B', 'translate', [-0.1 0 0]);

% Write and render
%
% If you look closely, you can see a vertical yellow bar in the distance,
% just to the left of the blue guy, that wasn't there before.
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name',sprintf('%s - coord added',sceneName));
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Add elements from the coordinate scene in another way
%
% First chop the two coordinate tree elements we added above
% back off again.
thisR.set('asset', addedSubtree1.name, 'chop');
thisR.set('asset', addedSubtree2.name, 'chop');
thisR.assets.show;

% Graft with materials and then scale and translate.
%
% NOT SURE HOW IT FINDES THE 'coordinate' assetTreeName BECAUSE I DON'T SEE
% THAT IN THE TREE AT THIS POINT.
%
% EXPLAIN HERE HOW 'graft with materials' DIFFERS FROM PLAIN OLD 'graft'.
assetTreeName = 'coordinate';
[~,rootST3] = thisR.set('asset', assetName, 'graft with materials', assetTreeName);
thisR.set('asset', rootST3.name, 'scale', 3);
[~,T2] = thisR.set('asset', rootST3.name, 'translate', [-0.5 0 0]);

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');