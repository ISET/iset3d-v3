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
% Last tested by BW, May 31, 2020
%
% See also
%   t_piIntro_*
%   isetLens repository

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
chdir(fullfile(piRootPath,'local'))

%% Read the pbrt files

% thisR = piRecipeDefault('scene name','living-room');
% thisR = piRecipeDefault('scene name','kitchen');
% {
 thisR = piRecipeDefault('scene name','chessSet'); 
 % from = [0.0000    0.0700   -0.7000];
 % to = [ 0.0000    0.0700    0.5000];
%}

%{
 thisR = piRecipeDefault('scene name','SimpleScene'); 
 to = [0    0.5000  -14.0000]; 
 from = [0    0.5000  -15.0000];
%}

%{
% Macbeth case
thisR  = piRecipeDefault; z = -2.7;
%}

%% Create the microlens

% Set the microlens size to 12 microns using the
% microlens.scale method.
microlens     = lensC('filename','microlens.json');
desiredHeight = 0.012;                       % mm
microlens.adjustSize(desiredHeight);
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f (mm)F-number %.3f\n',...
    microlens.focalLength,microlens.get('lens height'), microlens.focalLength/microlens.get('lens height'));

%% Choose the imaging lens 

% For the dgauss lenses 22deg is the half width of the field of view
imagingLens     = lensC('filename','dgauss.22deg.3.0mm.json');
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f\n',...
    imagingLens.focalLength,imagingLens.get('lens height'))

%% Set up the microlens array and film size

% Choose an even number for nMicrolens.  
% This assures that the sensor and ip data have the right integer
% relationships. 
nMicrolens = [40 40]*4;   % Appears to work for rectangular case, too

% 
filmheight = nMicrolens(1)*microlens.get('lens height');
filmwidth  = nMicrolens(2)*microlens.get('lens height');

% 5x5 array beneath each microlens
pixelsPerMicrolens = 3;
pixelSize  = microlens.get('lens height')/pixelsPerMicrolens;   % mm
filmresolution = [filmheight, filmwidth]/pixelSize;

%% Build the combined lens file using the docker lenstool

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

%{
% Chess set case
% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',from);     % Get higher and back away than default
thisR.set('to',  to);  % Look down default compared to default
thisR.set('rays per pixel',32);  % 32 is small
%}
%{
% Simple scene
thisR.set('from',from);     % Get higher and back away than default
thisR.set('to',  to);       % Look down default compared to default
thisR.set('rays per pixel',128);
%}

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  

% This is the aperture of the imaging lens of the camera in mm
thisR.set('aperture diameter',6);   

% thisR.summarize('all');

%% Render and display

% Change this for depth of field effects.
piWrite(thisR,'creatematerials',true);

[oi, result] = piRender(thisR,'render type','radiance');

% Parse the result for the lens to film distance and the in-focus
% distance in the scene.
[lensFilm, infocusDistance] = piRenderResult(result);

%% Name and show the OI

oi = oiSet(oi,'name',...
    sprintf('%s-%d',thisR.get('input basename'),thisR.get('aperture diameter')));
oiWindow(oi);
truesize

%% Lightfield manipulations

rgb = oiGet(oi,'rgb');
LF = LFImage2buffer(rgb,nMicrolens(2),nMicrolens(1));
imgArray = LFbuffer2SubApertureViews(LF);
ieNewGraphWin; imagesc(imgArray); axis image

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

% LFDispMousePan(lightfield.^(1/2.2))
LFDispVidCirc(lightfield.^(1/2.2))
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