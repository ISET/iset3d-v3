%% Camera introduction
%
%  Describes camera types, setting and getting some basic properties of the
%  film (sensor), and explains how to introduce some camera motion during
%  the rendering.
%
%  Camera lens properties are introduced in a separate script.
%

% Describe the ISETCam camera types.  There are four:
%   perspective (also called 'pinhole' in the documentation)
%   realistic
%   realisticEye (special case for the sceneEye in ISETBio)
% omni.
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

%% We are going to put a lens in the camera

lensfile  = 'dgauss.22deg.6.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Set the film so that the field of view makes sense

thisR.set('film diagonal',5,'mm');
thisR.get('fov')

%% Write, render and denoise

piWrite(thisR);
oi = piRender(thisR);

oi = piAIdenoise(oi);  % Denoising is not necessary, but it looks nice

oiWindow(oi);

% If you are running with ISETBio, there is no render flag.  Yet.
if piCamBio, oiSet(oi,'render flag','hdr'); end

%% END
