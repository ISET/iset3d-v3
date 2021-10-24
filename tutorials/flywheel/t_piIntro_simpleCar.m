%% Gets a skymap from Flywheel; also uses special scene materials
%
% This script shows how to create a simple scene using assets that are
% stored in the Flywheel stanfordlabs site.  To run this script you must
% have permission (a key) to login and download assets from Flywheel.
%
% This technique is used at a much larger scale in creating complex driving
% scenes.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), ISETAuto(zhenyi branch), JSONio, SCITRAN
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
% updated, 2021
%
% See also
%   t_piIntroduction01, t_piIntroduction02

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
% if ~piScitranExists, error('scitran installation required'); end

%% Render cars on a planar surface

% Initialize a planar surface with a checkerboard texture pattern
sceneName = 'simpleCarScene';
sceneR = piRecipeDefault('scene name','checkerboard');
sceneR.set('outputFile',fullfile(piRootPath, 'local', sceneName,[sceneName,'.pbrt']));

% render quality
sceneR.set('film resolution',[1280 600]/2);
sceneR.set('pixel samples',8);
sceneR.set('max depth',3);

% camera properties
sceneR.set('fov',45);
sceneR.set('from', [0 1.5 7]);   % from was 5
sceneR.set('to',[0 0.5 0]);
sceneR.set('up',[0 1 0]);

% scale and rotate planar checkerboard
sceneR.set('assets','0002ID_Checkerboard_B','scale',[10 10 1]);
sceneR.set('asset','Checkerboard_B','world rotation',[90 30 0]);

%% Read in the car model and reformat it 

% The scene starts in data/V3 and it is reformatted into
% local/formatted/car.
car_fname = fullfile(piRootPath, 'data','V3','car','car.pbrt');
car_formatted_fname = fullfile(piRootPath,'local','formatted','car','car.pbrt');

if ~exist(car_formatted_fname,'file')
    car_formatted_fname = piPBRTReformat(car_fname, 'outputfull', car_formatted_fname);
end

% Read the reformatted car recipe
objectR = piRead(car_formatted_fname);

%% Merge the background scene and the car object

% To merge, the files must exist on disk.  The base scene already exists,
% but we haven't written out the object recipe.  We write it out, which
% also reorganizes the PBRT files.
% piWrite(objectR);
sceneR = piRecipeMerge(sceneR, objectR);

% piAssetGeometry(sceneR);

%% Add a light to the merged scene
skyname = 'probe_16-30_latlongmap.exr';

% Delete any lights that happened to be there
sceneR = piLightDelete(sceneR, 'all');

rotation(:,1) = [0 0 0 1]';
rotation(:,2) = [45 0 1 0]';
rotation(:,3) = [-90 1 0 0]';

skymap = piLightCreate('new skymap', ...
    'type', 'infinite',...
    'string mapname', skyname,...
    'rotation',rotation);

sceneR.set('light', 'add', skymap);
disp('*** Skymap added');
%% This adds predefined sceneauto materials to the assets in this scene

% print material
sceneR.show('materials');

% assign material
iaAutoMaterialGroupAssign(sceneR); 
 
% check again after material assign
sceneR.show('materials');

% show corresponding material name for each asset
% piAssetMaterialPrint(sceneR);
sceneR.show('assets materials');

%% Set the car body to a new color.

colorkd = piColorPick('blue');

MaterialName = 'AudiSportsCar01_Metal_Carbody02'; 
sceneR.set('material',MaterialName,'kd value',colorkd);

% Assign a nice position.
sceneR.set('asset','AudiSportsCar01_B','world translation',[0.5 0 0]);
sceneR.set('asset','AudiSportsCar01_B','world rotation',[0 -15 0]);
sceneR.set('asset','AudiSportsCar01_B','world rotation',[0 -30 0]);

%% Write out the pbrt scene file, based on scene.
piWrite(sceneR);   % We get a warning.  Ignore

%% Render.

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(sceneR,'render type','radiance');

%  Show the scene in a window

% scene = sceneSet(scene,'name',sprintf('Time: %s',thisTime));
% denoise scene
% scene = sceneSet(scene,'gamma', 0.75);
scene = sceneSet(scene,'name', 'normal');
sceneWindow(scene);
sceneSet(scene,'display mode','hdr'); 

% denoise
%{
sceneDenoise = piAIdenoise(scene);
scene = sceneSet(scene,'name', 'denoised');
sceneWindow(sceneDenoise);
% sceneSet(scene,'display mode','hdr');   
%}
%% Create object instances
% Add one object instance
sceneR   = piObjectInstanceCreate(sceneR, 'AudiSportsCar01_B', 'position', [3.5 0 0]);
sceneR.assets = sceneR.assets.uniqueNames;

piWrite(sceneR);  
[scene, result] = piRender(sceneR,'render type','radiance');
scene = sceneSet(scene,'name', 'Add a car instance');
sceneWindow(scene);
%%  Add a rotated version of the car

rotation = piRotationMatrix('yrot',75);
sceneR   = piObjectInstanceCreate(sceneR, 'AudiSportsCar01_B', 'position', [-1 0 3], 'rotation',rotation);

sceneR.assets = sceneR.assets.uniqueNames;

% 'from' is a camera specification.  We are moving it closer??
% sceneR.set('from', [0 1.5 7]);

piWrite(sceneR);   
[scene, result] = piRender(sceneR,'render type','radiance');
scene = sceneSet(scene,'name', 'With 2 more identical cars at different postions');
sceneWindow(scene);
%%
% add new material
matName = 'newCarbody';
rgbkd = piColorPick('white');
rgbks = [0.15 0.15 0.15];

newMat = piMaterialCreate(matName, ...
    'type','substrate',...
    'kd value',rgbkd,...
    'ks value',rgbks,...
    'uroughness value', 0.0005,...
    'vroughness value', 0.0005);

sceneR.set('material','add', newMat);
piMaterialPrint(sceneR);
%% Change material of the object(carbody) of a car instance 

[idx,asset] = piAssetFind(sceneR, 'name', '0070ID_001_AudiSportsCar01_O_I_2');

% set asset material name
asset{1}.material.namedmaterial = matName;

% change asset type from instance to object
asset{1}.type = 'object';

% give it a new name
asset{1}.name = '001_AudiSportsCar01_newCarbody_O';
sceneR.assets = sceneR.assets.set(idx, asset{1});
sceneR.assets = sceneR.assets.uniqueNames;

piWrite(sceneR);   
[scene, result] = piRender(sceneR,'render type','radiance');
scene = sceneSet(scene,'name', 'change material of a car instance');
sceneWindow(scene);
%% Delete an instance

% remove '0036ID_AudiSportsCar01_B_I_1'
% only instance No.2 remains
sceneR = piObjectInstanceRemove(sceneR,'0036ID_AudiSportsCar01_B_I_1');
sceneR.assets = sceneR.assets.uniqueNames;
piWrite(sceneR);  

[scene, result] = piRender(sceneR,'render type','radiance');
scene = sceneSet(scene,'name', 'remove a car instance');
sceneWindow(scene);

%% Add the instance again

% now you should see the added instance using a index equals to 1

sceneR = piObjectInstanceCreate(sceneR, 'AudiSportsCar01_B', 'position', [4 0 0]);
sceneR.assets = sceneR.assets.uniqueNames;
piWrite(sceneR);  

[scene, result] = piRender(sceneR,'render type','radiance');
scene = sceneSet(scene,'name', 'Add a car instance back');
sceneWindow(scene);

%% END
