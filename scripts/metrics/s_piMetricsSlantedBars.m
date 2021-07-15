%% Add various charts to scenes
%
% Ultimately we will do this for metrics, such as MTF and color
%
% See also
%

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Test image raytransfer
        
thisR = piRecipeDefault('scene name','simple scene');
camera = piCameraCreate('raytransfer','lensfile','dgauss-22deg-3.0mm.json');
thisR.set('camera',camera);
piWrite(thisR);
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer';

[oi, result] = piRender(thisR, 'dockerimagename',...
            thisDocker);
        
        oiWindow(oi)
        
        
%% Make the chart, simple scene, and merge

        
        
thisR = piRecipeDefault('scene name','simple scene');
thisR.set('assets','Camera_B','delete');
thisR.set('assets','001_mirror_O','delete');

% Load the EIA chart recipe and merge node
eiachart = piAssetLoad('EIA.mat');

% Merge
piRecipeMerge(thisR,eiachart.thisR,'node name',eiachart.mergeNode);

% Assign the chart a position in this scene
piAssetSet(thisR,eiachart.mergeNode,'translate',[-2 1.5 0]);

% Render
piWRS(thisR);

% thisR.show;

%% Add a second chart

mcc = piAssetLoad('macbeth');
piRecipeMerge(thisR,mcc.thisR,'node name',mcc.mergeNode);
piAssetSet(thisR,mcc.mergeNode,'translate',[0.5 2.5 0]);
piWRS(thisR);

%% A third chart

sbar = piAssetLoad('slantedbar');
piRecipeMerge(thisR,sbar.thisR,'node name',sbar.mergeNode);
piAssetSet(thisR,sbar.mergeNode,'translate',[3 3 6]);
piWRS(thisR);

%%  Chess set.  Next, try to control the reflectances of the chart

% The chess set with pieces
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% Merge them
piRecipeMerge(chessR,eiachart.thisR,'node name',eiachart.mergeNode);

% Position and scale the EIA chart
piAssetSet(chessR,eiachart.mergeNode,'translate',[0 0.5 2]);
thisScale = chessR.get('asset',eiachart.mergeNode,'scale');
piAssetSet(chessR,eiachart.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this

% piWRS(chessR); % Quick check

% Grid lines
gridchart = piAssetLoad('gridlines');

piRecipeMerge(chessR,gridchart.thisR,'node name',gridchart.mergeNode);
piAssetSet(chessR,gridchart.mergeNode,'translate',[0.1 0.2 0.2]);
thisScale = chessR.get('asset',gridchart.mergeNode,'scale');
piAssetSet(chessR,gridchart.mergeNode,'scale',thisScale.*[0.05 0.05 0.05]);  % scale should always do this

% z y x
rotMatrix = [-35 10 0; fliplr(eye(3))];
piAssetSet(chessR, gridchart.mergeNode, 'rotation', rotMatrix);

% MCC Color chart
piRecipeMerge(chessR,mcc.thisR,'node name',mcc.mergeNode);
piAssetSet(chessR,mcc.mergeNode,'translate',[-0.2 0.3 0.7]);
thisScale = chessR.get('asset',mcc.mergeNode,'scale');
piAssetSet(chessR,mcc.mergeNode,'scale',thisScale.*[0.1 0.1 0.1]);  % scale should always do this

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

%% Add the bunny into the simple scene

thisR = piRecipeDefault('scene name','simple scene');
thisR.set('assets','Camera_B','delete');
thisR.set('assets','001_mirror_O','delete');
bunnychart = piAssetLoad('bunny');

piRecipeMerge(thisR,bunnychart.thisR,'node name',bunnychart.mergeNode);

thisScale = thisR.get('asset',bunnychart.mergeNode,'scale');
piAssetSet(thisR,bunnychart.mergeNode,'scale',thisScale.*[10 10 10]);  % scale should always do this
piAssetSet(thisR,bunnychart.mergeNode,'translate',[0 0 -10]);  % scale should always do this

coords = piAssetLoad('coordinate');
piRecipeMerge(thisR,coords.thisR,'node name',coords.mergeNode);
piAssetSet(thisR,coords.mergeNode,'translate',[1 1 -12]);  % scale should always do this

% piAssetGeometry(thisR);
piWRS(thisR);

%{
% How to find the bounding box of a recipe

coords = piRender(thisR,'render type','coordinates');
for ii=1:3
  [min2(coords(:,:,ii)), max2(coords(:,:,ii))]
end

% Make some plots showing the coordinates
ieNewGraphWin;
thisCoord = coords(:,:,1);
imagesc(thisCoord/max(thisCoord(:)));
colorbar;
colormap(jet)

% Surface?
ieNewGraphWin;
surf(coords(:,:,1), coords(:,:,2), coords(:,:,3))

%}
%%  Some other scenes.  Hand editing here.  Fix!!! so that is not needed.

kitchenR = piRecipeDefault('scene name','kitchen');

piRecipeMerge(kitchenR, eiachart.thisR,'node name',eiachart.mergeNode);
kitchenR.get('asset',eiachart.mergeNode,'translate')
d = kitchenR.get('look at direction');
from = kitchenR.get('from');
piAssetSet(kitchenR,eiachart.mergeNode,'translate',from + 3*d);
thisScale = kitchenR.get('asset',eiachart.mergeNode,'scale');
piAssetSet(kitchenR,eiachart.mergeNode,'scale',thisScale*0.3);

kitchenR.show('objects')
kitchenR.exporter = 'C4D';

%  Include "scene_geometry.pbrt" which is output by piWrite()
worldEnd = kitchenR.world{end};
kitchenR.world{end} = 'Include "scene_geometry.pbrt"';
kitchenR.world{end+1} = worldEnd;

kitchenR.set('spatial resolution',[256 256]);
kitchenR.set('rays per pixel',32);

scene = piWRS(kitchenR);

% scene = piAIdenoise(scene);
% sceneWindow(scene);

%% White room

whiteR = piRecipeDefault('scene name','white-room');
whiteR.exporter = 'C4D';

piRecipeMerge(whiteR,mcc.thisR,'node name',mcc.mergeNode);

d = whiteR.get('look at direction');
from = whiteR.get('from');
piAssetSet(whiteR,mcc.mergeNode,'translate',from + 3*d);

thisScale = whiteR.get('asset',mcc.mergeNode,'scale');
piAssetSet(whiteR,mcc.mergeNode,'scale',thisScale*1);

whiteR.set('spatial resolution',[320 320]);
whiteR.set('rays per pixel',16);

%  Include "scene_geometry.pbrt" which is output by piWrite()
worldEnd = whiteR.world{end};
whiteR.world{end} = 'Include "scene_geometry.pbrt"';
whiteR.world{end+1} = worldEnd;

piWRS(whiteR);

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

%% END


