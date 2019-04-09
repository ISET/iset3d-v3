%% Render using a lens
%
% Takes about 90 seconds to render
%
% Dependencies:
%    ISET3d, ISETCam, JSONio
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral:test
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_*
%   isetLens repository


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end
%% Read the pbrt files

% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output directory will be written here to inFolder/sceneName
inFolder = fullfile(piRootPath,'local','scenes');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);

% This is the PBRT scene file inside the output directory
inFile = fullfile(inFolder,sceneName,sceneFileName);
thisR = piRead(inFile);

% We will output the calculations to a temp directory.  
outFolder = fullfile(tempdir,sceneName);
outFile = fullfile(outFolder,[sceneName,'.pbrt']);
thisR.set('outputFile',outFile);
%% Set render quality

% Relatively low resolution for speed.
thisR.set('film resolution',[400 300]);
thisR.set('pixel samples',64);

%% Set output file

oiName = sceneName;
outFile = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
thisR.set('outputFile',outFile);
outputDir = fileparts(outFile);

%% Add camera with lens

% lensfile = 'fisheye.87deg.6.0mm.dat';
lensfile = 'dgauss.22deg.50.0mm.dat';
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('realistic','lensFile',lensfile);

%{
% You might adjust the focus for different scenes.  Use piRender with
% the 'depth map' option to see how far away the scene objects are.
dMap = piRender(thisR,'render type','depth');
ieNewGraphWin; imagesc(dMap); colormap(flipud(gray));
colorbar;
%}
thisR.camera.focusdistance.value = 0.375;

% Default aperture diameter is 5.  You can change this for depth of
% field effects.
thisR.camera.aperturediameter.value = 2;   

thisR.set('fov',45);
thisR.film.diagonal.value=  30;
thisR.film.diagonal.type = 'float';

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype = 'sobol';

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.set('nbounces',4); 

piWrite(thisR,'creatematerials',true);

%% Render and display

oi = piRender(thisR,'render type','radiance');
oi = oiSet(oi,'name',sprintf('%s',oiName));
oiWindow(oi);
oi = oiSet(oi,'gamma',0.8);

%% Change this for depth of field effects.
thisR.camera.aperturediameter.value = 10; 

piWrite(thisR,'creatematerials',true);

oi = piRender(thisR,'render type','radiance');
oi = oiSet(oi,'name',sprintf('%s',oiName));
oiWindow(oi);
oi = oiSet(oi,'gamma',0.8);

%% Change again for depth of field effects.
thisR.camera.aperturediameter.value = 1; 

piWrite(thisR,'creatematerials',true);

oi = piRender(thisR,'render type','radiance');
oi = oiSet(oi,'name',sprintf('%s',oiName));
oiWindow(oi);
oi = oiSet(oi,'gamma',0.8);

%% END