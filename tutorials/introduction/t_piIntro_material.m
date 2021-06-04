%% Illustrates setting scene materials
%
% This example scene includes glass and other materials.  The script
% sets up the glass material and number of bounces to make the glass
% appear reasonable.
%
% It also uses piMaterialsGroupAssign() to set a list of materials (in
% this case a mirror) that are part of the scene.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_*

% TODO:
%  See notes at end.

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt file for a Cinema4D exported scene

sceneName = 'sphere';
thisR = piRecipeDefault('scene name',sceneName);

% Create an environmental light source (distant light) that is a 9K
% blackbody radiator.
distLight = piLightCreate('new dist light',...
                            'type', 'distant',...
                            'spd', [9000 0.001],...
                            'cameracoordinate', true);
thisR.set('light', 'add', distLight);

thisR.set('film resolution',[200 150]*3);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5);

% Render
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

%% The material library

% Print out the named materials in this scene.
thisR.get('materials print');

% We have additional materials in an ISET3d library.  In the future, we
% will be creating the material library in a directory within ISET3d, and
% expanding on them.
piMaterialPrint(thisR);

%% Add a red matte surface

% Create a red matte material
redMatte = piMaterialCreate('redMatte', 'type', 'matte');

% Add the material to the materials list
thisR.set('material', 'add', redMatte);
thisR.get('materials print');

%% Set the spectral reflectance of the matte material to be very red.  

wave = 400:10:700;
reflectance = ones(size(wave));
reflectance(1:17) = 0;

% Put it in the PBRT spd format.
spdRef = piMaterialCreateSPD(wave, reflectance);

% Store the reflectance as the diffuse reflectance of the redMatte
% material
thisR.set('material', redMatte, 'kd value', spdRef);

%% Set the material 
assetName = '001_Sphere_O';
thisR.set('asset',assetName,'material name',redMatte.name);

% Show that we set it
thisR.get('object material')

%% Let's have a look
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name',sprintf('Red %s',sceneName));
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else,        sceneSet(scene,'gamma',0.6);
end
%%  Now change an environmental light

rmLight = piLightCreate('room light', ...
    'type', 'infinite',...
    'mapname', 'room.exr');
rmLight = piLightSet(rmLight, 'rotation val', {[0 0 1 0], [-90 1 0 0]});
%% Put the sphere in an environment

% Make the sphere a little smaller
assetName = '001_Sphere_O';
thisR.set('asset',assetName,'scale',[0.5 0.5 0.5]);

% Add an environmental light
thisR.set('light', 'delete', 'all');
thisR.set('light', 'add', rmLight);

% Check that the room.exr file is in the directory.
% In time, we will be using piRenderValidate()
%
% For standard environment lights, we want something like
%
%   thisR.set('skymap',filename); 
%
if ~exist(fullfile(thisR.get('output dir'),'room.exr'),'file')
    exrFile = which('room.exr');
    copyfile(exrFile,thisR.get('output dir'))
end

%% Write and render
piWrite(thisR);
scene = piRender(thisR,'render type','radiance');
scene = sceneSet(scene,'name',sprintf('Red %s',sceneName));
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else,        sceneSet(scene,'gamma',0.6);
end
%% Make the sphere glass

glassName = 'glass';
glass = piMaterialCreate(glassName, 'type', 'glass');
thisR.set('material', 'add', glass);
thisR.get('print materials');
thisR.set('asset', assetName, 'material name', glassName);
thisR.get('object material')

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change sphere to glass');
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else,        sceneSet(scene,'gamma',0.6);
end
%% Change the camera position

% Where is the sphere ...
assetPosition = thisR.get('asset',assetName,'world position');
thisR.set('to',assetPosition);

origFrom = [0 0 -500];  % Original from position

% Set the camera from position a little higher and closer
thisR.set('from',assetPosition + [0 100 -400]);
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change sphere to glass');
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else,        sceneSet(scene,'gamma',0.6);
end

%% Change the sphere to a mirror 

mirrorName = 'mirror2';
mirror = piMaterialCreate(mirrorName, 'type', 'mirror');
thisR.set('material', 'add', mirror);
thisR.get('print materials');
thisR.set('asset', assetName, 'material name', mirrorName);
thisR.get('object material')

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change sphere to glass');
sceneWindow(scene);
if piCamBio, sceneSet(scene,'render flag','hdr');
else,        sceneSet(scene,'gamma',0.6);
end

%% END
