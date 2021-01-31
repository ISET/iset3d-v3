% t_renderC4DScene.m
%
% Needs fixing
%
% A tutorial script that goes with the the wiki page on converting from C4D
% to PBRT/ISET3d.
%
% The wiki page can be found here:
% https://github.com/ISET/iset3d/wiki/Exporting-from-C4D
% 
% It goes through the steps of creating and exporting a scene from C4D.
% This ISET3d tutorial demonstrates how to read in the created scene, make
% final adjustments, and render.
%
%% Initialize
ieInit; clear; close all;

%% Read scene

% Must be a full file path to the test scene exported from C4D. We assume
% you are using the scene given on the wiki page, with the red cube, blue
% torus, and gray backdrop.
% You can find the tutorial and the included scene here:
% https://github.com/ISET/iset3d/wiki/Exporting-from-C4D
pbrtFile = fullfile(pwd,'testScene.pbrt');

% Check that the file exists
if(~exist(pbrtFile,'file'))
    error('PBRT file not found. Are you following the tutorial on the wiki page?')
end

% Read the PBRT file
thisRecipe = piRead(pbrtFile);

%% Add a light source
% The PBRT exporter automatically includes a distant light, even if there
% are no lights defined in the C4D scene. We will remove the distant light
% and use an infinite light instead. An infinite light is "an infinitely
% far away light source that casts illumination from all directions." It is
% often easy to debug with, since it has no directionality and doesn't cast
% many shadows. 
%
% Note: Some of these light adjustment functions need to be updated and
% cleaned up. We will put that on our todo list. 

% You can see the light sources currently in the scene with the following
% command:
% piLightGet(thisRecipe)

% There is only one (a distant light) so we will delete it here. 
% The "1" indicates the index of the light from piLightGet. 
thisRecipe = piLightDelete(thisRecipe, 1);

% Infinite light is easy to add and easy to test with.
thisRecipe = piLightAdd(thisRecipe,...
    'type','infinite',...
    'light spectrum','D65');

%% Set the camera

% Perspective camera is equivalent to a thin lens.
thisRecipe.set('cameratype','perspective');

% Set camera parameters
thisRecipe.set('fov',30); % in degrees

% We will make it large so we see lots of depth of field blur.
thisRecipe.set('lensradius',20e-3); % in mm

% Have the camera focus at 1 meter (the red cube)
thisRecipe.set('focaldistance',1); % in m

% You can see all the camera parameters here:
thisRecipe.camera

%% Set render quality

% Image size
thisRecipe.set('filmresolution',[256 256]);

% Reduces rendering noise but increases computation time
thisRecipe.set('pixelsamples',256); 

% For some scenes, this will increase the lighting realism but will also
% increase computation time. Since this is a simple scene, let's just use 1
% bounce for now. 
thisRecipe.set('max depth',1); % Number of bounces


%% Set an output file

% All output needed to render this recipe will be written into this
% directory. 
sceneName = 'testScene';
outFile = fullfile(piRootPath,'local',sceneName,'scene.pbrt');
thisRecipe.set('outputfile',outFile);

%% Write 

% Write modified recipe out
piWrite(thisRecipe);

%% Render and display

scene = piRender(thisRecipe);

% Name this render and display it
scene = sceneSet(scene,'name','focus_red_cube');
sceneWindow(scene);

% You can look at the depth map as well
% Units are in meters. We can see that the objects are at the distance
% where we put them in the C4D scene.
% scenePlot(scene,'depth map');

%% Change the focus

% Have the camera focus at 1.5 meter (the blue torus)
thisRecipe.set('focaldistance',1.5); % in m

%% Write (again)

% Write modified recipe out
piWrite(thisRecipe);

%% Render and display (again)

scene = piRender(thisRecipe);

% Name this render and display it
scene = sceneSet(scene,'name','focus_blue_torus');
sceneWindow(scene);

