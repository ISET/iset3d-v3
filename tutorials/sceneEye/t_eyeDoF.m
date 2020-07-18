%% t_eyeDoF.m
%
% We suggest reading the t_eyeIntro tutorial before running this tutorial.
%
% This tutorial renders a retinal image of the chess set to illustrate
%
%    * Quick scene rendering with a pinhole, no lens
%    * Set the lens and turn on chromatic aberration (in focus)
%    * Adjust the focal distance closer and further than the plane
%
% The Chess Set scene is not part of the GitHub repository.  To download
% the PBRT scene please visit
%
%     INSTRUCTIONS WILL BE PLACED HERE.  In the mean time, ask me.
% 
% Depends on: ISET3d, ISETBio, Docker
%
% See also
%   t_eyeIntro, t_eyeFocalDistance, 

%% Initialize ISETBIO
if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
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

thisEye.summary;
scene = thisEye.render('render type','radiance');
sceneWindow(scene);

%% Big pupil case.

% Set up for optical image with lens
thisEye.set('use optics',true);

% Focus on the rook at the back
thisEye.set('accommodation',1);

% Upgrade the quality
thisEye.set('pupil diameter',5);     % Big pupil
thisEye.set('rays per pixel',256);
thisEye.set('spatial samples',384);

% Print a summary
thisEye.summary;

oi = thisEye.render('render type','both');    % Radiance and depth
oiWindow(oi);


%% Reducing the pupil sharpens up the nearer pieces

% Shrink the pupil
thisEye.set('pupil diameter',2);   

% We add some more rays because shrinking the pupil adds some rendering
% noise.
thisEye.set('rays per pixel',512); % Use more rays 
thisEye.summary;

oi = thisEye.render('render type','radiance');    % Radiance and depth
oiWindow(oi);


%% END
