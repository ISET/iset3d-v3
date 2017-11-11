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
thisR.set('film resolution',256);
thisR.set('rays per pixel',128);

thisR.set('object distance',5000);
thisR.set('autofocus',true);

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

% tic
% scene = piRender(thisR);
% toc
% vcAddObject(oi); sceneWindow; sceneSet(scene,'gamma',0.5);   

tic
oi = piRender(thisR);
toc
vcAddObject(oi); oiWindow; oiSet(scene,'gamma',0.5);   
