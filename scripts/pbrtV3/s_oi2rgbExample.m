%% s_oi2rgbExample.m
% Load an OI and process it through a sensor and IP pipeline all the way to
% an RGB image.

% Tlian 1/2018

%% Initialize

ieInit;

% Load the OI here
oiFilename = '/Users/trishalian/RenderedData/livingRoomHQSingleShot.mat';
load(oiFilename);

%% Make some adjustments to the OI

% For a single image, we can just adjust illuminance directly. For multiple
% images in a camera rig, we have to be careful about the scaling. See
% "s_process360oi.m"
oi = oiSet(oi,'mean illuminance',10); % in lux

% Check the oi
vcAddAndSelectObject(oi);
oiWindow;

% It's helpful at this point to check the dimensions of the OI given in the
% window. Are they reasonable? If not, it's possible the focal length,
% aperture diameter, and FOV were not set correctly when saving the OI.

%% Sensor

sensor = sensorCreate();

% Set the pixel size
% Sensor size will be the same as the size of the optical image.
sensorPixelSize = oiGet(oi,'sample spacing','m');
oiHeight = oiGet(oi,'height');
oiWidth = oiGet(oi,'width');
sensorSize = round([oiWidth oiHeight]./sensorPixelSize);
sensor = sensorSet(sensor,'size',sensorSize);
sensor = sensorSet(sensor,'pixel size same fill factor',sensorPixelSize);

% Set exposure time
sensor = sensorSet(sensor,'exp time',1/200); % in seconds
%sensor = sensorSet(sensor,'auto Exposure',true); % Use auto exposure. 

% Compute!
sensor = sensorCompute(sensor,oi);

% Check exposure
exposureTime = sensorGet(sensor,'exp time');
fprintf('Exposure Time is 1/%0.2f s \n',1/exposureTime);

% Check the sensor window
ieAddObject(sensor);
sensorWindow;

%% Image Processing

ip = ipCreate;
ip = ipSet(ip,'demosaic method','bilinear');
ip = ipSet(ip,'correction method illuminant','gray world');

% Compute!
ip = ipCompute(ip,sensor);

ieAddObject(ip);
ipWindow;

%% Get RGB image
srgb = ipGet(ip,'data srgb');
