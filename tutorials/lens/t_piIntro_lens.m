%% Render using a lens
%
% Dependencies:
%    ISET3d, ISETCam, isetlens, JSONio
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% For more information about PBRT lens and camera formats:
%
% Generally
%   https://www.pbrt.org/fileformat-v3.html#overview
% 
% And specifically
%   https://www.pbrt.org/fileformat-v3.html#cameras
%
% Z Liu, BW 2018
%
% See also
%   t_piIntro_start, isetlens, 
%

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt files

% This is the PBRT scene file inside the output directory
% thisR  = piRecipeDefault();
thisR  = piRecipeDefault('scene name','chessSet');

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([600 600]*0.5));  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',64);                      % 128 for high quality

%% To determine the range of object depths in the scene

% depthRange = thisR.get('depth range');
%
% Runs this function
%   [depthRange, depthHist] = piSceneDepth(thisR);
%   histogram(depthHist(:)); xlabel('Depth (m)'); grid on
%
depthRange = [0.1674, 3.3153];  % Chess set distances in meters

%% Add camera with lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Set the focus into the middle of the depth range of the objects in the
% scene.
%{
 d = lensFocus(lensfile,max(depthRange*1000));   % Millimeters
 thisR.set('film distance',d);
%}
thisR.set('focal distance',mean(depthRange));

% The FOV is not used for the 'omni' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters (default 22)
% From the field of view and the focal length we should be able to
% calculate the proper size of the film.
thisR.set('film diagonal',33);

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default 

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype    = 'sobol';

thisR.set('aperture diameter',1);   % thisR.summarize('all');

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

%% Render and display

% Change this for depth of field effects.
piWrite(thisR);

oi = piRender(thisR,'render type','radiance');
oi = oiSet(oi,'name',sprintf('chessSet-%dmm',thisR.get('aperture diameter')));
oiWindow(oi);

%% Image look noisy?  Try this

% oi = piAIdenoise(oi);
% oiWindow(oi);

%% END
