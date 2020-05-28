%% Render using a lens
%
% Dependencies:
%    ISET3d, ISETCam, isetlens, JSONio
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% For more information about PBRT lens and camera formats:
%
% Generally
%   https://www.pbrt.org/fileformat-v3.html#overview
% 
% And specifically
%   https://www.pbrt.org/fileformat-v3.html#cameras
%
% Z Liu, BW 2018
%
% See also
%   t_piIntro_start, isetlens, 
%

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end

%% Read the pbrt files

%{
% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

inFolder = fullfile(piRootPath,'local','scenes');
inFile = fullfile(inFolder,sceneName,sceneFileName);
if ~exist(inFile,'file')
    % Sometimes the user runs this many times and so they already have
    % the file.  We only fetch the file if it does not exist.
    fprintf('Downloading %s from RDT',sceneName);
    dest = piPBRTFetch(sceneName,'pbrtversion',3,...
        'destinationFolder',inFolder,...
        'delete zip',true);
end

% This is the PBRT scene file inside the output directory

thisR  = piRead(inFile);
%}

thisR = piRecipeDefault;

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([600 600]*0.25));  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',64);                      % 128 for high quality

%% Set output file

oiName    = sceneName;
outFile   = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
outputDir = fileparts(outFile);
thisR.set('outputFile',outFile);

%% To determine the range of object depths in the scene

% [depthRange, depthHist] = piSceneDepth(thisR);
% histogram(depthHist(:)); xlabel('Depth (m)'); grid on
depthRange = [0.1674, 3.3153];  % Chess set distances in meters

%% Add camera with lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Set the focus into the middle of the depth range of the objects in the
% scene.
% d = lensFocus(lensfile,mean(depthRange));   % Millimeters
% thisR.set('film distance',d);
thisR.set('focal distance',mean(depthRange));

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters (default 22)
thisR.set('film diagonal',66);

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default 

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype    = 'sobol';

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

%% Render and display

% Change this for depth of field effects.
thisR.set('aperture diameter',2);   % thisR.summarize('all');
piWrite(thisR,'creatematerials',true);

oi = piRender(thisR,'render type','radiance');
oi = oiSet(oi,'name',sprintf('%s-%d',oiName,thisR.camera.aperturediameter.value));
oiWindow(oi);

%%
%{
%%
depth = piRender(thisR,'render type','depth');
ieNewGraphWin;
imagesc(depth);

%% Change this for depth of field effects.

thisR.set('aperture diameter',3);
piWrite(thisR,'creatematerials',true);

[oi,result] = piRender(thisR,'render type','both');
oi = oiSet(oi,'name',sprintf('%s-%d',oiName,thisR.camera.aperturediameter.value));
oiWindow(oi);

%% Change again for depth of field effects.

thisR.set('aperture diameter',1);
piWrite(thisR,'creatematerials',true);

oi = piRender(thisR,'render type','both');
oi = oiSet(oi,'name',sprintf('%s-%d',oiName,thisR.camera.aperturediameter.value));
oiWindow(oi);
%}
%% END