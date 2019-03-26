%% Add motion blur to the scene
%
% This script shows how to add motion blur to the objects in the scene
%
% Dependencies:
%
%    ISET3d, ISETCam 
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% Zhenyi SCIEN 2019
%
% See also
%   t_piIntroduction01, t_piIntroduction02


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
% if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files

FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 5;

% This adds a mirror and other materials that are used in driving
% simulation.
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.
thisR.set('fov',45);

sceneName = 'simpleTest';
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s_scene.pbrt',sceneName));
thisR.set('outputFile',outFile);

piWrite(thisR,'creatematerials',true);

%% Render.  

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(thisR);
sceneWindow(scene);
%%
% Check current position of the object
% Position is saved as x,y,z; z represents depth. x represents
% horizontal position.
fprintf('Object position: \n    x: %.1f, depth: %.1f \n', thisR.assets(3).position(1),...
    thisR.assets(3).position(3));
% Add a motion blur to this object, before you do that, you need to define
% the shutter speed of the camera
thisR.camera.shutteropen.type = 'float';
thisR.camera.shutteropen.value = 0;
thisR.camera.shutterclose.type = 'float';
thisR.camera.shutterclose.value = 0.5;
% Copy the data struct
thisR.assets(3).motion.position = thisR.assets(3).position;
thisR.assets(3).motion.rotate = thisR.assets(3).rotate;
% Now we want the object move horizontally along positive x axis
thisR.assets(3).motion.position(1) = thisR.assets(3).position(1)+0.1;
%% check the motion blur
piWrite(thisR,'creatematerials',true);
[scene, result] = piRender(thisR);
scene = sceneSet(scene,'name','motionblur: Position');
sceneWindow(scene);

%% add rotation blur
% rotation is defined as: 
%    (z    y    x in deg)
%     0    0    0
%     0    0    1
%     0    1    0
%     1    0    0 
thisR.assets(3).motion.position = thisR.assets(3).position;
thisR.assets(3).motion.rotate(:,1) = [30;0;0;1];

% check the motion blur
piWrite(thisR,'creatematerials',true);
[scene, result] = piRender(thisR);
scene = sceneSet(scene,'name','motionblur: Rotation');
sceneWindow(scene);
%% END







