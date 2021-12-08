%% Diffraction PSF calculated with HURB
%
% We compare the linespread function derived with ISETLens and Zemax
% for a Double Gauss lens.

%% % Thomas calculated the double Gauss using Zemax calculation.  
% So, we use that lens here. 
%
% Even with a few samples the agreement is good.

lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';
lens     = lensC('file',lensName);
lens.apertureSample = 500*[1 1];   % 400 is quick, 1000 is OK, 4000 is a lot.

%% Match the  Zemax properties

fieldHeightY_mm = 0;
filmdistance_mm =  36.959;

objectFromFront = 3000;   % For zemax, measures from first lens vertex
objectFromRear = objectFromFront + lens.thickness; % For isetlens
objectFromFilm = objectFromRear + filmdistance_mm;

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
oi = psfCamera.oiCreate();
% oiWindow(oi);

%% Extract the point spread data and compute the linespread

x_micron = 1e3*linspace(-filmSize(1)/2,filmSize(1)/2,filmres(1));
% y = x_micron;

% One of the wavelengths
PSF = oiGet(oi, 'photons',wave(1));

% The linespread can be obtained by summing down the columns of the
% pointspread.  A good trick to remember
LSF = psf2lsf(PSF);

ieNewGraphWin; plot(x_micron,LSF)
xlabel('Position (um)');
ylabel('Relative intensity');

%% Now compare with Zemax

load('zemax_lsf_3000.mat','zemax');

ieNewGraphWin; 
plot(x_micron,LSF/max(LSF(:)), 'r--',zemax(:,1),zemax(:,2)/max(zemax(:,2)),'g-')
grid on
xlabel('Position (um)');
ylabel('Relative intensity');
legend({'isetlens','zemax'});

%%