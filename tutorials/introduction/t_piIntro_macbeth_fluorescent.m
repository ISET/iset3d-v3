%% t_piIntro_macbeth_fluorescent
%
% Render a MacBeth color checker.  Then make an illuminant image to
% return a spatio-spectral illuminant.
% 
% Index numbers for MacBeth color checker:
%          ---- ---- ---- ---- ---- ----
%         | 01 | 05 | 09 | 13 | 17 | 21 |
%          ---- ---- ---- ---- ---- ----
%         | 02 | 06 | 10 | 14 | 18 | 22 | 
%          ---- ---- ---- ---- ---- ----
%         | 03 | 07 | 11 | 15 | 19 | 23 | 
%          ---- ---- ---- ---- ---- ----
%         | 04 | 08 | 12 | 16 | 20 | 24 | 
%          ---- ---- ---- ---- ---- ----
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio
%
% Author:
%   ZLY, BW, 2020

%% init
ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('fiToolboxRootPath'))
    disp('No fluorescence toolbox.  Skipping');
    return;
end

%% Read the recipe

thisR = piRecipeDefault('write',false);

%% Set rendering parameters

thisR.integrator.subtype = 'path';
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [640, 360]);

%% Write 

piWrite(thisR, 'overwritematerials', true);

%% Now add a blue light

% Change the light to 405 nm light source
thisR.set('light', 'delete', 'all');
newDistLight = piLightCreate('fluorescent light',...
                            'type', 'distant',...
                            'spd', 'blueLEDFlood',...
                            'specscale', 1,...
                            'cameracoordinate', true);
thisR.set('light', 'add', newDistLight);
%% Show the region/material options
piMaterialList(thisR);

%% Assign fluorescent materials on some patches
concentrationUniform = 0.5;
thisR.set('material', 'Patch19Material', 'concentration val', concentrationUniform);
thisR.set('material', 'Patch11Material', 'concentration val', concentrationUniform);
thisR.set('material', 'Patch06Material', 'concentration val', concentrationUniform);
thisR.set('material', 'Patch02Material', 'concentration val', concentrationUniform);
thisR.set('material', 'Patch18Material', 'concentration val', concentrationUniform);

wave = 365:5:705;

% Collagen
eemCollagen = piMaterialGenerateEEM('Collagen');
thisR.set('material', 'Patch11Material', 'fluorescence val', eemCollagen);
% Porphyrins
eemPorphyrins = piMaterialGenerateEEM('Porphyrins');
thisR.set('material', 'Patch06Material', 'fluorescence val', eemPorphyrins);
% NADH
eemNADH = piMaterialGenerateEEM('NADH');
thisR.set('material', 'Patch02Material', 'fluorescence val', eemNADH);
% FAD
eemFAD = piMaterialGenerateEEM('FAD');
thisR.set('material', 'Patch18Material', 'fluorescence val', eemFAD);
thisR.set('material', 'Patch19Material', 'fluorescence val', eemFAD);

%{
concentrationUniform = 0.5;
thisR.set('fluorophore eem', 'FAD', 'Patch19Material');
thisR.set('fluorophore eem', 'Collagen', 'Patch11Material');
thisR.set('fluorophore eem', 'Porphyrins', 'Patch06Material');
thisR.set('fluorophore eem', 'NADH', 'Patch02Material');
thisR.set('fluorophore eem', 'FAD', 'Patch18Material');

% Set the donaldson matrix based on the type of the materials
%{
thisR.set('eem', {'Patch19Material', 'FAD'});
thisR.set('eem', {'Patch11Material', 'Collagen'});
thisR.set('eem', {'Patch06Material', 'Porphyrins'});
thisR.set('eem', {'Patch02Material', 'NADH'});
thisR.set('eem', {'Patch18Material', 'FAD'});
%}
thisR.set('fluorophore concentration', 'FAD', 'Patch19Material');
thisR.set('fluorophore concentration', 'Collagen', 'Patch11Material');
thisR.set('fluorophore concentration', 'Porphyrins', 'Patch06Material');
thisR.set('fluorophore concentration', 'NADH', 'Patch02Material');
thisR.set('fluorophore concentration', 'FAD', 'Patch18Material');

% Give a concentration (scaling factor) to the fluophores
%{
thisR.set('concentration', {'Patch19Material', concentrationUniform});
thisR.set('concentration', {'Patch11Material', concentrationUniform});
thisR.set('concentration', {'Patch06Material', concentrationUniform});
thisR.set('concentration', {'Patch02Material', concentrationUniform});
thisR.set('concentration', {'Patch18Material', concentrationUniform});
%}
%}
%% Write 
% Write modified recipe out
piWrite(thisR, 'overwritematerials', true);

%% Render - At some point we will make this the default (latest)

% If you want to use the fluorescent modeling, specify this docker
% container.  We will promote to the default after we test it more.

thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, result] = piRender(thisR, 'docker image name', thisDocker,'wave',wave, 'render type', 'illuminant');
scene = sceneSet(scene,'wavelength', wave);
sceneWindow(scene);

%%