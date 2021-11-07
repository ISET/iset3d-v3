% Analyze how the rendering noise declines as we increase the number of
% rays per pixel
%
% Idea:
%
%   Pick a test scene, optics, and a sensor
%   Use ISET3d to render the test scene with different numbers of rays per
%     pixel
%   Assess the noise in different regions within the sensor image as we
%   sweep out the number of rays per pixel.
%
% 

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Test scene
% 
%   Let's include the slanted bar for sure
%   Maybe the Cornell Box with the slanted bar in it?
% 
%   Pin hole or lens or compare?
%
%   One sensor (Sony) or compare?
%
%   Different mean luminance levels
%

% Read the PBRT files into a recipe (this recipe, thisR).
% thisR = piRecipeDefault('scene name','Cornell Box Bunny Chart');
thisR = piRecipeDefault('scene name','cornellbox');

% Notice that the lights are not in the light slot, but they are in the
% tree of assets
thisR.show('objects');

% Render with a pinhole to make sure it looks OK.  When we render with a
% pinhole that is rendering a scene.
scene = piWRS(thisR);

%%  Let's increase the number of rays per pixel

raysperpixel = thisR.get('rays per pixel');
for factor = [2, 4, 8]
    thisR.set('rays per pixel',raysperpixel*factor);
    piWRS(thisR);
    scene = ieGetObject('scene');
    scene = sceneSet(scene,'name',sprintf('nrays-%d',raysperpixel*factor));
    ieReplaceObject(scene);
end

%% Add a lens and pick a sensor

lensname = 'dgauss.22deg.12.5mm.json';
c = piCameraCreate('omni','lens file',lensname);
thisR.set('camera',c);

% Because it has a camera, this is an optical image.  We reset the number
% of rays in the recipe to the original value.
thisR.set('rays per pixel',raysperpixel);

% Call PBRT to render the scene.
oi = piWRS(thisR);

%%  Pick a sensor

oi = oiSet(oi,'fov',5);
sensor = sensorCreate('imx363');
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov'),oi);

%% Loop to make a few sensor images with different rays per pixel

% The sensors are all in the vcSESSSION database.
ii = 1;
sensorList = cell(1,5);
for factor = 64 %[1 4 8 16]
    thisR.set('rays per pixel',raysperpixel*factor);
    oi = piWRS(thisR);
    oi = oiSet(oi,'fov',5);
    sensorList{ii} = sensorCompute(sensor,oi);
    sensorList{ii} = sensorSet(sensorList{ii},'name',sprintf('nrays-%d',raysperpixel*factor));
    sensorWindow(sensorList{ii}); drawnow;
    ii = ii + 1;
end

%%  Loop through the sensors and pull out regions of interest

% The plot also returns the 
uData = cell(1,5);
for ii=1:numel(sensorList)
    xy = [1,160];
    uData{ii} = sensorPlot(sensorList{ii},'electrons hline',xy,'twolines',true);
end

%% Compute some statistics, comparing the mis-match with the Poisson prediction

% Let's fit a polynomial through the smooth part of the data and then
% calculate the standard deviation around the polynomial.  Let's do it for
% the first data set, which is a green sensor.

thisData = uData{5};
% Pick the x-range
xposindex = (thisData.pixPos{1}) > -50 & (thisData.pixPos{1} < 200);
electrons = thisData.pixData{1}(xposindex);
xpos = thisData.pixPos{1}(xposindex);
ieNewGraphWin; plot(xpos,electrons);

% Fit a polynomial
thisPoly = polyfit(xpos,electrons,2);
polyPredicted = polyval(thisPoly,xpos);
ieNewGraphWin; plot(xpos,electrons,'o',xpos,polyPredicted,'-');

% This is the standard deviation after removing the polynomial fit.  The
% residuals are the noise.  They should be Poisson distributed and have a
% standard deviation predicted by the Poisson mean.
std(electrons - polyPredicted)

% This is the standard deviation of the Poisson distribution with the
% same mean.
sqrt(mean(electrons))


ieNewGraphWin; 
h = histogram(electrons(:) - polyPredicted(:),15);

% For a normal distribution, the kurtosis is 3.  So near 3 means like a
% normal.  Higher or lower means the tails are bigger or smaller.  The
% Poisson is close to normal when the mean is bigger than about 15.
kurtosis(electrons(:) - polyPredicted(:))

%%  Now try for a monochrome sensor with no noise

% This way we check whether the sensor imperfections were a significant
% part, or just the rendering noise

thisOI = ieGetObject('oi');

mSensor = sensorCreateIdeal;
mSensor = sensorSet(mSensor,'fov',5,thisOI);
mSensor = sensorSet(mSensor,'exp time',1e-3);
mSensor = sensorCompute(mSensor,oi);
xy = [1, 120];
mData = sensorPlot(mSensor,'electrons hline',xy);

xposindex = (mData.pixPos) > -50 & (mData.pixPos < 200);
electrons = mData.pixData(xposindex);
xpos = mData.pixPos(xposindex);
ieNewGraphWin; plot(xpos,electrons);

% Fit a polynomial
thisPoly = polyfit(xpos,electrons,2);
polyPredicted = polyval(thisPoly,xpos);
ieNewGraphWin; plot(xpos,electrons,'o',xpos,polyPredicted,'-');

% This is the standard deviation after removing the polynomial fit.  The
% residuals are the noise.  They should be Poisson distributed and have a
% standard deviation predicted by the Poisson mean.
std(electrons - polyPredicted)

% This is the standard deviation of the Poisson distribution with the
% same mean.
sqrt(mean(electrons))


ieNewGraphWin; 
h = histogram(electrons(:) - polyPredicted(:),15);
kurtosis(electrons(:) - polyPredicted(:))

%% How about checking for ISETCam, without the rendering?

scene = sceneCreate('uniform ee');
oiDiffraction = oiCreate;
oi = oiCompute(oiDiffraction,scene);
mSensor = sensorCompute(mSensor,oi);
sensorWindow(mSensor);

xy = [1, 120];
mData = sensorPlot(mSensor,'electrons hline',xy);

xposindex = (mData.pixPos) > -50 & (mData.pixPos < 200);
electrons = mData.pixData(xposindex);
xpos = mData.pixPos(xposindex);
ieNewGraphWin; plot(xpos,electrons);

% Fit a polynomial
thisPoly = polyfit(xpos,electrons,2);
polyPredicted = polyval(thisPoly,xpos);
ieNewGraphWin; plot(xpos,electrons,'o',xpos,polyPredicted,'-');

% This is the standard deviation after removing the polynomial fit.  The
% residuals are the noise.  They should be Poisson distributed and have a
% standard deviation predicted by the Poisson mean.
std(electrons - polyPredicted)

% This is the standard deviation of the Poisson distribution with the
% same mean.
sqrt(mean(electrons))

%% Now with a flat surface for simplicity 

% The idea here is to just use the flat surface to test

flatR = piRecipeDefault('scene name','flat surface');

lensname = 'dgauss.22deg.12.5mm.json';
c = piCameraCreate('omni','lens file',lensname);
flatR.set('camera',c);
flatR.set('film diagonal',1);
flatR.set('film resolution',[128,128]);

tic
rpp = [32 128 512 1024 2048, 4096];
s = zeros(size(rpp));
for ii=1:numel(rpp)
    flatR.set('rays per pixel',rpp(ii));
    oi = piWRS(flatR,'show',false);
    mSensor = sensorSet(mSensor,'fov',flatR.get('fov'));
    mSensor = sensorCompute(mSensor,oi);
    uData = sensorPlot(mSensor,'electrons hline',[1 64]);
    thisPoly = polyfit(uData.pixPos,uData.pixData,2);
    polyPredicted = polyval(thisPoly,uData.pixPos);
    % ieNewGraphWin; plot(uData.pixPos,uData.pixData,'o',uData.pixPos,polyPredicted,'-');
    disp([std(uData.pixData - polyPredicted), sqrt(mean(uData.pixData))])
    s(ii) = std(uData.pixData - polyPredicted);
end
toc

%%  Show the curve approaching the photon limit

ieNewGraphWin;
semilogx(rpp,s,'o-');
grid on; xlabel('Number of rays'); ylabel('Standard deviation');
thisL = line([rpp(1) rpp(end)],[sqrt(mean(uData.pixData)), sqrt(mean(uData.pixData))]);
thisL.Color = 'k';
thisL.LineStyle = '--';

%%




