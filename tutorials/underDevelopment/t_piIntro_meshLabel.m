%% t_piIntro_meshLabel
%
% Some scenes can be labeled by mesh identity, but not others.  For
% example, the Chess Set does not get the labels. This has to do with the
% way the assets were created.  With Cinema 4D or scenes we built
% ourselves,  we get the labels.  With scenes from the wild, not usually.
%
% Zheng, Brian, 2019
%
% See also
%  t_piIntro*
%

%%

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt file

thisR = piRecipeDefault('scene name','SimpleScene');

%% Set render quality by adjusting the multipler

% Set resolution for speed or quality.
thisR.set('spatial samples',round([600 600]*0.25));  % 2 is high res. 0.25 for speed
thisR.set('rays per pixel',16);                      % 128 for high quality

%% Write and render.  

% Some day we might just put the piWrite inside of piRender.

piWrite(thisR);

scene = piRender(thisR, 'render type', 'radiance');

sceneWindow(scene);
sceneSet(scene,'gamma',0.7);

%% Show the mesh of information

meshMap = piRender(thisR, 'render type', 'mesh');
ieNewGraphWin; 
imagesc(meshMap)

%% END