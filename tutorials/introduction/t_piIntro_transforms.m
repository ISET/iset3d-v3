%% Illustrate asset rotation, translation, and scaling
%
% This tutorial shows how to rotate, scale and translate an object
% using iset3D. The object is a cube with different colored sides.
%
% The order of operations in PBRT follows the order of operations that
% you define by the series of sets. 
% 
% We strongly recommend that you use this order of operations.  It
% helps us think about what will happen.  
%
% First, translate the object to the desired position.  The
% translation is always applied in the world coordinate frame.
%
% Second, rotate the object.  The rotation is applied in the object's
% coordinate frame.
%
% Third, scale the object.  The scale is applied to the object. Oddly,
% it also applies to the object's translation. As a consequence,
% translate-scale is not the same as scale-translate.  Luckily for us,
% the scale does NOT apply to the rotation.
%
% The order of operations effects are illustrated at the end of this
% script.
%
% The transforms are stored in branch nodes.  The shapes are stored in
% object nodes.  Each branch node can have one or more object nodes as
% children.  It can also have another branch node as a child.
%
% Depends on: ISET3d, Docker, ISET
%
% ISETBIO Team, 2017
%
% See also
%   t_piIntro*


%% Initialize 
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene

thisR = piRecipeDefault('scene name','coloredCube');

%% Render the original scene first    

scene = piWRS(thisR,'render type','radiance');
scene = sceneSet(scene, 'name', 'Original');
sceneSet(scene, 'render flag', 'hdr');
ieReplaceObject(scene);

%% Rotate the cube

% The different sides of the cube are individual assets with their own
% colors.  They have IDs that end with an _O that means they are
% objects (leafs of the tree).  There is a branch node that defines
% the transforms for all of these objects.  That transform node is
% above the collection of these object nodes.
nodeName = 'Cube_B'; 

% Get the branch node that defines the transforms 
thisNode = thisR.get('node',nodeName);

% Rotate this node 45 deg counter-clockwise around the z-axis. The
% rotation will be inherited by all of the cube sides.
thisR.set('node', thisNode.name, 'rotate', [0, 0, 45]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Scale the cube 

% Now transform the objects by a scale factor.
thisR.set('node', thisNode.name, 'scale', [1.2 1.2 1.2]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Scale');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Translate the cube

% In meters
thisR.set('node', thisNode.name, 'translate', [0.3 0.3 0]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Translate');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Here is the current world position of the object

currentP = thisR.get('node',thisNode.name,'world position');

% We can visualize the positions this way
piAssetGeometry(thisR);

%%  Bring it closer, specifying world position

thisR.set('node',thisNode.name,'world position',currentP + [0 0 -0.3]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'World Position');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Get rid of noise, for the heck of it

% scene = piAIdenoise(scene);
% sceneWindow(scene);

%% The order of operations between scale and rotate does not matter.

% Fresh copy of the object
thisR = piRecipeDefault('scene name','coloredCube');

% Scale and then rotate
thisR.set('node', thisNode.name, 'scale', [1.3 1.3 1.3]);
thisR.set('node', thisNode.name, 'rotate', [0 0 45]);
scene = piWRS(thisR);
scene = sceneSet(scene, 'name', 'Scale-Rotate');
ieReplaceObject(scene);

%% Rotate and then scale

% Fresh copy of the object
thisR = piRecipeDefault('scene name','coloredCube');

% Scale and then rotate
thisR.set('node', thisNode.name, 'rotate', [0 0 45]);
thisR.set('node', thisNode.name, 'scale', [1.3 1.3 1.3]);
scene = piWRS(thisR);
scene = sceneSet(scene, 'name', 'Rotate-Scale');
ieReplaceObject(scene);

%% Translate and scale differs from scale and translate

thisR = piRecipeDefault('scene name','coloredCube');

% Scale and then translate
thisR.set('node', thisNode.name, 'scale', [1.3 1.3 1.3]);
thisR.set('node', thisNode.name, 'translate', [0.3 0.3 0]);
scene = piWRS(thisR);
scene = sceneSet(scene, 'name', 'Scale-Translate');
ieReplaceObject(scene);
sceneWindow();

%%
thisR = piRecipeDefault('scene name','coloredCube');

% Scale and then translate
thisR.set('node', thisNode.name, 'translate', [0.3 0.3 0]);
thisR.set('node', thisNode.name, 'scale', [1.3 1.3 1.3]);
scene = piWRS(thisR);
scene = sceneSet(scene, 'name', 'Translate-Scale');
ieReplaceObject(scene);
sceneWindow();

%% END