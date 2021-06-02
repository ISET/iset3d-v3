% s_flatSurface

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name','sphere','write', true);

%% Set parameters for recipe
thisR.camera.fov.value = 50;
thisR.film.yresolution.value = 320;
thisR.sampler.pixelsamples.value = 64;

%% Add a equal energy light
%{
    piLightGet(thisR);
%}
piLightDelete(thisR, 'all');


distantLight = piLightCreate('distantLight', ...
    'type','distant',...
    'spd','equalEnergy',...
    'cameracoordinate', true);
thisR.set('light','add',distantLight);

% thisR = piLightAdd(thisR,...
%     'type','distant',...
%     'light spectrum','equalEnergy',...
%     'spectrumscale', 1,...
%     'cameracoordinate', true);
%{
thisR = piLightAdd(thisR,...
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cone angle', 20,...
    'cone delta angle', 25,...
    'cameracoordinate', true);
%}

%% Write the recipe
piWrite(thisR);

%% Render
scene = piRender(thisR,'render type','illuminant');
% sceneWindow(scene);

%%
% Adjust the mean luminance to 100 cd/m2
scene = sceneAdjustLuminance(scene, 100);
% sceneWindow(scene);

%% oi
oi = oiCreate;
oi = oiSet(oi,'optics fnumber',4);
oi = oiSet(oi,'optics offaxis','skip');
oi = oiSet(oi,'optics focal length',3e-3);

% Calculate optical irradiance image
oi = oiCompute(scene,oi);
% oiWindow(oi);

%% Sensor
% Sony_IMX123LQT spec

sensor = sensorCreate('bayer (gbrg)');  % create the sensor structure

sensor = sensorSet(sensor, 'wave', wave);

% Set some of the key pixel properties
voltageSwing   = 3.3;  % Volts
wellCapacity   = 9000;  % Electrons
conversiongain = voltageSwing/wellCapacity;   
fillfactor     = 1;       % A fraction of the pixel area
pixelSize      = 2.5*1e-6;   % Meters % Page 2
darkvoltage    = 4.5e-3;     % Volts/sec
% readnoise      = 0.00096;    % Volts
% darkvoltage    = 0;
readnoise      = 0;
% To change the fill factor, set the photodetector size and the
% pixel size to be some ratio.  To increase the fill factor 
%{
  % Compute the fill factor
  pd = sensorGet(sensor,'pixel pd size')
  pixelSize = sensorGet(sensor,'pixel size')
  fillfactor = (pd/pixelSize)^2
%}

sensor = sensorSet(sensor,'pixel size constant fill factor',[pixelSize pixelSize]);
sensor = sensorSet(sensor,'pixel conversion gain',conversiongain);
sensor = sensorSet(sensor,'pixel voltage swing',voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage);
sensor = sensorSet(sensor,'pixel read noise volts',readnoise);

%%  Now we set some general sensor properties
% exposureDuration = 0.030; % commented because we set autoexposure
% dsnu =  0.0010;           % Volts (dark signal non-uniformity)
% prnu = 0.2218;            % Percent (ranging between 0 and 100) photodetector response non-uniformity
% dsnu = 0;
% prnu = 0;
analogGain   = 1;         % Used to adjust ISO speed
analogOffset = 0;         % Used to account for sensor black level
rows = 1200;               % number of pixels in a row
cols = 1200;               % number of pixels in a column

quanMethod = '12 bit';

% Set these sensor properties
% sensor = sensorSet(sensor,'exposuretime',exposureDuration); % commented because we set autoexposure
sensorSet(sensor,'autoExposure',1);  
sensor = sensorSet(sensor,'rows',rows);
sensor = sensorSet(sensor,'cols',cols);
sensor = sensorSet(sensor,'dsnu level',dsnu);  
sensor = sensorSet(sensor,'prnu level',prnu); 
sensor = sensorSet(sensor,'analog Gain',analogGain);     
sensor = sensorSet(sensor,'analog Offset',analogOffset); 
sensor = sensorSet(sensor,'quantization method',quanMethod);

%% Load the calibration data and attach them to the sensor structure

% Set the Sony sensor
wave = sensorGet(sensor,'wave');
oeSensorFname = fullfile(oreyeRootPath,'data','sensor','fengyun','OralEyeSpectralQE.mat');
oeQE = ieReadSpectra(oeSensorFname, wave);

oeNIRFname = fullfile(oreyeRootPath,'data','filters','NIR_E084701.mat');
oeNIR = ieReadSpectra(oeNIRFname, wave);
oeUVFname = fullfile(oreyeRootPath,'data','filters','OralEyeUVBlocking.mat');
oeUV = ieReadSpectra(oeUVFname, wave);

oeQE(isnan(oeQE)) = 0;
oeNIR(isnan(oeNIR)) = 0;
oeUV(isnan(oeUV)) = 0;

sensor = sensorSet(sensor, 'pixel qe', ones(numel(wave), 1));
sensor = sensorSet(sensor, 'irfilter', oeNIR);
sensor = sensorSet(sensor, 'filter spectra', diag(oeUV)*oeQE);

% ieNewGraphWin; plot(wave,diag(oeUV.*oeNIR)*oeQE);
oeQETot = diag(oeUV.*oeNIR)*oeQE;

sensor = sensorSet(sensor,'Name','OralEye');

%{
    % Other option would be using improved QE
    filePath = fullfile(piRootPath, 'local', 'tmp', 'OralEyeQEImpvd.mat');
    oeQEImpvd = ieReadSpectra(filePath, wave);
    oeQEImpvd(isnan(oeQEImpvd)) = 0;
    
    sensor = sensorSet(sensor, 'pixel qe', ones(numel(wave), 1));
    sensor = sensorSet(sensor, 'irfilter', ones(numel(wave), 1));
    sensor = sensorSet(sensor, 'filter spectra', oeQEImpvd);
    
    plotRadiance(wave, oeQEImpvd, 'title','Optimized sensor QE');
%}
%% We are now ready to compute the sensor image

sensor = sensorSet(sensor, 'noise flag', 1);
sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);

%% ip
ip = ipCreate;
ip = ipSet(ip, 'gamma', 1);
ip = ipSet(ip, 'sensorconversionmethod', 'none');
ip = ipCompute(ip, sensor);
% ipWindow(ip);

%% Choose the rect
[locs,thisRect] = vcROISelect(ip);
ip = ipSet(ip,'roi',thisRect);
ipPlot(ip,'roi');

%%
roiRGB = ipGet(ip,'roi data',thisRect);
roirg = chromaticity(roiRGB);
ieNewGraphWin;
plot(roirg(:,1),roirg(:,2),'b.');
set(gca,'xlim',[0 1],'ylim',[0 1]); grid on
xlabel('r'); ylabel('g');

%{
    % Plot mean
    ieNewGraphWin;
    plot(mean(roirg(:,1)), mean(roirg(:,2)), 'b.');
    set(gca,'xlim',[0 1],'ylim',[0 1]); grid on
    xlabel('r'); ylabel('g');
%}

%% Choose another rect
[locs,thisRect] = vcROISelect(ip);
ip = ipSet(ip,'roi',thisRect);
ipPlot(ip,'roi');

%%
roiRGB = ipGet(ip,'roi data',thisRect);
roirg = chromaticity(roiRGB);
ieNewGraphWin;
plot(roirg(:,1),roirg(:,2),'r.');
set(gca,'xlim',[0 1],'ylim',[0 1]); grid on
xlabel('r'); ylabel('g');
