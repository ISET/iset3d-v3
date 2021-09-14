
%% Init
clear;
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Check that we have a scene at all



%%  Adjust the field of view and other parameters

lensfile  = 'dgauss.22deg.12.5mm.json';    % 30 38 18 10
lensfile  = 'dgauss.22deg.3.0mm.json';    % 30 38 18 10
rtffile  = 'dgauss.22deg.3.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);


thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';

%% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','dgauss.22deg.3.0mm_aperture0.6_spectral.json')
cameraOmni.filmdistance.type='float'
cameraOmni.filmdistance.value=0.002167;
cameraOmni = rmfield(cameraOmni,'focusdistance')
cameraOmni.aperturediameter.value=0.6


cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.3.0mm.json-raytransfer-spectral.json')
cameraRTF.aperturediameter.value=0.6
cameraRTF.aperturediameter.type='float'

cameras={cameraOmni,cameraRTF};oiLabels={'cameraOmni','cameraRTF'}




for c=1:numel(cameras)
pa = piAssetLoad('pointarray512');


thisR = pa.thisR;
thisR.outputFile='/home/thomas42/Documents/MATLAB/iset3d/local/flatSurface/flatSurface.pbrt'
piAssetGeometry(thisR);
%piWRS(thisR);


thisR.camera = cameras{c};


thisR.set('spatial resolution',[5000 5000]);
thisR.set('rays per pixel',300);

thisR.set('asset','pointarray_512_64-1712','scale',[5 5 1]);


thisR.integrator.subtype='path'
thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value =1

tic;
oi{c}=piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi{c}.name=oiLabels{c};
toc;
end

thisR.show('objects');

%%  Change the position


% thisR.set('asset','pointarray_512_64-1712','translate',[0 0 -2]);
