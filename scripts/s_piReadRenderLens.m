%% s_piReadRenderLens

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the pbrt scene file

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the file and return a recipe
thisR = piRead(fname);

%% Replace the pinhole camera with a lens-based camera

newCamera = piCameraCreate('realistic');
thisR.camera.aperture_diameter.value = 60;
opticsType = 'lens';

% Update the camera
thisR.camera = newCamera;

% This could probably be a function since we change it so often. 
thisR.film.xresolution.value = 576*2;
thisR.film.yresolution.value = 576*2;
thisR.sampler.pixelsamples.value = 256;

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
