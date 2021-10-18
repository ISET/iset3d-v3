%% Script to make the PSF figures

clear; close all
%% My own implementation for Geometric PSF calculation

filmdistance_mm=37.959;
lens = lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane = outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);

%% Load RTF
fit = load('rtf-dgauss.22deg.50mm.mat','fit');
rtf = fit.fit{1};

%% Configurations
fieldHeights_mm = [sqrt(150^2+100^2) ]
objectFromFront_distances_mm = [1399+50 ];
assert(numel(fieldHeights_mm)==numel(objectFromFront_distances_mm))


for f=1:numel(fieldHeights_mm)

    
    fieldHeightY_mm = fieldHeights_mm(f);
    objectFromFront = objectFromFront_distances_mm(f);   % For zemax, measures from first lens vertex
    objectFromRear= objectFromFront+lensThickness; % For isetlens
    objectFromFilm= objectFromRear+filmdistance_mm;
    
    
    %% Grid definition to sample the pupil uniformly
    gridCenterZ =-lensThickness;
    nbGridPoints= 200;
    gridSize_mm = 30;
    gridpoints = linspace(-gridSize_mm/2,gridSize_mm/2,nbGridPoints);
    
    [rows,cols] = meshgrid(gridpoints,gridpoints);
    
    grid=[rows(:) cols(:) ones(numel(rows),1)*gridCenterZ];
    
    
    %% Generate collection of rays by tracing origin points to grid points
    clear origins directions;
    origins = repmat([0 fieldHeightY_mm -objectFromRear],[numel(rows) 1]);
    directions = (grid-origins);
    directions = directions./sqrt(sum(directions.^2,2));
    
    
    %% Trace through real lens using isetlens
    % This works correctly with Zemax, and it matches the RTF
    % calculation below.
    %
    % So, isetlens is OK to this part of the calculations.
    waveindex=1;
    waveIndices=waveindex*ones(1, size(origins, 1));
    rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
    [~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);
    lensFilmPos(:,:,f)= pOut;
    
    %% Trace through real lens with RTF lens        
    rtfFilmPos(:,:,f) = rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm);
    
    %% Unit conversions
    mmToMicron=1e3;
    micronTomm=1e-3;
    
    
    %% Histogran binning
    nbBins=50;
    
    
    %% Add zero padding
    % This pads zeros to both  the sides of te LSF . This is imporant to get
    % the right MTF when using FFT, because FFT assumes the signal to ne
    % perodic. In reaslity the geometric PSF is zero everywhere except near its
    % peak.
    nbZeroPad = 20;    
    
    %% Generate LSF and MTF figures
    maxnorm = @(x)x/max(x);
    
    fig=figure(f);
    clf;hold on;
    fig.Name=['Object distance ' num2str(objectFromFront)  '- Field height ' num2str(fieldHeightY_mm) 'mm' ];
        
    labels={'X','Y'}
    for i = 1:2
        
        ax1=subplot(2,2,1+(i-1)); hold on;
        
        [binsLens_micron,countsLens]=paddedHistogram(lensFilmPos(:,i,f),nbBins,nbZeroPad)
        [binsRTF_micron,countsRTF]=paddedHistogram(rtfFilmPos(:,i,f),nbBins,nbZeroPad)
        
        
        hlens=plot(binsLens_micron,maxnorm(countsLens));
        hrtf=plot(binsRTF_micron,maxnorm(countsRTF));
        
        
        title(['Line spread function ' labels{i}])
        xlabel('Micron')
        
        
        % MTF
        subplot(2,2,3+(i-1)); hold on;
        [freqLens,MLens]=fftMTF(micronTomm*binsLens_micron,countsLens);
        [freqRTF,Mrtf]=fftMTF(micronTomm*binsRTF_micron,countsRTF);
        MLensXY{i}=MLens;
        freqLensXY{i}=freqLens;
        hlens=plot(freqLens,MLens)
        hrtf=plot(freqRTF,Mrtf)
        
        title(['MTF' labels{i}])
        xlabel('cycles/mm')
        
    end
    
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    set(findall(gcf,'-property','interpreter'),'interpreter','latex');
    
    autoArrangeFigures
    pause(0.01)
end

