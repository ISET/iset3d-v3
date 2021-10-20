%% Script to make the PSF figures

%clear; close all
%% My own implementation for Geometric PSF calculation

filmdistance_mm=36.959;
lens = lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')

lensThickness = lens.surfaceArray(1).sRadius-lens.surfaceArray(1).sCenter(3);
addPlane = outputPlane(filmdistance_mm); % Film plane
lens = addPlane(lens);

%% Load RTF
fit = load('rtf-dgauss.22deg.50mm.mat','fit');

rtf = fit.fit{1};
diaphragm_diameter=12
% Set diaphraghm diameter RTF
rtf.circleRadii(1) = rtf.diaphragmToCircleRadius*diaphragm_diameter/2;
    

%% Configurations
fieldHeights_mm = [0 1000 0 1000 ]
objectFromFront_distances_mm = [3000 3000 3300 3300  ];
assert(numel(fieldHeights_mm)==numel(objectFromFront_distances_mm))


for f=1:numel(fieldHeights_mm)

    
    fieldHeightY_mm = fieldHeights_mm(f);
    objectFromFront = objectFromFront_distances_mm(f);   % For zemax, measures from first lens vertex
    objectFromRear= objectFromFront+lensThickness; % For isetlens
    objectFromFilm= objectFromRear+filmdistance_mm;
    
    
    %% Grid definition to sample the pupil uniformly
    gridCenterZ = -lensThickness;
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



%% Load diffraction
fftlsf3000=dlmread('fftlsf3000.csv');
fftlsf3000fieldheight1000=dlmread('fftlsf3000_fieldheight1000.csv');
fftlsf3300=dlmread('fftlsf3300.csv');
fftlsf3300fieldheight1000=dlmread('fftlsf3300_fieldheight1000.csv');


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
        if(i==1)
            if(f==1)
                hdiffract(f)=plot(fftlsf3000(:,1),fftlsf3000(:,2),'m')
            elseif(f==2)
                hdiffract(f)=plot(fftlsf3000fieldheight1000(:,1),fftlsf3000fieldheight1000(:,2),'m')
            elseif(f==3)
                hdiffract(f)=plot(fftlsf3300(:,1),fftlsf3300(:,2),'m')
            elseif(f==4)
               hdiffract(f)=plot(fftlsf3300fieldheight1000(:,1),fftlsf3300fieldheight1000(:,2),'m') 
            end
        end
        
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
legh=legend([hlens(1) hrtf(1) hdiffract(1)],'Exact ray tracing','Ray Transfer Function','Including diffraction');
legh.Orientation='horizontal';
legh.Box='off'
legh.Position(1:2)=[0.3938 0.9421];
set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

saveas(gcf,'./fig/compareLSF.eps','epsc')




%% Make sliced view LSF
clear dataLens dataRTF binsLens binsRTF


colors={'r' 'g' 'b' 'k'}
figure(3);clf

for i=1:2
    for f=1:nbConfigs
        

        
        
        [binsLens_micron,countsLens]=paddedHistogram(lensFilmPos(:,i,f),nbBins,nbZeroPad);
        [binsRTF_micron,countsRTF]=paddedHistogram(rtfFilmPos(:,i,f),nbBins,nbZeroPad);
        
           
        dataLens(:,f,i)=maxnorm(countsLens);        binsLens(:,f,i)=binsLens_micron;
        dataRTF(:,f,i)=maxnorm(countsRTF);        binsRTF(:,f,i)=binsRTF_micron;
        

        

        
    end
end


clear X Y
figure(5); clf
box on

clear X Y
figure(6); hold on; clf
box on
configNumbers=1:nbConfigs;
colors={[1 1 1]*0.8 , [55 185 229]/255 }
configOffsetZ=[0 0.1]
for i=1:2
    peak=sum(binsLens(:,:,i).*dataLens(:,:,i),1)./sum(dataLens(:,:,i),1);
    hlens=sliceplot(binsLens(:,:,i)-peak,dataLens(:,:,i),configNumbers+configOffsetZ(i)); hold on
    hlens.FaceColor=colors{i};
   
    % Only first direction transparent
    if(i==1) % X
      set(hlens, 'FaceAlpha', 0.9);
    else % Y
        set(hlens, 'FaceAlpha', 0.99);
    end
    handles{i}=hlens;

for f=1:nbConfigs
    hrtf=plot3(binsRTF(:,f,i)-peak(f),configOffsetZ(i)+f*ones(size(dataRTF(:,f,i))),dataRTF(:,f,i),'color',[0 0 0],'linewidth',2)
    configLabels{f}=['z=' num2str(objectFromFront_distances_mm(f)/1000) 'm, h=' num2str(fieldHeights_mm(f)/1000) ' m'];
end
end
yticklabels(configLabels)
xlabel('Width (micron)')
    legh=legend([handles{1} handles{2} hrtf] ,'LSF X','LSF Y','LSF ray transfer function')
legh.Position= [0.6544 0.8953 0.3139 0.0869]
legh.Box='off'


view(48,20)

set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');
saveas(gcf,'./fig/LSF_waterfall.eps','epsc')


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
        
        
            if(i==1)
            if(f==1)
                  [freq,M]=fftMTF(micronTomm*fftlsf3000(:,1), fftlsf3000(:,2));
                hdiffract(f)=plot(freq,M,'m')
                xlim([0,500])
            elseif(f==2)
              
                     [freq,M]=fftMTF(micronTomm*fftlsf3000fieldheight1000(:,1), fftlsf3000fieldheight1000(:,2));
                hdiffract(f)=plot(freq,M,'m')
                xlim([0,200])
            elseif(f==3)
                     [freq,M]=fftMTF(micronTomm*fftlsf3300(:,1), fftlsf3300(:,2));
                hdiffract(f)=plot(freq,M,'m')
                xlim([0,150])
                hdiffract(f)=plot(fftlsf3300(:,1),fftlsf3300(:,2),'m')
            elseif(f==4)
                     [freq,M]=fftMTF(micronTomm*fftlsf3300fieldheight1000(:,1), fftlsf3300fieldheight1000(:,2));
                hdiffract(f)=plot(freq,M,'m')
                xlim([0,150])
               
            end
        end
        
        
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
legh=legend([hlens(1) hrtf(1) hdiffract(1)],'Exact ray tracing','Ray Transfer Function','Including diffraction');
legh.Orientation='horizontal';
legh.Box='off'
legh.Position(1:2)=[0.3938 0.9421];
set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

saveas(gcf,'./fig/compareMTF.eps','epsc')




%% Make sliced view MTF
clear dataLens dataRTF binsLens binsRTF

colors={'r' 'g' 'b' 'k'}
figure(3);clf

for i=1:2
    for f=1:nbConfigs
        

        
        
        [binsLens_micron,countsLens]=paddedHistogram(lensFilmPos(:,i,f),nbBins,nbZeroPad);
        [binsRTF_micron,countsRTF]=paddedHistogram(rtfFilmPos(:,i,f),nbBins,nbZeroPad);
        
                   
        
        [freqLens,MLens]=fftMTF(micronTomm*binsLens_micron,countsLens);
        [freqRTF,Mrtf]=fftMTF(micronTomm*binsRTF_micron,countsRTF);
        
        
        dataLens(:,f,i)=MLens;        binsLens(:,f,i)=freqLens;
        dataRTF(:,f,i)=Mrtf;        binsRTF(:,f,i)=freqRTF;
        

        

        
    end
end

clear X Y
figure(6); hold on; clf
box on
configNumbers=1:nbConfigs;

colors={[0.3 0.7 0.1] , [55 185 229]/255 }
offset = @(i)0.2*(i-1);
for i=1:2
hlens=sliceplot(binsLens(:,:,i),dataLens(:,:,i),configNumbers+offset(i)); hold on
hslice{i}=hlens(1);
hlens.FaceColor=colors{i}

for f=1:nbConfigs
    hrtf=plot3(binsRTF(:,f,i),offset(i)+f*ones(size(dataRTF(:,f,i))),dataRTF(:,f,i),'color',[0.9 0 0.1],'linewidth',2)
    configLabels{f}=['z=' num2str(objectFromFront_distances_mm(f)/1000) 'm, h=' num2str(fieldHeights_mm(f)/1000) ' m'];
end
end
yticklabels(configLabels)
xlabel('Spatial frequency (cy/mm)')
legh=legend([hslice{1} hslice{2} hrtf] ,'Exact X','Exact Y','Ray transfer function')
legh.Position= [0.6544 0.8953 0.3139 0.0869]
legh.Box='off'




set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');
saveas(gcf,'./fig/LSF_waterfall.eps','epsc')

