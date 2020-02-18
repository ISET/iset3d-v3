function [ip,sensor] = piOI2IP(oi,varargin)
% Convert an OI to the IP state, carrying along the metadata
%
% Syntax
%    [ip,sensor] = piOI2IP(oi,varargin)
%
% Description
%   After we simulate the OI we have both the radiance and the pixel level
%   metadata.  This function converts the OI and metadata all the way to
%   the IP level.
%
% Input
%   oi - This OI should generally have metadata attached to it.
%
% Optional key/value pairs
%   sensor        - File name containing the sensor (default sensorCreate)
%   pixel size    - Size in microns (e.g. 2)
%   film diagonal - In millimeters, default is 5 mm
%
% Output
%   ip
%   sensor
%
% See also
%   piMetadataSetSize

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('oi',@isstruct);
% p.addRequired('st',@(x)(isa(x,'scitran')));

p.addParameter('sensor','',@ischar);   % A file name
p.addParameter('pixelsize',2,@isscalar);
p.addParameter('filmdiagonal',5,@isscalar); % [mm]

p.parse(oi,varargin{:});
sensorName   = p.Results.sensor;
pixelSize    = p.Results.pixelsize;
filmDiagonal = p.Results.filmdiagonal;

%% oi to sensor
if isempty(sensorName)
    sensor = sensorCreate;
else
    load(sensorName,'sensor');
end

% Not sure why these aren't settable.  I think they are here to conform
% with the ISETAuto generalization paper
readnoise   = 1e-3;
darkvoltage = 1e-3;
[electrons,~] = iePixelWellCapacity(pixelSize);  % Microns
converGain = 1/electrons;         % voltage swing/electrons

sensor = sensorSet(sensor,'pixel read noise volts',readnoise);
sensor = sensorSet(sensor,'pixel voltage swing',1);
sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage);
sensor = sensorSet(sensor,'pixel conversion gain',converGain);
if ~isempty(pixelSize)
    % Pixel size in meters needed here.
    sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize*1e-6);
end

% Saved examples for some big images.
%
% rect = [568   264   708   410];
% rect = [776   896   339   176];% for 1920*1080
% rect = [253   208    25    21];

% [~,rect] = ieROISelect(oi);
% [colmin,rowmin,width,height]
oiSize = oiGet(oi,'size');
fraction = 0.2;
rect = [oiSize(2)*(1 - fraction)/2, oiSize(1)*(1 - fraction)/2, ...
    oiSize(2)*fraction oiSize(1)*fraction];
fprintf('Rectangle\n'); disp(rect); fprintf('\n');

% It appears we are figuring out how many pixels to use in the sensor to
% match the field of view of the OI.
%
% The film diagonal is in mm.  So the 1e-3 makes it meters. The oiSize is
% the pixels. The optimal pixel must be the sensor pixel size needed to
% match the sampling of the oi samples? But this seems to be in meters.
optimalPixel = sqrt(filmDiagonal^2/(oiSize(1)^2+oiSize(2)^2))*1e-3; % Meters
sensor = sensorSet(sensor, 'size', oiGet(oi,'size') * (optimalPixel/(pixelSize*1e-6)));

% Not sure why we don't do this, except perhaps the fov is unreliable?
% sensor   = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));

%% Compute

eTime  = autoExposure(oi,sensor,0.90,'weighted','center rect',rect);
fprintf('eT: %s ms \n',eTime*1e3);
sensor = sensorSet(sensor,'exp time',eTime);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% Copy metadata
if isfield(oi,'metadata')
    if ~isempty(oi.metadata)
     sensor.metadata          = oi.metadata;
     sensor.metadata.depthMap = oi.depthMap;
     sensor                   = piMetadataSetSize(oi,sensor);
    end
end

% annotate the sensor?
% sensor = piBatchSceneAnnotation(sensor);

%% Sensor to IP
ip = ipCreate;

% Choose the likely set of signals the sensor will encounter
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');

% demosaics = [{'Adaptive Laplacian'},{'Bilinear'}];
ip = ipSet(ip,'demosaic method','Adaptive Laplacian'); 
ip = ipCompute(ip,sensor);

% ipWindow(ip);

if isfield(sensor,'metadata')
    ip.metadata = sensor.metadata;
    ip.metadata.eT = eTime;
end

end