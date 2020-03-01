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

thisR = piLightAdd(thisR,... 
    'type','spot',...
    'light spectrum','equalEnergy',...
    'spectrum scale', 1,...
    'from', thisR.lookAt.from,...
    'to', thisR.lookAt.to);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%% Translate the camera away by 5 meters

thisR = piCameraTranslate(thisR, ...
    'z shift', -5);  % meters

%% Write the recipe
piWrite(thisR);

%% Used for scene
[scene, result] = piRender(thisR, 'render type', 'all');
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
[scene, result] = piRender(thisR, 'render type', 'all');
sceneWindow(scene);

%%