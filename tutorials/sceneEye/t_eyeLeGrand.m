%% t_eyeLeGrand.m
%
% We recommend you go through t_eyeIntro.m before running
% this tutorial.
%
% This tutorial renders the PBRT SCENE "letters at depth" using the
% LeGrand eye model.  The purpose of the script is to illustrate how to
%
%   * set up a sceneEye with the Navarro model
%   * position the camera and look at a particular scene object
%   * render with chromatic aberration
%
% Depends on: 
%    ISETBio, ISET3d, Docker
%
% Wandell, 2020
%
% See also
%   t_eye*
%

%% Check ISETBIO and initialize

if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Here are the World positions of the letters in the scene

% The units are in meters
toA = [-0.0486     0.0100     0.5556];
toB = [  0         0.0100     0.8333];
toC = [ 0.1458     0.0100     1.6667];

%% Show the scene

% This is rendered using a pinhole so the rendering is fast.  It has
% infinite depth of field (no focal distance).
thisSE = sceneEye('letters at depth','human eye','legrand');
% thisSE.summary;

% Position the eye off to the side so we can see the 3D easily
from = [0.25,0.3,-1.3];
thisSE.set('from',from);

% Look at the position with the 'B'.  The values for each of the letters
% are included above.
thisSE.set('to',toB);

% Reduce the rendering noise by using more rays. 
thisSE.set('rays per pixel',32);      

% Increase the spatial resolution by adding more spatial samples.
thisSE.set('spatial samples',512);  

% Have a quick check with the pinhole
thisSE.set('use pinhole',true);

% thisSE.get('object distance')   % Default is 2.1674
% If we make it further, we can narrow the FOV, I think
% thisSE.set('object distance',6);
% thisSE.set('fov',6);

% Given the distance from the scene, this FOV captures everything we want
thisSE.set('fov',15);             % Degrees

% Render the scene
scene = thisSE.render('render type','radiance');

sceneWindow(scene);

thisSE.summary;

% You can see the depth map if you like
%   scenePlot(scene,'depth map');

%% Now use the optics model with chromatic aberration

% Turn off the pinhole.  The model eye (by default) is the Navarro model.
thisSE.set('use pinhole',false);

% We turn on chromatic aberration.  That slows down the calculation, but
% makes it more accurate and interesting.  We oftens use only 8 spectral
% bands for speed and to get a rought sense. You can use up to 31.  It is
% slow, but that's what we do here because we are only rendering once. When
% the GPU work is completed, this will be fast!
nSpectralBands = 8;
thisSE.set('chromatic aberration',nSpectralBands);

% Find the distance to the object
oDist = thisSE.get('object distance');

% This is the distance to the B and we set our accommodation to that.
thisSE.set('focal distance',oDist);  

% Reduce the rendering noise by using more rays. 
thisSE.set('rays per pixel',768);      

% Increase the spatial resolution by adding more spatial samples.
thisSE.set('spatial samples',512);     

% This takes longer than the pinhole rendering, so we do not bother with
% the depth.
oi = thisSE.render('render type','radiance');

% Have a look.  Lots of things you can plot in this window.
oiWindow(oi);

% Summarize
thisSE.summary;

%% END
