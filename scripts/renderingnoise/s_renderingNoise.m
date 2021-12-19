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

%% Use flat surface for simplicity 

rays = [2 4 32 128];
[rn, pn, idealSensor, thisR] = piRenderNoise('rays',rays);

ieNewGraphWin;
plot(rays,rn,'-ok','Linewidth',2);
line([rays(1), rays(end)],[pn, pn],'Color','k','Linestyle','--');
grid on; xlabel('Rays per pixel'); ylabel('Noise');

%% Adjust the sensor pixel size
pSize = sensorGet(idealSensor,'pixel size');
idealSensor = sensorSet(idealSensor,'pixel size same fill factor',pSize/2);
[rn, pn, idealSensor, thisR] = piRenderNoise('rays',rays,'sensor',idealSensor);
% sensorWindow(idealSensor);

%% Use a different lens
wideLens = 'wide.56deg.100.0mm.json';

[rn, pn] = piRenderNoise('rays',rays, 'lensname', wideLens);
ieNewGraphWin;
plot(rays,rn,'-ok','Linewidth',2);
line([rays(1), rays(end)],[pn, pn],'Color','k','Linestyle','--');
grid on; xlabel('Rays per pixel'); ylabel('Noise');

%% Exposure time
expTime = sensorGet(idealSensor, 'exp time');
idealSensor = sensorSet(idealSensor, 'exp time', expTime / 3);
[rn, pn] = piRenderNoise('rays',rays, 'sensor', idealSensor);
ieNewGraphWin;
plot(rays,rn,'-ok','Linewidth',2);
line([rays(1), rays(end)],[pn, pn],'Color','k','Linestyle','--');
grid on; xlabel('Rays per pixel'); ylabel('Noise');

%% Now try different rendering properties.
%  This might the path integrator or number of bounces
%  Here is changing the bounces
thisR.set('n bounces',3);
[rn, pn, idealSensor] = piRenderNoise('rays',rays,'recipe',thisR);

% Other options could be samplers: {'halton', 'solbol', 'stratified'}
thisR.set('sampler subtype', 'solbol');
[rn, pn, idealSensor] = piRenderNoise('rays',rays,'recipe',thisR);

%% Try with the Cornell box.  Here the bounces are relevant
rays = [16 256];
[rn, pn, idealSensor] = piRenderNoise('rays',rays,...
    'scene name','cornell box reference', ...
    'film diagonal',0.5, ...
    'nbounces',4);

ieNewGraphWin;
plot(rays,rn,'-ok','Linewidth',2);
line([rays(1), rays(end)],[pn, pn],'Color','k','Linestyle','--');
grid on; xlabel('Rays per pixel'); ylabel('Noise');
%%
%{
%%  Messing around with another scene and sensor

% Read the PBRT files into a recipe (this recipe, thisR).
% thisR = piRecipeDefault('scene name','Cornell Box Bunny Chart');
thisR = piRecipeDefault('scene name','cornellbox');

% Notice that the lights are not in the light slot, but they are in the
% tree of assets
thisR.show('objects');

% Render with a pinhole to make sure it looks OK.  When we render with a
% pinhole that is rendering a scene.
scene = piWRS(thisR);
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


%%  Show the curve approaching the photon limit

ieNewGraphWin;
semilogx(rpp,s,'o-');
grid on; xlabel('Number of rays'); ylabel('Standard deviation');
thisL = line([rpp(1) rpp(end)],[sqrt(mean(uData.pixData)), sqrt(mean(uData.pixData))])
thisL.Color = 'k';
thisL.LineStyle = '--';

%%

%}



