%% Add fluorescent pattern on pbrt model
%
%   t_piFluorescentPattern
% 
% Description:
%   An example of how to generate fluorescent pattern on a selected region.
%   The core function is piFluorescentPattern(), where different pattern
%   generation algorithms will be implemented. Currently we have only one
%   algorithm called "half split". By using that algorithm, we expect to
%   split a certain region and assign fluorescent effect on half of the
%   region.
%   
% TODO:
%   Implement other algorithms so that we can generate more realistic
%   unhealthy patterns. A quick thought would be randomly select a triangle
%   mesh in the child geometry pbrt file, start from there to generate a
%   irregular shaped pattern.
%
%
% Author:
%   ZLY, BW, 2020
%
% See also:
%   piFluorescentPattern, piFluorescentDivision, piFluorescentHalfDivision



%% init
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe
%{
% We might want to store it on the Flywheel so we can download it using
% scitran.
filePath = fullfile(piRootPath, 'data', 'V3',...
                    'mouth', 'higher_res_mesh_segmentation.pbrt');
%}
filePath = '/Users/zhenglyu/Desktop/Research/3dmodel/mouth/final_c4d_resources/mesh_test/higher_res_mesh_segmentation.pbrt';
thisR = piRead(filePath);
thisR = piLightAdd(thisR,...
    'type','point',...
    'light spectrum','equalEnergy',...
    'spectrumscale', 1,...
    'cameracoordinate', true);

%% Set an output file

% All output needed to render this recipe will be written into this
% directory. 
sceneName = 'mouth_segmentation';
outFile = fullfile(piRootPath,'local',sceneName,'mouth_segmentation.pbrt');
thisR.set('outputfile',outFile);

%% Write 

% Write modified recipe out
piWrite(thisR);

%% Show the region/material options
piMaterialList(thisR);

%% Add fluorescent pattern 
unhealthyRegion = 'Unhealthy';
baseRegion = 'MouthPBR';
piFluorescentPattern(thisR, 'location', unhealthyRegion,...
                        'base', baseRegion);

%% After render the scene
%{
%% Used to visualize the result
wave = 395:10:705;  % Hard coded in pbrt
nWave = length(wave);
filename = '/Users/zhenglyu/Desktop/Research/git/pbrt_fluorescent/makefile/Release/pbrt.dat';
energy = piReadDAT(filename, 'maxPlanes', nWave);
photon = Energy2Quanta(wave,energy);
scene = piSceneCreate(photon, 'wavelength', wave);
sceneWindow(scene);
%}