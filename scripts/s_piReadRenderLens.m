%% s_piReadRenderLens
%
%
% See Temporary.m for a thisROrig that runs correctly.  Delete that when this
% runs correctly.
%
% BW SCIEN Team, 2017

%% Initialize ISET and docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene file

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the file and return a recipe
thisR = piRead(fname);

%% Edit the recipe, replacing camera with a lens-based camera

thisR.set('camera','realistic');

thisR.set('aperture',20);
thisR.set('film resolution',576);
thisR.set('rays per pixel',256);
opticsType = thisR.get('optics type');

% We need to move the camera far enough away so we get a decent focus.
objDist = thisR.get('object distance');
thisR.set('object distance',10*objDist);
thisR.set('autofocus',true);

% Good function needed to find the object distance
% focalDistance = thisR.get('focal distance');
% thisR.set('focal distance',focalDistance);

% For an object at 125 mm, the 2ElLens has a focus at 89 mm.  We should be able
% to look this up from stored data about each lens type.
%  thisR.camera.filmdistance.value = focalDistance;

% You can open and view the file this way
% edit(oname);

%% Write out the modified pbrt file

% This takes longer than the pinhole because, well, aperture

oname = fullfile(piRootPath,'local','lensTest.pbrt');

piWrite(thisR, oname,'overwrite',true);

% piWrite(thisROrig, oname,'overwrite',true);

%% Render and bring up the oi window

[oi, thisR.outputFile, result] = piRender(oname,'opticsType',opticsType);
vcAddObject(oi);
oiWindow;
oiSet(ieObject,'gamma',0.5);

%%
