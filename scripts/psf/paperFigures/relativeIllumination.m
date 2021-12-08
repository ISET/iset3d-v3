
%% Plot relative illumination DGAUSS 50mm lens compare Omni with RTF

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

thisR=piRecipeDefault('scenename','flatsurface')
%% Set camera position


filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
distanceFromFilm_m=1.469+50/1000


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



%% Light should be add infinitey to avoid additional vignetting nintrouced
% by light falloff
light =  piLightCreate('distant','type','distant')

 thisR     = piLightDelete(thisR, 'all');
thisR.set('light', 'add', light);


%% Loop ver Different aperture sizes

aperturediameters = [2 5 7 12 ];




for a=1:numel(aperturediameters)
% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','dgauss.22deg.50.0mm_aperture6.0.json');
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=0.037959;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=aperturediameters(a);

rtffile=['dgauss.22deg.50.0mm-poly5-diaphragm' num2str(aperturediameters(a)) 'mm-raytransfer.json'];
cameraRTF = piCameraCreate('raytransfer','lensfile',rtffile);
%cameraRTF = piCameraCreate('raytransfer','lensfile','/home/thomas42/Documents/MATLAB/libs/isetlens/local/dgauss.22deg.50.0mm_aperture6.0.json-raytransfer.json')
cameraRTF.filmdistance.value=0.037959;
%cameraRTF.aperturediameter.value=aperturediameters(a);
%cameraRTF.aperturediameter.type='float';

thisR.set('pixel samples',1500)



thisR.set('film diagonal',90,'mm');
resolution=400;
thisR.set('film resolution',resolution*[1 1])
    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1


% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
%chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar
% Omni
disp('---------Render Omni----------')
thisR.set('camera',cameraOmni);
[oi,resultsOmni] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oiOmni{a}=oi;
close all

% RTF
disp('---------Render RTF-----------')
thisR.set('camera',cameraRTF);
[oi,resultsRTF] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oiRTF{a}=oi;
close all
end

oiList = {oiOmni,oiRTF};

%save('oiRelativeIlluminationLowQuality.mat')



% %%
% %% Manual loading of dat file
% 
% 
% label={};path={};
% label{end+1}='nonlinear';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/rtf.dat';
% 
% oi = piDat2ISET(path{1}, 'wave', 400:10:700, 'recipe', thisR);
% 
%     
% oiWindow(oi);
% 
% oiList{2}={oi}


%% Load zemax

zemax=dlmread('relativeIllumZemax.csv');
zemax=zemax(2:end,:); % remove aperture diameters on first colum


%% Plot relative illuminations
cmap = hot;
s=size(cmap,1);
color{2,1}=cmap(round(0.3*s),:);
color{2,2}=cmap(round(0.45*s),:);
color{2,3}=cmap(round(0.5*s),:);
color{2,4}=cmap(round(0.6*s),:);
color{2,5}=cmap(round(0.66*s),:)
color{1,1}='k';
color{1,2}='k';
color{1,3}='k';
color{1,4}='k';
color{1,5}='k';

%load('oiRelativeIllumination.mat')
colors={'k',[0.9 0 0.1]}
clear mtf relativeIllum;
fig=figure(3);clf;hold on
fig.Position=[554 437 781 280]
maxnorm = @(x)x/max(x);


%construct x axis
filmdiagonal=thisR.get('filmdiagonal')
xaxis=0.5*filmdiagonal/sqrt(2) *linspace(-1,1,resolution);

linestyle={'-' ,'-.'}
% Plot relative illuminations
for o=1:numel(oiList)
    %oiWindow(oi);
    
    oi=oiList{o};
    for a=1:(numel(aperturediameters))

        
        relativeIllum(:,a)=maxnorm(oi{a}.data.photons(end/2,:,1))
             
        h(o)=plot(xaxis,relativeIllum(:,a),'color',color{o,a},'linewidth',2,'linestyle',linestyle{o})

        %plot(zemax(:,1),zemax(:,2+(a-1)),'color',[0.1 0.8 0.1],'linewidth',2)
    end

    
end

%Add diameter labels
pos=[122 0.55; 110 0.64 ; 99 0.72; 60 0.88];
pointOnCurve = [  17.2248   22.0635   24.1673   26.3237;
      0.6486    0.6675    0.6580    0.6769]'; pointForText = [    10.8082   18.5922   23.7465   28.5326;
                      0.6344    0.9316    0.9269    0.9033]';
                 offsets = [-5 0;0 0.02; 0 0.02 ;0 0.02];
                 pos=flip(pos,1);
pointOnCurve=flip(pointOnCurve,1);
pointForText=flip(pointForText,1);
offsets=flip(offsets,1);

for a=1:4
    line([pointOnCurve(a,1) pointForText(a,1)] , [pointOnCurve(a,2) pointForText(a,2)],'color','k');
    text(pointForText(a,1)+offsets(a,1),pointForText(a,2)+offsets(a,2),['$\O=' num2str(aperturediameters(a)) '$ mm'])
end
    

legh=legend([h(1) h(2)] ,'Exact Model','Ray Transfer Function','location','southwest')
 text(2.1,0.2901,['$\O$ Diaphragm diameter'])
legh.Box='off'
xlabel('Image height (mm)')
title('Relative illumination') 
box on
xlim([0 xaxis(end)])
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

saveas(gcf,'/scratch/thomas42/rtfpaper/relativeillumination_dgauss50.pdf','epsc')
