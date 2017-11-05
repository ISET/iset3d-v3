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

%% In this case, everything is inside the one file.

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found %s\n',fname); end

oname = fullfile(piRootPath,'local','lfTest.pbrt');

%% Set parameters

% Read the file and return it in a recipe format
thisR = piRead(fname);

thisR.set('camera','light field');
thisR.set('n microlens',[128 128]);
thisR.set('n subpixels',[5, 5]);
thisR.set('microlens',0);   % Not sure about on or off
thisR.set('aperture',50);
thisR.set('rays per pixel',128);
thisR.set('light field film resolution',[]);

% We need to move the camera far enough away so we get a decent focus.
objDist = thisR.get('object distance');
thisR.set('object distance',10*objDist);
thisR.set('autofocus',true);

piWrite(thisR, oname,'overwrite',true);

%% Render the light field oi

% We can also copy a directory over to the same folder as oname like this:
% thisR.outputFile = piWrite(thisR,oname,'copyDir',xxx,'overwrite',true);
[oi, outFile, result] = piRender(oname,'meanilluminance',10);
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);


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

%% Pack the samples of the rgb image into the lightfield structure used by the light field toolbox
% This is the format used by Don Dansereau's light field toolbox

% nPinholes = recipe.get('npinholes');
nPinholes = [thisR.camera.num_pinholes_h.value,thisR.camera.num_pinholes_w.value];
lightfield = ip2lightfield(ip,'pinholes',nPinholes,'colorspace','srgb');

superPixels(1) = size(lightfield,1);
superPixels(2) = size(lightfield,2);

%% Display the image from the center pixel of each microlens
img = squeeze(lightfield(3,3,:,:,:));
vcNewGraphWin; imagesc(img);

%% Display the light field

% LFDispVidCirc(lightfield)

%% Display individual images
%
% %    lightField(:,:, row, col, :)
% %
% % gives us a view from corresponding pixels in each of the pinhole (microlens
% % array) data sets. The pixels at the edges don't really get any rays or if they
% % do they get very little late (are noisier).
% 
% vcNewGraphWin;
% cnt = 1;
% rList = 1:2:superPixels(1);
% cList = 1:2:superPixels(2);
% for rr=rList
%     for cc=cList
%         img = squeeze(lightfield(rr,cc,:,:,:));
%         subplot(length(rList),length(cList),cnt), imagescRGB(img);
%         cnt = cnt + 1;
%     end
% end
% 
% %% Compare the leftmost and rightmost images in the middle
% vcNewGraphWin([],'wide');
% 
% img = squeeze(lightfield(3,2,:,:,:));
% subplot(1,2,1), imagescRGB(img);
% 
% img = squeeze(lightfield(3,8,:,:,:));
% subplot(1,2,2), imagescRGB(img);
% 
% %% Example images illustrating change in aperture size
% 
% % If we sume all the r,g and b pixels within each superPixel, we get a single
% % RGB image corresponding to the mean.
% 
% % This is a large aperture
% vcNewGraphWin;
% img = squeeze(sum(sum(lightfield,2),1));
% imagescRGB(img);
% title('Image at microlens plane')
% 
% % Now narrow the aperture, which increase the depth of field
% vcNewGraphWin;
% tmp = lightfield(4:6,4:6,:,:,:);
% img = squeeze(sum(sum(tmp,2),1));
% imagescRGB(img);
% title('Image at microlens plane')
% 
% % Single pixel aperture
% vcNewGraphWin;
% tmp = lightfield(5,5,:,:,:);
% img = squeeze(sum(sum(tmp,2),1));
% imagescRGB(img);
% title('Image at microlens plane')
% 
% %% Now what if we move the sensor forward?
% 
% % This corresponds to selecting a slightly different plane for the image sensor
% % by shifting the images first, and then summing.  The amount of the shift is in
% % the 'Slope' parameter. Use different Slopes for the benchLF and metronomeLF
% % pictures This is for metronome: Slope = -0.5:0.2:1.0;
%{
Shift = -0.5:0.5:3.0;  % BenchLF

vcNewGraphWin([],'wide');
for ii = 1:length(Shift)
    ShiftImg = LFFiltShiftSum(lightfield, Shift(ii) );
    subplot(1,length(Shift),ii);
    imagescRGB(lrgb2srgb(ShiftImg(:,:,1:3)));
    axis image;
    title(sprintf('%0.2f',Shift(ii)))
end
%}

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