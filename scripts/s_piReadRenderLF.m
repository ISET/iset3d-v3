% s_piReadRenderLF
%
% Implements a light field camera system with an array of microlenses over a
% sensor.  Converts the OI into a sensor, the sensor into a rendered image, and
% then uses D. Dansereau's toolbox to produce a small video of the images seen
% through the different sub-images.
%
%  Time        N Rays    NMicroLens     Nsubpixels
%                 64         64         7,7
%    30 s         64        128         7,7
%   150 s        128        128         7,7
%   103 s         16        128         7,7
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
thisR.set('rays per pixel',16);   % Governs quality of rendering
thisR.set('light field film resolution',true);  % Sets film resolution

% Move the camera far enough away to get a decent focus.
thisR.set('object distance',35);  % In mm
thisR.set('autofocus',true);

% thisR.get('film resolution')

%% Write out modified PBRT file

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','teapot',[n,e]));
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR,'mean illuminance',10);

% Show it in ISET
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%% Create a sensor 

% Make a sensor so that each pixel is aligned with a single sample
% in the OI.  Then produce the sensor data.  The sensor has a standard
% Bayer color filter array.
sensor = sensorCreate('light field',oi);
sensor = sensorSet(sensor,'exp time',0.01);  % 10 ms.

% Compute the sensor responses and show
sensor = sensorCompute(sensor,oi);
% ieAddObject(sensor); sensorWindow('scale',1);

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

%% White balance

%{

% We should pull this out into a separate script, experiment, 
% and run it on saved values to speed up debugging.

% This should get us how to scale each pixel so white is white
[cMatrix,sensorW,oiW] = piWhiteField(thisR);
% vcAddObject(oiW); oiWindow;
% vcAddObject(sensorW); sensorImageWindow;
% vcNewGraphWin; imagesc(cMatrix); truesize

% This function should be added to ISET, I think, to correct
function sensorW = sensorScale(sensor,varargin);
%
% Syntax (typical?) might be:
%    sensor = sensorScale(sensor,'volts',cMatrix);

% This is what it would do
v = sensorGet(sensor,'volts'); 
lst = (cMatrix > 1/10);   % Don't want to scale by more than this
v(lst) = v(lst) ./ cMatrix(lst);
% vcNewGraphWin; imagesc(v); truesize;

% Then replace the volts
sensorW = sensorSet(sensor,'volts',v);
sensorW = sensorSet(sensorW,'name','white field'); 

end

ieAddObject(sensorW); sensorWindow('scale',1);

% If you want to continue along ...
sensor = sensorW;
% 
%}

