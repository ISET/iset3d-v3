function [cameraParams, oi] = piCameraCalibrate(cameraBody, varargin)

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('cameraBody',@isstruct);
p.addOptional('from',[0 0 5; 0 0 6; 0 0 7]);
p.addOptional('to',[0 0 0; 1 1 0; -0.75 0.35 0]);
p.addOptional('pixelSamples',128);
p.parse(cameraBody,varargin{:});

inputs = p.Results;


% The output will be written here
sceneName = 'calChecker';
outFile = fullfile(piRootPath,'local',sceneName,'calChecker.pbrt');
recipe = piCreateCheckerboard(outFile,varargin{:});

%% Define the camera
recipe.set('pixel samples',inputs.pixelSamples);
recipe.set('camera body',inputs.cameraBody);

%% Render target from different viewpoints
%  In real life, camera is held fixed, and the target is moved. In
%  simulation it is more conveneint to move the camera around. These are
%  equivalent.
  
imageFolder = fullfile(recipe.get('working directory'),'Images');
if ~exist(imageFolder,'dir'), mkdir(imageFolder); end

imageNames = cell(size(inputs.from,1)*size(inputs.to,1),1);
ind = 1;
for i=1:size(inputs.from,1)
    for j=1:size(inputs.to,1)
        recipe.set('from',inputs.from(i,:));
        recipe.set('to',inputs.to(j,:));
        recipe.set('focus distance',inputs.from(i,3));
        
        % Render the optical image
        piWrite(recipe);
        oi(ind) = piRender(recipe);

        % Save image as a png file.
        % We should simulate the sensor and the ISP, but we skip this step 
        % for now.
        imageNames{ind} = fullfile(imageFolder,sprintf('img_%i.png',ind));
        imwrite(oiGet(oi(ind),'rgb image'),imageNames{ind});
        ind = ind + 1;
    end
end

%% Use Matlab calibration toolbox to estimate camera parametrs

try
    [imagePoints, boardSize] = detectCheckerboardPoints(imageNames);

    squareSizeInMMs = recipe.metadata.dimX*1000;
    worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMMs);

    cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                      'ImageSize',recipe.get('film resolution'),...
                                      'NumRadialDistortionCoefficients',2);

catch
    error('Please install Computer Vision Toolbox\n');
    cameraParams = [];
end



end

