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

fname = fullfile(piRootPath,'local','SimpleScene','SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3);

fname_materials = fullfile(piRootPath,'local','SimpleScene','SimpleScene_materials.pbrt');
if ~exist(fname_materials,'file'), error('File not found'); end
[thisR.materials,thisR.txtLines] = piMaterialRead(fname_materials,'version',3);
%% Call material lib

thisR.materiallib = piMateriallib;
%% list the property of materials 

piMaterialList(thisR);
%% Convert all jpg textures to png format,only *.png&*.exr are supported in pbrt.

work_dir = fullfile(piRootPath,'local','SimpleScene');
piTextureFileFormat(work_dir);

%% Assign Materials
% For detail: http://www.pbrt.org/fileformat-v3.html.
% Color chart: http://prideout.net/archive/colors.php

% We need a way to use strings to assign new materials to the target
% material.
target   = thisR.materiallib.mirror;
idx = 6;    
piMaterialAssign(thisR,idx,target);

piMaterialList(thisR);

%% Assign Color
%
% kd is the diffuse reflectance
rgbkd = [1 0 0]; % Red

% rgbkd = [0.943 0.710 0.113] %golden
% rgbkd= [0 1 0] % green
% rgbkd= [1 1 0] % yellow
% rgbkd= [0 0 1] % blue
% rgbkd= [0.753 0.753 0.753] % Silver

% kr is another type of reflectance, maybe specular?
% rgbkr= [1 0 0];% Red
% rgbkr= [0 1 0] % green
% rgbkr= [1 1 0] % yellow
% rgbkr= [0 0 1] % blue
rgbkr = [0.753 0.753 0.753]; % Silver
thisR.materials(idx).rgbkr = rgbkr;

%% Write thisR to *_material.pbrt
oiName = 'SimpleScene';
thisR.set('outputFile_materials',fullfile(work_dir,strcat(oiName,'_materials.pbrt')));

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

