% s_piReadRender
%
% The simplest script to read a PBRT scene file and then write it back
% out.  This 
%
% Path requirements
%    ISET
%    CISET      - If we need the autofocus, we could use this
%    pbrt2ISET  - 
%   
%    Consider RemoteDataToolbox, UnitTestToolbox for the lenses and
%    curated scenes.
%
% TL/BW SCIEN

%%
ieInit

%% In this case, everything is inside the one file.  Very simple

fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
exist(fname,'file')

% Read the file and return it in a recipe format
thisR = piRead(fname);
disp(thisR)

% Which is X?  Starting from centere -7    10     3, we are looking
% towards the origin (0,0,0).
% 
% First dimension moved us to the left and positive was to the right
% Second dimension moved towards and away (positive)
% Write out a file based on the recipe
oname = fullfile(piRootPath,'local','deleteMe.pbrt');
piWrite(thisR,oname,'overwrite',true);

% You can open and view the file this way
% edit(oname);
%
% We could use the single file piRender function to rennder from this
% output.
[scene, outFile] = piRender(oname);

vcAddObject(scene); sceneWindow;
%% Now, adjust this recipe to render using a lens

thisR = piRead(fname);

newCamera = piCameraCreate('realistic');
% newCamera = cameraCreate('lightfield');

% Update the camera
thisR.camera = newCamera;

% This could probably be a function since we change it so often. 
thisR.film.xresolution.value = 256;
thisR.film.yresolution.value = 256;
thisR.sampler.pixelsamples.value = 4096;

% Note: Part of the reason we cannot focus is because the scale of the
% teapot scene is not in physical units. The camera in the scene is 12.5
% units away from the teapot, meaning it is only 12.5 mm away! We move the
% camera further out to try to make the distance more reasonable.

% This moved us further away.  GOod function to implement.
diff = thisR.lookAt.from - thisR.lookAt.to;
diff = 10*diff;
thisR.lookAt.from = thisR.lookAt.to + diff;

% For an object at 125 mm, the 2ElLens has a focus at 89 mm.
thisR.camera.filmdistance.value = 89;

% You can open and view the file this way
% edit(oname);

%%

thisR.outputFile = piWrite(thisR,oname,'overwrite',true);
% We can also copy a directory over to the same folder as oname like this:
% thisR.outputFile = piWrite(thisR,oname,'copyDir',xxx,'overwrite',true);
[scene, outFile, result] = piRender(oname);
vcAddObject(scene); sceneWindow;

%%