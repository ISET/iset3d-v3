function [ip, sensor] = piOI2IP(oi, varargin)
% Convert an optical image to an image processor.
%
% Syntax:
%   [ip, sensor] = piOI2IP(oi, [varargin])
%
% Description:
%    Convert an optical image to an image processor and sensor.
%
% Inputs:
%    oi        - Struct. An optical image structure.
%
% Outputs:
%    ip        - Struct. An image processing structure.
%    sensor    - Struct. A sensor structure.
%
% Optional key/value pairs:
%    sensor    - String. The sensor name as a string. Default 'default'.
%    pixelSize - Numeric. The pixel size. Default [].
%

p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('sensor', 'default');
p.addParameter('pixelSize', []);
p.addParameter('filmdiagonal', 10); % [mm]
p.parse(varargin{:});
sensorName = p.Results.sensor;
pixelSize = p.Results.pixelSize;
filmDiagonal = p.Results.filmdiagonal;

%% oi to sensor
if strcmp(sensorName, 'default')
    sensor = sensorCreate;
else
    load(sensorName, 'sensor');
end

readnoise = 1e-3;
darkvoltage = 1e-3;
[electrons, ~] = iePixelWellCapacity(pixelSize * 1e6);%
converGain = 1 / electrons;  % voltage swing/electrons
% converGain = 1 / 2 ^ 12;
sensor = sensorSet(sensor, 'pixel read noise volts', readnoise);
sensor = sensorSet(sensor, 'pixel voltage swing', 1);
sensor = sensorSet(sensor, 'pixel dark voltage', darkvoltage);
sensor = sensorSet(sensor, 'pixel conversion gain', converGain);
if ~isempty(pixelSize)
    sensor = sensorSet(sensor, 'pixel size same fill factor', pixelSize);
    % sensor = sensorSet(sensor, 'pixel size constant fill factor', ...
    %    [pixelSize pixelSize]);
end

[~,rect] = ieROISelect(oi);
% rect = [776   896   339   176];% for 1920*1080
% rect = [253   208    25    21];
oiSize = oiGet(oi, 'size');
optimalPixel = sqrt(filmDiagonal ^ 2 / ...
    (oiSize(1) ^ 2 + oiSize(2) ^ 2)) * 1e-3;
sensor = sensorSet(sensor, 'size', oiGet(oi, 'size') * ...
    optimalPixel / pixelSize);
% sensor = sensorSetSizeToFOV(sensor,oiGet(oi, 'fov'));
eTime = autoExposure(oi, sensor, 0.90, 'video', 'center rect', rect, ...
    'videomax', 1 / 30);
fprintf('eT: %s ms \n', eTime * 1000);
sensor = sensorSet(sensor, 'exp time', eTime);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);
if isfield(oi, 'metadata')
    if ~isempty(oi.metadata)
        sensor.metadata = oi.metadata;
        sensor.metadata.depthMap = oi.depthMap;
        sensor = piMetadataSetSize(oi, sensor);
    end
end
% annotate it
% sensor = piBatchSceneAnnotation(sensor);
%% sensor to ip
ip = ipCreate;
% Choose the likely set of signals the sensor will encounter
ip = ipSet(ip, 'conversion method sensor', 'MCC Optimized');
ip = ipSet(ip, 'illuminant correction method', 'gray world');
% demosaics = [{'Adaptive Laplacian'}, {'Bilinear'}];
ip = ipSet(ip, 'demosaic method', 'Adaptive Laplacian');
ip = ipCompute(ip, sensor);
% ipWindow(ip);
if isfield(sensor, 'metadata')
    ip.metadata = sensor.metadata;
    ip.metadata.eT = eTime;
end
end
