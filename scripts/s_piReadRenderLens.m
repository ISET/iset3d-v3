%% s_piReadRenderLens
%
% Rendering takes longer through a lens as the size of the aperture grows.
% The pinhole case is always the fastest, of course.
%
% This rendering is set with a relatively small number of rays per pixel
% for speed.
%
% See also
%  s_piReadRender, s_piReadRenderLF
%
% BW SCIEN Team, 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
fname = fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Modify the recipe, thisR, to adjust the rendering

thisR.set('camera','realistic');
thisR.set('aperture',4);  % The number of rays should go up with the aperture 
thisR.set('film resolution',256);
thisR.set('rays per pixel',128);

% We need to move the camera far enough away so we get a decent focus.
objDist = thisR.get('object distance');
thisR.set('object distance',10*objDist);
thisR.set('autofocus',true);

%% Set up Docker 

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwrite', true);

%% Render the output file with the Docker container

oi = piRender(thisR,'meanilluminance',10,'renderType','both');

% Show it in ISET
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%%