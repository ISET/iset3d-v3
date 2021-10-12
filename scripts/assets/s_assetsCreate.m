%% Store small recipes as mat-files in the data assets directory
%
% We include these assets as little test objects in other scenes
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
%   s_scenesRecipe
%

%% Init

ieInit;
if ~piDockerExists, piDockerConfig; end

assetDir = fullfile(piRootPath,'data','assets');

%% A few more scenes as assets
sceneName = 'bunny';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('from',[0 0 0]);
thisR.set('to',[0 0 1]);
thisR.set('asset', 'Bunny_B', 'world position', [0 0 1]);
mergeNode = 'Bunny_B';
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
save(oFile,'mergeNode','-append');

%%  Coordinate axes at 000

sceneName = 'coordinate';
thisR = piRecipeDefault('scene name', sceneName);
mergeNode = 'Coordinate_B';
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
save(oFile,'mergeNode','-append');

%% We need a light to see it.
%
% Camera at 000 to 001 sphere at 001
%
sceneName = 'sphere';
thisR = piRecipeDefault('scene name', sceneName);
thisR.set('asset','Camera_B','delete');
thisR.set('asset',2,'delete');
piAssetSet(thisR, 'Sphere_B','translate',[0 0 1]);
thisR.set('from',[0 0 0]);
thisR.set('to',[0 0 1]);
mergeNode = 'Sphere_B';
oFile = thisR.save(fullfile(assetDir,[sceneName,'.mat']));
save(oFile,'mergeNode','-append');

%% Test charts

% The merge node is used for
%
%   piRecipeMerge(thisR,chartR,'node name',mergeNode);
%

[thisR, mergeNode] = piChartCreate('EIA');
oFile = thisR.save(fullfile(assetDir,'EIA.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode]= piChartCreate('ringsrays');
oFile = thisR.save(fullfile(assetDir,'ringsrays.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode] = piChartCreate('slanted bar');
oFile = thisR.save(fullfile(assetDir,'slantedbar.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode] = piChartCreate('grid lines');
oFile = thisR.save(fullfile(assetDir,'gridlines.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode] = piChartCreate('face');
oFile = thisR.save(fullfile(assetDir,'face.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode] = piChartCreate('macbeth');
oFile = thisR.save(fullfile(assetDir,'macbeth.mat'));
save(oFile,'mergeNode','-append');

[thisR, mergeNode] = piChartCreate('pointarray_512_64');
oFile = thisR.save(fullfile(assetDir,'pointarray512.mat'));
save(oFile,'mergeNode','-append');


%% END
