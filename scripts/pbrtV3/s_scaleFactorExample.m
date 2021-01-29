%% Test the scale factor parameter in piRender.
%
% TL SCIEN 2017
% DJC Fixed to run with current pi interface 2021

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
%recipe = piRead(fullfile(piRootPath,'data','V3','teapot','teapot-area-light.pbrt'));
recipe = piRecipeDefault('scene name','teapot');

%% Add a camera
%recipe.set('camera','realistic');
recipe.camera = piCameraCreate('omni','lensFile','dgauss.22deg.3.0mm.json');
recipe.set('filmdiagonal',35); 

%% Change render quality
recipe.set('filmresolution',[128 128]);
recipe.set('pixelsamples',128);
recipe.set('maxdepth',1); % Number of bounces

%% Render
% We will render three images at different camera positions. We will keep
% the scale factor the same between all images.

originalFrom = recipeGet(recipe,'from');
cameraShift = [-1 0 0;
                0 0 0;
                1 0 0]; % in meters

scaleFactor = 1;
for ii = 1:size(cameraShift,1)
    
    oiName = sprintf('teapot%i',ii);
    recipe.set('outputFile',fullfile(piRootPath,'local','scaleFactorEx',strcat(oiName,'.pbrt')));
    
    recipeSet(recipe,'from',originalFrom + cameraShift(ii,:));
    
    piWrite(recipe);
    % [oi, result,scaleFactor] = piRender(recipe,'scaleFactor',scaleFactor);
    [oi, result] = piRender(recipe,'scaleFactor',scaleFactor);
    
    ieAddObject(oi);
    oiWindow;
    
    oi = oiSet(oi,'gamma',0.5);
end

%% Should probably put through a sensor with fixed exposure...
% TODO
