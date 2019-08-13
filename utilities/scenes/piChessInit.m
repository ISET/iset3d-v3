function [outFile, dest] = piChessInit(resolution)
% Initialize Docker and ChessSet scene
%
%   piChessInit.m
%
% Many tutorial calculations use the Chess Set scene to demonstrate
% ISET3d parameters.  Rather than reload the scene each time, we get
% the data and recipe set up using this script
%
% Wandell, 2019
%
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
    dest = piPBRTFetch(sceneName,'pbrtversion',3,...
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

thisR.set('film diagonal',22);

%%
fprintf('Using lens:\t %s\n',lensfile);
fprintf('Output file:\t %s\n',outFile);
fprintf('Sample res:\t %f\n',filmResolution(1));

%%