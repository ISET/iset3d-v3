% s_piReadRender
%
% Read a PBRT scene file (teapot-area), make three versions, adjusting  the
% LookAt directions.  First the original.  Then make a stereo version pair.
% Another points the camera at a different direction. 
%
% This is done with pinhole optics for speed, but could be done with a lens
% camera.
%
% See also:  s_piReadRenderLens
%
% AJ/TL/BW SCIEN Stanford, 2017

%% Set up ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory.
fname = fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

% Save the original lookAt.  We will write over it below.
lookAt = thisR.get('lookAt');

%% Set up Docker working directory and file

[~,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local','chess',[n,e]);
piWrite(thisR);

%% Render with the Docker container

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);     

%%  Make an image with a camera positioned adjacent to the original

% First dimension is right-left
% Second dimension is towards the object.
% The up direction is specified in lookAt.up
thisR.set('from',lookAt.from + [1 0 0]);
piWrite(thisR);

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);     

%% Point the camera a little higher

thisR.set('to',[0 0 2]);
piWrite(thisR);

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);   

%%