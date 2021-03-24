%% Illustrate how to read a PBRT file and render
%
% Brief description
%
%   Read and render the ChessSet scene. 
% 
% Dependencies
%
%    ISET3d, ISETCam or ISETBio, JSONio
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% See also
%   thisR.list produces a list of the files on your system.


%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the white-room file for the Remote Data site

% This is the INPUT file name
% thisR = piRecipeDefault('scene name','cornellbox');
% thisR = piRecipeDefault('scene name','coloredCube');
thisR = piRecipeDefault('scene name','ChessSet');

%% Change render quality
thisR.set('film resolution',[192 192]);
thisR.set('rays per pixel',96);
thisR.set('n bounces',1); % Number of bounces

%% Render
tic
piWrite(thisR);
toc
%%  Create the scene
[scene, result] = piRender(thisR);

%%  Show it and the depth map
sceneWindow(scene);

%%
scenePlot(scene,'depth map');

%%