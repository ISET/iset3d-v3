%% Demonstrate how to estimate a PSF using "piCreateSimplePointScene."
%
% Here we approximate the PSF by rendering a very small circular disk at a
% certain distance away from the camera. The disk it completely white, so
% it should reflect the illumination of the scene. The illumination can be
% specified using 'illumination.'
%
% Another way to do this is to make an RGB image with a single pixel in the
% center, and to place this on a textured plane some distance from the
% camera using s_texturedPlane.

% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

workingFolder = fullfile(piRootPath,'local','psfEstimate');

%% Create a simple point scene

% Warning: If you change the illumination spectrum, you must put a copy of
% the .spd file into the working folder! The default illumination spectrum
% is D65.spd. 
recipe = piCreateSimplePointScene(...
    'pointDistance',3,...
    'pointDiameter',0.01,...
    'illumination','D65.spd',...
    'pbrtVersion',3);

%% Change image resolution

recipe.set('filmresolution',[256 256]);
recipe.set('pixelsamples',256);

%% Add a camera
% Currently we cannot (efficientally) render chromatic aberration for
% PBRTv3, so this will be monochromatic.

recipe.set('camera','omni');
recipe.set('lensfile',fullfile(piRootPath,'data','lens','dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal',10); 

recipe.set('focus distance',1);
recipe.set('aperture diameter',5);

%% Write and render

oiName = 'psfTest';
recipe.set('outputFile',fullfile(workingFolder,strcat(oiName,'.pbrt')));

piWrite(recipe);
[oi, results] = piRender(recipe);

vcAddAndSelectObject(oi);
oiWindow;

