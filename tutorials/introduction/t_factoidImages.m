%% Show how to extract various "factoids" about the scene
%
% Description:
%   This renders the teapot scene in the data directory of the
%   ISET3d repository. It then shows how to use iset3d to get various
%   "factoid" images about scene properties in the image plane.
%
%   By a factoid image, we mean an image that provides information about
%   some aspect of the underlying scene at each pixel in the radiance
%   image. The ability to extract factoids provides us with the ability to
%   label images, for example for applications in machine learning.
%
%   depth - Depth map of the scene at each pixel.
%     Q. IS THE DEPTH MAP DISTANCE ALONG CAMERAL LINE OF SIGHT?
%
%   illumination - Illumination at each pixel.  Obtained by rendering with
%     all materials set to white matte.
%     Q. WHY DOES THE ILLUMINATION IMAGE HAVE WHAT LOOKS LIKE A COLORED
%     SCENE IN THE BACKGROUND (OUTSIDE)?
%
%   material - Indicator variable for material at each pixel.
%     Q. THERE ARE ONLY TWO MATERIALS IN THIS MAP.  IS THAT BECAUSE THE
%     SAME MATERIAL TYPE GETS THE SAME INDICATOR, EVEN IF PARAMETERS ARE
%     DIFFERENT? IF SO, IS THERE A WAY TO GET AN INDICATOR VARIABLE WITH
%     THE LATTER?
%     Q. HOW DO I CONNECT THE INDICATOR WITH THE UNDERLYING DATA STRUCTURE?
%
%   mesh - Indicator variable for the mesh at each pixel.
%      Q. THIS LOOKS LIKE WHAT I EXPECTED FOR THE MATERIAL MAP.  WHAT IS A 
%      MESH?
%      Q. HOW DO I CONNECT THE INDICATOR WITH THE UNDERLYING DATA STRUCTURE?

%   image coordinates - 3d scene coordinates at each pixel.
%      Q. THESE ARE NOT AS I EXPECTED THEM TO LOOK.  FOR EXAMPLE, I
%      EXPECTED THE IMAGE OF THE X COORDINATE TO BE MORE OR LESS A LEFT TO
%      RIGHT GRADIENT IN THE IMAGE.  CAN SOMEONE UNPACK WHY THESE LOOK THE
%      WAY THEY DO?  -- ONE ANSWER, IT'S GOING TO DEPEND ON WHICH WAY THE
%      CAMERA IS LOOKING.  THE INTUITION IS ONLY GOOD IF Y IS UP and X IS
%      TO THE RIGHT FROM THE CAMERA'S POINT OF VIEW.
%
%   surface normals - 
%      Q. IS THERE A WAY TO GET SURFACE NORMALS?
% 
% Dependencies:
%    ISET3d, (ISETCam or ISETBio), JSONio
%
% See also
%   t_piIntro_*

%% History:
%   12/27/20 dhb  Started on this, although mostly just produced questions
%                 about things I don't understand.
%   12/29/20 dhb  Convert to work on blobbie image.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
clear; close all; ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set the input folder name
%
% This is currently set to a folder included in the iset3d repository
% but you can change it to your new folder (as described in heading above).
sceneName = 'BlenderSceneBlobs';

%% Set name of pbrt file exported from Blender
%
% This is currently set to a pbrt file included in the iset3d repository
% but you can change it to the pbrt file you exported from Blender.
pbrtName = 'BlenderSceneBlobs'; 

%% Set pbrt file path
%
% This is currently set to the file included in the iset3d repository
% but you can change it to the file path for your exported file.
filePath = fullfile(piRootPath,'local','scenes',sceneName);
fname = fullfile(filePath,[pbrtName,'.pbrt']);
if ~exist(fname,'file')
    error('File not found - see tutorial header for instructions'); 
end

%% Read scene
%
% piRead_Blender.m is an edited version of piRead.m
% that can read pbrt files exported from Blender.
exporter = 'Blender';
thisR = piRead_Blender(fname,'exporter',exporter);

%% Change render quality
%
% Decrease the resolution to decrease rendering time.
raysperpixel = thisR.get('rays per pixel');
filmresolution = thisR.get('film resolution');
thisR.set('rays per pixel', raysperpixel/2);
thisR.set('film resolution',filmresolution/2);

%% Save the recipe information
%
% piWrite_Blender.m is an edited version of piWrite.m
% that understands the exporter being set to 'Blender'.
piWrite_Blender(thisR);

%% Render and display radiance image
%
% piRender_Blender.m is an edited version of piRender.m
% that understands the exporter being set to 'Blender'.
theScene = piRender_Blender(thisR,'render type','radiance');
theScene = sceneSet(theScene,'name','Blender export');
sceneWindow(theScene);
sceneSet(theScene,'gamma',0.5);

%% Render depth map and show.
%
% When obtained this way, depthMap is an image that we add to the scene.
% give depth to each pixel.
[depthMap] = piRender(thisR,'renderType','depth');
theScene = sceneSet(theScene,'depth map',depthMap);
scenePlot(theScene,'depth map');

%% Render illumination image and show.
[sceneIllumination] = piRender(thisR,'renderType','illuminant only');
theScene = sceneSet(theScene,'illuminant photons',sceneIllumination);
scenePlot(theScene,'illuminant image');

%% Material.
%
% This is an image with a material indicator variable at each pixel.
% This only has two discrete values in it, which doesn't make sense to me.
[materialMap] = piRender(thisR,'renderType','material');
figure; imshow(materialMap/max(materialMap(:))); title('Material map')

%% Mesh
%
% This should have a label for the mesh at each pixel.  It looks like
% expect for the material map.  I don't think I know what a mesh is.
[meshMap] = piRender(thisR,'renderType','mesh');
figure; imshow(meshMap/max(meshMap(:))); title('Mesh map');
fprintf('The image is made up of %d different meshes\n',length(unique(meshMap(:))));
oneObjectMeshMap = zeros(size(meshMap));
[m,n] = size(meshMap);
theMeshIndex = meshMap(round(m/2),round(n/2));
oneObjectMeshMap(meshMap == theMeshIndex) = 1;
figure; imshow(oneObjectMeshMap); title('One Mesh');


%% Image coordinates
%
% I don't why these images look the way they do.
[coords] = piRender(thisR, 'render type','coordinates');
figure; imagesc(coords(:,:,1)); title('X coordinates');
figure; imagesc(coords(:,:,2)); title('Y coordinates');
figure; imagesc(coords(:,:,3)); title('Z coordinates');
