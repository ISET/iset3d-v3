%%
clear;
close all
 
%% Choose lens and sampling of lens  aperture

lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';

lens = lensC('file',lensName);
lens.apertureSample=400*[1 1 ];   % 1000 is OK, 4000 is a lot.

%% Helper variables
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);

%%
fieldHeightY_mm = 0;
objectFromFront = 3000;   % For zemax, measures from first lens vertex
objectFromRear = objectFromFront + lensThickness; % For isetlens
objectFromFilm = objectFromRear+filmdistance_mm;
 
filmdistance_mm =  36.959;

%% Calculate PSF


% Define point source for which PSF needs to be calculated
ps = {[0 0 -objectFromRear]}


% Define psfCameraC
wave = linspace(500,1000,7); 
filmSize = [0.04,0.04]; % mm
pos = [0 0 filmdistance_mm];  % distance
res = [200 200];   % Pixel samples
film = filmC('position', pos, 'size', filmSize, 'wave', wave, 'resolution', res);
psfCamera = psfCameraC('lens',lens,'film',film,'pointsource',ps);


%% Calculate psf image
% nlines is how many lines you want to see plotted while tracing
psfCamera.estimatePSF('nLines',0,'jitter',false);

% Turn this into ISETCam optical image
oimage = psfCamera.oiCreate();  % vcAddObject(oi); oiWindow;
% oiWindow(oimage);

%% Extract the point spread data
x_micron = 1e3*linspace(-filmSize(1)/2,filmSize(1)/2,res(1));
y = x_micron;
PSF = oiGet(oimage, 'photons',wave(1));
LSF = sum(PSF,1);
ieNewGraphWin; plot(x_micron,LSF)

load('zemax_lsf_3000.mat','zemax');
ieNewGraphWin; plot(zemax(:,1),zemax(:,2));

ieNewGraphWin; 
plot(x_micron,LSF/max(LSF(:)), 'r--',zemax(:,1),zemax(:,2)/max(zemax(:,2)),'g-')
grid on
legend({'isetlens','zemax'});

%%
ieNewGraphWin;clf;imagesc(x_micron,y,PSF)
shading interp
xlabel('x (\mu m)')
ylabel('x (\mu m)')


%psfCamera.PSFArray(points)
figure;plot(x_micron,PSF(end/2,:))
xlabel('x (\mu m)')



return


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



