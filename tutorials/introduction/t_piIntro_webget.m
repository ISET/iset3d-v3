%% Render some scenes available
%
% Description:
%    Show how to render a scene downloaded from
%    https://benedikt-bitterli.me/resources/.
%
%    The two scenes explored here are 'veach-ajar' and 'cornell-box'.
%
%    You need to download the corresponding folders from the website above
%    and put it into the local/scenes directory of your iset3d
%    installation. This folder is ignored by github, so it won't be synced
%    up with the repository.
%
%    The images are rendered left-right reversed from the images provided
%    with the scene description.
%
%    Have not managed to get textures correct in the 'veach-ajar' scene.
%
% Dependencies:
%    ISET3d, (ISETCam or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% Authors
%  TL, BW, ZL, ZLy SCIEN 2017
%
% See also
%   t_piIntro_*
%

% History:
%   11/03/20  dhb  Wrote it.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set scene
% 
% We know about
%    'cornell_box'
%    'veach-ajar'
%    'kitchen'
sceneName = 'kitchen';

%% Read scene.
%
% As noted in the header comments above, you need to download the scene
% first and put it into the right place.

FilePath = fullfile(piRootPath,'data','V3','web',sceneName);

if ~exist(FilePath,'dir')
  ieWebGet2('resourcename', sceneName, ...
      'resourcetype', 'pbrt',...
      'ask first',false);
end

%%  Initialize recipe

switch (sceneName)
    case {'veach-ajar','kitchen'}
        pbrtName = 'scene';
        exporter = 'Copy';
    case 'cornell_box'
        exporter = 'C4D';
        pbrtName = 'cornell_box';
    otherwise
        error('Unknown scene %s\n',sceneName);
end

fname = fullfile(FilePath,[pbrtName,'.pbrt']);
thisR = piRead(fname,'exporter',exporter);
% thisR.set('exporter',exporter);

%% Camera

% If no camera was included in the scene, add a pinhole by default.
if isempty(thisR.get('camera'))
    disp('Adding pinhole camera')
    theCamera = piCameraCreate('pinhole');
    thisR.set('camera',theCamera);
end

%% Set up scene specific parameters.

% The tricky part is to figure out where to put the camera so you can see
% the scene. I did this just by trying a lot of possibilities, and hoping
% that some point in the scene was near [0 0 0].
switch (sceneName)
    case 'cornell_box'
        % Resolution settings
        thisR.set('film resolution', [320, 320]);
        thisR.set('rays per pixel',128);
        thisR.set('n bounces',2);

        % Camera settings
        thisR.set('fov',45);
        thisR.set('to',[0 0 0]);
        thisR.set('from',[0 1.5 3]);
        thisR.set('up',[0 1 0]);
        
    case {'veach-ajar'}
        % Resolution settings
        thisR.set('film resolution', [320, 320]);
        thisR.set('rays per pixel',256);
        thisR.set('n bounces',5);

        % Camera settings
        thisR.set('fov',60);
        thisR.set('to',[-4.5 0 -3]);
        thisR.set('from',[10 3 -2]);
        thisR.set('up',[0 1 0]);
        thisR.set('object distance',6);
    case {'kitchen'}
        % Resolution settings
        thisR.set('film resolution', [320, 320]);
        thisR.set('rays per pixel',64);
        thisR.set('n bounces',3);
        
        % Camera settings
        thisR.set('fov',50);
        %{ 
            Original values
            from: [1.2110    1.8047    3.8524]
            to: [-0.7729   -1.7631   -2.9544]
            up: [-0.0183 0.9991 -0.0375]
        %}
        thisR.set('to',[-0.7729 0 -2.9544]);
        thisR.set('from',[1.2110    1.5    3.8524]);
        % thisR.set('object distance',6);
    otherwise
        error('Unknown scene specified');
end

%% Save the recipe information

% 1. Check for lights
% 2. Check for different directions
%
%  piCameraRotate(thisR,'x rot',45);
%  piCameraRotate(thisR,'y rot',25);
%  piCameraRotate(thisR,'y rot',-35);

piWrite(thisR);
[scene, result] = piRender(thisR,'render type','both');

% scene = piAIdenoise(scene);
sceneWindow(scene);
sceneSet(scene,'render flag','hdr');

%% Change the color of one of the materials in the kitchen scene
%{
thisR.get('materials','Walls','kd')

thisR.set('materials','Walls','kd',[1 0 0]);

thisR.set('materials','CupboardUnits','kd',[0.7 0.7 0.2])

%%  Messing around

thisR.set('light','delete','all');

ambientLight = piLightCreate('ambient',...
    'type','infinite',...
    'mapname','room.exr');
thisR.set('light','add',ambientLight);

%}
%{
  % Turn camera to the right and move towards the stove
  thisR = piCameraRotate(thisR,'y rot',25);
  saveFrom = [1.2110    1.5    3.8524];
  thisR.set('from',saveFrom + [0 0 -5]);
  
  thisR.set('film resolution', [320, 320]*2);
  thisR.set('rays per pixel',256);
  thisR.set('n bounces',5);
        
  piWrite(thisR);
  [scene, result] = piRender(thisR,'render type','both');

  scene = piAIdenoise(scene);
  sceneWindow(scene);
  sceneSet(scene,'render flag','hdr');
%}

%%


%% END
