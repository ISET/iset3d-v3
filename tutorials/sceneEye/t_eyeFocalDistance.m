%% t_eyeFocalDistance.m
%
% We recommend you go through t_rayTracingIntroduction.m before running
% this tutorial.
%
% This tutorial renders a retinal image of "slanted bar" to illustrate
%    * Quick scene rendering
%    * Setting the FOV
%    * turning on chromatic aberration
%    * adjusting the focal distance closer and further than the plane
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

thisEye = sceneEye('slantedbar');
thisEye.set('use pinhole',true);
thisEye.set('fov',2);                % About 3 deg on a side
scene = thisEye.render;
sceneWindow(scene);

thisEye.summary;

%% Render a fast image of the slanted bar first

thisEye.set('use pinhole',false);
thisEye.set('rays per pixel',128);              % Reduce render noise
thisEye.set('spatial samples',384);             % Number of OI sample points
oi = thisEye.render('render type','radiance');  % Do not bother with depth
oiWindow(oi);

thisEye.summary;


%% Turn on chromatic aberration

% This is slower because it includes (about 8x)
nSpectralBands = 8;
thisEye.set('chromatic aberration',nSpectralBands);
oi = thisEye.render('render type','radiance');  % Do not bother with depth
oiWindow(oi);

thisEye.summary;


%% Distance to the plane

sprintf('Mean depth %f\n',mean(thisEye.get('depth range')))   

%% Nearer than the plane
thisEye.set('focal distance',0.5); % Set the focus closer than the plane
oi = thisEye.render('render type','radiance');  % Do not bother with depth
oiWindow(oi);

thisEye.summary;

%%  Further than the plane

thisEye.set('focal distance',5);                % Set the focus further than the plane
oi = thisEye.render('render type','radiance');  % Do not bother with depth
oiWindow(oi);

thisEye.summary;

%% END
