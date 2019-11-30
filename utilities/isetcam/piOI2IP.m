function [ip,sensor]=piOI2IP(oi,varargin)
% Convert an OI to the IP state, carrying along the metadata
%
% Syntax
%    [ip,sensor]=piOI2IP(oi,varargin)
%
% Description
%   After we simulate the OI we have both the radiance and the pixel level
%   metadata.  This function converts the OI and metadata all the way to
%   the IP level.
%
% Input
%   oi - This OI needs to have the metadata attached to it.
%
% Optional key/value pairs
%   sensor - The name of a file containing the sensor
%   pixel size - Size in microns (e.g. 2)
%   film diagonal - In millimeters, default is 10 mm
%
% Output
%   ip
%   sensor
%
% See also
%   piMetadataSetSize

%%
p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('sensor','default');   % A file name
p.addParameter('pixelsize',[]);
p.addParameter('filmdiagonal',10); % [mm]

p.parse(varargin{:});
sensorName   = p.Results.sensor;
pixelSize    = p.Results.pixelsize;
filmDiagonal = p.Results.filmdiagonal;

%% oi to sensor
if strcmp(sensorName,'default')
    sensor = sensorCreate;
else
    load(sensorName,'sensor');
end

% Not sure why these aren't settable.  I think they are here to conform
% with the ISETAuto generalization paper
readnoise  = 1e-3;
darkvoltage= 1e-3;
[electrons,~] = iePixelWellCapacity(pixelSize*1e6);%
converGain = 1/electrons;% voltage swing/electrons
% converGain = 1/2^12;

sensor = sensorSet(sensor,'pixel read noise volts',readnoise);
sensor = sensorSet(sensor,'pixel voltage swing',1);
sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage);
sensor = sensorSet(sensor,'pixel conversion gain',converGain);
if ~isempty(pixelSize)
    sensor = sensorSet(sensor,'pixel size same fill factor',pixelSize);
%     sensor = sensorSet(sensor,'pixel size constant fill factor',[pixelSize pixelSize]);
end

[~,rect] = ieROISelect(oi);
% rect = [776   896   339   176];% for 1920*1080
% rect = [253   208    25    21];
oiSize = oiGet(oi,'size');
optimalPixel = sqrt(filmDiagonal^2/(oiSize(1)^2+oiSize(2)^2))*1e-3;
sensor = sensorSet(sensor, 'size', oiGet(oi,'size')*optimalPixel/pixelSize);

% sensor   = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));

eTime  = autoExposure(oi,sensor,0.90,'video','center rect',rect,'videomax',1/60);
fprintf('eT: %s ms \n',eTime*1000);
sensor = sensorSet(sensor,'exp time',eTime);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);
if isfield(oi,'metadata')
    if ~isempty(oi.metadata)
     sensor.metadata = oi.metadata;
     sensor.metadata.depthMap = oi.depthMap;
     sensor = piMetadataSetSize(oi,sensor);
    end
end
% annotate it
% sensor = piBatchSceneAnnotation(sensor);
%% sensor to ip
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