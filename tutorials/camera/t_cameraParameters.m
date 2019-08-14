%% Camera settings:  Object distance and focal distance illustration
%
% Loads the Chess Set scene and illustrates the effect of changing
% different camera parameters in the recipe.  Notice that
%
%   * We need to piWrite after changing thisR.  I wonder if we should do
%   the piWrite as part of the piRender?
%   * When we change the focal plane in the scene, there is a slight change
%   in the field of view, as well.
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

%% Very low resolution to start.  We only visualize the depth

thisR = piChessInit(0.2);

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

oi = piRender(thisR,'render type','both');
oi = oiSet(oi,'name','far both');
oiWindow(oi);
oiPlot(oi,'depth map');
depthrange = oiGet(oi,'depth range');

%% Move the camera closer

% Move the camera closer
thisR.set('object distance',objDistance - 0.2);   % In meters
thisR.summarize;
piWrite(thisR);

oi = piRender(thisR,'render type','both');
oi = oiSet(oi,'name','far camera');
oiWindow(oi);
oiPlot(oi,'depth map')

%%  Now, set up the in-focus distance 

% Adjust focal plane position, shrink the FOV, increase the resolution
focalDistance = 0.5;
thisR.set('film diagonal',11);  % mm
thisR.set('focal distance',focalDistance);   % In meters
thisR.set('film resolution',[300 300]);
thisR.summarize
piWrite(thisR);

oi = piRender(thisR,'render type','both');
oi = oiSet(oi,'name','near focus');
oiWindow(oi);

%%  Set up for different focal planes

% Move the focal plane position, shrink the FOV, increase the resolution

focalDistance = 0.8;
thisR.set('focal distance',focalDistance);   % In meters
thisR.summarize
piWrite(thisR);

oi = piRender(thisR,'render type','both');
oi = oiSet(oi,'name','far focus');
oiWindow(oi);

%% END