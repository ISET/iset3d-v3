% s_piReadRender
%
% Read a PBRT scene file, adjust the LookAt
%
% Path requirements
%    ISET or ISETBIO
%    pbrt2ISET  - 
% 
%{
fname = fullfile(piRootPath,'data','bunny','bunny.pbrt');
%}
% AJ/TL/BW SCIEN

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

%% Set up Docker 

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
% oname should be thisR.outFile.  Then get rid of oname.
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwrite', true);

%% Render with the Docker container

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);     

%%  Reset and make a stereo image to the original

% First dimension is right-left
% Second dimension is towards the object.
% 
thisR = piRead(fname);
thisR.lookAt.from = thisR.lookAt.from + [1 0 0];
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwrite', true);

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);     

%% Point the camera a little higher

thisR = piRead(fname);
thisR.lookAt.to = [0 0 2];
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwrite', true);

ieObject = piRender(thisR);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);   

%%