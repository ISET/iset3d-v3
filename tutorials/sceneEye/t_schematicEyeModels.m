%% t_schematicEyeModels
% Render the same scene using a couple of different eye models.

%% Initialize
if isequal(piCamBio,'isetcam')
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
clear; close all;

%% Load up a scene

% Three letters on a checkerboard background. A is at 1.4 dpt, B is at 1
% dpt, and C is at 0.6 dpt. 
thisScene = sceneEye('lettersAtDepth',...
                    'Adist',1/1.4,...
                    'Bdist',1/1,...
                    'Cdist',1/0.6,...
                    'Adeg',1.5,...
                    'Cdeg',1,...
                    'nchecks',[128 64]);

% Shrink the size of the letters so we can drop the FOV
for ii = 1:length(thisScene.recipe.assets)
    if (strcmp(thisScene.recipe.assets(ii).name,'A') || ...
       strcmp(thisScene.recipe.assets(ii).name,'B') || ...
       strcmp(thisScene.recipe.assets(ii).name,'C'))
        thisScene.recipe.assets(ii).scale = [0.5;0.5;0.5];
    end
end

% A small FOV is required to see the difference between the models.
thisScene.fov = 5; 

% Set general parameters
thisScene.resolution = 128;
thisScene.numRays = 256;
thisScene.numCABands = 8;

%% Try the Navarro eye model

% This tell isetbio which model to use.
thisScene.modelName = 'Navarro';

% The Navarro model has accommodation, but let's set it to infinity for now
% since other models may not have accommodation modeling.
thisScene.accommodation = 0;

% Render!
thisScene.name = 'navarro'; % The name of the optical image
oiNavarro = thisScene.render();

% Show the retinal image
% Everything is very out of focus since the accommodation is set to
% infinity. 
ieAddObject(oiNavarro);
oiWindow;

% You can see the lens file used and the dispersion curves of the material
% in the working directory. However, the lens file is not written out until
% time of rendering.
% thisScene.workingDir

%% Try the Gullstrand-LeGrand Model

% The gullstrand has no accommodation modeling. 
thisScene.modelName = 'LeGrand';
thisScene.name = 'LeGrand'; % The name of the optical image
oiLeGrand = thisScene.render();

ieAddObject(oiLeGrand);
oiWindow;

%% Try Arizona eye model

thisScene.modelName = 'Arizona';
thisScene.accommodation = 0;

% Render!
thisScene.name = 'arizona'; % The name of the optical image
oiArizona = thisScene.render();

ieAddObject(oiArizona);
oiWindow;
