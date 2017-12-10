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
% fname = fullfile(piRootPath,'data','ChessSet','chessSet.pbrt');
fname = fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);
from = thisR.get('from');

FOV = thisR.get('fov');

%% Set up Docker 
% Chess set
% thisR.set('camera','pinhole');
% thisR.set('from',from + [0 0 100]);  % First left/right, 2nd moved camera closer and to the right 
% thisR.set('film resolution',256);
% thisR.set('rays per pixel',128);

%%
[~,n,e] = fileparts(fname); 

nShots = 12;
eTime  = 0.002;
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',FOV);
sensor = sensorSet(sensor,'exp time',0.008);  % 8 ms exposure

% These are the positions of the camera for each shot
% We need a convenient way to express the parameters in terms of angles or
% distance or something
x = randn(nShots,1)*0.5;
dFrom = zeros(nShots,3);
dFrom(:,1) = x;

for ii=1:nShots
    n = sprintf('%s-%d',n,ii);
    thisR.outputFile = fullfile(piRootPath,'local','teapot',[n,e]);
    thisR.set('from',from + dFrom(ii,:));  % First left/right, 2nd moved camera closer and to the right
    if ii == 1, workingDir = piWrite(thisR);
    else,       piWrite(thisR,'overwrite resources',false);
    end
    
    % At this point, we could end the loop and do the calculation in
    % the cloud for all of the nShots
    % end
    
    % Then we would retrieve the dat files that were rendered and
    % proceed from here
    scene = piRender(thisR,...
        'renderType','radiance',...
        'meanluminance',100,...
        'fov',FOV);
    % vcAddObject(scene); sceneWindow;
    
    oi = oiCreate;
    oi = oiCompute(oi,scene);
    % vcAddObject(oi); oiWindow;
    
    sensor = sensorSet(sensor,'exp time',eTime);
    sensor = sensorCompute(sensor,oi);
    % vcAddObject(sensor); sensorWindow;
    if ii == 1
        volts = sensorGet(sensor,'volts');
        voltSum = volts;
    else
        voltSum = voltSum + sensorGet(sensor,'volts');
    end
    
    vImage = fullfile(workingDir,'renderings',[n,'.png']);
    imwrite(volts,vImage,'png');
end

%% Create a matched light field sensor

% This is the blurred image
sensorBurst = sensorSet(sensor,'volts',voltSum);
sensorBurst = sensorSet(sensorBurst,'name','burst');
vcAddObject(sensorBurst); sensorWindow;
sensorSet(sensorBurst,'gamma',0.5);

%%  Now a single shot from a still recording with the same total time.

thisR.set('from',from);  % First left/right, 2nd moved camera closer and to the right
piWrite(thisR,'overwrite resources',false);
scene = piRender(thisR,...
    'renderType','radiance',...
    'meanluminance',100,...
    'fov',FOV);
oi = oiCompute(oi,scene);
sensor = sensorSet(sensor,'exp time',nShots * eTime);
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','still');
vcAddObject(sensor); sensorWindow;
sensorSet(sensor,'gamma',0.5);
%%