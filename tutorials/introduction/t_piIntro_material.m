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

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt file for a Cinema4D exported scene

thisR = piRecipeDefault('scene name','sphere');
% thisR = piLightAdd(thisR, 'type', 'point', 'camera coordinate', true);

thisR = piLightAdd(thisR, 'type', 'distant', 'light spectrum', [9000 0.001],...
                        'camera coordinate', true);

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5);

%% The material library

% Print out the named materials in this scene.
thisR.get('materials print');

% We have additional materials in an ISET3d library.  In the future, we
% will be creating the material library in a directory within ISET3d, and
% expanding on them.
piMaterialList;

%% Render

piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

%% Add a red matte surface

% Create a red matte material
redMatte = 'redMatte';
newMatte = piMaterialCreate(redMatte, 'type', 'matte');

% Add the material to the materials list
thisR.set('material', 'add', newMatte);
thisR.get('print materials');

%%
% Set the spectral reflectance of the matte material to be very red.  Put
% it in the PBRT spd format.
wave = 400:10:700;
reflectance = ones(size(wave));
reflectance(1:20) = 0;
spdRef = piMaterialCreateSPD(wave, reflectance);

% Store the reflectance as the diffuse reflectance of the redMatte
% material
thisR.set('material', redMatte, 'kd value', spdRef);

%%
assetName = 'Sphere_O';
thisR.set('asset',assetName,'material name',redMatte);
thisR.get('object materials')
% thisR.assets.show;

%% Let's have a look
piWrite(thisR);
scene = piRender(thisR);
scene = sceneSet(scene,'name',sprintf('Uber %s',sceneName));
sceneWindow(scene);

%% Make the ball glass

%{
% Glass and mirror are not working.  Ask ZLyu why
%
mirrorName = 'glass';
newMirror = piMaterialCreate(mirrorName, 'type', 'glass');
thisR.set('material', 'add', newMirror);
thisR.get('print materials');
thisR.set('asset', assetName, 'material name', mirrorName);
thisR.get('object materials')

%
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Change sphere to mirror');
sceneWindow(scene);
%}

%%
