%% Object distance and focal distance illustration
%
% Loads up a scene and illustrates the effect of changing different
% camera parameters in the recipe
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
thisR = piChessInit(0.2);

%% For this object distance, what are the scene depths (m)
objDistance = thisR.get('object distance');  % In meters
fprintf('Distance between camera and scene position %f\n',objDistance);

focalDistance = thisR.get('focal distance');
fprintf('Distance to focal plane %f\n',focalDistance);

[depthRange, depthmap]= piSceneDepth(thisR);
disp(depthRange)
ieNewGraphWin; imagesc(depthmap);

%% Move the camera closer

% Here are some critical parameters
objDistance = 0.75;
thisR.set('object distance',objDistance);   % In meters
fprintf('Distance between camera and scene position %f\n',objDistance);
[depthRange, depthmap]= piSceneDepth(thisR);
disp(depthRange)
ieNewGraphWin; imagesc(depthmap);

%%  Now, set up the in-focus distance 

thisR = piChessInit(1);   % Higher resolution to see focus.  Takes longer.

objDistance = 0.75;
thisR.set('object distance',objDistance);   % In meters

% Here are some critical parameters
focalDistance = 0.25;
thisR.set('focal distance',focalDistance);   % In meters
fprintf('Focal distance %f\n',focalDistance);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);

%%  Set up for different focal planes


thisR.get('from')

%%


thisR.camera
disp(depthRange)

%% Now adjust the object distance and recalculate the scene depths
thisR.set('object distance',objDistance + 3);   % In meters
thisR.get('object distance')   % In meters
thisR.get('from')

[depthRange, depthmap] = piSceneDepth(thisR);
disp(depthRange)

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters (default 22)

histogram(depthHist(:)); xlabel('Depth (m)'); grid on

% Setting the position of the camera from the 'to' position in object
% space.
thisR.get('object distance')

thisR.set('object distance',0.5)
[depthRange, depthHist] = piSceneDepth(thisR);
histogram(depthHist(:)); xlabel('Depth (m)'); grid on



depthRange = [0.1674, 3.3153];  % Chess set distances in meters

%%

[depthmap, result]   = piRender(thisR, 'render type','depth');
lensFocus(thisR.get('lens file'),10*1e+3)
