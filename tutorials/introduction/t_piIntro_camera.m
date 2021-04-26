%% Camera introduction
%
%  Describes camera types, setting and getting some basic properties of the
%  film (sensor), and explains how to introduce some camera motion during
%  the rendering.
%
%  Camera lens properties are introduced in a separate script.
%
%  See also
%   t_piIntro_lens
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Init a default recipe 

% This the MCC scene
thisR = piRecipeDefault('scene name','SimpleScene');

% By default, the camera type for this scene is a 'perspective', which
% means a pinhole camera.
thisR.get('camera')

% The pinhole (perspective) camera has some simple properties such as a
% field of view
thisR.get('fov')

% Remember that pinhole cameras has an infinite depth of field.  The
% distance from the pinhole to the film is called the focal distance
thisR.get('film diagonal','mm')

%%  You can create different types of cameras

piCameraCreate


%% 
%% Set render quality
%
% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',128);

%% Rendering properites
%
% This value determines the number of ray bounces.  The scene has
% glass so we need to have at least 2 or more.
thisR.set('bounces',2);

% Field of view
thisR.set('fov',45);

% This is a convenient routine we use when there are many parts and
% you are willing to accept ZL's mapping into materials based on
% automobile parts. 
% piMaterialGroupAssign(thisR);

%% Write out the pbrt scene file, based on thisR.
piWrite(thisR,'creatematerials',true);

%% Render the scene with no camera motion
%
% Speed up by only returning radiance, and display
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
if isequal(piCamBio,'isetcam')
    sceneSet(scene,'display mode','hdr');
else
    sceneSet(scene,'gamma',0.5);
end

%% Motion blur from camera
%
% Specify the initial position and pose (rotation), translate,
% and then set camera motion end position.
%
% Findthe current camera position and rotation
from = thisR.get('from');
thisR.set('camera motion translate start',from(:));
thisR.set('camera motion rotate start',piRotationMatrix);

% Move in the direction camera is looking, but just a small amount.
fromto = thisR.get('from to');
endPos = -0.5*fromto(:) + thisR.lookAt.from(:);

% Set camera motion end parameters, no change in rotation yet.
thisR.set('camera motion translate end',endPos);
thisR.set('camera motion rotate end',piRotationMatrix);

% Write and render
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: Translation');
sceneWindow(scene);

%%  Now, rotate the camera
%
% No translation, end position is where camera is now.
endPos = thisR.lookAt.from(:);

% The angle specification is piRotationMatrix.  Here the angle is changed
% by 5 degrees around the z-axis.
endRotation = piRotationMatrix('zrot',5);

% Set camera motion end parameters.
thisR.set('camera motion translate end',endPos);
thisR.set('camera motion rotate end',endRotation);

%% Write an render
piWrite(thisR,'creatematerials',true);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Camera Motionblur: rotation');
sceneWindow(scene);
