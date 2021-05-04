%% Render using a fisheye lens
%
% We read in the PBRT file and render it through a pinhole.  Then we render
% the same data through a fisheye lens.
% 
% Dependencies:
%    ISET3d, ISETCam (or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%    docker pull vistalab/pbrt-v3-spectral
%    docker pull vistalab/pbrt-v3-spectral:test
%
%  You must have the chessSet PBRT scene in iset3d/data/V3
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_*, isetlens repository

% History:
%  10/28/20  dhb  Comment tuning.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the PBRT input scene

% Input the scene and store its parameters in a recipe
thisR = piRecipeDefault('scene name','chessSet');

% This is a quick rendering of the PBRT scene through a pinhole optics
piWrite(thisR);
[scene, result] = piRender(thisR,'render type','radiance');

% Have a look
sceneWindow(scene);

%% Set render quality
%
% Set resolution for speed or quality.
thisR.set('film resolution',round([600 400]*0.5));
quality = 1;   % 1 is fast/low 20 is high/slow
thisR.set('pixel samples',64*quality);   % Number of rays set the quality.

%% Add camera with a fisheye lens
%
% You could also try these lens files.
%   lensfile = 'dgauss.22deg.6.0mm.json';
%   lensfile = 'wide.40deg.6.0mm.json';
lensfile = 'fisheye.87deg.6.0mm.json';

% If isetlens is on the path, we can look at the lens
% and some of its properties.  Check by whether folder
% 'lensC' exists.
if exist('lensC','file')
    % If isetlens is on the path ....
    thislens = lensC('filename',lensfile);
    thislens.draw;
    % thislens.plot('focal distance');
end

% Create a camera with the lens.
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% PBRT estimates the distance.  It is not perfectly aligned to the depth
% map, but it is close.
thisR.set('focus distance',0.45);

% This is the size of the film/sensor in millimeters
thisR.set('film diagonal',10);

% Set rendering properties.
%
% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype = 'sobol';

% Lens aperture size
thisR.set('aperture diameter',3);

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more, but this increases
% rendering time.
thisR.set('nbounces',1); 

%% Write the recipe with the lens and render.
%
% The output is an optical image.
piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);
oiSet(oi,'gamma',0.5);

%% END

