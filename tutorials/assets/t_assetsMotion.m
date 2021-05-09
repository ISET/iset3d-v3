%% Move an asset during the rendering to simulate motion
%
% We can translate the object or rotate the object.  Both are illustrated
% below.
%
% See also
%   t_piIntro_*

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt files for a simple scene

thisR = piRecipeDefault('scene name','SimpleScene');

% This is a low resolution for speed.
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

% Speed up by only returning radiance.
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%% Introduce asset (object) motion blur (not camera motion)

% Move this asset
thisAssetName = 'figure_3m_O';
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

% Make this work!!!
% thisR.get('asset',thisAssetName,'motion','translation')

% Render the motion blur
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);

%% Delete the motion translation

thisR.assets.show([],2);

thisR.set('asset',T1.name,'delete');

thisR.assets.show([],2);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Translation');
sceneWindow(scene);

%% Add some rotation to the motion

[~,R1] = thisR.set('asset', thisAssetName, 'motion', 'rotation', [0, 0, 30]);

piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene,'name','motionblur: Rotation');
sceneWindow(scene);

%% END







