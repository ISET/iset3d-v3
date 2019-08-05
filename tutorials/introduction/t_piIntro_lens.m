%% A tutorial on how to render using a lens
%
% Dependencies:
%   ISET3d, ISETCam, JSONio
%
% Notes:
%    * Check that you have the updated docker image by running
%       docker pull vistalab/pbrt-v3-spectral
%       docker pull vistalab/pbrt-v3-spectral:test
%    * Generally - https://www.pbrt.org/fileformat-v3.html#overview
%    * And specifically - https://www.pbrt.org/fileformat-v3.html#cameras
%
% See Also:
%   t_piIntro_*, isetlens
%

% History:
%    XX/XX/18  ZL, BW  SCIEN 2018
%    04/23/19  JNM     Documentation pass
%    05/09/19  JNM     Merge with master
%    07/30/19  JNM     Rebase from master

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path');
end

%% Read the pbrt files
% sceneName = 'kitchen';
% sceneFileName = 'scene.pbrt';
% sceneName = 'living-room';
% sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet';
sceneFileName = 'ChessSet.pbrt';

% The output directory will be written here to inFolder/sceneName
inFolder = fullfile(piRootPath, 'local', 'scenes');

% This is the PBRT scene file inside the output directory
inFile = fullfile(inFolder, sceneName, sceneFileName);
thisR = piRead(inFile);

%% Set render quality
% Set resolution for speed or quality.
% 1.5 is pretty high res
thisR.set('film resolution', round([600 400] * 2.0));
thisR.set('pixel samples', 64);  % 4 is Lots of rays.

%% Set output file
oiName = sceneName;
outFile = fullfile(piRootPath, 'local', oiName, ...
    sprintf('%s.pbrt', oiName));
thisR.set('outputFile', outFile);
outputDir = fileparts(outFile);

%% Add camera with lens
% 22deg is the half width of the field of view
% lensfile = 'dgauss.22deg.50.0mm.json';
% lensfile = 'dgauss.22deg.50.0mm.dat';
lensfile = 'wide.56deg.3.0mm.json';
fprintf('Using lens: %s\n', lensfile);
thisR.camera = piCameraCreate('realistic', 'lensFile', lensfile);

%{
% You might adjust the focus for different scenes. Use piRender with the
% 'depth map' option to see how far away the scene objects are. There
% appears to be some difference between the depth map and the true focus.
  dMap = piRender(thisR, 'render type', 'depth');
  ieNewGraphWin; imagesc(dMap); colormap(flipud(gray)); colorbar;
%}

% PBRT estimates the distance.  It is not perfectly aligned to the depth
% map, but it is close.
thisR.set('focus distance', 0.6);

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens.

% This is the size of the film/sensor in millimeters (default 22)
% thisR.set('film diagonal', 22);
thisR.set('film diagonal', 12);

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from', [0 0.14 -0.7]);   % Get higher and back away than default
thisR.set('to', [0.05 -0.07 0.5]);  % Look down default compared to default
thisR.set('object distance', 0.7);

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';
thisR.sampler.subtype = 'sobol';

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces', 4);

%% Render and display
% Change this for depth of field effects.
thisR.set('aperture diameter', 6);  % thisR.summarize('all');
piWrite(thisR, 'creatematerials', true);

oi = piRender(thisR, 'render type', 'radiance');  %, 'reuse', true);
oi = oiSet(oi, 'name', ...
    sprintf('%s-%d', oiName, thisR.camera.aperturediameter.value));
oiWindow(oi);

%% Change this for depth of field effects.
depth = piRender(thisR, 'render type', 'depth');  %, 'reuse', true);
ieNewGraphWin;
imagesc(depth);

%% Change this for depth of field effects.
thisR.set('aperture diameter', 3);
piWrite(thisR, 'creatematerials', true);

[oi, result] = piRender(thisR, 'render type', 'both');  %, 'reuse', true);
oi = oiSet(oi, 'name', ...
    sprintf('%s-%d', oiName, thisR.camera.aperturediameter.value));
oiWindow(oi);

%% Change again for depth of field effects.
thisR.set('aperture diameter', 1);
piWrite(thisR, 'creatematerials', true);

oi = piRender(thisR, 'render type', 'both');  %, 'reuse', true);
oi = oiSet(oi, 'name', ...
    sprintf('%s-%d', oiName, thisR.camera.aperturediameter.value));
oiWindow(oi);

%% END