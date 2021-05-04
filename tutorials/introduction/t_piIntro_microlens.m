%% Render using a lightfield camera - lens and microlens array
%
%   Set up to work with the Chess Set scene.
%
% Dependencies:
%    ISET3d, ISETCam, JSONio, isetlens
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% This script uses the docker container in two ways.  Once to build the
% lens file and a second way to render radiance and depth. 
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_*

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piCamBio
    warning('Script requires ISETCam.  Returning');
    return;
end
if isempty(which('lensC')) 
    error('You must add the isetlens repository to your path'); 
end

if ~piCamBio, error('Requires ISETCam, not ISETBio'); end

% Run this from the local directorys
chdir(fullfile(piRootPath,'local'))

%% Read the pbrt files
testScenes = {'chessSet','livingroom','kitchen'};
thisR = piRecipeDefault('scene name',testScenes{1}); 

%% Read in the microlens and set its size
%
% This is a simple microlens file.
microlens     = lensC('filename','microlens.json');

% Adjust its size to 12 microns using the adjustSize method of the lensC
% class.
desiredHeight = 0.012;                       % mm
microlens.adjustSize(desiredHeight);
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f (mm)F-number %.3f\n',...
    microlens.focalLength,microlens.get('lens height'), microlens.focalLength/microlens.get('lens height'));

%% Choose the imaging lens 

% For the double gauss lenses 22deg is the half width of the field of view.
% This focal length produces a decent part of the central scene.
imagingLens     = lensC('filename','dgauss.22deg.12.5mm.json');

fprintf('Focal length =  %.3f (mm)\nHeight = %.3f\n',...
    imagingLens.focalLength,imagingLens.get('lens height'))

%% Set up the microlens array and film size

% The nMicrolens is the number of image samples in the reconstructed
% images. 

% Always choose an even number for nMicrolens.  This assures that the
% sensor and ip data have the right integer relationships. 
nMicrolens = [40 40]*8;   % Appears to work for rectangular case, too

% The sensor size (film size) should be big enough to support all of the
% microlenses
filmheight = nMicrolens(1)*microlens.get('lens height');
filmwidth  = nMicrolens(2)*microlens.get('lens height');

% Set the number of pixels behind each microlens.  This determines the size
% of the pixel.
pixelsPerMicrolens = 7;  % The 2D array of pixels is this number squared
pixelSize  = microlens.get('lens height')/pixelsPerMicrolens;   % mm
filmresolution = [filmheight, filmwidth]/pixelSize;

%% Build the lens file using the docker lenstool

% The combined lens includes the imaging lens and the microlens array.
[combinedlens,cmd] = piCameraInsertMicrolens(microlens,imagingLens, ...
    'xdim',nMicrolens(1),  'ydim',nMicrolens(2),...
    'film width',filmwidth,'film height',filmheight);

%% Create the camera with the lens+microlens

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
% map, but it is close.  For the Chess Set we use about 0.6 meters as the
% plane that will be in focus for this imaging lens.  With the lightfield
% camera we can reset the focus, of course.s
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
 thisR.set('from',from);          % Get higher and back away than default
 thisR.set('to',  to);            % Look down default compared to default
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
thisR.set('aperture diameter',6);   % In millimeters

thisR.summarize('all');

%% Render and display

% Change this for depth of field effects.
piWrite(thisR);

[oi, result] = piRender(thisR,'render type','radiance');

% Parse the result for the lens to film distance and the in-focus
% distance in the scene.  The lensFilm is the separation between the film
% and the microlens, which is the effective back of this lens (imaging lens
% plus microlens).  The infocusDistance is the distance in the scene that
% is rendered in good focus by the optics.
%
%  [lensFilm, infocusDistance] = piRenderResult(result);
%

% Name and show the OI

oiName = sprintf('%s-%d',thisR.get('input basename'),thisR.get('aperture diameter'));
oi = oiSet(oi,'name',oiName);
oiWindow(oi);

%% Lightfield manipulations

% Pull out the oi samples
rgb = oiGet(oi,'rgb');

% Convert these to the lightfield format used by the LF library.
LF = LFImage2buffer(rgb,nMicrolens(2),nMicrolens(1));

% Pull out the corresponding samples from the samples behind the pixel and
% show them as separate images
[imgArray, imgCorners] = LFbuffer2SubApertureViews(LF);

%{
imSize = size(LF,[1 2]);
thisCorner = imgCorners(3,3,:);
r = thisCorner(1):(thisCorner(1)+imSize(1));
c = thisCorner(2):(thisCorner(2)+imSize(2));
thisImg = imgArray(r,c,:);
ieNewGraphWin; imagesc(thisImg); axis image;
%}
% Notice how the pixelsPerMicrolens x pixelsPerMicrolens images are looking
% through the imaging lens from slightly different points of view.  Also,
% notice how we lose photons at the corner samples.
ieNewGraphWin; imagesc(imgArray); axis image;  

%% Convert the OI through a matched sensor 

% We create a sensor that has each pixel equal to one sample in the OI 
sensor = sensorCreate('light field',oi);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Image process ... should really use the whiteScene here

ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%%  Convert the image processed data into a light field representation

% The lightfield variable has the dimensions
%
%  pixelsPerMicrolens x pixelsPerMicrolens x nMicrolens x nMicrolens x 3
%
lightfield = ip2lightfield(ip,'pinholes',nMicrolens,'colorspace','srgb');

% Click on window and press Escape to close
%
% LFDispVidCirc(lightfield.^(1/2.2));

%% Mouse around 

% You can use your mouse to visualize this way
%  LFDispMousePan(lightfield.^(1/2.2))

% This shows up as a movie that cycles through the different images
%
% Click on window to select and then press Escape to close the window
%
LFDispVidCirc(lightfield.^(1/2.2))
%% Focus on a region

%{
outputImage = LFAutofocus(lightfield);
ieNewGraphWin;
imagescRGB(outputImage);
%}


%% END