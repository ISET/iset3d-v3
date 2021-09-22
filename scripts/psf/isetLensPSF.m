clear;
 close all
%%

lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';

lens=lensC('file',lensName)
lens.apertureSample=2*[800 800];



 
%% Determine necessary radius of target

lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);

objectDistance=3000; im=lens.findImagePoint([0 0 -objectDistance],1,1);filmdistance_mm=im(1,3)+0.01 %% Focus



objectfromVertex=objectDistance-lensThickness %mm



ps = {[0 0 -objectDistance]}

wave = linspace(500,1000,7); sz = [0.02,0.02]; pos = [0 0 filmdistance_mm]; res = [500 500];
film = filmC('position', pos, 'size', sz, 'wave', wave, 'resolution', res);
psfCamera = psfCameraC('lens',lens,'film',film,'pointsource',ps);

psfCamera.estimatePSF('jitter',false,'nLines',0);
oi = psfCamera.oiCreate();  % vcAddObject(oi); oiWindow;

% Extract the point spread data



x_micron = 1e3*linspace(-sz(1)/2,sz(1)/2,res(1));y=x_micron;
PSF = oiGet(oi, 'photons',wave(1));
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


[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 1, 'elevation max', 1,...
    'nAzSamp',2000,'nElSamp',2000,...
    'reverse', false,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',objectfromVertex,...
    'outputSurface',outputPlane(filmdistance_mm));

%% Visualize
close all
figure;hist2d(oRays(:,1),oRays(:,2),50)

figure;scatter(oRays(:,1),oRays(:,2))