%% Test a pbrtv3 scene with material property modified.


%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file

fname = fullfile(piRootPath,'local','carandbuilding','carandbuilding_materials.pbrt');
if ~exist(fname,'file'), error('File not found'); end
[thisR,txtLines] = piReadMaterial(fname,'version',3);
%% Call material lib

thisR.materiallib = piMateriallib;
%% list the property of materials 

pilistmaterial(thisR);
%% Convert all jpg textures to png format,only *.png&*.exr are supported in pbrt.

work_dir = fullfile(piRootPath,'local','carandbuilding');
checktextureformat(work_dir);

%% Assignmaterials
target = 'carpaintmix';
indexnum =16;
piAssignmaterial(thisR,indexnum,target)
pilistmaterial(thisR);

%% Write thisR to *_material.pbrt
oiName = 'carandbuilding';
thisR.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'_materials.pbrt')));
piWriteMaterial(thisR);
%%
% %% Render
% 
% oiName = 'simplecarscene';
% recipe.set('outputFile',fullfile(piRootPath,'local',strcat(oiName,'.pbrt')));
% 
% piWrite(recipe);
% [oi, result] = piRender(recipe);
% 
% vcAddObject(oi);
% oiWindow;
% 
% oi = oiSet(oi,'gamma',0.5);
