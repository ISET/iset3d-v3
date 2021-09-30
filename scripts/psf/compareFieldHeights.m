qclear; close all
%% My own implementation for Geometric PSF calculation

filmdistance_mm=36.959;
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane=outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);

%% Load RTF
fit=load('rtf-dgauss.22deg.50mm.mat','fit');
rtf=fit.fit{1};




%% Configurations
fieldHeights_mm = [0 1000 0 1000 0 400]
objectFromFront_distances_mm = [3000 3000 3300 3300 800 800]; 
assert(numel(fieldHeights_mm)==numel(objectFromFront_distances_mm))

for f=1:numel(fieldHeights_mm)
    
fieldHeightY_mm = fieldHeights_mm(f);
objectFromFront = objectFromFront_distances_mm(f);   % For zemax, measures from first lens vertex
objectFromRear= objectFromFront+lensThickness; % For isetlens
objectFromFilm= objectFromRear+filmdistance_mm; 


%% Grid definition to sample the pupil uniformly
gridCenterZ = -lensThickness;
nbGridPoints= 500;
gridSize_mm = 30; 
gridpoints = linspace(-gridSize_mm/2,gridSize_mm/2,nbGridPoints);

[rows,cols] = meshgrid(gridpoints,gridpoints);

grid=[rows(:) cols(:) ones(numel(rows),1)*gridCenterZ];


%% Generate collection of rays by tracing origin points to grid points
clear origins directions;
origins = repmat([0 fieldHeightY_mm -objectFromRear],[numel(rows) 1]);
directions = (grid-origins);
directions = directions./sqrt(sum(directions.^2,2));


%% Trace through real lens
waveindex=1;
waveIndices=waveindex*ones(1, size(origins, 1));
rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
[~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);

%% Trace through RTF lens
%%% Trace ray to input plane
  
rtfFilmPos=rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm);

%%

mmToMicron=1e3;
micronTomm=1e-3;


%% LSF   Y 
maxnorm = @(x)x/max(x);

fig=figure(f);clf;hold on;
fig.Name=['Object distance ' num2str(objectFromFront)  '- Field height ' num2str(fieldHeightY_mm) 'mm' ];
nbBins=50;


ax1=subplot(221); hold on;
[counts,bins]=hist(mmToMicron*pOut(:,1),nbBins)
[countsRTF,binsRTF]=hist(mmToMicron*rtfFilmPos(:,1),nbBins)

% Plots
hlens=plot(bins,maxnorm(counts))
hrtf=plot(binsRTF,maxnorm(countsRTF))


title('Line spread function X')
xlabel('Micron')


% MTF 
subplot(2,2,3); hold on;

% FFT bins
deltaX_mm = micronTomm*abs(diff(bins(1:2)));             % Sampling period       
Fs=1/deltaX_mm; %Sampling frequency
L = numel(bins);             % Length of signal
freq = Fs*(0:(L/2))/L;

% FFT binsRTF
deltaX_mm = micronTomm*abs(diff(binsRTF(1:2)));             % Sampling period       
Fs=1/deltaX_mm; %Sampling frequency
Lrtf = numel(binsRTF);             % Length of signal
fRTF = Fs*(0:(L/2))/L;


%Single sided spectrum
M=abs(fft([maxnorm(counts)]));M = M(1:L/2+1); M=M/M(1);M=abs(fft(maxnorm(counts)));M = M(1:L/2+1); M=M/M(1);
Mrtf=abs(fft(maxnorm(countsRTF)));Mrtf = Mrtf(1:Lrtf/2+1); Mrtf=Mrtf/Mrtf(1)


hlens=plot(freq,M)
hrtf=plot(fRTF,Mrtf)

title('MTF X')
xlabel('cycles/mm')

% Linespread function
ax2=subplot(222); hold on;
[counts,bins]=hist(mmToMicron*pOut(:,2),nbBins)
[countsRTF,binsRTF]=hist(mmToMicron*rtfFilmPos(:,2),nbBins)
% Plots
hlens=plot(bins,maxnorm(counts))
hrtf=plot(binsRTF,maxnorm(countsRTF))
xlabel('Micron')
title('Line spread function Y')
%linkaxes([ax1 ax2],'x')



% MTF 
subplot(2,2,4); hold on;

% FFT bins
deltaY_mm = micronTomm*abs(diff(bins(1:2)));             % Sampling period       
Fs=1/deltaY_mm; %Sampling frequency
L = numel(bins);             % Length of signal
freq = Fs*(0:(L/2))/L;

% FFT binsRTF
deltaY_mm = micronTomm*abs(diff(binsRTF(1:2)));             % Sampling period       
Fs=1/deltaY_mm; %Sampling frequency
Lrtf = numel(binsRTF);             % Length of signal
fRTF = Fs*(0:(L/2))/L;

%Single sided spectrum
M=abs(fft(maxnorm(counts)));M = M(1:L/2+1); M=M/M(1);
Mrtf=abs(fft(maxnorm(countsRTF)));Mrtf = Mrtf(1:Lrtf/2+1); Mrtf=Mrtf/Mrtf(1)


hlens=plot(freq,M)
hrtf=plot(fRTF,Mrtf)
title('MTF Y')
xlabel('cycles/mm')

autoArrangeFigures
pause(0.5)
end


%%
