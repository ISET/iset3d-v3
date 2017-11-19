% s_piReadRenderLF
%
% Implements a light field camera system with an array of microlenses over a
% sensor.  Converts the OI into a sensor, the sensor into a rendered image, and
% then uses D. Dansereau's toolbox to produce a small video of the images seen
% through the different sub-images.
%
%  Time        N Rays    NMicroLens     Nsubpixels
%    30 s         64        128         7,7
%   162 s        128        128         7,7
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

% Configure the light field camera
thisR.set('camera','light field');
thisR.set('n microlens',[128 128]);
thisR.set('n subpixels',[7, 7]);

thisR.set('microlens',1);   % Not sure what on or off means.  Investigate.
thisR.set('aperture',50);   % LF cameras need a big aperture
thisR.set('rays per pixel',128);   % Governs quality of rendering
thisR.set('light field film resolution',true);  % Sets film resolution

% Move the camera far enough away to get a decent focus.
thisR.set('object distance',35);  % In mm
thisR.set('autofocus',true);

% thisR.get('film resolution')

%% Write out modified PBRT file

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',[n,e]));
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR,'mean illuminance',10);

% Show it in ISET
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%% White balance

%{
[cMatrix,~,oiW] = piWhiteField(thisR);
vcAddObject(oiW); oiWindow;
vcNewGraphWin; imagesc(cMatrix)
%}

%% Create a sensor 

% Make a sensor so that each pixel is aligned with a single sample
% in the OI.  Then produce the sensor data.  The sensor has a standard
% Bayer color filter array.
sensor = sensorCreate('light field',oi);
sensor = sensorSet(sensor,'exp time',0.005);  % 10 ms.

% Compute the sensor responses and show
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow('scale',1);

%{
function sensor = sensorScale(sensor,varargin);
%
% Typical:
%    'volts' cMatrix derived by piWhiteField
%
% Do we have this type of scaling somewhere else?
v = sensorGet(sensor,'volts'); 
lst = (cMatrix > 1/10);   % Don't want to scale by more than this
v(lst) = v(lst) ./ cMatrix(lst);
% vcNewGraphWin; imagesc(v);

sensorW = sensorSet(sensor,'volts',v);
sensorW = sensorSet(sensorW,'name','white field'); 
ieAddObject(sensorW); sensorWindow('scale',1);

sensor = sensorW;
% 
%}

%% Use the image processor to demosaic (bilinear) the sensor data

ip = ipCreate;
ip = ipCompute(ip,sensor);
vcAddObject(ip); ipWindow;

%% Pack the sensor rgb image into the lightfield structure

% This is the format used by Don Dansereau's light field toolbox
nPinholes  = thisR.get('n microlens');  % Or pinholes
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

%% Show little video if you like

%{
 % Click on window and press ESC to end
 LFDispVidCirc(lightfield.^(1/2.2));
%}

%% Display the center pixel image

%{
r = ceil(size(lightfield,1)/2);
c = ceil(size(lightfield,2)/2);
img = squeeze(lightfield(r,c,:,:,:).^(1/2.2));
vcNewGraphWin; imagesc(img); truesize; axis off
%}

%% Whiten up this image
%{

% Produces the pixel voltages to a uniform white scene
[correctionMatrix, wSensor] = piWhiteField(thisR);
vcAddObject(wSensor); sensorImageWindow;
vcNewGraphWin; histogram(correctionMatrix(:));

% Read the voltages from the teapot scene and scale them by the correction
% matrix
v = sensorGet(sensor,'volts');
v = v ./ correctionMatrix;
sensorCC = sensorSet(sensor,'volts',v);
vcAddObject(sensorCC); sensorImageWindow;

ip = ipCompute(ip,sensor);
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');
LFDispVidCirc(lightfield.^(1/2.2));

%}
