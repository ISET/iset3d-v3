%% Render a sanmiguel scene with pinhole optics
%
% NOTES:
%
% Timing on a Linux box with multiple cores (gray.stanford.edu).
%
%  Timing     film resol   rays per pixel
%     216 s     192          128
%     90  s     256          128 
%     40  m     512          384 
%
% The sanmiguel scene is fairly large, so we do not include it in the github
% repository.  To download it, you can use the RemoteDataToolbox
% <https://github.com/isetbio/RemoteDataToolbox.git>.  
%
% The commands to download from the RDT are
%
%{
 rdt = RdtClient('isetbio');               % Open the connection
 a = rdt.searchArtifacts('sanmiguel');     % Root name of the artifact

 % Where you put the file and how you set it up is your choice. 
 destinationFolder = fullfile(piRootPath,'local');
 rdt.readArtifact(a,'destinationFolder',destinationFolder);
 fnameZIP = fullfile(destinationFolder,'sanmiguel.zip'); 
 unzip(fnameZIP);

 %  Make the fname below consistent with what you did above.  Might be this.
 fname = fullfile(destinationFolder,'sanmiguel','sanmiguel.pbrt'); 
%}
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
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDirectory,[n,e]);

% TL: We could do this in piWrite using a flag something like
%
%   piWrite(thisR,'overwrite',true,'workingDir',workingDir)
%
% We find the directory containing the pbrt scene file from the thisR.inputFile
% and we copy the whole directory over to working directory and assign the
% outputFile name.
[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local',[n,e]);
piWrite(thisR);

%% Render with the Docker container

scene = piRender(thisR);

% Show it in ISET
vcAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);

%%
