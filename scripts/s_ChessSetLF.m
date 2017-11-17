%% Render a ChessSet scene with LightField optics
%
% NOTES: NOT WORKING YET.  Need to set lens and focus better.  Need to add
% sensor and LF<> tools
%
% Timing on a 2015 MacPro with a few cores.
%
%  Timing     film resol   rays per pixel
%
% The ChessSet scene data are fairly large, so we do not include it in the
% github repository.  To download it, use the piFetchPBRT command below.
%
% Downloading requires that you have the RemoteDataToolbox installed.
% <https://github.com/isetbio/RemoteDataToolbox.git>.
% 
% Download comment
%   piFetchPBRT('ChessSet');      % Get the chess set for the RDT
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

%% Default is a relatively low resolution (256).
thisR.set('camera','light field');
thisR.set('n microlens',[128 128]);
thisR.set('n subpixels',[7, 7]);
thisR.set('microlens',1);   % Not sure about on or off
thisR.set('aperture',50);
thisR.set('rays per pixel',128);
thisR.set('light field film resolution',true);

% We need to move the camera far enough away so we get a decent focus.
thisR.set('object distance',35); 
thisR.set('autofocus',true);
%% Set up Docker 

[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local',[n,e]);
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR);

% Show it in ISET
vcAddObject(oi); oiWindow;

%%
