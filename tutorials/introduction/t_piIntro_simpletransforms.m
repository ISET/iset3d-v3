%% Illustrate object rotation, translation, and scaling, and moving camera.
%
% Description:
%    This tutorial shows how you can rotate and translate an object using
%    iset3D. The object here is a cube with different colored sides.
%
% Depends on: ISET3d, Docker, ISET
%
% TL ISETBIO Team, 2017

% History:
%  11/01/2020  dhb  Fix up read so scene is actually read.
%              dhb  The only asset in the scene is called 'root', not
%                   'Cube'.  Turns out we should be looking in the
%                   groupobjs field, not the root field.
%              dhb  Added scaling (based on Amy Ni's example) and camera
%                   position changes.
%  12/04/2021  dhb  Updating for materials branch.

%% Initialize 
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read in the base scene
thisR = piRecipeDefault('scene name','coloredCube');

%% Render the original scene first    
thisR.set('outputfile',fullfile(piRootPath,'local','coloredCube','coloredCube.pbrt'));
piWrite(thisR);
[scene, results] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Original');
sceneWindow(scene);

%% Rotate the cube
%
% Rotate 10 degrees clockwise around cube's y-axis

% First get the cube
% This asset is a cube, or part of it, at the bottom of the tree.
assetName = '003ID_Cube_B'; %'005ID_Cube_O'; 
thisAsset = thisR.get('asset',assetName);
sceneSet(scene, 'render flag', 'hdr');

% This places a new branch node representating a rotation just above the
% named leaf asset.  The rotation is (x,y,z) in degrees.  We are rotating
% around the z-axis in this case.
%
% But the call to set the rotation crashes out.
thisR.set('asset', thisAsset.name, 'rotate', [0, 0, 45]);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Rotation');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

% % Loop through all assets and act on the cube.
% for ii = 1:length(thisR.assets.groupobjs)
%     if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
%         % The rotation is stored in angle-axis format, along the columns.  
%         thisR.assets.groupobjs(ii).rotate(1,2) = ...
%             thisR.assets.groupobjs(ii).rotate(1,2) + 10;
%     end
% end
% 
% % Write and render
% piWrite(thisR);
% [scene, ~] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;

%% Rotate the cube again by another 10 degrees
% for ii = 1:length(thisR.assets.groupobjs)
%     if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
%         % The rotation is stored in angle-axis format, along the columns.  
%         thisR.assets.groupobjs(ii).rotate(1,2) = ...
%             thisR.assets.groupobjs(ii).rotate(1,2) + 10;
%     end
% end
% 
% % Write and render
% piWrite(thisR);%
% [scene, ~] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
% %% Now translate
% %
% % Move cube 15 cm along positive x-axis
% for ii = 1:length(thisR.assets.groupobjs)
%     if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
%         % Do this by adjusting position
%         thisR.assets.groupobjs(ii).position(1) = ...
%             thisR.assets.groupobjs(ii).position(1) + 0.15;
%     end
% end
% 
% % Write and render
% piWrite(thisR);
% [scene, result] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
% %% Scale cube along x-axis
% for ii = 1:length(thisR.assets.groupobjs)
%     if strcmp(thisR.assets.groupobjs(ii).name,'Cube')
%         % The rotation is stored in angle-axis format, along the columns.
%         thisR.assets.groupobjs(ii).scale(1) = ...
%             thisR.assets.groupobjs(ii).scale(1)*2;
%     end
% end
% 
% % Write and render
% piWrite(thisR);
% [scene, result] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
% %% Move camera further away
% %
% % This works if we set object distance, but not if
% % we set camera position directly.
% distance = thisR.get('object distance');
% thisR.set('object distance',distance*2);
% 
% % Write and render
% piWrite(thisR);
% [scene, result] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
% %% Control full camera position in space.
% %
% % The camera position and direction are controlled by specifying where it
% % is ('from') and where it is pointed ('to').
% from = thisR.get('from');
% thisR.set('from',from + [-5 -5 0]);
% 
% % Write and render
% piWrite(thisR);
% [scene, result] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
% %% Change where camera is pointed
% thisR.set('from',from);
% to = thisR.get('to');
% thisR.set('to',to + [-0.1 -0.1 1]);
% 
% % Write and render
% piWrite(thisR);
% [scene, result] = piRender(thisR,'version',3);
% ieAddObject(scene);
% sceneWindow;
% 
