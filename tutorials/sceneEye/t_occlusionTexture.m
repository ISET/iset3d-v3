%% t_occlusionTexture.m
%
% Render a slanted bar where there  are two planes at depth depths,
% and each plane has a texture. This creates an edge where there is a
% depth discontinuity.
%
% We would like to compare the ray-traced rendering with a simpler
% version in which we simply convolve the two images with different
% blur functions and then add them.s
%
% ZL ISETBIO Team, 2018
%
% See also
%   iset3d, isetbio, Docker
%

%% Initialize ISETBIO
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create the scene

% Try different depths
% Depth to the two textured planes in meters
frontDepth = 1; 
backDepth  = 2; 

scene3d = sceneEye('slantedBarTexture',...
    'frontDepth',frontDepth,...
    'backDepth',backDepth); % in meters

%% Set eye parameters
scene3d.accommodation = 1/frontDepth; % Accommodate to white plane (diopters)
scene3d.numCABands = 8; % Can increase to 16 or 32 at the cost of render speed.
scene3d.numBounces = 3;

% Set size parameters
scene3d.fov        = 1; % The smaller the fov the more the LCA is visible.
scene3d.resolution = 128; % Low quality
scene3d.numRays    = 128; % Low quality

% Scene name
scene3d.name = sprintf('%0.2f_%0.2f_slantedBar',frontDepth,backDepth(ii));

%% Render
[oi, result] = scene3d.render;

%%
ieAddObject(oi);
oiWindow;

%%
%%
