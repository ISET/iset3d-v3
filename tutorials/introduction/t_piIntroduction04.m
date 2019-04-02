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
%   t_piIntroduction*


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files

% This is the INPUT file name
% sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';
sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';

% The output will be written here
inFolder = fullfile(piRootPath,'local','scenes');
piPBRTFetch(sceneName,'pbrtversion',3,'destinationFolder',inFolder);

inFile = fullfile(inFolder,sceneName,sceneFileName);
thisR = piRead(inFile);

%% Set render quality

% This is a relatively low resolution for speed.
thisR.set('film resolution',[300 225]);
thisR.set('pixel samples',32);

%% Set output file

oiName = sceneName;
outFile = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
thisR.set('outputFile',outFile);
outputDir = fileparts(outFile);

%% List material library

% This value determines the number of ray bounces.  The scene has
% glass we need to have at least 2 or more.  We start with only 1
% bounce, so it will not appear like glass or mirror.
thisR.integrator.maxdepth.value = 4;

% This adds a mirror and other materials that are used in driving.s
% piMaterialGroupAssign(thisR);


%% To learn about the range of distances, you can use
%
%   dMap = piRender(thisR,'render type','depth');
%   ieNewGraphWin; histogram(dMap(:),100);  median(dMap(:))

%% Add camera with lens

% lensfile = 'fisheye.87deg.6.0mm.dat';
lensfile = 'dgauss.22deg.50.0mm.dat';
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('realistic','lensFile',lensfile);

thisR.camera.focusdistance.value = 5;

% Default aperture diameter is 5
% thisR.camera.aperturediameter.value = 10;   

thisR.set('fov',45);
thisR.film.diagonal.value=  30;
thisR.film.diagonal.type = 'float';

thisR.integrator.subtype = 'path';  % bdpt
thisR.sampler.subtype = 'sobol';

piWrite(thisR,'creatematerials',true);

%% Render and display

oi = piRender(thisR);
oi = oiSet(oi,'name',sprintf('%s',oiName));
oiWindow(oi);
oi = oiSet(oi,'gamma',0.8);

%% END