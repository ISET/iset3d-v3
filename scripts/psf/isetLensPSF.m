clear;
 close all
%% Choose lens and sampling of lens  aperture

lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';

lens=lensC('file',lensName)
lens.apertureSample=2000*[1 1 ];


%% Helper variables
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);


 
%% Determine required film distance
% Define onject distance from rear lens vertx
% This calculates the image point

objectDistance_fromrear=3032.04;


im=lens.findImagePoint([0 0 -objectDistance_fromrear],1,1);

% Distance from the film
filmdistance_mm=im(1,3) 

% Manually override if wanted ff
filmdistance_mm =  36.9590;


%% Calculqte PSF


% Define point source for which PSF needs to be calculated
ps = {[0 0 -objectDistance_fromrear]}


% Define psfCameraC
wave = linspace(500,1000,7); sz = [0.02,0.02]; pos = [0 0 filmdistance_mm]; res = [500 500];
film = filmC('position', pos, 'size', sz, 'wave', wave, 'resolution', res);
psfCamera = psfCameraC('lens',lens,'film',film,'pointsource',ps);


% Calculate psf imagem
% nlines is how many lines you want to see plotted while tracing
psfCamera.estimatePSF('jitter',false,'nLines',101,'diffractionmethod','HURB');
oimage = psfCamera.oiCreate();  % vcAddObject(oi); oiWindow;

% Extract the point spread data
x_micron = 1e3*linspace(-sz(1)/2,sz(1)/2,res(1));y=x_micron;
PSF = oiGet(oimage, 'photons',wave(1));
figure(5);clf;imagesc(x_micron,y,PSF)
shading interp
xlabel('x (\mu m)')
ylabel('x (\mu m)')


%psfCamera.PSFArray(points)
figure;plot(x_micron,PSF(end/2,:))
xlabel('x (\mu m)')



return


%% Generate ray pairs
maxRadius = 0.6;
minRadius = 0.0;

objdistance_mm_fromfront = 3000; %Relative to rear surface vertxof lens
objdistance_mm_fromrear= objdistance_mm_fromfront+lensThickness %Relative to film position
objdistance_mm_fromfilm= objdistance_mm_fromrear+filmdistance_mm; %Relative to film position


[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 1, 'elevation max', 1,...
    'nAzSamp',2000,'nElSamp',2000,...
    'reverse', false,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',objdistance_mm_fromfront,...
    'outputSurface',outputPlane(filmdistance_mm));aaq



%% Visualize
close all

maxnorm=@(x)x/max(x);
figure(1);clf
[N,X]=hist(oRays(:,1),100);
lsf=N/max(N);

plot(X,lsf,'r')
hold on;
plot(1e-3*x_micron,maxnorm(sum(PSF,1)),'b')

xlabel('x (\mu m)')



