function thisR = piChessInit(resolution)
% Initialize Docker and ChessSet scene
%
% Syntax:
%
%   thisR = piChessInit(resolution)
%
% Brief description
%   Many tutorial calculations use the Chess Set scene to demonstrate
%   ISET3d parameters.  Rather than reload the scene each time, we get
%   the data and recipe set up using this script
%
% Wandell, 2019
%

% Maybe we should generalize.
% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';


%%
if notDefined('resolution'), resolution = 0.25; end

if ~piDockerExists, piDockerConfig; end

%% Read the pbrt files

sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

inFolder = fullfile(piRootPath,'local','scenes');
inFile = fullfile(inFolder,sceneName,sceneFileName);
if ~exist(inFile,'file')
    if isempty(which('RdtClient'))
        error('You must have the remote data toolbox on your path');
    end
    % Sometimes the user runs this many times and so they already have
    % the file.  We only fetch the file if it does not exist.
    fprintf('Downloading %s from RDT',sceneName);
    piPBRTFetch(sceneName,'pbrtversion',3,...
        'destinationFolder',inFolder,...
        'delete zip',true);
end

% This is the PBRT scene file inside the output directory
thisR  = piRead(inFile);

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
piWrite(thisR,'creatematerials',true);

%%
thisR.summarize;

%%