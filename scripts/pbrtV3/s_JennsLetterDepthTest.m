%% s_JennsLetterDepthTest
% Testing Letter Depth
%
% Description:
%    Render the letters A, B, and C at varying depths and degrees of
%    separation, mostly testing my understanding.
%
% History:
%    04/02/19  JNM  Created

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);
workingFolder = fullfile(piRootPath, 'local', 'LetTestEx');
recipe = piCreateLettersAtDepth('adist', .50, 'bdist', .75, 'cdist', 1);
% recipe = piCreateLettersAtDepth;

%% Change image resolution
recipe.set('filmresolution', [128 128]);
recipe.set('pixelsamples', 256);

%% Add a camera
recipe.set('camera', 'realistic');
recipe.set('lensfile', ...
    fullfile(piRootPath, 'data', 'lens', 'dgauss.22deg.50.0mm.dat'));
% filmdiagonal controls the 'zoom'
recipe.set('filmdiagonal', 50);

recipe.set('focus distance', 1);
recipe.set('aperture diameter', 5);

%% Write and render
recipe.set('outputFile', fullfile(workingFolder, 'letTest.pbrt'));

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
%axis image;
