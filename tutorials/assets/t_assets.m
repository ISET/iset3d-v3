%%
ieInit;

%% Test the simplest case for mcc
thisR = piRecipeDefault('scene name', 'MacBethChecker');
piWrite(thisR)
[scene, results] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);

%% Test simple scene
thisRSS = piRecipeDefault('scene name', 'SimpleScene');
disp(thisRSS.assets.tostring)

piWrite(thisRSS);

[scene, results] = piRender(thisRSS, 'render type', 'radiance');
sceneWindow(scene);

%% Now check the cornell box
thisRCB = piRead(which('cornell_box_formal.pbrt'));
thisRCB.set('film resolution',[512 512]);
thisRCB.set('rays per pixel',32);
thisRCB.set('n bounces',5); % Number of bounces

disp(thisRCB.assets.tostring);

%% Delete all light
piLightDelete(thisRCB, 'all');

%%
% Check if piAssetFind works
ids = piAssetFind(thisRCB, {'name', 'type'}, {'3_1_Area Light', 'object'});
piAssetGet(thisRCB, ids)


% Change an object node to light
newLight = piLightCreate('type', 'area');
newLight = piLightSet(newLight, [], 'lightspectrum', 'BoxLampSPD');
% newLight = piLightSet(newLight, [], 'spectrumscale', 1e-10);

thisRCB = piAssetObject2Light(thisRCB, ids, newLight);

%% Reflectance
wave = 400:10:700;
refWhite = ieReadSpectra('CBWhiteSurface', wave);
%%
leftWallIdx = piMaterialFind(thisRCB, 'name', 'Left Wall');
rightWallIdx = piMaterialFind(thisRCB, 'name', 'Right Wall');
whiteWallIdx = piMaterialFind(thisRCB, 'name', 'Other Walls');

piMaterialSet(thisRCB, leftWallIdx, 'spectrumkd', refWhite);
piMaterialSet(thisRCB, rightWallIdx, 'spectrumkd', refWhite);
piMaterialSet(thisRCB, whiteWallIdx, 'spectrumkd', refWhite);

piWrite(thisRCB);
[scene, results] = piRender(thisRCB, 'render type', 'radiance');
sceneWindow(scene);

%%
sensor = sensorCreate('Monochrome');
