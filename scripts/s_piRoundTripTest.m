%% Store recipes as mat-files and json-files this way
%
% At this date only the mat-files always work.  There are still problems
% with the round-trip for the JSON files.  I will try to solve that.
%
% Saving the recipes after the piRead saves a lot of time for some scenes.
% Not all.  
%
% We save the test charts and small scenes in data/assets
% We save the recipes for the bigger scenes in their input directories.
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

%% A few more scenes as assets

assetDir = fullfile(piRootPath,'data','assets');

sceneName = 'bunny';
thisR = piRecipeDefault('scene name', sceneName);
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
disp(oFile)

sceneName = 'coordinate';
thisR = piRecipeDefault('scene name', sceneName);
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
disp(oFile)

thisR = piChartCreate('EIA');
thisR.save(fullfile(assetDir,'EIA.mat'));

thisR = piChartCreate('ringsrays');
thisR.save(fullfile(assetDir,'ringsrays.mat'));

thisR = piChartCreate('slanted bar');
thisR.save(fullfile(assetDir,'slantedbar.mat'));

thisR = piChartCreate('grid lines');
thisR.save(fullfile(assetDir,'gridlines.mat'));

thisR = piChartCreate('face');
thisR.save(fullfile(assetDir,'face.mat'));

thisR = piChartCreate('macbeth');
thisR.save(fullfile(assetDir,'macbeth.mat'));






%%

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

