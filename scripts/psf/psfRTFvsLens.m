clear
%% My own implementation for Geometric PSF calculation

filmdistance_mm=36.959;
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
lens.draw
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane=outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);

%% Load RTF
fit=load('rtf-dgauss.22deg.50mm.mat','fit');
rtf=fit.fit{1};


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




%% LSF   Y 
maxnorm = @(x)x/max(x);
mmToMicron=1e3;
figure(5);clf;hold on;


% Because of the narrow peak, the different binsize of zemax which is quite
% large changes the relative peak height. Therefore to make the data
% comparable we calculat the number bins required to match the same binsize
% as zemax.

% Calculate historgram by counting rays 


nbBins=50;

subplot(121); hold on;
[counts,bins]=hist(mmToMicron*pOut(:,1),nbBins)
[countsRTF,binsRTF]=hist(mmToMicron*rtfFilmPos(:,1),nbBins)
% Plots
hlens=plot(bins,maxnorm(counts))
hrtf=plot(binsRTF,maxnorm(countsRTF))
title('Line spread function X')

subplot(122); hold on;
[counts,bins]=hist(mmToMicron*pOut(:,2),nbBins)
[countsRTF,binsRTF]=hist(mmToMicron*rtfFilmPos(:,2),nbBins)
% Plots
hlens=plot(bins,maxnorm(counts))
hrtf=plot(binsRTF,maxnorm(countsRTF))
title('Line spread function Y')

legend([hlens hrtf],'lens','rtf')


%% Histogran   Y 
maxnorm = @(x)x/max(x);
mmToMicron=1e3;
nbBins=100
figure(2);clf
ax1=subplot(121)
histogram2(mmToMicron*pOut(:,1),mmToMicron*pOut(:,2),nbBins,'FaceColor','flat');
xlabel('x (micron)');
ylabel('y (micron)');
title('PSF Lens')

ax2=subplot(122)
histogram2(mmToMicron*rtfFilmPos(:,1),mmToMicron*rtfFilmPos(:,2),nbBins,'FaceColor','flat');
xlabel('x (micron)');
ylabel('y (micron)');
title('PSF RTF')
linkaxes([ax1 ax2],'xy')
return
%% Sanity check: RTF and lens should give almost identical results
%% Compare trace

origin = [0 0 rtf.planes.input];

direction = [0 sind(a) cosd(a)];
[tracePos]=trace_io(lens,origin,direction)
[rtfPos,rtfDir] = rtfTrace(origin,direction,rtf.polyModel);
% Continue trace to film
alpha=abs(rtfPos(3)-filmdistance_mm)./rtfDir(3);
rtfFilmPos(r,:) = rtfPos + alpha*rtfDir

pass = (doesRayPassCircles(origin,direction,rtf.circleRadii,rtf.circleSensitivities,rtf.circlePlaneZ))


%% Check if vignetting functions behave identical
passCircles = (doesRayPassCircles(inputOrigins,directions,rtf.circleRadii,rtf.circleSensitivities,rtf.circlePlaneZ));
pass = doesRayPassPupils(inputOrigins,directions, pupil_distances,pupil_radii);
assert(~any(passCircles-pass))