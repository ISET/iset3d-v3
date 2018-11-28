%% t_renderAllScenes.m
%
% Works with ISETBio (not ISETCam)
%
% This tutorial will run quick renders of all available scenes. It will
% also give examples on how to set certain parameters for certain scenes
% (e.g. the distance to a textured plane.)
%
% In order to save on computation time, we do not render any chromatic
% aberration in the lens.
%
% On an 8-core machine, this script takes around 2-3 minutes to run.
% (Excluding the time it takes to download new scenes from the remote data
% toolbox).
%
% Depends on: iset3d, isetbio, Docker, RemoteDataToolbox
%
% TL ISETBIO Team, 2017

%% Initialize

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Chess set
% A chess set "to scale" (e.g. the pieces match real word sizes). A ruler
% is placed in the middle of the chess set.

scene3d = sceneEye('chessSet');
               
scene3d.fov = 30; 
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1; 

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Chess set scaled
% The same chess set, but it's been distorted in order to emphasize depth
% of field effects.

scene3d = sceneEye('chessSetScaled');
               
scene3d.fov = 30; 
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/0.3; % Accommodate to the white pawn 

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Snellen Single
% A single letter E placed at a certain depth. The background is a black
% backdrop.

% The E is placed 1 meter away and has a height of 0.3 meters (I think).
scene3d = sceneEye('snellenSingle',...
                   'objectDistance',1,...
                   'objectSize',0.3);
scene3d.fov = 30;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/2.78;

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Snellen "at depth"
% A series of E's placed at fixed distances away (check depth map for
% distances.) A checkerboard is used for the ground and backdrop.

scene3d = sceneEye('snellenAtDepth');

scene3d.fov = 30;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/0.8;

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Black backdrop and blank scene
% Exactly what it says on the tin. A black wall, or an empty scene with
% nothing in it. Ideally used when adding objects in (see below).

% Load scene
scene3d = sceneEye('blankScene');
%scene3d = sceneEye('blackBackdrop');

scene3d.fov = 30;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/10;

% Add red and green sphere in the scene. They will have a radius of 0.3
% meter and a distance of 10 meters,and be separated by a meter.
scene3d.recipe = piAddSphere(scene3d.recipe,...
    'rgb',[1 0.05 0],...
    'radius',0.3,...
    'location',[0 0 10]);
scene3d.recipe = piAddSphere(scene3d.recipe,...
    'rgb',[0.05 1 0],...
    'radius',0.3,...
    'location',[1 0 10]);

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Numbers at depth
% Similar to snellen at depth, but with colored numbers instead. The number
% represents the distance away in millimeters.

scene3d = sceneEye('numbersAtDepth');

scene3d.fov = 30;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/(200e-3); % Accommodate to "200"

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Slanted bar
% A very large plane with a diagonal line through it. The bottom half of
% the plane is black while the top half is white. Primarily used to
% calculate the MTF of the system using ISO12233.

% The plane is placed at 3 meters
scene3d = sceneEye('slantedBar',...
                   'planeDistance',3);
scene3d.fov = 10;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/3; % Accommodate to the plane

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Slanted bar (texture ver.)
% Similar the previous scene, except the two planes now have checkerboard
% textures on them. In this version, you can place the top plane and bottom
% plane at different depths, creating an depth discontinuity.

scene3d = sceneEye('slantedBarTexture',...
                   'topDepth',0.5,...
                   'bottomDepth',2);
               
scene3d.fov = 5; % Keep FOV small to see the checkerboard more clearly
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/2; % Accommodate to the bottom plane

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Textured plane
% A blank plane that is placed perpendicular to the optical axis so that it
% is facing the eye. Any arbitrary texture such as PNG image can be placed
% on the plane.

% Let's attach a resolution chart image on the plane, place it 1 meter
% away, and make it 1x1 meters large.
textureFile = fullfile(piRootPath,...
    'data','imageTextures','squareResolutionChart.png');
scene3d = sceneEye('texturedPlane',...
                    'planeTexture',textureFile,...
                    'planeSize',[1 1],...
                    'planeDistance',2);

scene3d.fov = 30; 
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1; % Accommodate to the plane 

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

%% Point source
% The "point source" is actually just a sphere placed at a certain
% distance. To make it a point source, we would make it very small and
% place it very far away. Because of the way ray-tracing works, we need
% quite a lot of rays in order to capture the point spread function this
% way, so this is definitely not the most efficient way to analyze the
% performance of the system.

% 10 mm diameter point at a distance of 1 meter, so the "point" spans
% roughly half a degree. This is no where close to a point source, but
% makes it easier to test this scene without having to render with lots of
% rays.
scene3d = sceneEye('pointSource',...
                    'pointDiameter',0.01,...
                    'pointDistance',1);
                
scene3d.fov = 30; 
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1; % Accommodate to the point 

oi = scene3d.render();
ieAddObject(oi);
oiWindow;                

%% Letters at depth
% Similar to the "numbers at depth" and "snellen at depth" scenes. Three
% letters (A,B and C)placed in a checkerboard backdrop. Unlike the other
% two scenes though, the letters can be placed at any distance away from
% the camera.

% Let's put A at 1.8 dpt, B at 1.4 dpt, and C at 1.0 dpt (~0.5, 0.7 and 1
% meters)
scene3d = sceneEye('lettersAtDepth',...
                    'Adist',1/1.8,...
                    'Bdist',1/1.4,...
                    'Cdist',1);
                
scene3d.fov = 30; 
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1; % Accommodate to the point 

oi = scene3d.render();
ieAddObject(oi);
oiWindow;   

%% Colored Cube
% A cube with different colored sides. Another mdoel used primarily to test
% rotations. You can see how ISET3d handles rotations in
% "t_piSimpleTransforms.m." To do something like this with sceneEye, you
% could replace the "recipe" variable with "scene3d.recipe." 

scene3d = sceneEye('coloredCube');

scene3d.fov = 30;
scene3d.resolution = 128;
scene3d.numRays = 128;
scene3d.numCABands = 0;
scene3d.accommodation = 1/2.78;

oi = scene3d.render();
ieAddObject(oi);
oiWindow;

% You can rotate the cube like this:

% Rotate 10 degrees clockwise around cube's y-axis
% Loop through all assets and rotate the one called "Cube"
for ii = 1:length(scene3d.recipe.assets)
    if strcmp(scene3d.recipe.assets(ii).name,'Cube')
        % The rotation is stored in angle-axis format, along the columns.  
        scene3d.recipe.assets(ii).rotate(1,2) = ...
            scene3d.recipe.assets(ii).rotate(1,2) + 20;
    end
end

oi = scene3d.render();
ieAddObject(oi);
oiWindow;
                  