%% Creating a microlens plus imaging lens calculation
%
% Uses the isetlens toolbox
%
% See also
%   piCameraInsertMicrolens
%

%% 
ieInit
piDockerConfig;

%% Shows the lenses

% This is just for clarification.  
microLensName = 'microlens.2um.Example.json';
microLens = lensC('filename','microlens.2um.Example.json');
microLens.draw;

imagingLensName = 'dgauss.22deg.3.0mm.json';
imagingLens = lensC('filename','dgauss.22deg.3.0mm.json');
imagingLens.draw;

%% Matlab wrapper for the insert microlens docker tool
%
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName);

%% Set other than the default parameters

chdir(fullfile(piRootPath,'local'));
microLensName   = 'microlens.2um.Example.json';
imagingLensName = 'dgauss.22deg.3.0mm.json';
combinedLens = piCameraInsertMicrolens(microLensName,imagingLensName, ...
    'xdim',32, 'ydim',32);

% Have a look at the output
%  edit(combinedLens);
lensInfo = jsonread(combinedLens);

% Some questions -
%  Given that we set the filmwidth and filmheight, should we be able to
%  read these from the lens file?  Same with filmtomicrolens
%% Help command for the lenstool insertmicrolens
%
% Copy and paste this into a terminal window
%
status = system('docker run -ti --rm vistalab/pbrt-v3-spectral lenstool');

%% Example of a docker command for the lenstool insertmicrolens
%
% Copy and paste this into a terminal window - after putting the
% relevant files into place ...
%
docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json

%%