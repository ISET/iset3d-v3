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
ieInit;

% In some cases, you may need to run piDockerConfig

%% In this case, everything is inside the one file.  Very simple

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
exist(fname,'file')

% Read the file and return it in a recipe format
thisR = piRead(fname);
disp(thisR)
opticsType = 'pinhole';

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
[ieObject, outFile] = piRender(oname,'opticsType',opticsType);
vcAddObject(ieObject);
switch(opticsType)
    case 'pinhole'
        sceneWindow;
        sceneSet(ieObject,'gamma',0.5);     
    case 'lens'
        oiWindow;
        oiSet(ieObject,'gamma',0.5);
end

%% Now, adjust this recipe to render using a lens

thisR = piRead(fname);

newCamera = piCameraCreate('realistic');
opticsType = 'lens';
thisR.camera.aperture_diameter.value = 20;

% Some of the parameters for the light field camera fail to produce any images,
% while others produce kind of OK images, just not quite right.
% for one thing, when we have a light field camera, we aren't quite sure how to
% set the focalDistance.  That seems to be solved for other simple lenses.
%{
newCamera = piCameraCreate('light field');
newCamera.aperture_diameter.value = 60;
newCamera.num_pinholes_h.value = 64;
newCamera.num_pinholes_w.value = 64;
newCamera.microlens_enabled.value = 0;
%} 

% Update the camera
thisR.camera = newCamera;

% This could probably be a function since we change it so often. 
thisR.film.xresolution.value = 576;
thisR.film.yresolution.value = 576;
thisR.sampler.pixelsamples.value = 128;

% We need to move the camera to a distance that is far enough away so we can
% get a decent focus. When the object is too close, we can't focus.
diff = thisR.lookAt.from - thisR.lookAt.to;
diff = 10*diff;
thisR.lookAt.from = thisR.lookAt.to + diff;

% Good function needed to find the object distance
objDist = sqrt(sum(diff.^2));
[p,flname,~] = fileparts(thisR.camera.specfile.value);
focalLength = load(fullfile(p,[flname,'.FL.mat']));
focalDistance = interp1(focalLength.dist,focalLength.focalDistance,objDist);
% For an object at 125 mm, the 2ElLens has a focus at 89 mm.  We should be able
% to look this up from stored data about each lens type.
thisR.camera.filmdistance.value = focalDistance;

% You can open and view the file this way
% edit(oname);

%%

thisR.outputFile = piWrite(thisR,oname,'overwrite',true);
% We can also copy a directory over to the same folder as oname like this:
% thisR.outputFile = piWrite(thisR,oname,'copyDir',xxx,'overwrite',true);
[ieObject, outFile, result] = piRender(oname,'opticsType',opticsType);
vcAddObject(ieObject);
switch(opticsType)
    case 'pinhole'
        sceneWindow;
        sceneSet(ieObject,'gamma',0.5);     
    case 'lens'
        oiWindow;
        oiSet(ieObject,'gamma',0.5);
end

%%