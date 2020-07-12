%% t_eyeFOV
%
% Field of view calculations with the sceneEye model
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

thisEye = sceneEye('slantedbar');
thisEye.summary;

% There are a number of PBRT scenes stored in piRootPath/data/V3.  This is
% one of them.  To read in the recipe for this scene, we use this command.
thisEye = sceneEye('chesssetscaled');
thisEye.summary;

thisR = piRecipeDefault('scene name','sanmiguel');

%%
oi = thisEye.render;
oiWindow(oi);

thisEye.set('fov',2);
thisEye.set('rays per pixel',384);

thisFrom = thisEye.get('from');
thisEye.set('from',thisFrom + [0 0 -2]);
oDist = thisEye.get('object distance','m');

thisEye.set('focal distance',oDist);
oi = thisEye.render;
oiWindow(oi);



thisEye.get('fov')
thisEye.get('retina semidiam','mm')

thisEye.set('fov',10);
thisEye.get('retina semidiam','mm')

thisEye.set('fov',2);
thisEye.get('retina semidiam','mm')

thisEye.get('fov')

thisEye.set('retina semidiam',4);
thisEye.get('fov')

thisEye.set('retina semidiam',2);
thisEye.get('fov')

thisEye.set('retina semidiam',1);
thisEye.get('fov')

% We should be able to call this and set the semidiam correctly.

thisEye.set('fov')

%%
thisEye.set('chromatic aberration',true)
oi = thisEye.render;
oiWindow(oi);

thisEye.set('chromatic aberration',false)
thisEye.summary
oi = thisEye.render;
oiWindow(oi);

%% END