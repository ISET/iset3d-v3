%% Illustrate how to control properties of scene lights
%
%  The light structure has a large number of parameters that control its
%  properties.  We will be controlling the properties with commands of sthis
%  type:
%
%    thisR.set('light ' .....)
% 
% Here we illustrate examples for creating and setting properties of
%
%     * Spot lights (cone angle, cone delta angle, position)
%     * SPD: RGB and Spectrum
%     * Environment lights
%
% See also
%   The PBRT book definitions for lights are:
%      https://www.pbrt.org/fileformat-v3.html#lights
%

%% Initialize ISET and Docker and read a file

% Start up ISET/ISETBio and check that the user is configured for docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

thisR = piRecipeDefault('scene name','checkerboard');

%% Check the light list that came with the scene

% To summarize the lights use this
thisR.get('light print');

% We can get a specific light by its name
thisR.get('light', '#1_Light_type:distant')

% Or we can get the light from its index (number) in this list.
thisR.get('light', 1)

%% Remove all the lights

thisR.set('light', 'delete', 'all');
thisR.get('light print');

%% Types of lights

% There are a few different types of lights.  The different types we
% control in ISET3d are defined in piLightCreate;  To see the list of
% possible light types use
%
piLightCreate('help');

%% Add a spot light
%
% The spot light is defined by
%
%  * the cone angle parameter, which describes how far the spotlight
%  spreads (in degrees of visual angle), and
%  * the cone delta angle parameter describes how rapidly the light falls
%  off at the edges (also in degrees).
%

% NOTE: 
% Unlike most of ISET3d, you do not have the freedom to put spaces into the
% key/val parameters for this function.  Thus, coneangle cannot be 'cone
% angle'.
%
% Consult the textbook to see the full list of parameters.
%
% https://www.pbrt.org/fileformat-v3.html#lights
%
lightName = 'new spot light';
newLight = piLightCreate(lightName,...
                        'type','spot',...
                        'spd','equalEnergy',...
                        'specscale', 1, ...
                        'coneangle', 15,...
                        'conedeltaangle', 10, ...
                        'cameracoordinate', true);
thisR.set('light', 'add', newLight);
thisR.get('light print');

%% Set up the render parameters

% This moves the camera closer to the color checker,
% which illustrates the effects of interest here better.
% 
% Shift is in meters.  You have to know something about the
% scale of the scene to use this sensibly.
piCameraTranslate(thisR,'z shift',1); 

piWrite(thisR);
%%
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
sceneWindow(scene);

%%  Narrow the cone angle of the spot light a lot

% We just have one light, and can set its properites with
% piLightSet, indexing into the first light.
thisR.set('light', lightName, 'coneangle', 10);
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val   = thisR.get('light', lightName, 'coneangle val');
scene = sceneSet(scene,'name',sprintf('EE spot %d',val));
sceneWindow(scene);

%% Shift the light to the right

% The general syntax for the set is to indicate
%
%   'light' - action - lightName or index - parameter value
%
% We shift the light here by 0.1 meters in the x-direction.
thisR.set('light', 'translate', 'new spot light', [0.1, 0, 0]);

piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val   = thisR.get('light', lightName, 'coneangle');
scene = sceneSet(scene,'name',sprintf('EE spot to right %d',val));
sceneWindow(scene);

%% Rotate the light

% thisR.set('light', 'rotate', lghtName, [XROT, YROT, ZROT], ORDER)
thisR.set('light', 'rotate', 'new spot light', [0, -5, 0]); % -5 degree around y axis
piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Equal energy (spot)');
val   = thisR.get('light', lightName, 'coneangle val');
scene = sceneSet(scene,'name',sprintf('Rotate EE spot'));
sceneWindow(scene);

%%  Change the light once more and render again

% Here we're changing enough that it's easier to delete the
% existing light and add another from scratch.
thisR.set('light', 'delete', 'all');
pointLight = piLightCreate('new point',...
                           'type', 'point', ...
                           'spd spectrum', 'Tungsten',...
                           'specscale float', 1,...
                           'cameracoordinate', true);
thisR.set('light', 'add', pointLight);

thisR.get('light print');

%% Render and look

piWrite(thisR);
[scene, ~] = piRender(thisR, 'render type', 'radiance'); 
scene = sceneSet(scene,'name','Tungsten (point)');
sceneWindow(scene);

%% When spd is three numbers, we recognize it is rgb values

distLight = piLightCreate('new dist',...
                           'type', 'distant', ...
                           'spd', [0.3 0.5 1],...
                           'specscale float', 1,...
                           'cameracoordinate', true);
thisR.set('lights', 'replace', 'new point', distLight);                       
thisR.get('lights print');

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Blue (distant)');
sceneWindow(scene);

%% Add an environment light

thisR.set('light', 'delete', 'all');

fileName = 'pngExample.png';
exampleEnvLight = piLightCreate('room light', ...
    'type', 'infinite',...
    'mapname', fileName);
exampleEnvLight = piLightSet(exampleEnvLight, 'rotation val', {[0 0 1 0], [-90 1 0 0]});

thisR.set('lights', 'add', exampleEnvLight);                       

% Check the light list
thisR.get('light print');

% Zoom out a bit 
piCameraTranslate(thisR,'z shift', -10); 

% Rotate around x and y axis
piCameraRotate(thisR, 'y rot', -10);
piCameraRotate(thisR, 'x rot', 10);

piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','Environment light');
sceneWindow(scene);

%% END