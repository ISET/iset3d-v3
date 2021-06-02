% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
fname = fullfile(piRootPath,'data','V3','ChessSet','ChessSet.pbrt');
formattedFname = piPBRTReformat(fname);

thisR = piRead(formattedFname);

%% Specify new rendering setting
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 

piWrite(thisR);
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);

%%
sceneWindow(scene);
