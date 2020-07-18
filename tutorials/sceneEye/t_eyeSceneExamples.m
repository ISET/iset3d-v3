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
%{
thisR = piRecipeDefault('scene name','classroom'); c = piCameraCreate('pinhole');
thisR.set('camera',c);
%}

% Adjust the rendering and related parameters
thisR.set('rays per pixel',1024);
thisR.set('spatial samples',[512 512]);
piWrite(thisR);

% Renders radiance and depth (by default)
scene = piRender(thisR);

% Show the scene
sceneWindow(scene);
sceneSet(scene,'gamma',0.4);
scenePlot(scene,'depth map'); colormap(parula); colorbar;