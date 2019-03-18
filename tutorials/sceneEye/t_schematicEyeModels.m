%% t_schematicEyeModels
% Render the same scene using a couple of different eye models.
%
% Description:
%   Model the same scene with multiple eye models, including the following:
%   Navarro, Gullstrand, and Arizona.
%
% History:
%    XX/XX/XX  ???  Created
%    03/15/19  JNM  Documentation pass

%% Initialize
if isequal(piCamBio,'isetcam')
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename);
    return;
end
ieInit;
clear; close all;

%% Load up a scene

thisScene = sceneEye('numbersAtDepth');

% Set general parameters
thisScene.fov = 30;
thisScene.resolution = 128;
thisScene.numRays = 256;
thisScene.numCABands = 0;

%% Try the Navarro eye model
% This tell isetbio which model to use.
thisScene.modelName = 'Navarro';

% The Navarro model has accommodation, but let's set it to infinity for now
% since other models may not have accommodation modeling.
thisScene.accommodation = 0;

% Render!
thisScene.name = 'navarro'; % The name of the optical image
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
oiNavarro = thisScene.render(); %'reuse');

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
thisScene.modelName = 'Gullstrand';

% Render!
thisScene.name = 'gullstrand'; % The name of the optical image
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
oiGullstrand = thisScene.render(); %'reuse');

ieAddObject(oiGullstrand);
oiWindow;

%% Try Arizona eye model
thisScene.modelName = 'Arizona';
thisScene.accommodation = 0;

% Render!
thisScene.name = 'arizona'; % The name of the optical image
% to reuse an existing rendered file of the correct size, uncomment the
% parameter provided below.
oiArizona = thisScene.render(); %'reuse');

ieAddObject(oiArizona);
oiWindow;
