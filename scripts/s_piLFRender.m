% s_piReadRender
%
% The simplest script to read a PBRT scene file and then write it back
% out.  This 
%
% Path requirements
%    ISET
%    CISET      - If we need the autofocus, we could use this
%    pbrt2ISET  - 
%   
%    Consider RemoteDataToolbox, UnitTestToolbox for the lenses and
%    curated scenes.
%
% TL/BW SCIEN

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

% In some cases, you may need to run piDockerConfig

%% In this case, everything is inside the one file.

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
exist(fname,'file')

% Read the file and return it in a recipe format
thisR = piRead(fname);
disp(thisR)

oname = fullfile(piRootPath,'local','lfTest.pbrt');
piWrite(thisR,oname,'overwrite',true);

% The relationship between the pinholes/microlens and the sub-pixels.
% We want the number of xresolution/yresolution values to be a sqrt()
% 128*9  
nMicroLens = 128;
thisR = piRead(fname);
newCamera = piCameraCreate('light field');
nPinholes = 64;
newCamera.aperture_diameter.value = 60;
newCamera.num_pinholes_h.value = nMicroLens;
newCamera.num_pinholes_w.value = nMicroLens;
newCamera.microlens_enabled.value = 0;  % Not sure about on or off

opticsType = 'lens';

% Update the camera
thisR.camera = newCamera;

% This could probably be a function since we change it so often. 
% The number of sub-pixels times the number of pixels has to work out evenly
thisR.film.xresolution.value = nMicroLens*3;
thisR.film.yresolution.value = nMicroLens*3;
thisR.sampler.pixelsamples.value = 256;

fprintf('Number of pixels for each pinhole %f\n',filmSamples/nPinholes);
% Let's make this whole thing a function.  Maybe we can base it on focusLens()
% instead of the LUT.

% We need to move the camera far enough away so we can get a decent
% focus. When the object is too close, we can't focus.

% recipe.get('object distance');
% recipe.set('lookAt from',xxx);
diff = thisR.lookAt.from - thisR.lookAt.to;
diff = 10*diff;
thisR.lookAt.from = thisR.lookAt.to + diff;

% Good function needed to find the object distance
% focalDistance = recipe.get('focal distance');
objDist = sqrt(sum(diff.^2));
[p,flname,~] = fileparts(thisR.camera.specfile.value);
focalLength = load(fullfile(p,[flname,'.FL.mat']));
focalDistance = interp1(focalLength.dist,focalLength.focalDistance,objDist);
% For an object at 125 mm, the 2ElLens has a focus at 89 mm.  We should be able
% to look this up from stored data about each lens type.
% recipe.set('film distance',focalDistance);
thisR.camera.filmdistance.value = focalDistance;

thisR.outputFile = piWrite(thisR,oname,'overwrite',true);

% You can open and view the file this way
% edit(oname);

%% Render the light field oi

% We can also copy a directory over to the same folder as oname like this:
% thisR.outputFile = piWrite(thisR,oname,'copyDir',xxx,'overwrite',true);
[ieObject, outFile, result] = piRender(oname,'opticsType',opticsType);

% Show the ieObject after brightening it to a reasonable level.
switch(opticsType)
    case 'pinhole'
        oi = sceneAdjustLuminance(ieObject,100);
        sceneSet(ieObject,'gamma',0.5);
        vcAddObject(ieObject); sceneWindow;
    case 'lens'
        ieObject = oiAdjustIlluminance(ieObject,10);
        oiSet(ieObject,'gamma',0.5);
        vcAddObject(ieObject); oiWindow;
end

%% Create a sensor 

% Make the sensor so that each pixel is aligned with a single sample
% in the OI.  Then produce the sensor data.  The sensor has a standard
% color filter array.
% sensorCreate('light field',oi);
ss = oiGet(oi,'sample spacing','m');
sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size same fill factor',ss(1));
sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
sensor = sensorSet(sensor,'exp time',0.010);

% Describe
sensorGet(sensor,'pixel size','um')
sensorGet(sensor,'size')
sensorGet(sensor,'fov',[],oi)

% Compute the sensor responses and show
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow('scale',1);

%% Use the image processor to demosaic (bilinear) the color filter data

ip = ipCreate;
ip = ipCompute(ip,sensor);
vcAddObject(ip); ipWindow;

%% Convert the rgb data into a lightfield structure 

% This is the format used by Don Dansereau's light field toolbox

% nPinholes = recipe.get('npinholes');
nPinholes = [thisR.camera.num_pinholes_h.value,thisR.camera.num_pinholes_w.value];
% nPinholes = [data.numPinholesH, data.numPinholesW];

%% Pack the samples of the rgb image into the lightfield structure used by the light field toolbox
nPinholes = [thisR.camera.num_pinholes_h.value,thisR.camera.num_pinholes_w.value];
% nPinholes = [data.numPinholesH, data.numPinholesW];
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

superPixels(1) = size(lightfield,1);
superPixels(2) = size(lightfield,2);

%% Display the light field

LFDispVidCirc(lightfield)

%% Display individual images
%
%    lightField(:,:, row, col, :) 
%
% gives us a view from corresponding pixels in each of the pinhole
% (microlens array) data sets. The pixels at the edges don't really get any
% rays or if they do they get very little late (are noisier).

vcNewGraphWin;
cnt = 1;
rList = 1:2:superPixels(1);
cList = 1:2:superPixels(2);
for rr=rList
    for cc=cList
        img = squeeze(lightfield(rr,cc,:,:,:));
        subplot(length(rList),length(cList),cnt), imagescRGB(img);
        cnt = cnt + 1;
    end
end

%% Compare the leftmost and rightmost images in the middle
vcNewGraphWin([],'wide');

img = squeeze(lightfield(3,2,:,:,:));
subplot(1,2,1), imagescRGB(img);

img = squeeze(lightfield(3,8,:,:,:));
subplot(1,2,2), imagescRGB(img);

%% Example images illustrating change in aperture size

% If we sume all the r,g and b pixels within each superPixel, we get a
% single RGB image corresponding to the mean.  

% This is a large aperture
vcNewGraphWin;
img = squeeze(sum(sum(lightfield,2),1));
imagescRGB(img);
title('Image at microlens plane')

% Now narrow the aperture, which increase the depth of field
vcNewGraphWin;
tmp = lightfield(4:6,4:6,:,:,:);
img = squeeze(sum(sum(tmp,2),1));
imagescRGB(img);
title('Image at microlens plane')

% Single pixel aperture
vcNewGraphWin;
tmp = lightfield(5,5,:,:,:);
img = squeeze(sum(sum(tmp,2),1));
imagescRGB(img);
title('Image at microlens plane')

%% Now what if we move the sensor forward?

% This corresponds to selecting a slightly different plane for the image
% sensor by shifting the images first, and then summing.  The amount of the
% shift is in the 'Slope' parameter.
% Use different Slopes for the benchLF and metronomeLF pictures
% This is for metronome: Slope = -0.5:0.2:1.0;
Shift = -0.5:0.5:3.0;  % BenchLF

vcNewGraphWin([],'wide');
for ii = 1:length(Shift)
    ShiftImg = LFFiltShiftSum(lightfield, Shift(ii) );
    subplot(1,length(Shift),ii);
    imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
    axis image;
    title(sprintf('%0.2f',Shift(ii)))
end

%% The white image

% What is this fourth plane?  I think it is an overall intensity estimate.
% We need to calculate this for our simulation.  At present, it is just
% arbitrary.
% wImage = ShiftImg(:,:,4);
% vcNewGraphWin;
% imagesc(wImage);

%%  Interact with the lightfield using the toolbox

% In this case, we use the srgb representation because we are just
% visualizing
% LFDispMousePan(lightfield)


%%