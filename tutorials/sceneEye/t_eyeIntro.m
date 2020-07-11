%% t_eyeIntro
%
% In just a few commands, we can render a 3D image through a model of the
% physiological optics of the human eye.  This tutorial only as a couple of
% lines, but it has a lot of comments.
%
% Further examples show more of the principles and programming tools.
%
% Dependencies:
%   ISETBio, ISET3d, Docker
%
% See also
%  t_eye*
%

%% Check ISETBIO and initialize

% The sceneEye modeling uses ISETBio and ISET3d.  So we check.
if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end

% Then we initialize ISETBio and make sure the user has Docker configured.
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Load a scene and set an eye model

% There are a number of PBRT scenes stored in piRootPath/data/V3.  This is
% one of them.  To read in the recipe for this scene, we use this command.
thisR = piRecipeDefault('scene name','chesssetscaled');

% The recipe includes a camera definition.  We set a model of the
% physiological optics (from Navarro) as the camera model for rendering.
thisR.set('camera',piCameraCreate('humaneye','lens file','navarro.dat'));

%% Create the 

thisEye = sceneEye;
thisEye.set('recipe',thisR);

%% Check the basic scene.

% It is pretty quick to make sure the scene was read in properly on your
% computer.  To render quickly we tell the renderer to just use a pinhole
% model and return a representation of the scene.   Then we show it.
thisEye.usePinhole = true;
scene = thisEye.render;
sceneWindow(scene);

%% A quick oi render

thisEye.usePinhole = false;
oi = thisEye.render;
oiWindow(oi);

%% Increase the resolution

% Takes 30 sec

thisEye.set('spatial resolution',512);
thisEye.set('rays per pixel',128);
oi = thisEye.render;
oiWindow(oi);

%{
% Push it a little more.  What we really want is to control the FOV, say
% with 512 samples over 5 deg.
% Work on that next.
thisEye.set('spatial resolution',768);
thisEye.set('rays per pixel',512);
oi = thisEye.render;
oiWindow(oi);
%}

%% END
