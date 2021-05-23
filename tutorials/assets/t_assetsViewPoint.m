%% Change the viewing direction and position
%
%   Put the camera at the position of different objects in the scene, and
%   we look at other objects.  In the first case, from the blue guy to the
%   yellow guy and then from the yellow guy to the blue guy (Simple Scene).
%
%   Also shows how to position the camera along the direction between two
%   objects (red sphere and blue guy).
%
%   Note that you cannot put the 'from' at exactly the same position as an
%   object.  If you do, the camera will be in the middle of it and cannot
%   see through it. You can put the camera adjacent to the object.
%
%   See also
%    t_assets*

%% Initialize 

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Show the base scene

thisR = piRecipeDefault('scene name', 'Simple Scene');

thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
drawnow;

%%  Move the blue asset to the left and look at it

assetName = '001_figure_3m_O';
[~,T1] = thisR.set('asset', assetName, 'translation', [-0.5 0 0]);
bluePos = thisR.get('asset', assetName, 'world position');

% Look at the blue guy
thisR.set('to', bluePos);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%  Look from the yellow guy to the blue guy

% We are still looking at the blue guy (from behind)
yellowAssetName = '001_figure_6m_O';
yellowPos = thisR.get('asset', yellowAssetName, 'world position');

% Just outside of the yellow guy's position
thisR.set('from', yellowPos + [0 0 -0.2]);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Now from the blue guy to the yellow guy

% Not inside the blue guy.  Just outside the blue guy's position
thisR.set('from', bluePos + [0 0 0.1]);
thisR.set('to', yellowPos);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%% Finally, from the direction of red sphere towards the blue guy

sphereAssetName = '001_Sphere_O';
spherePos = thisR.get('asset', sphereAssetName, 'world position');

% Start at the sphere and change the from in the direction of the blue guy
thisR.set('from', spherePos + 0.7*(bluePos - spherePos));
thisR.set('to', bluePos);

piWrite(thisR)
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');

%%  END


