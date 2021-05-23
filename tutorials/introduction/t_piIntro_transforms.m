%% Illustrate asset rotation, translation, and scaling
%
% This tutorial shows how you can rotate and translate an object using
% iset3D. The object is a cube with different colored sides.
%
% The effects depend on the order of the operations.  You can see the
% different operations using
%
%    thisR.assets.showUI
%
% Depends on: ISET3d, Docker, ISET
%
% ISETBIO Team, 2017
%
% See also
%   t_piIntro*


%% Initialize 
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene

thisR = piRecipeDefault('scene name','coloredCube');

%% Render the original scene first    

piWrite(thisR);
[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Original');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Rotate the cube

% The different sides of the cube are individual assets with their own
% colors.  They have IDs that end with an _O that means they are objects
% (leafs of the tree).  There is a branch node above the collection of
% these objects.  This node is a branch.
assetName = 'Cube_B'; 

% We get the branch node here.
thisAsset = thisR.get('asset',assetName);

% Rotate this node. The rotation will be inherited by all of the cube
% sides.
thisR.set('asset', thisAsset.name, 'rotate', [0, 0, 45]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Scale the cube 

% Now scale all of the objects beneath the branch.  This inserts a new node
% that contains the scale parameters.  It ends with an _S.
thisR.set('asset', thisAsset.name, 'scale', [1.2 1.2 1.2]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Scale');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate the cube

% This adds a node that translates.  It ends with an _T.
thisR.set('asset', thisAsset.name, 'translate', [0.2 0.2 0.2]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translate');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Here is the current position of the object

currentP = thisR.get('asset',thisAsset.name,'world position');

% This is another way to change its position.
thisR.set('asset',thisAsset.name,'world position',currentP + [-0.3 -0.3 -0.3]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'World Position');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Get rid of noise, for the heck of it

scene = piAIdenoise(scene);
sceneWindow(scene);

%% END