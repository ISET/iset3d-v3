%% Render using a lens plus a microlens
%
% Set up to work with the Chess Set scene.
%
% Dependencies:
%    ISET3d, ISETCam, JSONio
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
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

chdir(fullfile(piRootPath,'local'))

%% Read the pbrt files

% sceneName = 'kitchen';     sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output directory will be written here to inFolder/sceneName
inFolder = fullfile(piRootPath,'local','scenes');

% This is the PBRT scene file inside the output directory
inFile = fullfile(inFolder,sceneName,sceneFileName);

if ~exist(inFile,'file')
    % Sometimes the user runs this many times and so they already have
    % the file.  We only fetch the file if it does not exist.
    fprintf('Downloading %s from RDT',sceneName);
    dest = piPBRTFetch(sceneName,'pbrtversion',3,...
        'destinationFolder',inFolder,...
        'delete zip',true);
end

thisR  = piRead(inFile);

% We will output the calculations to a temp directory.  
outFolder = fullfile(tempdir,sceneName);
outFile   = fullfile(outFolder,[sceneName,'.pbrt']);
thisR.set('outputFile',outFile);

%% Set output file

oiName = sceneName;
outFile = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
thisR.set('outputFile',outFile);
outputDir = fileparts(outFile);

%% Add camera with lens

% This little microlens is only 2 um high.  So, we scale it
microlensName = fullfile(piRootPath,'data','lens','microlens.json');
microlens     = lensC('filename',microlensName);
currentHeight = microlens.get('lens height');
desiredHeight = 0.012;   % millimeters
microlens.scale(desiredHeight/currentHeight);
microlens.name = sprintf('%s-scaled',microlens.name);
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f\n',...
    microlens.focalLength,microlens.get('lens height'));

% For the dgauss lenses 22deg is the half width of the field of view
imagingLensName = fullfile(piRootPath,'data','lens','dgauss.22deg.3.0mm.json');
imagingLens     = lensC('filename',imagingLensName);
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f\n',...
    imagingLens.focalLength,imagingLens.get('lens height'))

% Set up the microlens array and film size
% Choose an even number for nMicrolens.  This assures that the sensor and
% ip data have the right integer relationships.
pixelsPerMicrolens = 5;
nMicrolens = [512 512];   % Appears to work for rectangular case, too
pixelSize  = microlens.get('lens height')/pixelsPerMicrolens;   % mm
filmheight = nMicrolens(1)*pixelsPerMicrolens*pixelSize;
filmwidth  = nMicrolens(2)*pixelsPerMicrolens*pixelSize;
filmresolution = [filmheight, filmwidth]/pixelSize;

% Build the combined lens file
[combinedlens,cmd] = piCameraInsertMicrolens(microlens,imagingLens, ...
    'xdim',nMicrolens(1),  'ydim',nMicrolens(2),...
    'film width',filmwidth,'film height',filmheight);

%% Set up the lens+microlens

thisLens = combinedlens;
fprintf('Using lens: %s\n',thisLens);
thisR.camera = piCameraCreate('omni','lensFile',thisLens);

%{
% You might adjust the focus for different scenes.  Use piRender with
% the 'depth map' option to see how far away the scene objects are.
% There appears to be some difference between the depth map and the
% true focus.
  dMap = piRender(thisR,'render type','depth');
  ieNewGraphWin; imagesc(dMap); colormap(flipud(gray)); colorbar;
%}

% PBRT estimates the distance.  It is not perfectly aligned to the depth
% map, but it is close.
thisR.set('focus distance',0.6);

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters 
thisR.set('film diagonal',sqrt(filmwidth^2 + filmheight^2));

% Film resolution -
thisR.set('film resolution',filmresolution);

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default
thisR.set('rays per pixel',256);

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  

%% Render and display

% Change this for depth of field effects.
thisR.set('aperture diameter',6);   % thisR.summarize('all');
piWrite(thisR,'creatematerials',true);

[oi, result] = piRender(thisR,'render type','radiance');

% Parse the result for the lens to film distance and the in-focus
% distance in the scene.
[lensFilm, infocusDistance] = piRenderResult(result);

%%
oi = oiSet(oi,'name',sprintf('%s-%d',oiName,thisR.camera.aperturediameter.value));
oiWindow(oi);

%% Lightfield manipulations

rgb = oiGet(oi,'rgb');
LF = LFImage2buffer(rgb,nMicrolens(2),nMicrolens(1));
imgArray = LFbuffer2SubApertureViews(LF);
ieNewGraphWin; imagesc(imgArray);

%% Move the OI through the sensor to the IP and visualize

sensor = sensorCreate('light field',oi);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;

%% Image process ... should really use the whiteScene here

ip = ipCreate;
ip = ipCompute(ip,sensor);
ieAddObject(ip); ipWindow;

%%  Show the different views

lightfield = ip2lightfield(ip,'pinholes',nMicrolens,'colorspace','srgb');

% Click on window and press Escape to close
%
% LFDispVidCirc(lightfield.^(1/2.2));

%% Mouse around 

LFDispMousePan(lightfield.^(1/2.2))

%% Focus on a region

%{
outputImage = LFAutofocus(lightfield);
ieNewGraphWin;
imagescRGB(outputImage);
%}

%% The depth is not right any more

%{
 depth = piRender(thisR,'render type','depth');
 ieNewGraphWin;
 imagesc(depth);
%}


%% END