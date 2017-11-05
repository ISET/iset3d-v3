%% s_piReadRenderLens
%
% Rendering takes longer through a lens as the size of the aperture grows.
% The pinhole case is always the fastest, of course.
%
% See Temporary.m for a thisROrig that runs correctly.  Delete that when this
% runs correctly.
%
% See also
%  s_piReadRender, s_piReadRenderLF
%  
%
% BW SCIEN Team, 2017

%% Initialize ISET and docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene file

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

%% Edit the recipe, replacing camera with a lens-based camera

% Read the file and return a recipe
thisR = piRead(fname);

thisR.set('camera','realistic');
thisR.set('aperture',3);  % The number of rays should go up with the aperture 
thisR.set('film resolution',384);
thisR.set('rays per pixel',256);

% We need to move the camera far enough away so we get a decent focus.
objDist = thisR.get('object distance');
thisR.set('object distance',10*objDist);
thisR.set('autofocus',true);

%% Write out the modified pbrt file

oname = fullfile(piRootPath,'local','lensTest.pbrt');
piWrite(thisR, oname,'overwrite',true);

%% Render and bring up the oi window

[oi, thisR.outputFile, result] = piRender(oname);

vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);

%%
