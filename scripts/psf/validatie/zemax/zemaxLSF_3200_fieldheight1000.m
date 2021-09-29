clear
%% My own implementation for Geometric PSF calculation

filmdistance_mm=36.959;
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
lens.draw
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane=outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);


%% Object distances with different reference ponts

fieldHeightY_mm = 1000;
objectFromFront = 3200;   % For zemax, measures from first lens vertex
objectFromRear= objectFromFront+lensThickness; % For isetlens
objectFromFilm= objectFromRear+filmdistance_mm; 


%% Grid definition to sample the pupil uniformly
gridCenterZ = -lensThickness;
nbGridPoints= 500;
gridSize_mm = 30;
gridpoints = linspace(-gridSize_mm/2,gridSize_mm/2,nbGridPoints);

[rows,cols] = meshgrid(gridpoints,gridpoints);

grid=[rows(:) cols(:) ones(numel(rows),1)*gridCenterZ];





%% Collect rays
clear origins directions;
count=1;
origins = repmat([0 fieldHeightY_mm -objectFromRear],[numel(rows) 1]);
        

directions = (grid-origins);
directions = directions./sqrt(sum(directions.^2,2));

waveindex=1;
waveIndices=waveindex*ones(1, size(origins, 1));
rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
[~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);


%% Load LSF
zemaxlsfXY=dlmread('zemaxLSF_3200_fieldheight1000.csv')
% POSITION,  LSFx, LSFy


%% LSF   Y 
maxnorm = @(x)x/max(x);
mmToMicron=1e3;
figure(5);clf;hold on;


% Because of the narrow peak, the different binsize of zemax which is quite
% large changes the relative peak height. Therefore to make the data
% comparable we calculat the number bins required to match the same binsize
% as zemax.
deltazemax = diff(zemaxlsfXY(1:2,1));
range_micron=mmToMicron*(max(pOut(:,1))-min(pOut(:,1)));
nbBins = round(range_micron/deltazemax)

% Calculate historgram by counting rays 
[counts,bins]=hist(mmToMicron*pOut(:,2),nbBins)


% Plots
hthomas=plot(bins+16000-243,maxnorm(counts))
hzemax=plot(zemaxlsfXY(:,1),maxnorm(zemaxlsfXY(:,2)))

legend([hthomas hzemax],'Thomas PSF ray counter','zemax','zemax')
title('Linespread function Y Direction')



%% LSF   Y 
maxnorm = @(x)x/max(x);
mmToMicron=1e3;
figure(5);clf;hold on;


% Because of the narrow peak, the different binsize of zemax which is quite
% large changes the relative peak height. Therefore to make the data
% comparable we calculat the number bins required to match the same binsize
% as zemax.

directionlabel={'X','Y'}
for col =[1 2]

deltazemax = diff(zemaxlsfXY(1:2,1));
range_micron=mmToMicron*(max(pOut(:,3-col))-min(pOut(:,3-col)));
nbBins = round(range_micron/deltazemax)

% Calculate historgram by counting rays 
[counts,bins]=hist(mmToMicron*pOut(:,3-col),nbBins)

% Plots
subplot(1,2,col); hold on;
normalizedPeak=maxnorm(counts);
peakCenter=bins(find(normalizedPeak==1,1))

hthomas=plot(bins-peakCenter,normalizedPeak)
hzemax=plot(zemaxlsfXY(:,1),maxnorm(zemaxlsfXY(:,1+col)))

title(['Linespread function ' directionlabel{col}])    
end

legend([hthomas(1) hzemax(1)],'Thomas PSF ray counter','zemax')

%