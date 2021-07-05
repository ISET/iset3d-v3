%% Test round trip for assets

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