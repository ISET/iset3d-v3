%% We calculate the PSF of a lens several ways
%
% The purpose is to compare Zemax, ISETLens, and the RTF methods.
%
% For this lens at this time, the agreement seems good.  There are
% some issues to consider for the future.
%
% Important: These calculations are purely ray trace.  But for this
% lens there is considerable diffraction.  So the linespread is in
% fact much thinner than the real performance.  It is, however, the
% same calculation for Zemax and for ISETLens.  That is what we wanted
% to know. 
%
% TG/BW
%
% See also:
%   compareFieldHeights, lensC.estimatePSF
%
 
%% Choose a lens and sampling of lens  aperture
%
% The double Gauss is what Thomas used for the Zemax calculation.  So,
% we use it here.
%

lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';
lens = lensC('file',lensName);

% Even with a few samples the agreement is good.
lens.apertureSample = 500*[1 1];   % 400 is quick, 1000 is OK, 4000 is a lot.

%%
fieldHeightY_mm = 0;
objectFromFront = 3000;   % For zemax, measures from first lens vertex
objectFromRear = objectFromFront + lens.thickness; % For isetlens
objectFromFilm = objectFromRear+filmdistance_mm;
 
filmdistance_mm =  36.959;

%% Calculate PSF using the ISETLens methods

% Define point source position.  Could be a cell array of points.
ps = {[0 0 -objectFromRear]};

% Define the psf camera (psfCameraC)

wave = linspace(500,1000,7); 

filmSize = [0.04,0.04]; % mm
filmpos = [0 0 filmdistance_mm];  % distance
filmres = [200 200];   % Pixel samples
film = filmC('position', filmpos, 'size', filmSize, 'wave', wave, 'resolution', filmres);

psfCamera = psfCameraC('lens',lens,'film',film,'pointsource',ps);

%% Calculate psf image
% nlines is how many lines you want to see plotted while tracing
psfCamera.estimatePSF('nLines',0,'jitter',false);

% Turn this into ISETCam optical image
oimage = psfCamera.oiCreate();  % vcAddObject(oi); oiWindow;
% oiWindow(oimage);

%% Extract the point spread data

x_micron = 1e3*linspace(-filmSize(1)/2,filmSize(1)/2,filmres(1));
y = x_micron;

% One of the wavelengths
PSF = oiGet(oimage, 'photons',wave(1));

% The linespread can be obtained by summing down the columns of the
% pointspread.  A good trick to remember
LSF = sum(PSF,1);
ieNewGraphWin; plot(x_micron,LSF)

%% Now compare with Zemax

load('zemax_lsf_3000.mat','zemax');

ieNewGraphWin; 
plot(x_micron,LSF/max(LSF(:)), 'r--',zemax(:,1),zemax(:,2)/max(zemax(:,2)),'g-')
grid on
legend({'isetlens','zemax'});

%% Not sure.

%{ 
ieNewGraphWin;
imagesc(x_micron,y,PSF)
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
%}


