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

thisR.film.xresolution.value = 128;
thisR.film.yresolution.value = 128;
thisR.sampler.pixelsamples.value = 256;

% Write out a file based on the recipe
% TODO: This kind of copying into a working folder needs to be done
% automatically in some sort of render function. 
oname = fullfile(piRootPath,'local','deleteMe.pbrt');
lensFile = fullfile(piRootPath,'data','lens','2ElLens.dat');
copyfile(lensFile,fullfile(piRootPath,'local'));

% This moved us further away.  GOod function to implement.
diff = thisR.lookAt.from - thisR.lookAt.to;
diff = 5*diff;
thisR.lookAt.from = thisR.lookAt.to + diff;

thisR.outputFile = piWrite(thisR,oname,'overwrite',true);

% You can open and view the file this way
% edit(oname);
%

%%
[scene, outFile, result] = piRender(oname);

vcAddObject(scene); sceneWindow;

%%