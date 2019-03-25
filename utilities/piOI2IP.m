function [ip,sensor]=piOI2IP(oi,varargin)
p = inputParser;
p.addParameter('sensor','default');
p.addParameter('pixelSize',[]);
p.parse(varargin{:});
sensorName   = p.Results.sensor;
pixelSize= p.Results.pixelSize;

%% oi to sensor
if strcmp(sensorName,'default')
    sensor = sensorCreate;
else
    load(sensorName,'sensor');
end
readnoise  =  1e-3;
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
end

% [~,rect] = ieROISelect(oi);
rect = [718   698   200   198];
sensor = sensorSet(sensor, 'size',[800,1920]);
sensor   = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
eTime  = autoExposure(oi,sensor,0.90,'video','center rect',rect,'videomax',1/60);
fprintf('eT: %s ms \n',eTime*1000);
sensor = sensorSet(sensor,'exp time',eTime);
sensor = sensorCompute(sensor,oi);
    % sensorWindow(sensor);
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