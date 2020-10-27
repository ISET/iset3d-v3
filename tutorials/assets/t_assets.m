%%
ieInit;

%% Test the simplest case for mcc
thisR = piRecipeDefault('scene name', 'MacBethChecker');

%% Test simple scene
thisRSS = piRecipeDefault('scene name', 'SimpleScene');
disp(thisRSS.assets.tostring)

%%
thisRCB = piRead(which('cornell_box_formal.pbrt'));
disp(thisRCB.assets.tostring);

%%