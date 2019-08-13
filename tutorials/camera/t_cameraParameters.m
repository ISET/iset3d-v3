%% Object distance and focal distance illustration
%
% Loads up a scene and illustrates the effect of changing different
% camera parameters in the recipe
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

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([600 600]*0.25));  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',16);                      % 128 for high quality

%% Set output file

oiName    = sceneName;
outFile   = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
outputDir = fileparts(outFile);
thisR.set('outputFile',outFile);

%% Create a camera with lens

% lensFiles = lensList;
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

thisR.set('film diagonal',11);

%% Set the focus plane

% Here are some critical parameters
objDistance = 1.5;
thisR.set('object distance',objDistance);   % In meters

objDistance = thisR.get('object distance')   % In meters
thisR.get('focal distance')

thisR.get('from')

%%
% For this object distance, what are the scene depths (m)
[depthRange, depthmap]= piSceneDepth(thisR);
ieNewGraphWin; imagesc(depthmap);

thisR.camera
disp(depthRange)

%% Now adjust the object distance and recalculate the scene depths
thisR.set('object distance',objDistance + 3);   % In meters
thisR.get('object distance')   % In meters
thisR.get('from')

[depthRange, depthmap] = piSceneDepth(thisR);
disp(depthRange)

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters (default 22)

histogram(depthHist(:)); xlabel('Depth (m)'); grid on

% Setting the position of the camera from the 'to' position in object
% space.
thisR.get('object distance')

thisR.set('object distance',0.5)
[depthRange, depthHist] = piSceneDepth(thisR);
histogram(depthHist(:)); xlabel('Depth (m)'); grid on



depthRange = [0.1674, 3.3153];  % Chess set distances in meters

%%

[depthmap, result]   = piRender(thisR, 'render type','depth');
lensFocus(thisR.get('lens file'),10*1e+3)
