%% Read and show a microlens
%
% Requires the isetlens toolbox
%
% See also
%   piCameraInsertMicrolens
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

%% Matlab wrapper for the insert microlens docker tool
%
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName);

%% Help command for the lenstool insertmicrolens
%
% Copy and paste this into a terminal window
%
docker run -ti --rm vistalab/pbrt-v3-spectral lenstool 

%% Example of a docker command for the lenstool insertmicrolens
%
% Copy and paste this into a terminal window - after putting the
% relevant files into place ...
%
docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json

%%