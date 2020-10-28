%% Render the checkerboard scene with different light sources.

% History:
%   10/28/20  dhb Comment tuning.

%% Initialize ISET and Docker
%
% Start up ISET/ISETBio and check that the user is configured for docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the scene file
thisR = piRecipeDefault('scene name','MacBethChecker');

%% Check the light list that came with the scene
initialLightList = piLightGet(thisR);
for ii = 1:length(initialLightList)
    initialLightList{ii}
end

%% Remove all the lights
thisR = piLightDelete(thisR, 'all');
lightList = piLightGet(thisR);
if (~isempty(lightList))
    error('Light list was not deleted');
end

%% Add one equal energy light
%
% The cone angle parameter describes how far the spotlight spreads (in
% degrees of visual angle).
%
% The cone delta angle parameter describes how rapidly the light falls off
% at the edges (also in degrees).
thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrum scale', 1,...
    'cone angle',20,...
    'cone delta angle', 3, ...
    'cameracoordinate', true);

%% Set up the render parameters
% 
% This moves the camera closer to the color checker,
% which illustrates the effects of interest here better.
% 
% Shift is in meters.  You have to know something about the
% scale of the scene to use this sensibly.
piCameraTranslate(thisR,'z shift',2); 

%% Render and take a look
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot
%
% We just have one light, and can set its properites with
% piLightSet, indexing into the first light.
lightIndex = 1;
piLightSet(thisR,lightIndex,'cone angle', 10);

%% Render
piWrite(thisR);

%% Render the scene.
%
% Note use of piLightGet to obtain the cone angle of the light.
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val = piLightGet(thisR,'idx',lightIndex,'param','coneangle','print',false);
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%%  Change the light once more and render again
%
% Here we're changing enough that it's easier to delete the
% existing light and add another from scratch.
thisR = piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,... 
    'type','point',...
    'light spectrum','Tungsten',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Check the light list
lightList = piLightGet(thisR);
for ii = 1:length(lightList)
    lightList{ii}
end

%% Render and look
piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'both');
scene = sceneSet(scene,'name','Tungsten (point)');
sceneWindow(scene);

%% END