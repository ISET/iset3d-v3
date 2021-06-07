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
%   04/02/21 amb  Adapted for general parser and assets/materials updates.

%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker.
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Get scene to render
whichScene = 'blobbie';
switch (whichScene)
    case 'simpleScene'
        % Initialize ISET and Docker
        %
        % We start up ISET and check that the user is configured for docker
        clear; close all; ieInit;
        if ~piDockerExists, piDockerConfig; end
        
        % Read the scene recipe file
        %
        % Need a scene that has a material library
        sceneName = 'SimpleScene';
        thisR = piRecipeDefault('scene name','SimpleScene');
        
        % Set render quality
        %
        % This is a low resolution for speed.
        thisR.set('film resolution',[200 150]);
        thisR.set('rays per pixel',32);
        thisR.set('fov',45);
        thisR.set('nbounces',1);
        
        % The output will be written here
        outFile = fullfile(piRootPath,'local',sceneName,'scene.pbrt');
        thisR.set('outputFile',outFile);
    case 'blobbie'
        % Read the Blender scene that was exported to PBRT
        fname = fullfile(piRootPath,'data','blender','BlenderSceneBlobs','BlenderSceneBlobs.pbrt');
        newName = piBlender2C4D(fname);
        thisR   = piRead(newName);

        % This scene was exported without a light, so add an infinite light.
        infiniteLight = piLightCreate('infiniteLight','type','infinite','spd','D65');
        thisR.set('light','add',infiniteLight);
        
        % This scene was exported without materials, so add a matte material
        % of a random color to each object in the scene.
        for ii = 1:length(thisR.assets.Node)
            if isfield(thisR.assets.Node{ii},'name')
                assetName = thisR.assets.Node{ii}.name;
                % Only act on the object's materials.
                if contains(assetName,'_O')
                    materialName = append(assetName,'_Material');
                    newMaterial = piMaterialCreate(materialName,'type','matte');
                    thisR.set('material','add',newMaterial);
                    thisR.set('material',materialName,'kd value',[rand rand rand]);
                    thisR.set('asset',ii,'material name',materialName);
                end
            end
        end
        
        % Decrease the resolution and rays/pixel to decrease rendering time.
        raysperpixel = thisR.get('rays per pixel');
        filmresolution = thisR.get('film resolution');
        thisR.set('rays per pixel', raysperpixel/2);
        thisR.set('film resolution',filmresolution/2);
    otherwise
        error('Unknown scene requested');
end

%% Save the recipe information
piWrite(thisR);

%% Render and display radiance image
theScene = piRender(thisR,'render type','radiance');
sceneWindow(theScene);
sceneSet(theScene,'gamma',0.7);

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
