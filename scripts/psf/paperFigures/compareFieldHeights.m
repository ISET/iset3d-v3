clear; close all
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
fieldHeights_mm = [0 1000 0 1000 0]
objectFromFront_distances_mm = [3000 3000 3300 3300 800 ]; 
assert(numel(fieldHeights_mm)==numel(objectFromFront_distances_mm))

for f=1:numel(fieldHeights_mm)
    
fieldHeightY_mm = fieldHeights_mm(f);
objectFromFront = objectFromFront_distances_mm(f);   % For zemax, measures from first lens vertex
objectFromRear= objectFromFront+lensThickness; % For isetlens
objectFromFilm= objectFromRear+filmdistance_mm; 


%% Grid definition to sample the pupil uniformly
gridCenterZ = -lensThickness;
nbGridPoints= 2000;
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
lensFilmPos(:,:,f)=pOut;

%% Trace through RTF lens
%%% Trace ray to input plane
  
rtfFilmPos(:,:,f)=rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm);

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

fig=figure(f);clf;hold on;
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



%% Generate LSF figures
close all
maxnorm = @(x)x/max(x);

colorLens = 'k';
colorRTF= [0.8 0 0.1];


nbConfigs=numel(fieldHeights_mm);
fig=figure(1);clf;hold on;
fig.Position= [434 240 1058 529]


labels={'LSF\,X','LSF\,Y'}

for i=1:2
    for f=1:nbConfigs
    
    
        index=sub2ind([nbConfigs 2 ],f,i)
        subplot(2,nbConfigs,index); hold on
        
        [binsLens_micron,countsLens]=paddedHistogram(lensFilmPos(:,i,f),nbBins,nbZeroPad);
        [binsRTF_micron,countsRTF]=paddedHistogram(rtfFilmPos(:,i,f),nbBins,nbZeroPad);
        
        hlens(f)=plot(binsLens_micron,maxnorm(countsLens),'color',colorLens);
        hrtf(f)=plot(binsRTF_micron,maxnorm(countsRTF),'color',colorRTF);
        
        xlabel('Micron')

      if(f==1)
         
       ylabel(['$\mathbf{' labels{i} '}$'])
       ylh = get(gca,'ylabel');
    ylp = get(ylh, 'Position');
    ylh.FontWeight='Bold'
    set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
    
      end
      
      if(f>1)
            % no ylabel
            ax=gca; ax.YTickLabels=[];ax.YTick=[];
            ax.YAxis.Visible='off'
      end
      
      if(i==1)
          xpos=[2 4 10 10 500]
         text(xpos(f),0.8,['Object dist.: ' num2str(objectFromFront_distances_mm(f)/1000) ' m']) 
         text(xpos(f),0.7,['Field height: ' num2str(fieldHeights_mm(f)/1000) ' m']) 
      end
        
    end
    
    

end

% Add legend
legh=legend([hlens(1) hrtf(1)],'Exact ray tracing','Ray Transfer Function');
legh.Orientation='horizontal';
legh.Box='off'
legh.Position(1:2)=[0.3938 0.9421];
set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

saveas(gcf,'./fig/compareLSF.eps','epsc')




%% Generate MTF figures
close all
maxnorm = @(x)x/max(x);

colorLens = 'k';
colorRTF= [0.8 0 0.1];


nbConfigs=numel(fieldHeights_mm);
fig=figure(1);clf;hold on;
fig.Position= [434 240 1058 529]


labels={'MTF\,X','MTF\,Y'}

for i=1:2
    for f=1:nbConfigs
    
    
        index=sub2ind([nbConfigs 2 ],f,i)
        subplot(2,nbConfigs,index); hold on
        
        [binsLens_micron,countsLens]=paddedHistogram(lensFilmPos(:,i,f),nbBins,nbZeroPad);
        [binsRTF_micron,countsRTF]=paddedHistogram(rtfFilmPos(:,i,f),nbBins,nbZeroPad);
        
        
        [freqLens,MLens]=fftMTF(micronTomm*binsLens_micron,countsLens);
        [freqRTF,Mrtf]=fftMTF(micronTomm*binsRTF_micron,countsRTF);
        hlens=plot(freqLens,MLens)
        hrtf=plot(freqRTF,Mrtf)

        xlabel('cycles/mm')
        
        

      if(f==1)
         
       ylabel(['$\mathbf{' labels{i} '}$'])
       ylh = get(gca,'ylabel');
    ylp = get(ylh, 'Position');
    ylh.FontWeight='Bold'
    set(ylh, 'Rotation',0, 'Position',ylp, 'VerticalAlignment','middle', 'HorizontalAlignment','right')
    
      end
      
      if(f>1)
            % no ylabel
            ax=gca; ax.YTickLabels=[];ax.YTick=[];
            ax.YAxis.Visible='off'
      end
      
      if(i==1)
          xpos=[1 1 1 1 1]*10
         text(xpos(f),0.8,['Object dist.: ' num2str(objectFromFront_distances_mm(f)/1000) ' m']) 
         text(xpos(f),0.7,['Field height: ' num2str(fieldHeights_mm(f)/1000) ' m']) 
      end
        
    end
    
    

end

% Add legend
legh=legend([hlens(1) hrtf(1)],'Exact ray tracing','Ray Transfer Function');
legh.Orientation='horizontal';
legh.Box='off'
legh.Position(1:2)=[0.3938 0.9421];
set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

saveas(gcf,'./fig/compareMTF.eps','epsc')

