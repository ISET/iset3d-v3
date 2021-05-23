%% Move an asset during the rendering to simulate motion
%
%  We can translate or rotate the object during the rendering.  Both are
%  illustrated.
%
% See also
%   t_piIntro_*

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files for a simple scene

thisR = piRecipeDefault('scene name','SimpleScene');

% This is low resolution and only radiance for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');
drawnow;

%% Introduce asset (object) motion blur (not camera motion)

% Move this asset
thisAssetName = '001_figure_3m_O';
fprintf('Translating asset : %s\n',thisAssetName);
assetPos = thisR.get('asset', thisAssetName, 'world position');

% Position is represented as a three vector x,y,z; 
%  x represents horizontal position
%  y represents vertical position
%  z represents depth. 
fprintf('Object position: \n    x: %.1f, y: %0.1f, depth: %.1f \n',...
            assetPos(1), assetPos(2), assetPos(3));

% To add a motion blur we define the shutter exposure duration to the
% camera. This simulates how long the shutter is open (seconds).
thisR.set('camera exposure', 0.5);

% This sets the motion translation.  Make it return the T1!!!
[~,T1] = thisR.set('asset', thisAssetName, 'motion', 'translation', [0.1, 0.1, 0]);

% Render the motion blur
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);

%% Delete the motion translation

% We illustrate the change in the asset three before and after deleting the
% branch
thisR.assets.show([],2);
thisR.set('asset',T1.name,'delete');
thisR.assets.show([],2);

% This illustrates that we have deleted the translation correctly.
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);

%% Add a rotation to the motion

[~,R1] = thisR.set('asset', thisAssetName, 'motion', 'rotation', [0, 0, 30]);

% Show that it worked
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Rotation');
sceneWindow(scene);

%% END







