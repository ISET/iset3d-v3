%% Camera introduction
%
%  This tutorial demonstrates several camera types, how to set and get
%  some basic properties of the film (sensor), and explains how to
%  introduce camera motion to the scene that in turn affects the
%  rendering.
%
%  Note: Camera lens properties are explained in a separate script.
%
% Describes the ISETCam camera types.  There are four:
%   * perspective - also called 'pinhole' in the documentation
%   * omni - allows for lenses and microlenses
%   * realisticEye - special case for sceneEye class in ISETBio
%   * realistic - will be deprecated for omni
%
%  See also:
%   t_piIntro_lens
%
%  Update History:
%   10/15/21    djc     fix for Windows & Linux
%%
% Clear the decks
ieInit;

% Make sure docker is working
if ~piDockerExists, piDockerConfig; end

%% Initialize a default recipe for a simple scene

% This the a simple scene with a variety of objects
thisR = piRecipeDefault('scene name','SimpleScene');

% By default, the camera type for this scene is a 'perspective', which
% means a pinhole camera. We'll display its properties here.
thisR.get('camera')

% The pinhole (perspective) camera has some simple properties such as a
% field of view. 
thisR.get('fov')

% Remember that pinhole cameras has an infinite depth of field.  The
% distance from the pinhole to the film is called the focal distance.
% Our default camera has a specified film (sensor) size that we can
% query.
thisR.get('film diagonal','mm')

%% Pinhole cameras aren't everything
% Here is how we add a lens to our camera

% Many lens files are named with their FOV and focal length
lensfile  = 'dgauss.22deg.6.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);

% We'll replace our pinhole camera with one using the lens
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Set the film so that the field of view makes sense
thisR.set('film diagonal',5,'mm');
thisR.get('fov')

%% Write, render and denoise
piWrite(thisR);
oi = piRender(thisR);

% show the result
oiWindow(oi);

% If you are running with ISETBio, there is no render flag.  Yet.
if piCamBio, oiSet(oi,'render flag','hdr'); end

%% END
