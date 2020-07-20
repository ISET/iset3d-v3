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

thisR = piRecipeDefault('scene name','SimpleScene');

%% Set render quality

% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',128);

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.set('bounces',2);

thisR.set('fov',45);

% This is a convenient routine we use when there are many parts and
% you are willing to accept ZL's mapping into materials based on
% automobile parts. 
piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.

piWrite(thisR,'creatematerials',true);

%% Render the original scene with no camera motion

% We speed this up by only returning radiance.
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
if isequal(piCamBio,'isetcam')
    sceneSet(scene,'display mode','hdr');
else
    sceneSet(scene,'gamma',0.5);
end
%% Motion blur from camera

% Specify the initial position and rotation of the camera.  We find
% the current camera position

from = thisR.get('from');
thisR.set('camera motion translate start',from(:));
thisR.set('camera motion rotate start',piRotationMatrix);

% thisR.camera.motion.activeTransformStart.pos    = thisR.lookAt.from(:);
% thisR.camera.motion.activeTransformStart.rotate = piRotationMatrix;

% Move in the direction you are looking, but just a small amount.
fromto = thisR.get('from to');
endPos = -0.5*fromto(:) + thisR.lookAt.from(:);

thisR.set('camera motion translate end',endPos);
thisR.set('camera motion rotate end',piRotationMatrix);

% thisR.camera.motion.activeTransformEnd.pos      = endPos;
% thisR.camera.motion.activeTransformEnd.rotate   = piRotationMatrix;

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







