%% To speed up loading we pre-compute the recipes for certain scenes.
%
% This approach seems to work with mat-files, but it does not yet work for
% all JSON file round trips.  In time we will try to figure out what is
% missing, using piJSON2Recipe
%
% We save these recipes in the original folder with a scene-recipe.mat file
% name.

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Simple scene

thisR = piRecipeDefault('scene name','simple scene');
oFile = thisR.save; disp(oFile)

%% Mat file rendering of simple scene works
%{
load(oFile,'thisR');
piWRS(thisR);
%}

%% Create ChessSetPieces-recipe that has assets included

% Because it is a large scene, we save it in the input folder.  This takes
% a long time to load this way.  But it is pretty quick if we just load the
% recipe, below.
thisR = piRecipeDefault('scene name','chess set pieces');
oDir = thisR.get('input dir');
oFile = thisR.save(fullfile(oDir,'ChessSetPieces-recipe.mat')); 

%{
% Much faster
 load(oFile,'thisR');
 piWRS(thisR);
%}

%% ChessSet with no assets.  Still renders.

thisR = piRecipeDefault('scene name','chess set');
oDir = thisR.get('input dir');
oFile = thisR.save(fullfile(oDir,'ChessSet-recipe.mat')); 

%{
 load(oFile,'thisR');
 piWRS(thisR);
%}

%% END

% Test translate with the ruler.
thisR.set('assets','001_mesh_00072_O','world translate',-[0.01 0.02 0]);
thisR.set('assets','001_mesh_00073_O','world translate',-[0.01 0.02 0]);

%% This is slow!!!  And it doesn't work.

% See the code below where I started debugging the JSON round trips.

%{
savedjson = thisR.savejson(oFile);
thisR = piJson2Recipe(savedjson);   % Very slow
piWRS(thisR);
%}


%% Test json file round trip
% This fails.

%{
jsonFile = fullfile(piRootPath,'data','assets','SimpleScene.json');
savedjson = thisR.savejson(jsonFile);
thisR = piJson2Recipe(savedjson);
scene = piWRS(thisR);
%}


%% This is slow!!!  And it doesn't work.

%{
savedjson = thisR.savejson(oFile);
thisR = piJson2Recipe(savedjson);   % Very slow
piWRS(thisR);
%}

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

%% END