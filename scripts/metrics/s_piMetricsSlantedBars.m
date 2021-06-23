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

flatR.set('asset',surfaceName,'world position',[0 2 0]);
flatR.set('asset',surfaceName,'scale',5e-4);
% xyz = thisR.get('asset',surfaceName,'world position');
% piAssetGeometry(thisR);

% Aim the camera at the object and bring it closer.
flatR.set('from',[0,3,0]);
flatR.set('to',  [0,2.5,0]);
surfaceName = '001_Cube_O';
xyz = flatR.get('asset',surfaceName,'world position');

% piAssetGeometry(thisR);

%% Create a texture

chartName = 'EIAChart';
imgFile = 'EIA1956-300dpi-top.png';
%imgFile = 'pngExample.png';

chartTexture = piTextureCreate(chartName,...
    'format', 'spectrum',...
    'type', 'imagemap',...
    'filename', imgFile);
flatR.set('spatial samples',[320,320]);

surfaceMaterial = flatR.get('asset',surfaceName,'material');
flatR.set('texture', 'add', chartTexture);

flatR.get('texture print');

flatR.set('material', surfaceMaterial.name, 'kd val', chartName);
flatR.show('assetsmaterials');

%%
flatR.set('assets',surfaceName,'rotate',[30 20 10]);

%% Write and render
% piWrite(thisR, 'overwritematerials', true);
piWrite(flatR);
[scene,results] = piRender(flatR,'render type','radiance');
sceneWindow(scene);

%%  Now put the chart inside the simple scene

simpleR = piRecipeDefault('scene name','simple scene');

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

% Change the position, scale and rotation
simpleR.set('asset','001_Cube_O','world position',[-0.5 0.7 -11]);
simpleR.set('asset','001_Cube_O','scale',3e-4);
simpleR.set('asset','001_Cube_O','rotate',[90 0 0]);

% simpleR.set('asset','001_Cube_O','world position',[0.1 0.7 -11]);
% simpleR.get('asset','001_Cube_O','world position')

% Copy and add to a new position
%{
flatSurface = simpleR.get('asset','001_Cube_O');
flatSurface.name = '002_Cube_O';
simpleR.set('asset','root','add',flatSurface);
simpleR.set('asset','001_Cube_O','world position',[-0.5 0.7 -11]);
csimpleR.set('asset','002_Cube_O','scale',3e-4);
simpleR.set('asset','002_Cube_O','rotate',[90 0 0]);
simpleR.set('asset','001_Cube_O','delete');
%}

% simpleR.show;
% piAssetGeometry(simpleR,'size',true);

%% Render

piWrite(simpleR);
[scene,results] = piRender(simpleR,'render type','radiance');
sceneWindow(scene);
%%
simpleR.set('asset','001_Cube_O','delete');
simpleR.set('asset','002_Cube_O','delete');

% We should delete more nodes when we do this, not leave the solitary
% branch

