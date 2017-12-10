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
%
fname = fullfile(piRootPath,'data','ChessSet','chessSet.pbrt');
workDir = fullfile(piRootPath,'local','chess');
%}

%{
 fname = fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt');
 workDir = fullfile(piRootPath,'local','teapot');
%}

if ~exist(fname,'file'), error('File not found'); end
[~,basename,ext] = fileparts(fname); 

% Working directory
% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);
from = thisR.get('from');

%% Set up Docker 

% For teapot
%{
thisR.get('rays per pixel')
thisR.set('rays per pixel',8);
FOV = thisR.get('fov');
%}

% Chess set
%
 thisR.set('camera','pinhole');
 thisR.set('film resolution',256);
 thisR.set('rays per pixel',64);
 FOV = thisR.get('fov');
%}


%%

nShots = 4;
eTime  = 0.006;
sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',FOV);
sensor = sensorSet(sensor,'exp time',eTime);  
vSwing = sensorGet(sensor,'pixel voltage swing');

% These are the positions of the camera for each shot
% We need a convenient way to express the parameters in terms of angles or
% distance or something
% Now, we set the scalar to be a percentage of the distance to the
% object.
d = thisR.get('object distance');
sd = d*0.005;
dFrom = randn(nShots,3)*sd;

for ii=1:nShots
    outputName = sprintf('%s-%d%s',basename,ii,ext);
    thisR.outputFile = fullfile(workDir,outputName);
    
    % First left/right, 2nd moved camera closer and to the right
    thisR.set('from',from + dFrom(ii,:)); 
    
    if ii == 1, piWrite(thisR);
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
    vcAddObject(oi); oiWindow;
    
    sensor = sensorSet(sensor,'exp time',eTime);
    sensor = sensorCompute(sensor,oi);
    sensor = sensorSet(sensor,'name',sprintf('from %d',ii));
    volts = sensorGet(sensor,'volts');
    vcAddObject(sensor); sensorWindow('scale',true);
    
    if ii == 1, voltSum = volts;
    else,       voltSum = voltSum + volts;
    end
    
    outputName = sprintf('%s-%d%s',basename,ii,'.png');
    vImage = fullfile(workDir,'renderings',outputName);

    % Write out png scaled to 0 to 255, re: voltage swing
    imwrite((volts/vSwing)*255,vImage,'png');
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