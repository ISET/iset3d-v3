%% Add slanted bar charts to the simple scene

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

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

flatR.set('asset',surfaceName,'world position',[0 2 0]);
flatR.set('asset',surfaceName,'scale',5e-4);
% xyz = thisR.get('asset',surfaceName,'world position');
% piAssetGeometry(thisR);

% Aim the camera at the object and bring it closer.
flatR.set('from',[0,3,0]);
flatR.set('to',  [0,2.5,0]);
surfaceName = '001_Cube_O';
xyz = flatR.get('asset',surfaceName,'world position');

%{
piWrite(flatR);
scene = piRender(flatR);
sceneWindow(scene);
%}

% piAssetGeometry(flatR,'size',true);

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


