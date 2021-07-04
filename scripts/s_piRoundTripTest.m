%% Store simple recipes as mat-files and json-files this way
%
% See also
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Make the chart, simple scene, and merge

[chartR, gName]  = piChartCreate('EIA');

oFile = fullfile(piRootPath,'data','assets','EIA.mat');
saved = chartR.save(oFile);

jsonFile = fullfile(piRootPath,'data','assets','EIA.json');
savedjson = chartR.savejson(jsonFile);

%%  Test mat-file round trip
load(oFile,'thisR');
piWRS(thisR);

%% Test json file round trip
thisR = piJson2Recipe(savedjson);
piWRS(thisR);

%%  Simple scene not working yet.

thisR = piRecipeDefault('scene name','simple scene');

oFile = fullfile(piRootPath,'data','assets','SimpleScene');
thisR.save(oFile);

jsonFile = fullfile(piRootPath,'data','assets','SimpleScene.json');
savedjson = thisR.savejson(jsonFile);

%% Mat file rendering of simple scene works
load(oFile,'thisR');
piWRS(thisR);

%% Test json file round trip
% This fails.

thisR = piJson2Recipe(savedjson);
scene = piWRS(thisR);

%% Debugging why the simple scene fails.
ieStructCompare(thisR,testR)

s1 = thisR.camera;
s2 = testR.camera;

ieStructCompare(testR.camera,thisR.camera)
isequal(testR.sampler,thisR.sampler)
isequal(testR.integrator,thisR.integrator)
isequal(testR.world,thisR.world)
isequal(testR.lookAt,thisR.lookAt)
isequal(testR.inputFile,thisR.inputFile)
isequal(testR.outputFile,thisR.outputFile)
isequal(testR.exporter,thisR.exporter)
isequal(testR.materials.lib,thisR.materials.lib)
isequal(testR.materials.inputFile_materials,thisR.materials.inputFile_materials)


isequal(testR,chartR)

