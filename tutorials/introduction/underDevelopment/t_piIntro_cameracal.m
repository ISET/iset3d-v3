%% This scripts demonstrates camera calibration using a checkerboard pattern
%
% Brief description:
%   This script shows how to use ISET3d to generate images of a
%   checkerboard pattern that are analyzed by Matlab's camera calibration.
%   toolbox. That toolbox derives camera intrinsic parameters and lens
%   distortion coefficients.
% 
% Dependencies:
%
%    Computer Vision Toolbox, ISET3d, (ISETCam or ISETBio), JSONio
%
% Check that you have the updated docker image by running
%
%   docker pull vistalab/pbrt-v3-spectral
%
% HB SCIEN 2019
%
% See also
%  t_piIntro_*
%

%% Problems (11/1/2020, DHB):
%  1) piCreateCheckerboard is broken.  This is because there is no
%  materials.outputFile_materials field, but the routine refers to i.
%  There is a materials.inputFile_materials.  I tried changing to that and
%  things got further, but it looks like this will continually add lines to
%  the checkerboard_materials.pbrt file and doesn't seem good as a real
%  fix.  I reverted.
%
%  2) This tries to set 'camera type' to 'realistic' but that is not
%  supported.  Changed to 'Camera' which is the only allowable variable and
%  that go further, but other problems prevented success and I reverted.
%
%  3) Writing the recipe dies at piTextureText, because what is passed to
%  it doesn't have some required fields.  This is beyond me to reverse
%  engineer in finite time, and at this point I gave up and added these
%  comments.

%% Initialize ISET and Docker

% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create a checkerboard 

% There is a default checkerboard
%
%    thisR = piRecipeDefault('scene name','checkerboard');
%
% But here we start with that and adjust the parameters of the checkerboard
% for calibration testing.
%
% The board must have even/odd numbers of blocks for the computer vision
% toolbox below.
% The physical size should be calculable from the oi data. Something like
% using the size of the image in deg and the distance to the object.
squareSize = 0.1; xsquares = 6; ysquares = 7;
thisR = piCreateCheckerboard('numX',xsquares,'numY',ysquares,'dimX',squareSize,'dimY',squareSize);

%% Define the camera

thisR.set('pixel samples',32);
thisR.set('film resolution',[1280 1024]/2);
thisR.set('camera type','realistic');
thisR.set('film diagonal', 6);
thisR.set('lensfile',fullfile(piRootPath,'data','lens','fisheye.87deg.6.0mm.dat'));
thisR.set('focus distance',4);

%% This piWrite writes the PBRT file and material file

piWrite(thisR);

%% Render target from different viewpoints

% This is where we will place the simulated images
imageFolder = fullfile(thisR.get('working directory'),'Images');
if ~exist(imageFolder,'dir'), mkdir(imageFolder); end

%  In real life, camera is held fixed, and the target is moved. In
%  simulation it is more conveneint to move the camera around. These are
%  equivalent.

% We generate size(from,1) images with the camera at these positions
from = [
    0.3 1 8;
    1 0.3 8;
    1 0 7;
    0 1 9];

% This is where we are pointing the camera.  Could have multiple points.
to = [0 0 0];

nImages = size(from,1)*size(to,1);
% Label the images
imageNames = cell(nImages,1);

%%  Render and then save the images

cntr = 1;
fprintf('**** Rendering %d images for camera calibration testing.\n',nImages);

for i=1:size(from,1)
    for j=1:size(to,1)
        thisR.set('from',from(i,:));
        thisR.set('to',to(j,:));

        % Render the optical image
        piWrite(thisR);
        [oi, result] = piRender(thisR);
        oi = oiSet(oi,'name',sprintf('img_%d',cntr));
        ieAddObject(oi);
        % oiWindow;

        % Save image as a png file. We could simulate the sensor and the
        % ISP, but we skip this step for now.
        imageNames{cntr} = fullfile(imageFolder,sprintf('img_%i.png',cntr));
        img = oiGet(oi,'rgb image');
        imwrite(img,imageNames{cntr});
        fprintf('**** Finished image %d.\n',cntr);

        cntr = cntr + 1;
    end
end

%% Use Matlab calibration toolbox to estimate camera parametrs

% Need to adjust the checkerboard parameters to run this bit of code.  Not
% done yet.  It was done by HB previously, but we need to update.
%
try
    [imagePoints,boardSize,imagesUsed] = detectCheckerboardPoints(imageNames);
    %{
     % Overlay the image with the detected points
     imageFileNames = imageNames(imagesUsed); 
     for i = 1:numel(imageFileNames) 
      I = imread(imageFileNames{i}); subplot(2, 2,i); 
      imshow(I); hold on;
      plot(imagePoints(:,1,i),imagePoints(:,2,i),'ro'); 
     end
    %}
    
    squareSizeInMMs = squareSize*1000;
    worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMMs);

    % Apparently the ISET3D and Computer Vision toolbox resolutions
    % dimensions differ.  So I had to flip to film resolution.
    params = estimateCameraParameters(imagePoints,worldPoints, ...
                                      'ImageSize',fliplr(thisR.get('film resolution')));

    % Convert focal length units from pixels to mm.
    fr = thisR.get('film resolution');
    pixelSize = thisR.get('film diagonal') / sqrt(sum(fr.^2));
    estFocalLength = params.FocalLength * pixelSize;

    fprintf('Focal length: estimated %f, mm\n',estFocalLength(1));
    
    sampleImage = imread(imageNames{1});
    undistortedImage = undistortImage(sampleImage,params,'OutputView','full');
    
    ieNewGraphWin([],'wide'); 
    subplot(1,2,1); imshow(sampleImage); title('Input');
    subplot(1,2,2); imshow(undistortedImage); title('Undistorted');
    
catch
    fprintf('Please install Computer Vision Toolbox\n');
end


%% END