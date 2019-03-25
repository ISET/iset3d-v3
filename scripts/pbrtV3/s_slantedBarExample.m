%% s_slantedBarExample
% Render a slanted bar with the two sides at two different depths.
%
% Description:
%    Render a slanted bar with each side at adifferent depth.
%
% History:
%    XX/XX/17  TL   SCIEN 2017
%    03/19/19  JNM  Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

workingFolder = fullfile(piRootPath, 'local', 'slantedBarExample');

%% Create the slanted bar scene
% Depth is in meters.
recipe = piCreateSlantedBarScene('whiteDepth', 1, 'blackDepth', 2, ...
    'illumination', 'EqualEnergy.spd');

%% Change image resolution
recipe.set('filmresolution', [128 128]);
recipe.set('pixelsamples', 256);

%% Add a camera
recipe.set('camera', 'realistic');
recipe.set('lensfile', ...
    fullfile(piRootPath, 'data', 'lens', 'dgauss.22deg.50.0mm.dat'));
recipe.set('filmdiagonal', 10);

recipe.set('focus distance', 1);
recipe.set('aperture diameter', 5);

%% Write and render
oiName = 'slantedBarExample';
recipe.set('outputFile', fullfile(workingFolder, strcat(oiName, '.pbrt')));

piWrite(recipe);
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
[oi, results] = piRender(recipe); %, 'reuse', true);

vcAddAndSelectObject(oi);
oiWindow;

%% Check the depth map
% There is a slight mismatch between the given depth and the set depth.
% This is due to the distance between the back of the lens and the front of
% the camera. This discrepency has been removed in isetBio/sceneEye since
% it makes a big difference when doing analysis related with the eye.
depthMap = oiGet(oi, 'depthMap');
figure();
imagesc(depthMap);
colorbar;
axis off;
axis image;
