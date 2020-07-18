%% t_eyeNavarro.m
%
% We recommend you go through t_eyeIntro.m before running
% this tutorial.
%
% This tutorial renders a "letters at depth" as an example that we show of
% the Navarro eye model.
%
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

%% Show the scene

% This is rendered using a pinhole so the rendering is fast.  It has
% infinite depth of field (no focal distance).
thisEye = sceneEye('letters at depth');

% Position the eye somewhere I kind of like
from = [0.25,0.3,-1.3];
thisEye.set('from',from);

% Here are the World positions of the letters
toA = [-0.0486     0.0100     0.5556];
toB = [  0         0.0100     0.8333];
toC = [ 0.1458     0.0100     1.6667];

% Look at the position with the 'B'
thisEye.set('to',toB);

% This is the distance to the edge in the scene.  We will match the focal
% plane.
sprintf('Mean depth %f (m)\n',mean(thisEye.get('depth range')))  

thisEye.set('use pinhole',true);
thisEye.set('fov',15);             % Degrees

% The scene has a little imperfection.  We will fix it some day.
scene = thisEye.render;
sceneWindow(scene);   

thisEye.summary;

% Have a look at the depth map so you can see the distance to the different
% letters.    from: (0,0.1,0):      C: 1.66, B:0.832  A:0.548
% alternative from: (0.25,0.3,-1.3): C: 3.0   B:2.5    A:1.89
scenePlot(scene,'depth map');

%% Now use the optics model.

% Turn off the pinhole.  The model eye (by default) is the Navarro model.
thisEye.set('use pinhole',false);

% Suppose you are in focus at the proper distance to the edge. And we turn
% on chromatic aberration.  That will slow down the calculation, but makes
% it more accurate and interesting.  We only use 8 spectral bands for
% speed.  You can use up to 31.
nSpectralBands = 31;
thisEye.set('chromatic aberration',nSpectralBands);

% Find the distance to the object
oDist = thisEye.get('object distance');

% This is the distance to the A we calculated above
thisEye.set('focal distance',oDist);  

% Reduce the rendering noise by using more rays. 
thisEye.set('rays per pixel',512);      

% Increase the spatial resolution by adding more spatial samples.
thisEye.set('spatial samples',784);     

% Summarize
thisEye.summary;

% This takes longer than the pinhole rendering, so we do not bother with
% the depth.
oi = thisEye.render('render type','radiance');
oiWindow(oi);

%% END

%{
A position ans =

   -0.0486
    0.0100
    0.5556

B position
ans =

         0
    0.0100
    0.8333

thisEye.recipe.assets.groupobjs(6).position

ans =

    0.1458
    0.0100
    1.6667

%}