% Render scenes of differet types
%
% Description:
%    Use PBRT to render radiance image, depth matte,
%    radiance image with all surfaces matte, and %
%    reflectance map.
%
%    The recipe is store in local/scences/ColorfulScene.
%    The rendered data end up in the same directory.
%
%    Wavelength sampling is [400 10 31], set by precompiled
%    renders.
%
% There are some scenes available via RDT.  Run
%     piPBRTList
% to get a list.  Run
%     piPBRTFetch('ColorfulScene','pbrt version',3,'destination folder',fullfile(piRootPath,'local','scenes'));
% to get the one we use here.

%% Initialize
ieInit;
if ~piDockerExists, piDockerConfig; end

% This is if you want to use the Google cloud
%if ~mcGcloudExists, mcGcloudConfig; end

%% Specify and get scene recipe
sceneName = 'ColorfulScene';
InputFile = fullfile(piRootPath, 'local', 'scenes', sceneName, [sceneName, '.pbrt']);
thisR = piRead(InputFile);

%% Set rendering quality parameters
%
% These are for PBRT
thisR.set('film resolution',[1200 900]/2);
thisR.set('pixel samples',16);
thisR.set('max depth',5); 

%% Render radiance and depth
%
% The basic render gets the radiance and depth maps
piWrite(thisR);
ieObject = piRender(thisR,'render type','both');
sceneWindow(ieObject);

%% Process recipe to make all the materials to be matte
matteR = thisR;
materialNameList = fieldnames(thisR.materials.list);
for ii = 1:length(materialNameList)
    target = matteR.materials.lib.matte;
    piMaterialAssign(matteR, materialNameList{ii}, target);
end
piWrite(matteR);
ieObject = piRender(matteR,'render type','radiance');
sceneWindow(ieObject);

%% Render reflectance map return an NxNx31 data.
reflectanceMap = piRender(matteR, 'render type', 'reflectance');
figure; imagesc(reflectanceMap(:,:,1));