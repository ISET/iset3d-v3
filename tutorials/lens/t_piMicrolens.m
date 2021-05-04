%% Creating a microlens plus imaging lens for PBRT lightfield calculation
%
% Dependencies
%   isetlens toolbox
%
% Wandell, 2019
%
% See also
%   t_piIntro_microlens, piCameraInsertMicrolens, 
%

%% Programming questions -
% 
% * Given that we set the filmwidth and filmheight, should we be able to
%  read these from the lens file?  
%
% * How do we set filmtomicrolens for the omni camera in PBRT?
%

%% 
ieInit
if ~piDockerExists, piDockerConfig; end
if isempty(which('lensC')), error('Add isetlens to your path'); end


%% Help command for the lenstool insertmicrolens
%
status = system('docker run -ti --rm vistalab/pbrt-v3-spectral lenstool');

%% Shows the lenses

if isempty(which('lensC'))
    error('The isetlens repository must be on your path'); 
end

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

% You can run the cmd this way
%
%  system(cmd);
%

%% Have a look at the output file

thisLens = lensC('filename',combinedLens);
thisLens.draw;

%%