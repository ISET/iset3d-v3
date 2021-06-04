%% Test a pbrtv3 scene with material property modified.
%
% ************ Deprecated **************
%
% Creates an image with glass and a mirror and text and some objects.
% The materials are pulled in from Cinema 4D.  They can be edited for
% specularity and diffusivity and type.  More explanation of this will
% appear later.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
%{
FilePath = fullfile(piRootPath,'local','SimpleSceneExport');
fname = fullfile(FilePath,'new_SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname,'version',3);
%}
thisR = piRecipeDefault('scene name','SimpleScene');

%% Change render quality

% [800 600] 32 - takes around 30 seconds to render on a machine with 8 cores.
% [300 150] 16 -

thisR.set('filmresolution',[800 600]);
thisR.set('pixelsamples',16);
thisR.set('n bounces',5);

%% Assign Materials and Color

% it's helpful to check what current material properties are.
thisR.get('material print');

% Assign a new material
materialBody = thisR.get('material','BODY'); 
% materialTarget = thisR.get('material','carpaintmix')

%{
material = thisR.materials.list.BODY;   % A type of material.
target = thisR.materials.lib.carpaintmix;      % Give it a chrome spd
%}
rgbkd  = [1 0 0];                        % Make it green diffuse reflection
rgbkr  = [0.753 0.753 0.753];            % Specularish in the different channels
thisR.set('material','BODY','kd',rgbkd); % Diffuse reflectance
thisR.set('material','BODY','kr',rgbkr); % Mirror reflectance

% it's helpful to check what current material properties are.
thisR.get('material print');

%% Write thisR to *_material.pbrt

piWrite(thisR);
scene = piRender(thisR);
sceneWindow(scene);

%% Label the pixels by mesh of origin and material

meshImage = piRender(thisR,'renderType','mesh'); % This just returns a 2D image
ieNewGraphWin; 
imagesc(meshImage);colormap(jet);title('Mesh')

materialImage = piRender(thisR,'renderType','material'); % This just returns a 2D image
ieNewGraphWin; 
imagesc(materialImage); colormap(jet); title('Material')

%%