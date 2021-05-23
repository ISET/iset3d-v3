%% t_cameraPosition
%
%  Adjust the camera position and rotation to show the MCC surface in 3D.
%
% The camera position and viewing direction is determined by the lookat
% structure, a term that is defined in the PBRT book.
%
% The lookat elements are
%
%   from - Where the camera is located in world coordinates
%   to   - A point in the direction the camera is pointed
%   up   - The upward pointing direction
%
% With this definition, you can move the 'to' location anywhere along the
% line between from and to.  The direction is to - from.  You can find the
% direction using
%
%    thisR.get('lookat direction')
%
%  For any positive value of k, you will have the same scene becauses these
%  all preserve the lookat direction.
%
%    thisR.set('to',thisR.get('from') + k*thisR.get('lookat direction') 
%
% See also:
%   t_camera*, tls_camera*
%   

%% Init a default recipe, but change the light
ieInit;
if ~piDockerExists, piDockerConfig; end

% This the MCC scene
thisR = piRecipeDefault;

% Delete the lights
thisR.set('light', 'delete', 'all');

% Add an equal energy distant light
lName = 'new dist light';
lightSpectrum = 'equalEnergy';
newDistLight = piLightCreate(lName,...
                            'type', 'distant',...
                            'spd', lightSpectrum,...
                            'cameracoordinate', true);
thisR.set('light', 'add', newDistLight);           

% Render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%% Translate the camera 5 meters back

% By default, translating the camera shifts both the 'from' and 'to'
% directions.  You can change this behavior using the 'fromto' flag.
thisR.get('lookat')
thisR = piCameraTranslate(thisR, 'z shift', -5);  % meters
thisR.get('lookat')

piWrite(thisR);
[scene,result] = piRender(thisR);
sceneWindow(scene);

%% Move back, slide to the right, rotate

thisR.get('lookat')
thisR = piCameraTranslate(thisR, ...
    'z shift', 3, ...
    'x shift', 2);  % meters

% The y-axis is up-down. We will turn the camera direction toward the
% center of the MCC.
% Rotating leaves the 'from' value unchanged, but rotates the lookat
% direction 
thisR = piCameraRotate(thisR, 'y rot', -20);  % deg (CCW)
thisR.get('lookat')

piWrite(thisR);
scene = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%% END