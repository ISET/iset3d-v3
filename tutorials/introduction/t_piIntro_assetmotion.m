%% Add motion blur of an asset to the scene
%
% Brief description:
%   This script shows how to add motion blur to individual objects in a
%   scene.
%
% Dependencies:
%    ISET3d, ISETCam 
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% Authors:
%   Zhenyi SCIEN 2019
%
% See also
%   t_piIntro_*

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files

thisR = piRecipeDefault('scene name','SimpleScene');

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%% List material library

% This is a convenient routine we use when there are many parts and
% you are willing to accept ZL's mapping into materials based on
% automobile parts.  
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.

% We have to check what happens when the sceneName is the same as the
% original, but we have added materials.  This section here is
% important to clarify for us.
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

% The first time, we create the materials folder.
piWrite(thisR,'creatematerials',true);

%{
% Just showing off that we can do some stuff with point clouds.
% Not sure why this is here!

 coordMap = piRender(thisR,'renderType','coordinates');
 coordMap((coordMap(:,:,1)==0) & (coordMap(:,:,2)==0) & (coordMap(:,:,3)==0)) = NaN;
 x  = coordMap(:,:,1) - thisR.lookAt.from(1);
 y  = coordMap(:,:,2) - thisR.lookAt.from(2);
 z  = coordMap(:,:,3) - thisR.lookAt.from(3);

 player = pcplayer([min(x(:)), nanmax(x(:))],...
                   [min(z(:)), nanmax(z(:))],...
                   [min(y(:)), nanmax(y(:))]);
ptCloud = pointCloud([x(:),z(:),y(:)]);
view(player,ptCloud);

%}
%% Render.  

% Maybe we should speed this up by only returning radiance.
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% Introduce asset (object) motion blur (not camera motion)

% The motion blur is assigned to a particular asset.  In this example,
% we are moving the third asset, assets(3)

fprintf('Moving asset named: %s\n',thisR.assets.groupobjs(3).name);

% Check current object position
%
% Position is saved as x,y,z; 
%  z represents depth. 
%  x represents horizontal position
%  y represents vertical position

fprintf('Object position: \n    x: %.1f, depth: %.1f \n', ...
    thisR.assets.groupobjs(3).position(1), ...
    thisR.assets.groupobjs(3).position(3));

% To add a motion blur you need to define the shutter speed of the
% camera. This is supposed in the shutter open time and close time.
% These are represented in seconds.

% Open at time zero
thisR.camera.shutteropen.type = 'float';
thisR.camera.shutteropen.value = 0;  

% Close in half a second
thisR.camera.shutterclose.type = 'float';
thisR.camera.shutterclose.value = 0.5;

% Copy the asset position and rotation into the motion slot.
thisR.assets.groupobjs(3).motion.position = thisR.assets.groupobjs(3).position;
thisR.assets.groupobjs(3).motion.rotate   = thisR.assets.groupobjs(3).rotate;

% We will change the position, but not the rotation.  The change in
% position is during the shutter open period.  In this case, in half a
% second the object changes 0.1 meters in the x-direction.  To make
% him jump, we would change the y-position.
thisR.assets.groupobjs(3).motion.position(1) = thisR.assets.groupobjs(3).position(1) + 0.1;

%% Render the motion blur

piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% Add some rotation to the motion

% The rotation matrix is defined as: 
%
%    (z    y    x in deg)
%     0    0    0
%     0    0    1
%     0    1    0
%     1    0    0 
%
% To rotate around the z-axis, we change (1,1)
% To rotate around the y-axis, we change (1,2)
% To rotate around the y-axis, we change (1,3)
% 
% A plus value for rotation is CCW
%
% The rotation is around the center of the asset

% No translation
thisR.assets.groupobjs(3).motion.position = thisR.assets.groupobjs(3).position;

% Rotate 30 deg around the z-axis (depth direction)
thisR.assets.groupobjs(3).motion.rotate(1,1) = 30;

%% Write and render the motion blur
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Rotation');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% END







