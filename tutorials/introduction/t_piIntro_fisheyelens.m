%% ISET3D Render using a fisheye lens
%
% We read in the PBRT file and render it through a pinhole.  Then we render
% the same data through a fisheye lens.
% 
% Dependencies:
%    ISET3d, ISETCam, JSONio
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
%   t_piIntro_*
%   isetlens repository

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the PBRT input scene

% We input the scene and store its parameters in a recipe
thisR = piRecipeDefault('scene name','chessSet');

% This is a quick rendering of the PBRT scene through a pinhole optics
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');

% Have a look
sceneWindow(scene);

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([600 400]*0.5));
quality = 1;   % 1 is fast/low 20 is high/slow
thisR.set('pixel samples',64*quality);   % Number of rays set the quality.

%% Add camera with a fisheye lens

%{
% We have another repository for thinking about lenses (isetlens)
% I added it to the path so I can show you the lens surfaces.
 lensfile = 'dgauss.22deg.6.0mm.json';
 lensfile = 'wide.40deg.6.0mm.json';
 thislens.plot('focal distance');
%}
lensfile = 'fisheye.87deg.6.0mm.json'; 
thislens = lensC('filename',lensfile);
thislens.draw;

thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% PBRT estimates the distance.  It is not perfectly aligned to the depth
% map, but it is close.
thisR.set('focus distance',0.45);

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters
thisR.set('film diagonal',10);

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype = 'sobol';

thisR.set('aperture diameter',3);

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

%% Change this for depth of field effects.

piWrite(thisR,'creatematerials',true);

oi = piRender(thisR,'render type','radiance');
oiWindow(oi);
oiSet(oi,'gamma',0.6);

%% END

%%  Scratch

%{
% ISETBIO integration
  cm = coneMosaic;
  cm.setSizeToFOV(4);
  cm.compute(oi);
  cm.window; truesize;
%}

%{
 outDir = thisR.get('output dir')
 dir(fullfile(outDir,'renderings'))
%}

%{
% You might adjust the focus for different scenes.  Use piRender with
% the 'depth map' option to see how far away the scene objects are.
% There appears to be some difference between the depth map and the
% true focus.
  dMap = piRender(thisR,'render type','depth');
  ieNewGraphWin; imagesc(dMap); colormap(flipud(gray)); colorbar;
%}
