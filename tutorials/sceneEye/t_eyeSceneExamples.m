%% t_piExampleScenes
%
% Some examples and the basics of ISET3d
%
% See also
%  v_iset3d


%% The basics of ISET3d

% Read a rendering recipe
% thisR = piRecipeDefault('scene name','living room');
% thisR = piRecipeDefault('scene name','kitchen');  % Very high dynamic range
% thisR = piRecipeDefault('scene name','yeahright');
% thisR = piRecipeDefault('scene name','plants dusk');  % Doesn't work
% thisR = piRecipeDefault('scene name','bathroom');
% thisR = piRecipeDefault('scene name','chess set scaled');
% thisR = piRecipeDefault('scene name','teapot full');
% thisR = piRecipeDefault('scene name','white room');
% % thisR = piRecipeDefault('scene name','living room 3');  % Not running.

%{
thisR = piRecipeDefault('scene name','classroom'); c = piCameraCreate('pinhole');
thisR.set('camera',c);
%}

%%
% Adjust the rendering and related parameters
thisR.set('rays per pixel',128);
thisR.set('spatial samples',[1024 1024]);
thisR.set('n bounces',5);

fromOrig = thisR.get('from');
toOrig   = thisR.get('to');
up       = thisR.get('up');
oDist    = thisR.get('object distance');

piWrite(thisR);

% Renders radiance and depth (by default)
scene = piRender(thisR,'render type','radiance');
sceneWindow(scene);


%%
thisR.set('fov',25);
thisR.set('rays per pixel',128);
thisR.set('from',fromOrig + -0.5*up);
thisR.set('to', toOrig    + -0.5*up);
thisR.set('object distance',2.2*oDist);
thisR.set('spatial samples',[768 768]);

%%
piWrite(thisR);
[scene, result] = piRender(thisR,'render type','radiance');

% Show the scene
sceneWindow(scene);
truesize
% sceneSet(scene,'gamma',0.4);
%%
scenePlot(scene,'depth map'); colorbar;

%%