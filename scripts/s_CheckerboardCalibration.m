%% Render a series of checkerboard images
% The checekboard plane is rotated and translated in order to generate a
% set of different images. These images can be used to calibrate the camera
% intrinstics and extrinsics. 
%
% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene

fname = fullfile(piRootPath,'data','texturedPlane','texturedPlane.pbrt');

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

% Setup working folder
workingDir = fullfile(piRootPath,'local','texturedPlane');
if(~isdir(workingDir))
    mkdir(workingDir);
end

%% Attach the checkerboard texture

imageName = 'checkerboard.exr';
imageFile = fullfile(piRootPath,'data','imageTextures',imageName);

% We copy the image texture into the working directory. 
copyfile(imageFile,workingDir);
thisR = piWorldFindAndReplace(thisR,'dummyTexture.exr',imageName);



