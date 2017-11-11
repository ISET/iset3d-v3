%% Render a sanmiguel scene with pinhole optics
%
% NOTES:
%
% Timing on a Linux box with multiple cores (gray.stanford.edu).
%
%  Timing     film resolution     rays per pixe.
%     90 sec    256 resolution     128 
%     40 min    512 resolution     384 
%
% PROGRAMMING TODO
%  We should place the sanmiguel scene up on the RdtClient server for most
%  people, and here we should include instructions about how to download it.
%
% BW SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
% fname = '/home/wandell/pbrt-v2-spectral/pbrtScenes/sanmiguel/sanmiguel.pbrt';
fname = fullfile(piRootPath,'data','sanmiguel','sanmiguel.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%%
thisR.set('film resolution',256);
thisR.set('rays per pixel',128);
% thisR.set('autofocus',true);

%% Set up Docker 

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
% Note from Trisha: We can do this in piWrite using the flag
% "copyDir", so something like:
% piWrite(thisR,oname,'overwrite',true,'copyDir',p) 
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwrite', true);

%% Render with the Docker container

tic
scene = piRender(thisR);
toc

% Show it in ISET
vcAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);

%%
