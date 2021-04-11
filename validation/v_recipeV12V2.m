%% Test the piJson2Recipe conversion
%
% This mainly tests converting from Version 1 to Version 2
%

%% Load a Version 1 json file for the SimpleScene and update to Version 2.


%% Replace the default recipe with this recipe

tmp = piRecipeDefault('scene name','SimpleScene');
piWrite(tmp);
[scene, result] = piRender(tmp,'render type','radiance');
sceneWindow(scene);

%% Adjust the other PBRT file locations

% The json file is stored in data/recipeV1 for validation purpose.
thisR = piJson2Recipe('SimpleScene.json');

thisR.set('input File',tmp.inputFile);
thisR.set('output File',tmp.outputFile);

%% Render

piWrite(thisR);
[assetList, missingAssets,...
    textureList, missingTextures,...
    lightList, missingLights] = piRenderValidate(thisR);

[scene, result]= piRender(thisR,'render type','radiance');
sceneWindow(scene);

%% END