%% Creating a microlens plus imaging lens calculation
%
% Uses the isetlens toolbox
%
% See also
%   piCameraInsertMicrolens
%

%% Programming questions -
%  Given that we set the filmwidth and filmheight, should we be able to
%  read these from the lens file?  Same with filmtomicrolens

%% 
ieInit
piDockerConfig;

%% Shows the lenses

% Microlens with height of 2 um 
microLensName = fullfile(piRootPath,'data','lens','microlens.json');   
microLens = lensC('filename',microLensName);
microLens.scale(4);                  % Increases the size to 8 um
microLens.name = sprintf('%s-scale4',microLens.name);
microLens.draw;

imagingLensName = fullfile(piRootPath,'data','lens','dgauss.22deg.3.0mm.json');    % Size is 2 um
imagingLens = lensC('filename','dgauss.22deg.3.0mm.json');
imagingLens.draw;

%% Call lenstool from Docker container and set special parameters

chdir(fullfile(piRootPath,'local','microlens'));

% Small dimensions to speed up the calculation
[combinedLens, cmd]  = piCameraInsertMicrolens(microLens,imagingLens, ...
    'xdim', 8, 'ydim', 8);

% cmd is the terminal command built up in the window
disp(cmd)

%% Have a look at the output file

thisLens = lensC('filename',combinedLens);
thisLens.draw;

%% Help command for the lenstool insertmicrolens
%
% Copy and paste this into a terminal window
%
status = system('docker run -ti --rm vistalab/pbrt-v3-spectral lenstool');

%% The command line docker command for "lenstool insertmicrolens"
%
% Copy and paste the command into a terminal window - after putting the
% relevant files into place ...  This is the command that is built up in
% piCameraInsertMicrolens
%
% docker run -ti --rm vistalab/pbrt-v3-spectral lenstool insertmicrolens -xdim 64 -ydim 64 dgauss.22deg.3.0mm.json microlens.2um.Example.json combined.json
system(cmd)

%%