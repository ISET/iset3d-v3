%%
ieInit;

%%
thisR = piRecipeDefault('scene name', 'MacBethChecker');

%%
thisRSS = piRecipeDefault('scene name', 'SimpleScene');
disp(thisRSS.assets.tostring)

%%
thisR = piRead(which('cornell_box_formal.pbrt'));