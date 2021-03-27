%% Camera types
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Init a default recipe 

% This the MCC scene
thisR = piRecipeDefault('scene name','SimpleScene');

% By default, the camera type is a 'perspective', which means a pinhole
% camera.
thisR.get('camera')

% The pinhole (perspective) camera has some simple properties such as a
% field of view
thisR.get('fov')

% Remember that pinhole cameras has an infinite depth of field.  The
% distance from the pinhole to the film is called the focal distance
thisR.get('film diagonal','mm')

%% 
