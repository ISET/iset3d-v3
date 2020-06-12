%% Add camera motion blur
%
% This script shows how to add camera motion blur while keeping the
% whole scene still.
%
% Dependencies:
%
%    ISET3d, ISETCam 
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%    docker pull vistalab/pbrt-v3-spectral:test
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
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',128);

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.set('bounces',2);

% This is a convenient routine we use when there are many parts and
% you are willing to accept ZL's mapping into materials based on
% automobile parts. 
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.
thisR.set('fov',45);

% We have to check what happens when the sceneName is the same as the
% original, but we have added materials.  This section here is
% important to clarify for us.
sceneName = 'SimpleScene';
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
thisR.set('outputFile',outFile);

% The first time, we create the materials folder.
piWrite(thisR,'creatematerials',true);

%% Render the original scene with no camera motion

% We speed this up by only returning radiance.
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene,'display mode','hdr');

%% Motion blur from camera

% Specify the initial position and rotation of the camera.  We find
% the current camera position 
thisR.camera.motion.activeTransformStart.pos    = thisR.lookAt.from(:);
thisR.camera.motion.activeTransformStart.rotate = piRotationMatrix;

% Move in the direction you are looking, but just a small amount.
fromto = thisR.get('from to');
endPos = -0.5*fromto(:) + thisR.lookAt.from(:);
thisR.camera.motion.activeTransformEnd.pos      = endPos;

% No rotation
thisR.camera.motion.activeTransformEnd.rotate   = piRotationMatrix;

piWrite(thisR,'creatematerials',true);

%%
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: Translation');
sceneWindow(scene);

%%  Now, rotate the camera

% No translation
thisR.camera.motion.activeTransformEnd.pos = thisR.lookAt.from(:);

% The angle specification is piRotationMatrix.  To change the angle,
% say by rotation around the z-axis by 5 deg we set
thisR.camera.motion.activeTransformEnd.rotate = piRotationMatrix('zrot',5);
piWrite(thisR,'creatematerials',true);

%%
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: rotation');
sceneWindow(scene);

%% END







