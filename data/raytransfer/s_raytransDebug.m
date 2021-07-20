%% Test the ray transfer docker
clear;

% docker pull vistalab/pbrt-v3-spectral:raytransfer
thisR = piRecipeDefault('scene name','simple scene');


camera = piCameraCreate('raytransfer','lensfile','dgauss-22deg-3.0mm.json');
camera.filmdistance.value=0.002167; % meters




thisR.set('film distance',0.002167);
thisR.set('film diagonal',5)
thisR.set('camera',camera);
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer';

piWrite(thisR);
[oi, result] = piRender(thisR, 'dockerimagename',thisDocker,'render type','radiance');
oiWindow(oi);

%[dMap, result] = piRender(thisR, 'dockerimagename',thisDocker,'render type','depth');

% The .dat file is generated and I can open it manually but there is an error generated in piRender that you might be most suited to understand.
% Just to make sure I copied the error down here:
 
% Output argument "ieObject" (and maybe others) not assigned during call to "piDat2ISET".
 
% Error in piRender (line 423)
% ieObject = piDat2ISET(outFile,...
 
% Error in s_piMetricsSlantedBars (line 18)
% [oi, result] = piRender(thisR, 'dockerimagename',...


%{
 camera = piCameraCreate('raytransfer','lensfile','dgauss-22deg-3.0mm.json');
 chessR.set('film distance',0.002167);
 chessR.set('film diagonal',2);
% thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer';
 thisDocker = 'vistalab/pbrt-v3-spectral:latest';
 piWRS(chessR,'docker image name',thisDocker); % Quick check
%}