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

% History:
%   10/28/20  dhb    Removed block of commented out code about point clouds,
%                    which didn't seem to belong here at all (as the comment
%                    indicated.  Added some comments.
%
%   12/13/20  ZLY/BW Updated the code with new asset style.

%% Initialize ISET and Docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files for a simple scene
thisR = piRecipeDefault('scene name','SimpleScene');
thisR.assets.print
%% Set render quality
%
% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

%% Set up material mappings
%
% This is a convenient routine we use when there are many parts and
% you are willing to accept ZL's mapping into materials based on
% automobile parts.  
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.
%
% We have to check what happens when the sceneName is the same as the
% original, but we have added materials.  This section here is
% important to clarify for us.

sceneName = thisR.get('input basename');
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

% The first time, we create the materials folder.
piWrite(thisR,'creatematerials',true);

%% Render.  
%
% Speed up by only returning radiance.
[scene, result] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% Introduce asset (object) motion blur (not camera motion)

% Print the assets tree
[~, names] = thisR.assets.tostring;

% Move this asset
thisAssetName = 'figure_3m_material_uber_blue';

assetPos = thisR.get('asset', thisAssetName, 'position');
% The motion blur is assigned to a particular asset.  In this example,
% we are moving the third asset, assets(3)

fprintf('Moving asset named: %s\n',thisAssetName);

% Check current object position
%
% Position is represented as a three vector x,y,z; 
%  z represents depth. 
%  x represents horizontal position
%  y represents vertical position
fprintf('Object position: \n    x: %.1f, y: %0.1f, depth: %.1f \n',...
            assetPos(1), assetPos(2), assetPos(3));

% To add a motion blur you need to define the shutter speed of the
% camera. This is supposed in the shutter open time and close time.
% These are represented in seconds.
%
thisR.set('cameraexposure', 0.5);

thisR.set('asset', thisAssetName, 'motion', 'translation', [0.1, 0, 0]);
thisR.set('asset', thisAssetName, 'motion', 'translation', [0, 0.1, 0]);

thisR.assets.print;

%% Render the motion blur
piWrite(thisR,'creatematerials',true);
[scene, result] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% Add some rotation to the motion

thisR.set('asset', thisAssetName, 'motion', 'rotation', [0, 0, 30]);
thisR.assets.print
%% Write and render the motion blur
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Rotation');
sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% END







