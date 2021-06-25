%% 
%
% Camera settings:  Object distance and focal distance illustration
%
% Illustrates depth of field
%
% Loads the Chess Set scene and illustrates the effect of changing
% different camera parameters in the recipe.  Notice that
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

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% Very low scene resolution to start.  We only visualize the depth

% The recipe has a pinhole camera (also called perspective)
thisR = piRecipeDefault('scene name','ChessSet');
thisR.get('camera subtype')

%% For this object distance, what are the scene depths (m)
objDistance = thisR.get('object distance');  % In meters
fprintf('Distance between camera and scene position %f\n',objDistance);

focalDistance = thisR.get('focal distance');
fprintf('Distance to focal plane %f\n',focalDistance);

%{
[depthRange, depthmap]= piSceneDepth(thisR);
fprintf('%f close, %f far\n',depthRange(1),depthRange(2));
ieNewGraphWin; imagesc(depthmap); axis image
%}

thisR.summarize;
piWrite(thisR);
[scene,result] = piRender(thisR);
scene = sceneSet(scene,'name','far both');
sceneWindow(scene);

%%
scenePlot(scene,'depth map');
depthrange = sceneGet(scene,'depth range');

%% Move the camera closer

% Move the camera closer
thisR.set('object distance',objDistance - 0.2);   % In meters
thisR.summarize;
piWrite(thisR);

scene = piRender(thisR);
scene = sceneSet(scene,'name','far camera');
sceneWindow(scene);
scenePlot(scene,'depth map')

%% Add a lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

%% Set up rendering parameters

thisR.set('film diagonal',22);    % In mm

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default 
thisR.set('object distance',1.2);    % From-To separation in meters

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype    = 'sobol';

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

% Change this for depth of field effects.
thisR.set('aperture diameter',2);   % thisR.summarize('all');

%%  Now, set up the in-focus distance 

% Adjust focal plane position, shrink the FOV, increase the resolution
focalDistance = 0.5;
thisR.set('film diagonal',11);  % mm
thisR.set('focal distance',focalDistance);   % In meters
thisR.set('film resolution',[300 300]);
thisR.summarize
piWrite(thisR);

oi = piRender(thisR);
oi = oiSet(oi,'name','near focus');
oiWindow(oi);

%%  Set up for different focal planes

% Move the focal plane position, shrink the FOV, increase the resolution

focalDistance = 0.8;
thisR.set('focal distance',focalDistance);   % In meters
thisR.summarize
piWrite(thisR);

oi = piRender(thisR);
oi = oiSet(oi,'name','far focus');
oiWindow(oi);

%% END