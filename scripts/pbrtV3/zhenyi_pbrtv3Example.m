%% Test a pbrtv3 scene.


%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

% Replace this with your own path. You can find the living room scene here:
% https://benedikt-bitterli.me/resources/
% or the direct link here:
% https://benedikt-bitterli.me/resources/pbrt-v3/living-room-2.zip

% WARNING: You will have to "clean up" the pbrt file before running, or
% else the parser will not read it correctly. Soon we will put up a cleaned
% up version of this scene somewhere, but right now it's too big. 
fname = fullfile(piRootPath,'data','carandbuilding','carandbuilding_materials.pbrt');
if ~exist(fname,'file'), error('File not found'); end
[materialR,txtLines] = piReadMaterial(fname,'version',3);
%% Convert all jpg textures to png format.

checktextureformat(work_dir)

%% Call material lib
[materiallib]=piMateriallib;



%% Render

oiName = 'simplecarscene';
recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));

piWrite(recipe);
[oi, result] = piRender(recipe);

vcAddObject(oi);
oiWindow;

oi = oiSet(oi,'gamma',0.5);
