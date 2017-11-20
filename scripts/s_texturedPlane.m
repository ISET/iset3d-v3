%% Demonstrate how to use the texturedPlane scene
% The textured plane scene consists of a single plane sized 1 m x 1 m.
% Initially, it is located at the origin (0,0,0) and rotated so it is
% perpendicular to the y-axis and parallel to the x-axis. The plane can be
% arbitrarily textured with an EXR image file. You will need to scale and
% translate the plane away from the camera in order to see anything. We
% have some handy functions in pbrt2ISET that can do this.
%
% Side note: The "no filtering" flag for the texture is automatically
% turned on, so there is no anti-aliasing filter applied during rendering
% when we sample the texture. This is very important, and was added by me
% (TL) in PBRTv2. However, given how important it is I think it would be
% worth double checking to make sure it's operating as we want it to.
%
% TL SCIEN 2017

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene
fname = fullfile(piRootPath,'data','texturedPlane','texturedPlane.pbrt');

% Read the main scene pbrt file.  Return it as a recipe
thisR = piRead(fname);

% Setup working folder
workingDir = fullfile(piRootPath,'local','texturedPlane');
if(~isdir(workingDir))
    mkdir(workingDir);
end

%% 
% Note: In ISETBIO, we do the scaling/translating/texture all in a single
% step when we load this scene. For example: 
%
% scene =
% sceneEye('texturedPlane','planeDistance',1000,'texture','resolution.exr');
%
% This is only possible because the sceneEye object can automatically take
% care of these setps for the user. It is more convenient for the user but
% has less flexibility. Maybe we should think about whether we want
% pbrt2ISET to be as easy to use as the sceneEye object in ISETBIO.

%% Scale and translate the plane
% For this example, let's move the plane 1 meter away and be 500 mm x 500
% mm.

scale = 0.5; % 1000*0.5 = 500 mm
translate = 1000; % mm

% The textured plane has specifically been named "Plane" in this scene. We
% also know that our camera is located at the origin and looking down the
% positive y-axis. 
% Note: The order of scaling and translating matters!
piMoveObject(thisR,'Plane','Scale',[scale scale scale]); % The plane is oriented in the x-z plane
piMoveObject(thisR,'Plane','Translate',[0 translate 0]); 

%% Attach a desired texture
% Let's add a resolution chart texture.

% Since the plane is square, the texture should also be square. Otherwise
% you should scale the plane appropriately in the above step. You can find
% some textures to use in pbrt2ISET --> data --> imageTextures.
%
% The texture also needs to be an EXR file. You can use OSX Preview app to
% convert image files. In the future, we will also add in our docker
% conversion tools into pbrt2ISET.
imageName = 'squareResolutionChart.exr';
imageFile = fullfile(piRootPath,'data','imageTextures',imageName);

% The original file has an dummy texture called "dummyTexture.exr." We use
% pbrt2ISET find and replace this texture with one of our own. Be sure to
% copy it to the right folder location!
% TODO: Should we have piWrite check for textures in the world block and
% copy them automatically? Then we would have the user put in an absolute
% path here instead of a relative one.
copyfile(imageFile,workingDir);
thisR = piWorldFindAndReplace(thisR,'dummyTexture.exr',imageName);

%% Write out a new pbrt file

% We copy the pbrt scene directory to the working directory
[p,n,e] = fileparts(fname); 
copyfile(p,workingDir);

% Now write out the edited pbrt scene file, based on thisR, to the working
% directory.
thisR.outputFile = fullfile(workingDir,[n,e]);

piWrite(thisR, 'workingDir', workingDir);

%% Render with the Docker container

scene = piRender(thisR);

% Show it in ISET
vcAddObject(scene); sceneWindow;   
