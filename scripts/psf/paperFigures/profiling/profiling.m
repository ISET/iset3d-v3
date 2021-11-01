%%  s_goMTF3D
%
% Questions:
%   * I am unsure whether the focal distance is in z or in distance from
%   the camera.  So if the camera is at 0, these are the same.  But if the
%   camera is at -0.5, these are not the same.
%
%  * There is trouble scaling the object size.  When the number gets small,
%  the object disappears.  This may be some numerical issue reading the
%  scale factor in the pbrt geometry file?
%

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
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';


%% Loop ver Different aperture sizes

aperturediameters = 12


for a=1:numel(aperturediameters)
% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','dgauss.22deg.50.0mm_aperture6.0.json')
cameraOmni.filmdistance.type='float'
cameraOmni.filmdistance.value=0.037959;
cameraOmni = rmfield(cameraOmni,'focusdistance')
cameraOmni.aperturediameter.value=aperturediameters(a);


cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.50.0mm_aperture6.0.json-filmtoscene-raytransfer.json')
cameraRTF.filmdistance.value=0.037959;
cameraRTF.aperturediameter.value=aperturediameters(a);
cameraRTF.aperturediameter.type='float'



thisR.set('film diagonal',90,'mm');
thisR.set('film resolution',3*[200 200])
    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value =1


% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
%chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar
% Omni


% Loop over ray number samples5
samples = [20 50 100 200 300 400 500 1000 2000 ];
figure(1);clf; hold on
time_omni=zeros(size(samples))
time_rtf=time_omni;
for s=1:numel(samples)
    % Set pixel samples
    thisR.set('pixel samples',samples(s))
    
    
    disp('---------Render Omni----------')
    
    thisR.set('camera',cameraOmni);
    
    
    piWrite(thisR);
    tic;
    [oi,resultsOmni] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);
    time_omni(s)=toc;
    log_omni{s}=resultsOmni;
    % RTF
    disp('---------Render RTF-----------')
    
    
    thisR.set('camera',cameraRTF);
    piWrite(thisR);
    tic;
    [oi,resultsRTF] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);
    time_rtf(s)=toc;
    log_rtf{s}=resultsOmni;
    % Plot intermediate result
    clf; hold on;
    plot(samples,time_omni,'k.-')
    plot(samples,time_rtf,'r.-')
    legend('omni','rtf')
    ylabel('Time')
    pause(0.1)%to 
    % Intermediate backups in file
    save('profiling2.mat','samples','time_rtf','time_omni','log_rtf','log_omni')
end


end


%%
figure; 
subplot(211);hold on
    plot(samples,time_omni,'k.-')
    plot(samples,time_rtf,'r.-')
    legend('omni','rtf')
    xlabel('Number of rays per pixel')
        ylabel('Time (seconds)')
title('Rendering time')
subplot(212);;hold on
   plot(samples,(time_rtf-time_rtf(1))./(time_omni-time_omni(1)),'k.-')
xlabel('Number of rays per pixel')    
title('Ratio RTF/OMNI after removing intercept')
saveas(gcf,'profilingRTF.eps','epsc')
    


