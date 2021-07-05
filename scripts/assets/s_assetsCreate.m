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

thisR = piRecipeDefault('scene name','sphere');
thisR.save(fullfile(assetDir,'sphere.mat'));

%% END
