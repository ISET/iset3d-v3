%% Render a sanmiguel scene with pinhole optics
%
% NOTES:
%
% Timing on a Linux box with multiple cores (gray.stanford.edu).
%
%  Timing     film resol   rays per pixel
%     216 s     192          128
%     285 s     256          128 
%     40  m     768          128 
%
% The sanmiguel scene is fairly large, so we do not include it in the github
% repository.  To download it, you can use the RemoteDataToolbox
% <https://github.com/isetbio/RemoteDataToolbox.git>.  
%
% The commands to download from the RDT are
%
%{
 if ~exist(fullfile(piRootPath,'data','sanmiguel'),'dir')
    piPBRTFetch('sanmiguel');
 end
 s_sanmiguel
%}
%
% BW SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

% Check that you have the sanmiguel data in the data directory.
if ~exist(fullfile(piRootPath,'data','sanmiguel'),'dir')
    piPBRTFetch('sanmiguel','pbrt version',2);
end

%% Specify the pbrt scene file and its dependencies

% We organize the pbrt files with its includes (textures, brdfs, spds, geometry)
% in a single directory. 
fname = fullfile(piRootPath,'data','sanmiguel','sanmiguel.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

%% Default is a relatively low resolution (256).

thisR.set('film resolution',768);
thisR.set('rays per pixel',1024);

%% Set up Docker 

[p,n,e] = fileparts(fname); 
thisR.outputFile = fullfile(piRootPath,'local','sanmiguel',[n,e]);
piWrite(thisR);

%% Render with the Docker container

scene = piRender(thisR);

% Show it in ISET
ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);

%%
