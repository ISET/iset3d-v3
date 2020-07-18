%% t_eyeFocalDistance.m
%
% We recommend you go through t_eyeIntro.m before running
% this tutorial.
%
% This tutorial renders a retinal image of "slanted bar" to illustrate
%
%    * Quick scene rendering with a pinhole, no lens
%    * Set the lens and turn on chromatic aberration (in focus)
%    * Adjust the focal distance closer and further than the plane
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

%% Show the slanted bar scene

% This is rendered using a pinhole so the rendering is fast.  It has
% infinite depth of field (no focal distance).

thisEye = sceneEye('slantedbar');

% This is the distance to the edge in the scene.  We will match the focal
% plane.
sprintf('Mean depth %f (m)\n',mean(thisEye.get('depth range')))  

thisEye.set('use pinhole',true);
thisEye.set('fov',2);             % Degrees

% The scene has a little imperfection.  We will fix it some day.
scene = thisEye.render;
sceneWindow(scene);   

thisEye.summary;

%% Now use the optics model.

% Turn off the pinhole.  The model eye (by default) is the Navarro model.
thisEye.set('use pinhole',false);

% Suppose you are in focus at the proper distance to the edge. And we turn
% on chromatic aberration.  That will slow down the calculation, but makes
% it more accurate and interesting.  We only use 8 spectral bands for
% speed.  You can use up to 31.
nSpectralBands = 8;
thisEye.set('chromatic aberration',nSpectralBands);

% This is the distance we calculate above
thisEye.set('focal distance',1);  

% Reduce the rendering noise by using more rays. 
thisEye.set('rays per pixel',128);      

% Increase the spatial resolution by adding more spatial samples.
thisEye.set('spatial samples',384);     

% Summarize
thisEye.summary;

% This takes longer than the pinhole rendering, so we do not bother with
% the depth.
oi = thisEye.render('render type','radiance');
oiWindow(oi);

% You can see the spread of the short wavelength light.

%% Adjust the accommodation nearer than the plane

% Suppose the plane is there, but you look at something closer.

thisEye.set('focal distance',0.3); 

% Show the user what will be rendered
thisEye.summary;

oi = thisEye.render('render type','radiance');  
oiWindow(oi);

% When you are focused closer than the blur is larger and the spread of the
% short wavelength light increases.

%% Beyond the plane

% Now look at something beyond the plane
thisEye.set('focal distance',5);      

% Show the user what will be rendered
thisEye.summary;

oi = thisEye.render('render type','radiance');  
oiWindow(oi);

% When you are focused beyond the edge the blur changes substantially.  In
% this case the color fringe is very different.  This change in color
% fringe provides a wonderful single to direct the direction of
% accommodation. 

%% END
