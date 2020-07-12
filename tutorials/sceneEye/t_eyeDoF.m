%% t_eyeDoF.m
%
% This tutorial uses the sceneEye class and methods to calculate the effect
% of pupil diameter on the depth of field in the scene.
% 
% Depends on: iset3d, isetbio, Docker
%
% TL ISETBIO Team, 2017  

%% Initialize ISETBIO
if ~isequal(piCamBio,'isetbio')
    fprintf('%s: requires ISETBIO\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Load scene

% This version of the chess set is scaled to the right dimensions
thisEye = sceneEye('chessSetScaled');
fprintf('Pupil diameter:  %0.1f mm\n',thisEye.get('pupil diameter','mm'));

%% Render a quick, low quality scene

% Through a pinhole you get a large depth of field
thisEye.set('fov',20);             % deg
thisEye.set('use pinhole',true);
scene = thisEye.render('render type','radiance');
sceneWindow(scene);

thisEye.summary;

%% This takes roughly 30 sec to render on an 8 core machine.

% Set up for optical image with lens
thisEye.set('use pinhole',false);

% Upgrade the quality
thisEye.set('rays per pixel',256);
thisEye.set('spatial samples',384);

oi = thisEye.render('render type','both');    % Radiance and depth
oiWindow(oi);

% Print a summary
thisEye.summary;

%% Adjust the focus plane to the back piece

thisEye.set('accommodation',1);
oi = thisEye.render('render type','radiance');
oiWindow(oi);

% Print a summary
thisEye.summary;

%% Reducing the pupil sharpens up the nearer pieces

thisEye.set('pupil diameter',2);   % Shrink the pupil
thisEye.set('rays per pixel',512); % Use more rays 
oi = thisEye.render('render type','radiance');    % Radiance and depth
oiWindow(oi);

thisEye.summary;

%%




