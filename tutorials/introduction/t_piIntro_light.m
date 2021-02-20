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
nLight = thisR.get('n light');
for ii = 1:nLight
    thisR.get('light', ii)
end

%% Remove all the lights
thisR.set('light', 'delete', 'all');
lightList = thisR.get('light');
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
newLight = piLightCreate('new spot light',...
                        'type','spot',...
                        'spd spectrum','equalEnergy',...
                        'specscale float', 1,...
                        'coneangle float',20,...
                        'conedeltaangle float', 3, ...
                        'cameracoordinate', true);
thisR.set('light', 'add', newLight);
thisR.get('light print');
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
[scene, result] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot
%
% We just have one light, and can set its properites with
% piLightSet, indexing into the first light.
lightIndex = 1;
thisR.set('light', lightIndex, 'coneangle val', 10);

%% Render
piWrite(thisR);

%% Render the scene.
%
% Note use of piLightGet to obtain the cone angle of the light.
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val = thisR.get('light', lightIndex, 'coneangle val');
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%% Shift the light to the right
% thisR.set('light', 'translate', lghtName, [XSFT, YSFT, ZSFT], FROMTO)
thisR.set('light', 'translate', 'new spot light', [0.1, 0, 0]);

%% Render
piWrite(thisR);

%% Render the scene.
%
% Note use of piLightGet to obtain the cone angle of the light.
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val = thisR.get('light', lightIndex, 'coneangle val');
scene = sceneSet(scene,'name',sprintf('EE spot to right %d',val));
sceneWindow(scene);


%% Rotate the light
% thisR.set('light', 'rotate', lghtName, [XROT, YROT, ZROT], ORDER)
thisR.set('light', 'rotate', 'new spot light', [0, -5, 0]); % -5 degree around y axis

%% Render
piWrite(thisR);

%% Render the scene.
%
% Note use of piLightGet to obtain the cone angle of the light.
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val = thisR.get('light', lightIndex, 'coneangle val');
scene = sceneSet(scene,'name',sprintf('Rotate EE spot'));
sceneWindow(scene);

%%  Change the light once more and render again
%
% Here we're changing enough that it's easier to delete the
% existing light and add another from scratch.
thisR.set('light', 'delete', 'all');
pointLight = piLightCreate('new point',...
                           'type', 'point', ...
                           'spd spectrum', 'Tungsten',...
                           'specscale float', 1,...
                           'cameracoordinate', true);
thisR.set('light', 'add', pointLight);
%% Check the light list
thisR.get('light print');

%% Render and look
piWrite(thisR);
[scene, ~] = piRender(thisR, 'render type', 'both'); 
scene = sceneSet(scene,'name','Tungsten (point)');
sceneWindow(scene);

%%
% When spd is three numbers, we recognize it is rgb values
distLight = piLightCreate('new dist',...
                           'type', 'distant', ...
                           'spd', [0.3 0.5 1],...
                           'specscale float', 1,...
                           'cameracoordinate', true);
thisR.set('lights', 'replace', 'new point', distLight);                       
thisR.get('lights print');

%% Render and look
piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'both');
scene = sceneSet(scene,'name','Blue (distant)');
sceneWindow(scene);

%% Add an environment light
fileName = 'pngExample.png';
exampleEnvLight = piLightCreate('room light', ...
    'type', 'infinite',...
    'mapname', fileName);
exampleEnvLight = piLightSet(exampleEnvLight, 'rotation val', {[0 0 1 0], [-90 1 0 0]});

thisR.set('light', 'delete', 'all');
thisR.set('lights', 'add', exampleEnvLight);                       
% Check the light list
thisR.get('light print');

% Zoom out a bit 
piCameraTranslate(thisR,'z shift', -10); 

% Rotate around x and y axis
piCameraRotate(thisR, 'y rot', -15);
piCameraRotate(thisR, 'x rot', 10);
%% Render and look
piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Environment light');
sceneWindow(scene);

%% END