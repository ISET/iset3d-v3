%% Read and show a microlens
%
% Requires the isetlens toolbox
%
% See also
%
%

%% 

ieInit
piDockerConfig;

%%
microLensName = 'microlens.2um.Example.json';
microLens = lensC('filename','microlens.2um.Example.json');
microLens.draw;

imagingLensName = 'dgauss.22deg.3.0mm.json';
imagingLens = lensC('filename','dgauss.22deg.3.0mm.json');
imagingLens.draw;

%%
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName);

%%
docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json


docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens

