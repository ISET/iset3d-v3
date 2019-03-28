%% s_piReadRender
%
% DEPRECATED
%
% Read a PBRT scene file, interpret it, render it (with depth map).
% On a reasonable machine, this takes about 10 sec.
%
% Dependencies (see wiki pages for iset3d)
%    ISETCAM or ISETBIO
%    iset3d
%    Docker must be set up
%
% TL/BW SCIEN
%
% See also
%   piRead, piWrite, piRender

%
error('DEPRECATED')

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


%% Set up Docker directory

% Write out the pbrt scene file, based on thisR.  By def, to the working directory.
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','teapot',[n,e]));
piWrite(thisR);

%% Render locally with the pbrt Docker container

scene = piRender(thisR);

% Show it in ISET
ieAddObject(scene); sceneWindow; sceneSet(scene,'gamma',0.5);     

%%