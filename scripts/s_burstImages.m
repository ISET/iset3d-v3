%% Burst image examples
%
%  Chess set example with pinhole for speed.
%  Others can be built on this
%
%  For Rob Jones
%
% BW

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

[~,n,e] = fileparts(fname); 

nShots = 4;
FOV    = 10;
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',FOV);
dFrom = [0 0 25; 0 0 30; 0 0 60; 0 0 100];
for ii=1:nShots
    n = sprintf('%s-%d',n,ii);
    thisR.outputFile = fullfile(piRootPath,'local','chessLF',[n,e]);
    thisR.set('from',from + dFrom(ii,:));  % First left/right, 2nd moved camera closer and to the right 
    workingDir = piWrite(thisR);    
    oi = piRender(thisR);
    oi = oiSet(oi,'fov',FOV);
    sensor = sensorCompute(sensor,oi);
    volts = sensorGet(sensor,'volts');
    vImage = fullfile(workingDir,'renderings',[n,'.png']);
    imwrite(volts,vImage,'png');
end
% Show it in ISET
vcAddObject(oi); oiWindow;

%% Create a matched light field sensor


vcAddObject(sensor); sensorWindow;
