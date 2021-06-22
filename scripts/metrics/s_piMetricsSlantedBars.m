%% Add slanted bar charts to the simple scene

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%%  Read the scene and add a light

thisR = piRecipeDefault('scene name','flatsurface');

% Add a light
distantLight = piLightCreate('distant','type','distant',...
    'spd', [9000 0.001], ...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

%% Point the camera

% Find the position of the surface
surfaceName = '001_Cube_O';
% xyz = thisR.get('asset',surfaceName,'world position');

thisR.set('asset',surfaceName,'world position',[0 2 0]);
thisR.set('asset',surfaceName,'scale',5e-4);
% xyz = thisR.get('asset',surfaceName,'world position');
% piAssetGeometry(thisR);

% Aim the camera at the object and bring it closer.
thisR.set('from',[0,3,0]);
thisR.set('to',  [0,2.5,0]);
surfaceName = '001_Cube_O';
xyz = thisR.get('asset',surfaceName,'world position');

% piAssetGeometry(thisR);

%% Create a texture

chartName = 'EIAChart';
imgFile = 'EIA1956-300dpi-top.png';
%imgFile = 'pngExample.png';

chartTexture = piTextureCreate(chartName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', imgFile);
thisR.set('spatial samples',[320,320]);

surfaceMaterial = thisR.get('asset',surfaceName,'material');
thisR.set('texture', 'add', chartTexture);

thisR.get('texture print');

thisR.set('material', surfaceMaterial.name, 'kd val', chartName);
thisR.show('assetsmaterials');

%%
thisR.set('assets',surfaceName,'rotate',[30 20 10]);

%% Write and render
% piWrite(thisR, 'overwritematerials', true);
piWrite(thisR);
[scene,results] = piRender(thisR,'render type','radiance');
sceneWindow(scene);

%%
simpleR = piRecipeDefault('scene name','simple scene');
piAssetGeometry(simpleR);
simpleR.get('from')
simpleR.get('to')

flatSurface = thisR.get('asset',surfaceName);
flatSurface.name = 'flatsurface';
simpleR.set('asset','root','add',flatSurface);
thisR.set('asset',surfaceName,'scale',5e-6);

% simpleR.show;

simpleR.set('asset',flatSurface.name,'world position',[1 1 0]);
piAssetGeometry(simpleR);

%%
piWrite(simpleR);
[scene,results] = piRender(simpleR,'render type','radiance');
sceneWindow(scene);

simpleR.set('asset','flatsurface','delete');

