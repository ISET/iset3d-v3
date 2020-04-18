% t_textureBasisFunction
% Apply new basis functions to texture

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
piLightGet(thisR); % Should be nothing

% Add a new equalEnergy light
thisR = piLightAdd(thisR, 'type', 'distant', 'camera coordinate', true,...
                    'light spectrum', 'equalEnergy');
                
%% Write the recipe
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:fluorescent';
wave = 365:5:705;
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'illuminant');
sceneName = 'PBRT original basis';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Check texture list

piTextureList(thisR);
%% Now set the basis function 

basisFunctions = 'pbrtReflectance.mat';
textureIdx = 1;
piTextureSetBasis(thisR, textureIdx, wave, 'basis functions', basisFunctions);

%% Write the recipe again
piWrite(thisR, 'overwritematerials', true);

%% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:fluorescent';
wave = 365:5:705;
[scene, ~] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'radiance');
sceneName = 'SVD processed basis';
scene = sceneSet(scene, 'scene name', sceneName);
sceneWindow(scene);

%% Use this for now
wave = 365:5:705;
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/pbrt.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene);