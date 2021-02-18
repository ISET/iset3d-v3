% t_textureBasisFunction
%
% Check if we can effectively use our basis function as new reflectance
% estimation basis in PBRT for 2D texture map
%
% Zheng Lyu, 2020

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the flatSurfaceTexture scene
thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');
%% Use a smaller resolution
thisR.set('filmresolution', [360, 320])
thisR.sampler.pixelsamples.value = 16;
thisR.integrator.maxdepth.value = 1;
%% Check and remove all lights
thisR.get('lights') % Should be nothing

newDistLight = piLightCreate('new dist light', 'type', 'distant',...
                                               'cameracoordinate', true,...
                                               'spd', 'equalEnergy');
thisR.set('light', 'add', newDistLight);

thisR.get('lights print');

                
%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
wave = 365:5:705;
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'PBRT original basis';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Check texture list
thisR.get('texture print');

%% Now set the basis function 

basisFunctions = 'pbrtReflectance2.mat';
tName = 'reflectanceChart_color';
thisR.set('texture', 'basis', tName, wave, basisFunctions);

%% Write the recipe again
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
wave = 365:5:705;
[scene, result] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'SVD processed basis';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);
