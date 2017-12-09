%% Render a ChessSet scene with LightField optics
%
% NOTES: NOT WORKING YET.  Need to set lens and focus better.  Need to add
% sensor and LF<> tools
%
% Timing on a 2015 MacPro with a few cores.
%
%  Timing     film resol   rays per pixel
%   482 s        128            128
%   1063 s       192            128
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

%% Default is a relatively low resolution

% Set up LF camera
thisR.set('camera','light field');
thisR.set('n microlens',[128 128]);
thisR.set('n subpixels',[7, 7]);

%  Configure for big aperture and pbrt parameters
thisR.set('microlens',1);   % Not sure about on or off
thisR.set('aperture',50);
thisR.set('rays per pixel',128);
thisR.set('light field film resolution',true); % Sets film resolution

% Set the film distance to get a focus for the lookAt.to
thisR.set('autofocus',true);
%% Write the pbrt file we will render

[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local','chessLF',[n,e]);
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR);

% Show it in ISET
vcAddObject(oi); oiWindow;

%% Create a matched light field sensor

sensor = sensorCreate('light field',oi);
sensor = sensorCompute(sensor,oi);
vcAddObject(sensor); sensorWindow;

%% Image process ... should really use the whiteScene here

ip = ipCreate;
ip = ipCompute(ip,sensor);
vcAddObject(ip); ipWindow;

%%  Show the different views

nPinholes  = thisR.get('n microlens');
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

% Click on window and press ESC to end
LFDispVidCirc(lightfield.^(1/2.2));

%%



