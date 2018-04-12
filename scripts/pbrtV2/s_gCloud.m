close all;
clear all;
clc;

gCloud = gCloud('dockerImage','gcr.io/primal-surfer-140120/pbrt-v2-spectral-gcloud',...
                'cloudBucket','gs://primal-surfer-140120.appspot.com');

gCloud.init();



fName = fullfile('/','home','hblasins','City','001_city_1_placement_1_radiance.pbrt');
workdir = fullfile('/','scratch','hblasins','pbrt2ISET','City');
if exist(workdir,'dir') == false,
    mkdir(workdir);
end

scene = piRead(fName);

distances = [0.01 0.1 10];

for d=1:length(distances)

        scene.set('camera type','realisticDiffraction');
        scene.set('lens file','/home/hblasins/Documents/MATLAB/RTBscenes/SharedData/dgauss.22deg.3.0mm.dat')

        filmDist = focusLens(fullfile('/home/hblasins/Documents/MATLAB/RTBscenes/SharedData/dgauss.22deg.3.0mm.dat'),distances(d)*1000);

        scene.set('focal distance',filmDist);
        scene.set('outputFile',fullfile(workdir,sprintf('city_lens_%i.pbrt',d)));
        piWrite(scene);
    
        gCloud.upload(scene);
end




gCloud.render();
objects = gCloud.download();