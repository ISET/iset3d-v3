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

% newCamera = cameraCreate('realistic diffraction');
clear newCamera
newCamera.type = 'Camera';
newCamera.subtype = 'realisticDiffraction';
newCamera.specfile.type = 'string';
newCamera.specfile.value = '2ElLens.dat';
newCamera.filmdistance.type = 'float';
newCamera.filmdistance.value = 50;    % mm
newCamera.aperture_diameter.type = 'float';
newCamera.aperture_diameter.value = 2; % mm
newCamera.filmdiag.type = 'float';
newCamera.filmdiag.value = 7;
newCamera.diffractionEnabled.type = 'bool';
newCamera.diffractionEnabled.value = 'false';
newCamera.chromaticFlag.type = 'bool';
newCamera.chromaticFlag.value = 'false';

% Update the camera
thisR.camera = newCamera;

% Lenses need more samples than pinholes
thisR.sampler.pixelsamples.value = 512;
thisR.film.xresolution.value = 128;
thisR.film.yresolution.value = 128;

% Write out a file based on the recipe
oname = fullfile(piRootPath,'local','deleteMe.pbrt');
lensFile = fullfile(piRootPath,'data','lens','2ElLens.dat');
copyfile(lensFile,fullfile(piRootPath,'local'));

% This moved us further away.  GOod function to implement.
diff = thisR.lookAt.from - thisR.lookAt.to;
diff = 5*diff;
thisR.lookAt.from = thisR.lookAt.to + diff;

piWrite(thisR,oname,'overwrite',true);

% You can open and view the file this way
% edit(oname);
%

%%
[scene, outFile] = piRender(oname);

vcAddObject(scene); sceneWindow;

%%