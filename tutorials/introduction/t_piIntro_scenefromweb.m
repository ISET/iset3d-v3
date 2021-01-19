%% Render some scenes available at https://benedikt-bitterli.me/resources/
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
%    'cornell-box'
%    'veach-ajar'
sceneName = 'veach-ajar';

%% Read scene.
%
% As noted in the header comments above, you need to download the scene
% first and put it into the right place.
pbrtName = 'scene';
FilePath = fullfile(piRootPath,'local','scenes',sceneName);
fname = fullfile(FilePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file'), error('File not found'); end
exporter = 'C4D';
thisR = piRead(fname);
thisR.set('exporter',exporter);

%% Output directory
%
% By default, do the rendering into iset3d/local.  That
% directory is not part of the git upload area.
[~,n,e] = fileparts(fname);
outFile = fullfile(piRootPath,'local',sceneName,[n,e]);
thisR.set('outputfile',outFile);

%% Camera
% If no camera was included, add a pinhole by default.
if isempty(thisR.get('camera'))
    theCamera = piCameraCreate('pinhole');
end

% Add a light
% thisR = piLightDelete(thisR, 'all');
% thisR = piLightAdd(thisR,... 
%     'type','point',...
%     'light spectrum','Tungsten',...
%     'spectrumscale', 1000,...
%     'cameracoordinate', true);

%% Set up scene specific parameters.
%
% The tricky part is to figure out where to put the camera so you can see
% the scene. I did this just by trying a lot of possibilities, and hoping
% that some point in the scene was near [0 0 0].
switch (sceneName)
    case 'cornell-box'
        % Resolution settings
        thisR.set('pixelsamples', 32);
        thisR.set('filmresolution', [320, 320]);
        thisR.set('rays per pixel',128);
        thisR.set('n bounces',2);

        % Camera settings
        theCamera.fov.value = 45;
        thisR.set('to',[0 0 0]);
        thisR.set('from',[0 1.5 3]);
        thisR.set('up',[0 1 0]);
    case 'veach-ajar'
        % Resolution settings
        thisR.set('pixelsamples', 64);
        thisR.set('filmresolution', [320, 320]);
        thisR.set('rays per pixel',128);
        thisR.set('n bounces',2);

        % Camera settings
        theCamera.fov.value = 90;
        thisR.set('to',[-4.5 0 -3]);
        thisR.set('from',[10 3 -2]);
        thisR.set('up',[0 1 0]);
        thisR.set('object distance',6);
    otherwise
        error('Unknown scene specified');
end

%% Set the camera
thisR.set('camera',theCamera);

%% Save the recipe information
piWrite(thisR);

%% Render and display
[scene, result] = piRender(thisR,'render type','radiance');
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);

%% END
