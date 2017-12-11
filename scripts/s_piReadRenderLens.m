%% s_piReadRenderLens
%
% Renders an optical image (oi) for the teapot-area-light scene through a lens.
% This rendering takes longer than a pinhole, and the duration increases with
% the aperture size.
%
% This rendering is set with a relatively small number of rays per pixel
% for speed.
%
%  Time (sec)     film res        n Rays        Aperture
%     9            256            128             2
%     2            256            128             3
%     2.4          256            256             3
%     18           256            256             2
%     25           256            256             5
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
thisR.set('aperture',2);  % The number of rays should go up with the aperture 
thisR.set('film resolution',128);
thisR.set('rays per pixel',96);

% We need to move the camera far enough away so we get a decent view.
objDist = thisR.get('object distance');
thisR.set('object distance',3.5*objDist);
thisR.set('autofocus',true);

%% Set up Docker directory

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','teapot',[n,e]));
piWrite(thisR);

%% Render the output file with the Docker container

oi = piRender(thisR,'meanilluminance',10,'renderType','both');

% Show it in ISET
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%%