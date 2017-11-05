% s_piReadRender
%
% Read a PBRT scene file, adjust the LookAt
%
% Path requirements
%    ISET or ISETBIO
%    pbrt2ISET  - 
%   
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

%% Modify the recipe, thisR, to adjust the rendering


%% Set up Docker 

% Docker will mount the volume specified by the working directory
workingDirectory = fullfile(piRootPath,'local');

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDirectory);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
oname = fullfile(workingDirectory,[n,e]);
piWrite(thisR, oname, 'overwrite', true);

%% Render with the Docker container

ieObject = piRender(oname);

% Show it in ISET
vcAddObject(ieObject); sceneWindow; sceneSet(ieObject,'gamma',0.5);     

%%