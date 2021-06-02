%% Rendering of an MCC planar surface
%
%   We change the camera position and rotation to show the MCC surface in
%   3D.
%
% t_piIntro_cameraposition
%
% Zheng Lyu, 2020
%
% See also:
%   t_piIntro_cameracal, t_piIntro_cameramotion
%   

%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Init a default recipe 

% This the MCC scene
thisR = piRecipeDefault;

%% Delete all the lights
thisR = piLightDelete(thisR, 'all');

%% Add one equal energy light
thisR.set('light', 'delete', 'all');

% Add an equal energy distant light
lName = 'new dist light';
lightSpectrum = 'equalEnergy';

newDistLight = piLightCreate(lName,...
                            'type', 'distant',...
                            'spd', lightSpectrum,...
                            'cameracoordinate', true);
thisR.set('light', 'add', newDistLight);           

%% Used for scene
piWrite(thisR);
scene = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%% Translate the camera away by 5 meters

thisR = piCameraTranslate(thisR, ...
    'z shift', -5);  % meters

%% Write the recipe
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%%  
%{
thisR = piCameraTranslate(thisR, ...
    'x shift',  1.0,...
    'y shift',  0.5,...
    'z shift', -0.5);  % meters
%}

% Move it back and then slide it to the right
thisR = piCameraTranslate(thisR, ...
    'z shift', 3, ...
    'x shift', 2);  % meters

% The y-axis is up-down in this case. We will turn the camera toward the
% center of the MCC.  
thisR = piCameraRotate(thisR, 'y rot', -20);  % deg (CCW)

%% Write the recipe
piWrite(thisR);

%% Used for scene
scene = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%%