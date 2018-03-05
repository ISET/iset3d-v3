%% Test a pbrtv3 scene with material property modified.
%
% Creates an image with glass and a mirror and text and some objects.
% The materials are pulled in from Cinema 4D.  They can be edited for
% specularity and diffusivity and type.  More explanation of this will
% appear later.
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
FilePath = fullfile(piRootPath,'data','SimpleSceneV3');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Warnings may appear about filter and Renderer
thisR = piRead(fname,'version',3);

fname_materials = fullfile(FilePath,'SimpleScene_materials.pbrt');
if ~exist(fname_materials,'file'), error('File not found'); end
[thisR.materials,thisR.txtLines] = piMaterialRead(fname_materials,'version',3);

%% Call material lib

thisR.materiallib = piMateriallib;
%% list the property of materials 

piMaterialList(thisR);

%% Convert all jpg textures to png format,only *.png & *.exr are supported in pbrt.

piTextureFileFormat(thisR);

%% Assign Materials and Color
% For detail: http://www.pbrt.org/fileformat-v3.html.
% Color chart: http://prideout.net/archive/colors.php

% We use strings to assign new materials to the target material.
material = 'pyramid';   % A type of material.
target = thisR.materiallib.chrome_spd;  % Give it a chrome spd
rgbkd  = [0 1 0];            % Make it green diffuse reflection
rgbkr  = [0.753 0.753 0.753];% Specularish in the different channels

piMaterialAssign(thisR,material,target,'rgbkr',rgbkr);
piMaterialList(thisR);

%% Write thisR to *_material.pbrt

% Write out the pbrt scene file, based on thisR.  By def, to the working directory.
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','SimpleScene',[n,e]));
outputMaterials = fullfile(fileparts(thisR.get('outputFile')),'SimpleScene_materials.pbrt');
thisR.set('outputFile_materials',outputMaterials);

piWrite(thisR);

% This should be inside of piWrite, called when there is a .material
% slot
piMaterialWrite(thisR);

%% Change the camera lens

% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% thisR.version can tell us, but piCameraCreate does not take a thisR as
% input. For now let's put things in manually. 

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat');
thisR.camera.lensfile.value = lensFile;
% exist(lensFile,'file')

% Attach the lens
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 1; % mm
thisR.camera.aperturediameter.type = 'float';

% Focus at roughly meter away. 
thisR.camera.focusdistance.value = 1; % meter
thisR.camera.focusdistance.type = 'float';

% Use a 1" sensor size
thisR.film.diagonal.value = 16; 
thisR.film.diagonal.type = 'float';

%% Change render quality

% [800 600] 32 - takes around 30 seconds to render on a machine with 8 cores.
% [300 150] 16 -

thisR.set('filmresolution',[300 150]);
thisR.set('pixelsamples',16);
thisR.integrator.maxdepth.value = 1;

%% Render
tic
oi = piRender(thisR);
toc

ieAddObject(oi);
oiWindow;
