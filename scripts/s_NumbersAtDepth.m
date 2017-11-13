%% Render the sanmiguel scene with pinhole optics
%
% BW SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
% fname = '/home/wandell/pbrt-v2-spectral/pbrtScenes/sanmiguel/sanmiguel.pbrt';
fname = fullfile(piRootPath,'data','NumbersAtDepth','numbersAtDepth.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% The file has RealisticEye, but we use the default lens

% thisR.set('camera','pinhole');
% thisR.set('film resolution',256);
% thisR.set('rays per pixel',128);
% thisR.set('object distance',5000);

thisR.set('camera','lens');
thisR.set('film resolution',128);
thisR.set('rays per pixel',128);

thisR.set('object distance',300);
thisR.set('autofocus',true);

%% Set up Docker 

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

[p,n,e] = fileparts(fname); 

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);
piWrite(thisR, 'overwritedir', true);

%% Render with the Docker container

tic
oi = piRender(thisR);
toc
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   
