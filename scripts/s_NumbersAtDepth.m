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

thisR.set('camera','lens');   % Lens, not pinhole
thisR.set('aperture',6);      % Try varying for depth of field effects
thisR.set('film resolution',256);
thisR.set('rays per pixel',256);

thisR.set('object distance',300); % Could be much bigger
thisR.set('autofocus',true);      % Sets focal distances to 300

%% Set up Docker 

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',[n,e]));
piWrite(thisR);

%% Render with the Docker container

oi = piRender(thisR);
oi = oiSet(oi,'name','big aperture');
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%%
thisR.set('aperture',2);      % Try varying for depth of field effects
piWrite(thisR, 'overwritedir', true);
oi = piRender(thisR);
oi = oiSet(oi,'name','small aperture');
vcAddObject(oi); oiWindow; oiSet(oi,'gamma',0.5);   

%%