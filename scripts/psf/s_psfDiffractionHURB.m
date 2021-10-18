%% Diffraction PSF calculated with HURB
%

%% A two element lens
lens = lensC;
lens.draw;


%%
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