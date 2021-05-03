function thisR = piChessInit(resolution)
% Initialize Docker and ChessSet scene
%
% Syntax:
%   thisR = piChessInit(resolution)
%
% Inputs
%   resolution:  A number relative to 1 (600,600) to set the spatial
%                resolution
%
% Brief description
%   Many tutorial calculations use the Chess Set scene to demonstrate
%   ISET3d parameters.  Rather than reload and set scene parameters each
%   time, we get the data and recipe set up using this script.  It includes
%   a lens, so the return will be an OI.
%
%   This script was probably more useful in the past.  The default chess
%   set scene seems pretty much OK now.
%
% Wandell, 2019
%
% See also
%   piRecipeDefault

%%
if notDefined('resolution'), resolution = 0.25; end
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt files

sceneName = 'ChessSet';
thisR = piRecipeDefault('scene name',sceneName);

%% Set render quality

% Set resolution for speed or quality.
filmResolution = round([600 600]*resolution);
thisR.set('film resolution',filmResolution);  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',16);                      % 128 for high quality

%% Set output file

oiName    = sceneName;
outFile   = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
% outputDir = fileparts(outFile);
thisR.set('outputFile',outFile);

%% Create a camera with lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

%% Set up rendering parameters

thisR.set('film diagonal',22);    % In mm

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default 
thisR.set('object distance',1.2);    % From-To separation in meters

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype    = 'sobol';

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

% Change this for depth of field effects.
thisR.set('aperture diameter',2);   % thisR.summarize('all');

%% Save.  I think you may need to run piWrite() whenever you change thisR
piWrite(thisR);

%%
thisR.summarize;

%%