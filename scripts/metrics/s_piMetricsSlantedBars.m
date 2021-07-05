%% Add slanted bar charts to the simple scene

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Make the chart, simple scene, and merge

thisR = piRecipeDefault('scene name','simple scene');
thisR.set('assets','Camera_B','delete');
thisR.set('assets','001_mirror_O','delete');

% Load the chart recipe and merge node
eiachart = load('EIA.mat');

% Merge
piRecipeMerge(thisR,eiachart.thisR,'node name',eiachart.mergeNode);

% Assign the chart a position in this scene
piAssetSet(thisR,eiachart.mergeNode,'translate',[-2 1.5 0]);

% Render
piWRS(thisR);

% thisR.show;

%% Add a second chart
% [chartR, chart.mergeNode]  = piChartCreate('grid lines');

chart = load('macbeth.mat');
piRecipeMerge(thisR,chart.thisR,'node name',chart.mergeNode);

piAssetSet(thisR,chart.mergeNode,'translate',[0.5 2.5 0]);

piWRS(thisR);

%% A third chart
chart = load('slantedbar.mat');
piRecipeMerge(thisR,chart.thisR,'node name',chart.mergeNode);
piAssetSet(thisR,chart.mergeNode,'translate',[3 3 6]);

piWRS(thisR);

%%  I would like to control the chart reflectance

% The chess set with pieces
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
chart = load('EIA.mat');

% Merge them
piRecipeMerge(chessR,chart.thisR,'node name',chart.mergeNode);

% wRotate = chessR.get('asset', eiachart.mergeNode, 'rotation', rotMatrix);

% Position and scale the chart
piAssetSet(chessR,chart.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',chart.mergeNode,'scale');
piAssetSet(chessR,chart.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this

% piWRS(chessR); % Quick check

gridchart = load('gridlines.mat');

piRecipeMerge(chessR,gridchart.thisR,'node name',gridchart.mergeNode);

piAssetSet(chessR,gridchart.mergeNode,'translate',[0.1 0.2 0.2]);
thisScale = chessR.get('asset',gridchart.mergeNode,'scale');
piAssetSet(chessR,gridchart.mergeNode,'scale',thisScale.*[0.05 0.05 0.05]);  % scale should always do this

% z y x
rotMatrix = [-35 10 0; fliplr(eye(3))];
piAssetSet(chessR, gridchart.mergeNode, 'rotation', rotMatrix);

%% Color chart
mccchart = load('macbeth.mat');

% [chartR, mccchart.mergeNode]  = piChartCreate('macbeth');
piRecipeMerge(chessR,mccchart.thisR,'node name',mccchart.mergeNode);
piAssetSet(chessR,mccchart.mergeNode,'translate',[-0.2 0.3 0.7]);
thisScale = chessR.get('asset',mccchart.mergeNode,'scale');
piAssetSet(chessR,mccchart.mergeNode,'scale',thisScale.*[0.1 0.1 0.1]);  % scale should always do this

%{
 chessR.show('objects');
 chessR.set('spatial resolution',[160 160]);
 chessR.set('rays per pixel',8);
 piWRS(chessR); % Quick check
%}

%% High resolution
chessR.set('spatial resolution',[1024 1024]);
chessR.set('rays per pixel',128);
piWRS(chessR);

% chessR.show;

%% Add the bunny into the simple scene

thisR = piRecipeDefault('scene name','simple scene');
thisR.set('assets','Camera_B','delete');
thisR.set('assets','001_mirror_O','delete');
bunnychart = load('bunny.mat');
piRecipeMerge(thisR,bunnychart.thisR,'node name',bunnychart.mergeNode);

thisScale = thisR.get('asset',bunnychart.mergeNode,'scale');
piAssetSet(thisR,bunnychart.mergeNode,'scale',thisScale.*[10 10 10]);  % scale should always do this
piAssetSet(thisR,bunnychart.mergeNode,'translate',[0 0 -10]);  % scale should always do this

% piAssetGeometry(thisR);
% piWRS(thisR);

%%  Some other scenes.  Hand editing here.  Fix!!! so that is not needed.

kitchenR = piRecipeDefault('scene name','kitchen');

% [chartR, eiachart.mergeNode, eiaName]  = piChartCreate('eia');
% kitchenR.assets = chartR.assets;

piRecipeMerge(kitchenR,chartR,'node name',eiachart.mergeNode);
kitchenR.get('asset',eiachart.mergeNode,'translate')
d = kitchenR.get('look at direction');
from = kitchenR.get('from');
piAssetSet(kitchenR,eiachart.mergeNode,'translate',from + 3*d);
thisScale = kitchenR.get('asset',eiachart.mergeNode,'scale');
piAssetSet(kitchenR,eiachart.mergeNode,'scale',thisScale*0.3);

kitchenR.show('objects')
kitchenR.exporter = 'C4D';


kitchenR.set('spatial resolution',[1024 1024]);
kitchenR.set('rays per pixel',512);

piWrite(kitchenR);
% I edited scene.pbrt to add
% Include "scene_geometry.pbrt"
scene = piRender(kitchenR,'render type','radiance');
sceneWindow(scene);
% scene = piAIdenoise(scene);
% sceneWindow(scene);
%%
whiteR = piRecipeDefault('scene name','white-room');
whiteR.exporter = 'C4D';
[chartR, eiachart.mergeNode]  = piChartCreate('macbeth');

piRecipeMerge(whiteR,chartR,'node name',eiachart.mergeNode);

d = whiteR.get('look at direction');
from = whiteR.get('from');
piAssetSet(whiteR,eiachart.mergeNode,'translate',from + 3*d);

thisScale = whiteR.get('asset',eiachart.mergeNode,'scale');
piAssetSet(whiteR,eiachart.mergeNode,'scale',thisScale*1);

whiteR.set('spatial resolution',[320 320]);
whiteR.set('rays per pixel',16);

% piAssetGeometry(whiteR)
% Include "scene_geometry.pbrt"
piWrite(whiteR);
% I edited scene.pbrt to add
% Include "scene_geometry.pbrt"
scene = piRender(whiteR,'render type','radiance');
sceneWindow(scene);
scene = piRender(kitchenR,'render type','radiance');
sceneWindow(scene);

%{
whiteR.show('objects')
whiteR.set('spatial resolution',[1024 1024]);
whiteR.set('rays per pixel',512);
piWrite(whiteR);
% I edited scene.pbrt to add
% Include "scene_geometry.pbrt"
%}
scene = piRender(whiteR,'render type','radiance');
sceneWindow(scene);

% scene = piAIdenoise(scene);
% sceneWindow(scene);



%%
%{
%%  We did not set up the independent textures correctly

[chartR, chart.mergeNode, oName] = piChartCreate('EIA');
mergedR = piRecipeMerge(thisR,chartR,'node name',chart.mergeNode);
piAssetSet(mergedR,chart.mergeNode,'translate',[2 1 0]);
piWRS(mergedR);

% scene = piWRS(thisR);
% piAssetGeometry(thisR, 'inplane','xz');
% piAssetGeometry(thisR,'inplane','xy');

%%
%%  Read the scene and add a light

flatR = piRecipeDefault('scene name','flatsurface');

% Add a light
distantLight = piLightCreate('distant','type','distant',...
    'spd', [9000 0.001], ...
    'cameracoordinate', true);
flatR.set('light','add',distantLight);

%% Point the camera

% Find the position of the surface
surfaceName = '001_Cube_O';
% xyz = thisR.get('asset',surfaceName,'world position');
% thisR.get('object size',surfaceName)

flatR.set('asset',surfaceName,'world position',[0 -10 0]);
sz = flatR.get('asset',surfaceName,'size');
flatR.set('asset',surfaceName,'scale', (1 ./ sz));

% flatR.set('asset',surfaceName,'scale',5e-4);
% piAssetGeometry(thisR);

% Aim the camera at the object and bring it closer.
flatR.set('from',[0,3,0]);
flatR.set('to',  [0,2.5,0]);

%{
flatR.get('asset',surfaceName,'world position')
flatR.get('asset',surfaceName,'size') 
piWRS(flatR);
piAssetGeometry(flatR,'size',true);
%}

%% Create a texture

% textureName = 'example';
% imgFile   = 'pngExample.png';

textureName = 'EIAChart';
% imgFile   = 'EIA1956-300dpi-top.png';
% imgFile   = 'EIA1956-300dpi.png';
imgFile   = 'EIA1956-300dpi-center.png';
flatR.get('asset',surfaceName,'size')

% textureName = 'face';
% imgFile   = 'monochromeFace.png';

%{
% We would like to make the size of the surface equal to the size of the
% image texture.  This is a start
foo = imread(imgFile);
flatR.get('asset',surfaceName,'size')
% Compare the row/col and object size.  crop the image or change the asset
% size
%}
chartTexture = piTextureCreate(textureName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', imgFile);

surfaceMaterial = flatR.get('asset',surfaceName,'material');
flatR.set('texture', 'add', chartTexture);

% flatR.get('texture print');

flatR.set('material', surfaceMaterial.name, 'kd val', textureName);
% flatR.show('assetsmaterials');

flatR.set('spatial samples',[320,320]);

%%
% flatR.set('assets',surfaceName,'rotate',[30 20 10]);

%% Write and render
% piWrite(thisR, 'overwritematerials', true);
piWrite(flatR);
scene = piRender(flatR,'render type','radiance');
sceneWindow(scene);

%%  Now put the chart inside the simple scene

simpleR = piRecipeDefault('scene name','simple scene');

%%

% Lose the annoying mirror at the top of the scene
simpleR.set('asset','001_mirror_O','delete');

% Get the flat surface from the flatR recipe and add it to the simpleR
flatSurface = flatR.get('asset','001_Cube_O');
simpleR.set('asset','root','add',flatSurface);

% Add the flat surface material
surfaceMaterial = flatR.get('asset',flatSurface.name,'material');
simpleR.set('material','add',surfaceMaterial);

% Add the chart texture, which is needed by the texture
simpleR.set('texture', 'add', chartTexture);
% simpleR.get('texture print');

% This adds the axis from the coordinate.mat subtree
% [~,axisTree] = simpleR.set('asset','root','graft with materials','coordinate');
fig6pos = simpleR.get('asset','001_figure_6m_O','world position');
fig3pos = simpleR.get('asset','001_figure_3m_O','world position');

% Change the position, scale and rotation
% simpleR.set('asset','001_Cube_O','world position',[-0.5 0.7 -11]);
simpleR.set('asset','001_Cube_O','world position',fig3pos + [-0.3 0 0]);
simpleR.set('asset','001_Cube_O','scale',3e-4);
simpleR.set('asset','001_Cube_O','rotate',[90 0 0]);
simpleR.set('asset','001_Cube_O','translate',[0 0 0]);

simpleR.set('spatial samples',[320,320]*2);

%
% [assetTree, matList] = piAssetTreeLoad('coordinate');
% simpleR.set('assets','root','graft',assetTree);
% simpleR.set('assets','graft',assetTree);
%

% simpleR.set('asset',axisTree.name,'world position',fig6 + [0.3 0.3 0.3]);

% Copy and add to a new position.  We should use piTreeSave/Load to create
% this test chart.
% We should be able to have
% [~,axisTree] = simpleR.set('asset','root','graft with materials','EIAChart');
flatSurface = simpleR.get('asset','001_Cube_O');
flatSurface.name = '002_Cube_O';
simpleR.set('asset','root','add',flatSurface);
% simpleR.set('asset','002_Cube_O','world position',[0.5 0.7 -11]);
simpleR.set('asset','002_Cube_O','world position',fig6pos + [-0.3 0 0]);
simpleR.set('asset','002_Cube_O','scale',3e-4);
simpleR.set('asset','002_Cube_O','rotate',[90 0 0]);

% simpleR.set('asset','001_Cube_O','delete');

%%
% simpleR.show;
% piAssetGeometry(simpleR,'size',true);
piWrite(simpleR);
scene = piRender(simpleR,'render type','radiance');
sceneWindow(scene);
%% Render with the Chess Set
% 0051ID_001_Lyse_brikker_008-103740_O - close
% 0059ID_001_Mrke_brikker_004-231090_O - far

chessR = piRecipeDefault('scene name','chess set pieces');
% chessR.set('asset',59,'translate',[0 0.1 0]);
% chessR.set('asset',51,'translate',[0 0.05 0]);
chessR.get('asset',51,'size')
fig1Pos = chessR.get('asset',51,'world position');

% Get the flat surface with the image texture.  This should become a graft
% with material call.
flatSurface = simpleR.get('asset','001_Cube_O');
chessR.set('asset','root','add',flatSurface);
chessR.set('asset','001_Cube_O','world position',fig1Pos + [0 -0.2 0]);
chessR.set('asset','001_Cube_O','rotate',[90 0 0]);
chessR.set('asset','001_Cube_O','scale',3e-4);
%}
%{
% Helpers
chessR.set('asset','001_Cube_O','delete');
chessR.show('asset positions'); 
piAssetGeometry(chessR);
%}
%%
piWrite(chessR);
[scene,results] = piRender(chessR,'render type','radiance');
sceneWindow(scene);

%%


