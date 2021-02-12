thisR = piRecipeDefault('scene name', 'slantedbar');
% Change the light to 405 nm light source
thisR.set('light', 'delete', 'all');
newDistLight = piLightCreate('fluorescent light',...
                            'type', 'distant',...
                            'spd', 'blueLEDFlood',...
                            'specscale', 1,...
                            'cameracoordinate', true);
thisR.set('light', 'add', newDistLight);
assetName = 'WhitePlane_O';
thisR = piFluorescentPattern(thisR, assetName, 'algorithm', 'half split', 'concentration', 2);
piWrite(thisR);
wave = 365:5:705;
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, result] = piRender(thisR, 'docker image name', thisDocker,'wave',wave, 'render type', 'radiance');
scene = sceneSet(scene,'wavelength', wave);
sceneWindow(scene);