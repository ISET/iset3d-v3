%% Calculations of scene properties and camera properties
%
% Maybe t_piSetRenderingParameters
%
%   1.  We show to calculate the distance to the scene from the current
%       camera position
%
%   2.  We show how to change a lens and set its position.
%
%   3.  We show how to set the film size correctly given a lens.
%
%   3.  We show how to adjust the focal distance from one object to another
%   

%% Load a test scene

thisR = piRecipeDefault('scene name','chessSet');
thisR.get('object distance')

%% Distance to objects in the scene

% Runs the docker container to estimate the depth from the current camera
% position to the objects in the scene.
dRange = thisR.get('depth range');
fprintf('Min %f Max %f Mean %f\n',dRange(1),dRange(2), mean(dRange));

%%  Render the scene and confirm the depth map range

piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);
scenePlot(scene,'depth map');

%% Add a lens. The depth map is the same 
%
% That's because we estimate the depth using the pinhole model, removing
% the lens.

lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
dRange = thisR.get('depth range');
fprintf('Min %f Max %f Mean %f\n',dRange(1),dRange(2), mean(dRange));

%% Now move the camera and recompute

% Usually, negative shifts in the z-axis means away from the elements of
% the scene
thisR = piCameraTranslate(thisR,'z shift',-2,'fromto','from');
dRange = thisR.get('depth range');
fprintf('Min %f Max %f Mean %f\n',dRange(1),dRange(2), mean(dRange));
thisR.get('object distance')

%%  When we compute the oi, the depth map is still OK.

piWrite(thisR);
oi = piRender(thisR);
oiWindow(oi);
dm = oiGet(oi,'depth map');
dRange = [min(dm(:)),max(dm(:))];
fprintf('Min %f Max %f Mean %f\n',dRange(1),dRange(2), mean(dRange));

%% Translate it back

% Negative shifts in the z-axis means away from the elements of
% the scene
thisR = piCameraTranslate(thisR,'z shift',2,'fromto','from');
thisR.get('object distance')

%%  How to adjust the film size

lensfile  = 'dgauss.22deg.3.0mm.json';    % 30 38 18 10
thisR.camera = piCameraCreate('omni','lensFile',lensfile);

% Distance to the in-focus object
objectDistance = thisR.get('object distance');

% Set the focal distance to the middle of the objects
thisR.set('focal distance',objectDistance);

% We need to change the film size
fov = 20;
filmDistance = thisR.get('film distance');  % meters

% The formula for the new film distance is this
%
% tan(fov) = filmDiag/filmDistance
% tand(fov/2) = filmDiag/2/filmDistance
% filmDiag = tand(fov/2)*filmDistance*2
%
% For realistic this would work
%   filmDiagonal = piCameraFilmSize(thisR,fov);
%
% Not sure about pinhole.
%
filmDiagonal = filmDistance*tand(fov/2)*2;    % mm
thisR.set('film diagonal',filmDiagonal*1e3);  % Set in millimeters

%% Show the effect of changing the focal distance

% Add many more rays so the focus sharpness is easier to see
thisR.set('rays per pixel',256);

piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);

%%  Set the focal closer to the Queen

thisR.set('focal distance',objectDistance/3);
piWrite(thisR);
oi = piRender(thisR,'render type','radiance');
oiWindow(oi);

%% END
