function ip=piOI2IP(oi,varargin)
p = inputParser;
p.addParameter('sensor','default');
p.parse(varargin{:});
sensor   = p.Results.sensor;


%% oi to sensor
if strcmp(sensor,'default')
    sensor = sensorCreate;
else
    load(sensor,'sensor');
end

exposureTime  = normrnd(1/300,0.001);
% exposureTime = 1/600;
sensor = sensorSet(sensor,'exposure time',exposureTime);
fprintf('********ExposureTime : %f ******** \n',exposureTime);
% sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorCompute(sensor,oi);
sensor.metadata = oi.metadata;
sensor.metadata.depthMap = oi.depthMap;
sensor = piMetadataSetSize(oi,sensor);
% annotate it
sensor = piBatchSceneAnnotation(sensor);
%% sensor to ip
ip = ipCreate;
% Choose the likely set of signals the sensor will encounter
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');
ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
ip = ipCompute(ip,sensor);
% ieAddObject(ip);ipWindow;
ip.metadata = sensor.metadata;
end