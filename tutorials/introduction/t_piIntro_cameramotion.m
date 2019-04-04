%% Add camera motion blur
%
% This script shows how to add motion blur to camera while keeping the
% whole scene still.
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
%   t_piIntro_*

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files

FilePath = fullfile(piRootPath,'data','V3','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

thisR = piRead(fname);

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',32);

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

% We have to check what happens when the sceneName is the same as the
% original, but we have added materials.  This section here is
% important to clarify for us.
sceneName = 'simpleTest';
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s_scene.pbrt',sceneName));
thisR.set('outputFile',outFile);

% The first time, we create the materials folder.
piWrite(thisR,'creatematerials',true);

%% Render.  

% Maybe we should speed this up by only returning radiance.
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Motion blur from camera
thisR.camera.motion.activeTransformStart.pos   = thisR.assets(2).position;
thisR.camera.motion.activeTransformStart.rotate = thisR.assets(2).rotate;
thisR.camera.motion.activeTransformEnd.pos     = thisR.assets(2).position;
thisR.camera.motion.activeTransformEnd.rotate = thisR.assets(2).rotate;

thisR.camera.motion.activeTransformEnd.pos(3) = thisR.assets(2).position(3)+0.7;
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: Translation');
sceneWindow(scene);

%%
thisR.camera.motion.activeTransformEnd.pos(3) = thisR.assets(2).position(3);
thisR.camera.motion.activeTransformEnd.rotate(1,1) = 5;
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: rotation');
sceneWindow(scene);

%% END







