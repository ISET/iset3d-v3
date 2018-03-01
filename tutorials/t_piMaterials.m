%% Test a pbrtv3 scene with material property modified.
%
%
%
% ZL SCIEN Team, 2018

%% Initialize ISET and Docker

% Check: Does the pbrt-v3-spectral docker container pull automatically?
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read pbrt_material files
FilePath = fullfile(piRootPath,'FromC4','SimpleScene');
fname = fullfile(FilePath,'SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

fname_materials = fullfile(FilePath,'SimpleScene_materials.pbrt');
if ~exist(fname_materials,'file'), error('File not found'); end
[thisR.materials,thisR.txtLines] = piMaterialRead(fname_materials,'version',3);
%% Call material lib

thisR.materiallib = piMateriallib;
%% list the property of materials 

piMaterialList(thisR);
%% Convert all jpg textures to png format,only *.png & *.exr are supported in pbrt.

piTextureFileFormat(FilePath);

%% Assign Materials and Color
% For detail: http://www.pbrt.org/fileformat-v3.html.
% Color chart: http://prideout.net/archive/colors.php

% We need a way to use strings to assign new materials to the target
% material.
target   = thisR.materiallib.chrome_spd;
rgbkd    = [0 1 0];
%rgbkr = [0.753 0.753 0.753];
material = 'pyramid'; 
piMaterialAssign(thisR,material,target,'rgbkr',rgbkr);

piMaterialList(thisR);

%% Write thisR to *_material.pbrt
thisR.set('outputFile_materials',fullfile(FilePath,'SimpleScene_materials.pbrt'));

piMaterialWrite(thisR);

%% Change the camera lens

% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% thisR.version can tell us, but piCameraCreate does not take a thisR as
% input. For now let's put things in manually. 

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'scripts','pbrtV3','360CameraSimulation','wide.56deg.6.0mm_v3.dat');thisR.camera.lensfile.value = lensFile;
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
% This quality takes around 30 seconds to render on a machine with 8 cores.

thisR.set('filmresolution',[800 600]);
thisR.set('pixelsamples',32);
thisR.integrator.maxdepth.value = 1;

%% Render

