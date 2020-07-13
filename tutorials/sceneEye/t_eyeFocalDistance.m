%% t_eyeFocalDistance.m
%
% We recommend you go through t_rayTracingIntroduction.m before running
% this tutorial.
%
% This tutorial renders a retinal image of "slanted bar" to illustrate
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

% This is rendered using a pinhole so the rendering is fast and has
% infinite depth of field (no focal distance).
thisEye = sceneEye('slantedbar');
thisEye.set('use pinhole',true);
thisEye.set('fov',2);                % About 3 deg on a side
scene = thisEye.render;
sceneWindow(scene);

thisEye.summary;

%% Suppose you look at the edge of the plane in the image

% Turn off the pinhole and use the Navarro model.
thisEye.set('use pinhole',false);

% Turn on chromatic aberration.  
nSpectralBands = 8;
thisEye.set('chromatic aberration',nSpectralBands);

% This is the distance to the plane.  We will match the focal plane.
sprintf('Mean depth %f\n',mean(thisEye.get('depth range')))   

thisEye.set('focal distance',1);

% Reduce the rendering noise
thisEye.set('rays per pixel',128);              % Reduce render noise
thisEye.set('spatial samples',384);             % Number of OI sample points

% Show the user what will be rendered
thisEye.summary;

% This takes longer than the pinhole rendering.
oi = thisEye.render('render type','radiance');  % Do not bother with depth
oiWindow(oi);

%% Suppose the plane is there, but you look at something closer.

thisEye.set('focal distance',0.3); 

% Show the user what will be rendered
thisEye.summary;

oi = thisEye.render('render type','radiance');  
oiWindow(oi);

%%  Further than the plane

% Now look at something beyond the plane
thisEye.set('focal distance',5);      

% Show the user what will be rendered
thisEye.summary;

oi = thisEye.render('render type','radiance');  
oiWindow(oi);

%% END
