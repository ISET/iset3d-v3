%% piAssetTreeCreate

%{
% The Stanford Bunny
 assetSceneName = 'bunny';
 assetName = 'Bunny_B';
 thisR    = piRecipeDefault('scene name', 'bunny');
 thisST   = thisR.get('asset', assetName, 'subtree');
 fullPath = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','bunny.mat'));
%}
%{
% XYZ coordinate axis to insert in a scene
 assetSceneName = 'coordinate';
 assetName = 'Coordinate_B';
 thisR     = piRecipeDefault('scene name', 'coordinate');
 thisST    = thisR.get('asset', assetName, 'subtree');
 fullPath  = piAssetTreeSave(thisST, thisR.materials.list,'outFilePath',fullfile(piRootPath,'data','assets','coordinate.mat'));
%}
%{

  flatR = piRecipeDefault('scene name','flatsurface');
  flatR.set('asset','Camera_B','delete');
  flatR.set('lights','delete','all');

  % Add a light.
  distantLight = piLightCreate('distant','type','distant',...
    'spd', [9000 0.001], ...
    'cameracoordinate', true);
  flatR.set('light','add',distantLight);

 % Aim the camera at the object and bring it closer.
  flatR.set('from',[0,3,0]);
  flatR.set('to',  [0,2.5,0]);

  % Find the position of the surface
  surfaceName = '001_Cube_O';

  flatR.set('asset',surfaceName,'world position',[0 -1 0]);
  sz = flatR.get('asset',surfaceName,'size');
  flatR.set('asset',surfaceName,'rotate',[5 5 5]);
  flatR.set('asset',surfaceName,'scale', (1 ./ sz));

  piWRS(flatR);


  flatR.get('from')
  flatR.get('to')
  flatR.get('asset',thisObj,'world position')
  flatR.get('asset',thisObj,'size')
  
  % The camera is rotated correctly, but the object is not.  Good for
  % debugging
  % flatR = piRecipeRectify(flatR);

  flatR.set('from',[0 0 0]);
  flatR.set('to',[0 0 1]);
  flatR.set('asset',thisObj,'world position',[0 0 5]);

  piAssetGeometry(flatR,'inplane','xy','size',true);
  piAssetGeometry(flatR,'inplane','xz');
  flatR.show;

%}

% This simplifies the tree.
wpos    = flatR.get('asset',surfaceName,'world position')
wscale  = flatR.get('asset',surfaceName,'world scale')
wrotate = flatR.get('asset',surfaceName,'world rotation angle')

% How many geometry nodes (branches) are from the object to the root?
% All the nodes up the path are geometry nodes.  Object nodes are
% always leafs.
id = flatR.get('asset',surfaceName,'path to root');
fprintf('Geometry nodes:  %d\n',numel(id) - 1);

for ii=2:numel(id)
    flatR.set('asset',id(ii),'delete');
end

% Check again
id = flatR.get('asset',surfaceName,'path to root');
fprintf('Geometry nodes:  %d\n',numel(id) - 1);

if (numel(id)-1 == 0)
    geometryNode = piAssetCreate('type','branch');
    geometryNode.name = '001_Cube_G';
    flatR.set('asset','root','add',geometryNode);
    flatR.set('asset',surfaceName,'parent',geometryNode.name);
end

piAssetSet(flatR, geometryNode.name, 'translate',wpos);
piAssetSet(flatR, geometryNode.name, 'scale',wscale);
rotMatrix = [wrotate; fliplr(eye(3))];
piAssetSet(flatR, geometryNode.name, 'rotation', rotMatrix);

% flatR.set('asset',surfaceName,'world position',wpos);
% pid = flatR.get('asset parent id',surfaceName);
% piAssetSet(flatR, pid, 'scale',wscale);
% rotMatrix = [wrotate; fliplr(eye(3))]
% piAssetSet(flatR, pid, 'rotation', rotMatrix);

[scene, results] = piWRS(flatR);



