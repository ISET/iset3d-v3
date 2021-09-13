
%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Check that we have a scene at all

pa = piAssetLoad('pointarray512');
thisR = pa.thisR;
thisR.outputFile='/home/thomas/Documents/stanford/libraries/iset/iset3d/local/flatSurface/flatSurface.pbrt'
piAssetGeometry(thisR);
%piWRS(thisR);

%%  Adjust the field of view and other parameters

lensfile  = 'dgauss.22deg.12.5mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

thisR.set('spatial resolution',[2000 2000]);
thisR.set('rays per pixel',32);

thisR.set('asset','pointarray_512_64-1712','scale',[3 3 1]);

tic;
piWRS(thisR);
toc;

thisR.show('objects');

%%  Change the position


% thisR.set('asset','pointarray_512_64-1712','translate',[0 0 -2]);
