%% Script with charts at different depths 
% This script is written as part of a class project on autofocus  psych221
% For Itamar
%
% The aim is to generate a scene with objects at controllable depths
% Supervised by Thomas Goossens

ieInit;



%% Filmdistance and 
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')
filmdistance_mm=37.959 % mm

% Positions of chart as measured from the film
distancesFromFilm_meter = [1 1.5 2 3 4 5 6 ]

%% Create the two cameras and choose a lens
lensname='dgauss.22deg.50.0mm_aperture6.0';
cameraOmni = piCameraCreate('omni','lensfile',[lensname '.json']);
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm/1000;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=12;

cameras = {cameraOmni}; oiLabels = {'cameraOmni'};




%% Loop over different chart distances, as measured from film

for i=1:numel(distancesFromFilm_meter)

    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
    % Add chart at depth
    positionXY = [0 0];% Center
    scaleFactor=0.5; % adjust to your liking
    piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(i),positionXY,scaleFactor);
        
    thisR.set('camera',cameraOmni);
    thisR.set('spatial resolution',[1000 500]);
    thisR.set('rays per pixel',300);
    thisR.set('film diagonal',10); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi] = piRender(thisR,'render type','radiance');
    oi.name=['Chart distance from film: ' num2str(distancesFromFilm_meter(i))]
    oiList{i}=oi;
    oiWindow(oi)
end


%% Compare edge smoothing at different depths
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))

figure(5);clf; hold on
for i=1:numel(distancesFromFilm_meter)
   oi=oiList{i} ;
   edge=oi.data.photons(end/2,:,1); % Take horizontal line in center
   plot(pixels,edge,'color',color(18*i,:))
   labels{i}=[num2str(distancesFromFilm_meter(i)) ' m'];
   xlabel('mm')
   xlim([-2 1])
end
legend(labels)

