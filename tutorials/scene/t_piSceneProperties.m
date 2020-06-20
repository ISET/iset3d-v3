%% Calculations of scene properties, like depth
%
% We also show to set the film distance given the depth in the scene.  And
% to change the aperture to vary the depth of field
%


%% Load a test scene

thisR = piRecipeDefault('scene name','chessSet');

%% Distance to objects in the scene

dRange = thisR.get('depth range');
disp(dRange);

%%
piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);

%% If we add a lens, the depth map should be the same
lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
dRange = thisR.get('depth range');
disp(dRange);

%%  PBRT gets the depth map correctly also

piWrite(thisR);
oi = piRender(thisR);
oiWindow(oi);

%% Now move the camera and recompute

% Usually, negative shifts in the z-axis means away from the elements of
% the scene
thisR = piCameraTranslate(thisR,'z shift',-2);
dRange = thisR.get('depth range');
disp(dRange);

%%
piWrite(thisR);
oi = piRender(thisR);
oiWindow(oi);
dm = oiGet(oi,'depth map');
min(dm(:)),max(dm(:))


%% Translate it back
% Usually, negative shifts in the z-axis means away from the elements of
% the scene
thisR = piCameraTranslate(thisR,'z shift',2);

%%  When we change the lens, we check the new film size
lensfile  = 'dgauss.22deg.3.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Distance to the in-focus object
dRange = thisR.get('depth range');
thisR.set('focal distance',mean(depthRange));

% We need to change the film size
fov = 20;
filmDistance = thisR.get('film distance');  % meters

% tan(fov) = filmDiag/filmDistance
% tand(fov/2) = filmDiag/2/filmDistance
% filmDiag = tand(fov/2)*filmDistance*2
%
filmDiagonal = filmDistance*tand(fov/2)*2;    % mm
thisR.set('film diagonal',filmDiagonal*1e3);  % Set in meters

%%
piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);


%% END
