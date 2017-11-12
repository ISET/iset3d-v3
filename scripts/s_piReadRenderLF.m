% s_piReadRenderLF
%
% Implements a light field camera system with an array of microlenses over a
% sensor.  Converts the OI into a sensor, the sensor into a rendered image, and
% then uses D. Dansereau's toolbox to produce a small video of the images seen
% through the different sub-images.
%
%  Time        N Rays    NMicroLens     Nsubpixels
%   162 s        128      128, 128         7,7
%
% TL/BW SCIEN, 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
fname = fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Modify the recipe, thisR, to adjust the rendering

thisR.set('camera','light field');
thisR.set('n microlens',[128 128]);
thisR.set('n subpixels',[7, 7]);
thisR.set('microlens',1);   % Not sure about on or off
thisR.set('aperture',50);
thisR.set('rays per pixel',128);
thisR.set('light field film resolution',true);

% We need to move the camera far enough away so we get a decent focus.
thisR.set('object distance',35);   % I guess about 10 mm away because the scene is tiny
thisR.set('autofocus',true);

%% Set up Docker files

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',[n,e]));
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR,'meanilluminance',10);

% Show it in ISET
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%% Create a sensor 

% Make the sensor so that each pixel is aligned with a single sample
% in the OI.  Then produce the sensor data.  The sensor has a standard
% color filter array.
% sensorCreate('light field',oi);
ss = oiGet(oi,'sample spacing','m');
sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size same fill factor',ss(1));
sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
sensor = sensorSet(sensor,'exp time',0.010);

% Describe
sensorGet(sensor,'pixel size','um')
sensorGet(sensor,'size')
sensorGet(sensor,'fov',[],oi)

% Compute the sensor responses and show
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow('scale',1);

%% Use the image processor to demosaic (bilinear) the color filter data

ip = ipCreate;
ip = ipCompute(ip,sensor);
vcAddObject(ip); ipWindow;

%% Pack the samples of the rgb image into the lightfield structure used by the light field toolbox
% This is the format used by Don Dansereau's light field toolbox

% nPinholes = recipe.get('npinholes');
nPinholes  = thisR.get('n microlens');
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

superPixels(1) = size(lightfield,1);
superPixels(2) = size(lightfield,2);

%% Display the image from the center pixel of each microlens
img = squeeze(lightfield(3,3,:,:,:));
vcNewGraphWin; imagesc(img); truesize; axis off

%%
LFDispVidCirc(lightfield);

%%
