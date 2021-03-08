%% Initialize ISET and Docker
% Setup ISETcam and ISET3d system.
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'simple scene');

%% Modify new rendering settings
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 

%% Build a lens

lensfile = 'dgauss.22deg.3.0mm.json';
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('focus distance', 0.5);
thisR.set('film diagonal', 5); % mm

%{
nSamples = 100;
thisLens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensfile);
thisLens.draw;
%}

%% Write and render
piWrite(thisR);
% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = 'CBLens';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);