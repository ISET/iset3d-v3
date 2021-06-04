%% Test a pbrtv3 scene with material property modified.
%
% Creates an image with glass and a mirror and text and some objects.
% The script gives a demo of rendering a retroreflective traffic sign.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
FilePath = fullfile(piRootPath,'data','V3','StopSign');
fname = fullfile(FilePath,'stop.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname,'version',3);


%% Change render quality

% [800 600] 32 - takes around 30 seconds to render on a machine with 8 cores.
% [300 150] 16 -

thisR.set('filmresolution',[640 480]);
thisR.set('pixelsamples',16);

thisR.integrator.maxdepth.value = 5;  %Multiple bounces of a ray allowed
%% Change the camera lens

% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% recipe.version can tell us, but piCameraCreate does not take a recipe as
% input. For now let's put things in manually.

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'data','lens','wide.56deg.12.5mm.dat');
thisR.camera.lensfile.value = lensFile;
% Attach the lens
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 1; % mm
thisR.camera.aperturediameter.type = 'float';

% Focus at roughly meter away.
thisR.camera.focusdistance.value = 1; % meter
thisR.camera.focusdistance.type = 'float';

% Use a 1" sensor size
thisR.film.diagonal.value = 16; 
thisR.film.diagonal.type = 'float';
%% Change viewing distance Moving forward?
thisR.lookAt.from(3)= (thisR.lookAt.from(3)-(thisR.lookAt.from(3)-thisR.lookAt.to(3))*0.5);

%% Write thisR to *_material.pbrt

% Write out the pbrt scene file, based on thisR.  By def, to the working directory.
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','StopExport',[n,e]));

% material.pbrt is supposed to overwrite itself.
piWrite(thisR);

%% Render
tic, oi_uber = piRender(thisR); toc
oi_uber = oiSet(oi_uber,'name','Uber');
ieAddObject(oi_uber); oiWindow;

%% Assign Retroreflective Materials.

% it's helpful to check what current material properties are.
piMaterialPrint(thisR);

% target = thisR.materials.lib.retroreflective;      

piMaterialAssign(thisR,'Stop',thisR.materials.lib.retroreflective);
piMaterialAssign(thisR,'Allway',thisR.materials.lib.retroreflective);
piMaterialAssign(thisR,'Background',thisR.materials.lib.matte);
% it's helpful to check what current material properties are.
piMaterialPrint(thisR);

%% Write thisR to *_material.pbrt

% Write out the pbrt scene file, based on thisR.  By def, to the working directory.
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','StopExport',[n,e]));

% material.pbrt is supposed to overwrite itself.
piWrite(thisR);

%% Render
%tic, oi = piRender(thisR); toc
tic, oi_retro = piRender(thisR); toc
oi_retro = oiSet(oi_retro,'name','Retro');
ieAddObject(oi_retro); oiWindow;
%%
% %% oi_uber
% oi = oi_uber;
% scale = 4.5495e15; % this scale creates roughly 10 lux of mean illuminance in the optical image.
% photons = scale.*oiGet(oi,'photons');
% oi = oiSet(oi,'photons',photons);

% ieAddObject(oi); oiWindow;

% %% Sensor
% % To create the sensor structure, we call
% sensor = sensorCreate();
% 
% sensorPixelSize = oiGet(oi,'sample spacing','m');
% oiHeight = oiGet(oi,'height');
% oiWidth = oiGet(oi,'width');
% sensorSize = round([oiHeight oiWidth]./sensorPixelSize);
% sensor = sensorSet(sensor,'size',sensorSize);
% sensor = sensorSet(sensor,'pixel size same fill factor',sensorPixelSize);
% 
% % We are now ready to compute the sensor image
% % sensor = sensorSet(sensor,'auto Exposure',ture); % Disable auto exposure.
% % sensor = sensorSet(sensor,'exp time',2.3454e-04);
% sensor = sensorCompute(sensor,oi);
% 
% % ieAddObject(sensor); sensorWindow;
% 
% exposureTime = sensorGet(sensor,'exp time');
% fprintf('Exposure time was: %f \n',exposureTime);
% 
% %% Image Processor
% ip = ipCreate;
% ip = ipSet(ip,'name','Unbalanced');
% %ip = ipSet(ip,'scaledisplay',0);
% ip = ipCompute(ip,sensor);
% % As in the other cases, we can bring up a window to view the
% % processed data, this time a full RGB image.
% ieAddObject(ip); ipWindow
% 
% result_uber = ip.data.result;
% 
% % imshow(result.^(1/2.2));
% % title('Material: Uber')
% 
% %% oi_retro
% oi = oi_retro;
% scale = 4.5495e15; % this scale creates roughly 10 lux of mean illuminance in the optical image.
% photons = scale.*oiGet(oi,'photons');
% oi = oiSet(oi,'photons',photons);
% 
% % ieAddObject(oi); oiWindow;
% 
% %% Sensor
% % To create the sensor structure, we call
% sensor = sensorCreate();
% 
% sensorPixelSize = oiGet(oi,'sample spacing','m');
% oiHeight = oiGet(oi,'height');
% oiWidth = oiGet(oi,'width');
% sensorSize = round([oiHeight oiWidth]./sensorPixelSize);
% sensor = sensorSet(sensor,'size',sensorSize);
% sensor = sensorSet(sensor,'pixel size same fill factor',sensorPixelSize);
% 
% % We are now ready to compute the sensor image
% sensor = sensorSet(sensor,'auto Exposure',true); % Disable auto exposure.
% %sensor = sensorSet(sensor,'exp time',2.3454e-04);
% sensor = sensorCompute(sensor,oi);
% 
% % ieAddObject(sensor); sensorWindow;
% 
% exposureTime = sensorGet(sensor,'exp time');
% fprintf('Exposure time was: %f \n',exposureTime);
% 
% %% Image Processor
% ip = ipCreate;
% ip = ipSet(ip,'name','Unbalanced');
% %ip = ipSet(ip,'scaledisplay',0);
% ip = ipCompute(ip,sensor);
% % As in the other cases, we can bring up a window to view the
% % processed data, this time a full RGB image.
% % ieAddObject(ip); ipWindow
% 
% result_retro = ip.data.result;
% 
% %%
% vcNewGraphWin;
% imshowpair(result_uber.^(1/2.2),result_retro.^(1/2.2),'montage');
% 
% title('Uber vs Retroreflective','FontSize', 18)



