%% t_eyeDoF.m
%
% We suggest reading the t_eyeIntro and perhaps t_eyeFocalDistance before
% running this tutorial.
%
% This tutorial renders a retinal image of the chess set to illustrate
%
%    * Quick scene rendering with a pinhole, no lens.  Infinite depth of
%    field
%    * Set the physiological optics and a focal distance at the rook.  The
%    nearby pieces are blurred
%    * Adjust the focal distance closer, the rook becomes blurred.
%
% For speed, we do this calculation without chromatic aberration.
%
% N.B. The Chess Set scene is not part of the GitHub repository.  To
% download the PBRT scene please visit
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

% This version of the chess set is scaled to the right physical dimensions
thisEye = sceneEye('chessSetScaled');

fprintf('Pupil diameter:  %0.1f mm\n',thisEye.get('pupil diameter','mm'));

%% Render a quick, low quality scene

% Through a pinhole you get a large depth of field
thisEye.set('fov',20);             % deg

thisEye.set('use pinhole',true);

thisEye.summary;

scene = thisEye.render;

sceneWindow(scene);

% For fun, have a look at the depth map (units are meters).
scenePlot(scene,'depth map');  colorbar;

%% Big pupil case.

% Set up for optical image with lens
thisEye.set('use optics',true);

% Focus on the rook at the back (1 diopter)
thisEye.set('accommodation',1);

% Upgrade the quality.  For a big pupil, we need some extra rays.
thisEye.set('pupil diameter',5);     
thisEye.set('rays per pixel',256);

% Print a summary
thisEye.summary;

% Radiance only for speed
oi = thisEye.render('render type','radiance');    
oiWindow(oi);

% Yellow because of the lens.  Blurry for the chess pieces that are close.

%% Reducing the pupil sharpens up the nearer pieces

% Shrink the pupil.  That will increse the depth of field.
thisEye.set('pupil diameter',2);   

% We add even more rays because shrinking the pupil adds more rendering
% noise.
thisEye.set('rays per pixel',512); % Use more rays 

thisEye.summary;

oi = thisEye.render('render type','radiance');    % Radiance and depth
oiWindow(oi);

% Less blurry for the chess pieces that are close. 
%
% There is more rendering noise, though. We reduced the pupil area by
% about a factor of 6 and only doubled the number of rays.  Impatient
% people out here in California.

%% END
