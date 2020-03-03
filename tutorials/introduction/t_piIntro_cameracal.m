%% This scripts demonstrates camera calibration using a checkerboard pattern
%
% Brief description:
%
% This script shows how to use ISET3d to generate images of a checkerboard
% pattern that is used for camera calibration. Specifically to
% derive camera intrinsic parameters and lens distortion coefficients.
% 
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio
%
%  Check that you have the updated docker image by running
%
%   docker pull vistalab/pbrt-v3-spectral
%
% HB SCIEN 2019
%
% See also
%

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create a checkerboard 
%  The board wll have 8 x 7 blocks and be 2.4 x 2.1 meter in size.
squareSize = 0.3;

% The output will be written here
sceneName = 'calChecker';
outFile = fullfile(piRootPath,'local',sceneName,'calChecker.pbrt');
recipe = piCreateCheckerboard(outFile,'numX',8,'numY',7,'dimX',squareSize,'dimY',squareSize);

%% Define the camera

recipe.set('pixel samples',32);
recipe.set('film resolution',[1280 1024]);
recipe.set('camera type','realistic');
recipe.set('film diagonal', 6);
recipe.set('lensfile',fullfile(piRootPath,'data','lens','fisheye.87deg.6.0mm.dat'));
recipe.set('focus distance',4);

%% Render target from different viewpoints
%  In real life, camera is held fixed, and the target is moved. In
%  simulation it is more conveneint to move the camera around. These are
%  equivalent.

from = [0 0 3];
    
to = [0 0 0];

  
imageFolder = fullfile(recipe.get('working directory'),'Images');
if ~exist(imageFolder,'dir'), mkdir(imageFolder); end

imageNames = cell(size(from,1)*size(to,1),1);
cntr = 1;
for i=1:size(from,1)
    for j=1:size(to,1)
        recipe.set('from',from(i,:));
        recipe.set('to',to(j,:));

        
        % Render the optical image
        piWrite(recipe);
        [oi, result] = piRender(recipe);

        % Save image as a png file.
        % We should simulate the sensor and the ISP, but we skip this step 
        % for now.
        oiWindow(oi);
        imageNames{cntr} = fullfile(imageFolder,sprintf('img_%i.png',cntr));
        imwrite(oiGet(oi,'rgb image'),imageNames{cntr});
        cntr = cntr + 1;
    end
end

%% Use Matlab calibration toolbox to estimate camera parametrs

try
    [imagePoints, boardSize] = detectCheckerboardPoints(imageNames);

    squareSizeInMMs = squareSize*1000;
    worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMMs);

    params = estimateCameraParameters(imagePoints,worldPoints, ...
                                      'ImageSize',recipe.get('film resolution'));

    % Convert focal length units from pixels to mm.
    fr = recipe.get('film resolution');
    pixelSize = recipe.get('film diagonal') / sqrt(sum(fr.^2));
    estFocalLength = params.FocalLength * pixelSize;

    fprintf('Focal length: estimated %f, mm\n',estFocalLength(1));
    
    sampleImage = imread(imageNames{1});
    undistortedImage = undistortImage(sampleImage,params,'OutputView','full');
    
    figure; 
    subplot(1,2,1); imshow(sampleImage); title('Input');
    subplot(1,2,2); imshow(undistortedImage); title('Undistroted');
    
catch
    fprintf('Please install Computer Vision Toolbox\n');
end

                              