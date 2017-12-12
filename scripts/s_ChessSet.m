%% Render a ChessSet scene with pinhole optics
%
% NOTES:
%
% Timing on a 2015 MacPro with a few cores.
%
%  Timing     film resol   rays per pixel
%    11 s       128            64
%    17 s       128            128
%    27 s       256            64
%    49 s       256            128
%   201 s       256            256
%   364 s       512            256
%
% The ChessSet scene data are fairly large, so we do not include it in the
% github repository.  To download it, use the piFetchPBRT command below.
%
% Downloading requires that you have the RemoteDataToolbox installed.
% <https://github.com/isetbio/RemoteDataToolbox.git>.
% 
% Download comment
%   piPBRTFetch('ChessSet');      % Get the chess set for the RDT
%
% BW SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
fname = fullfile(piRootPath,'data','ChessSet','chessSet.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);
from = thisR.get('from');

%% Default is a relatively low resolution (256).
thisR.set('camera','pinhole');
thisR.set('from',from + [0 0 100]);  % First left/right, 2nd moved camera closer and to the right 
thisR.set('film resolution',256);
thisR.set('rays per pixel',128);

%% Set up Docker 

[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local','chess',[n,e]);
piWrite(thisR);

%% Render with the Docker container

scene = piRender(thisR);

% Show it in ISET
vcAddObject(scene); sceneWindow;

%%
